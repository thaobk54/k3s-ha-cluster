#!/bin/bash
# Fail on any error
set -e
set -x
echo "Fetching message from SQS"
# Set the path to the AWS CA bundle
export AWS_CA_BUNDLE=/etc/ssl/certs/ca-bundle.crt

export AWS_PAGER=""

POD_NAME=$POD_NAME
export CONFIGMAP_NAME="${POD_NAME%-*}"

if kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE &> /dev/null; then
  echo "ConfigMap $CONFIGMAP_NAME already exists."
  # Get message from configmap
  kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE -o jsonpath='{.data.message\.json}' > message.json
else
  echo "Creating ConfigMap $CONFIGMAP_NAME."
  # Receive message from SQS with long polling
  aws sqs receive-message \
    --queue-url https://sqs.us-east-1.amazonaws.com/879381274960/ValueAD \
    --attribute-names All \
    --message-attribute-names All \
    --max-number-of-messages 1 \
    --region us-east-1 \
    --wait-time-seconds 20 > message.json
  # Create configmap for message    
  kubectl create configmap $CONFIGMAP_NAME --from-file=message.json -n $NAMESPACE
fi

cat message.json

# Extract prefix file name from SQS message
# Example: split_1.csv -> split_1
PREFIX_FILE=$(jq -r '.Messages[0].Body | fromjson | .Records[0].s3.object.key' message.json | awk -F '/' '{print $2}' | awk -F '.' '{print $1}')

# Extract receipt handle from SQS message
RECEIPT_HANDLE=$(jq -r '.Messages[0].ReceiptHandle' message.json)

# Check if PREFIX_FILE or RECEIPT_HANDLE is empty
if [[ -z "$PREFIX_FILE" ]]; then
  echo "PREFIX_FILE is empty."
  set +x
  echo "Job is stopping..."
  echo "Skipping empty SQS message CAPTURED_STATUS=SKIPPED"
  set -x
  exit 1
fi

if [[ -z "$RECEIPT_HANDLE" ]]; then
  echo "RECEIPT_HANDLE is empty."
  set +x
  echo "Job is stopping..."
  echo "Skipping empty SQS message CAPTURED_STATUS=SKIPPED"
  set -x
  exit 1
fi

# Delete message from SQS
aws sqs delete-message \
  --queue-url https://sqs.us-east-1.amazonaws.com/879381274960/ValueAD \
  --receipt-handle $RECEIPT_HANDLE \
  --region ap-southeast-2

# Download configuration and split files from S3
# Download configuration file
aws s3api get-object \
  --bucket k3s-ha-cluster-assembly \
  --key sla-configs/${PREFIX_FILE}.config \
  ${PREFIX_FILE}.config

cp ${PREFIX_FILE}.config /tmp/${PREFIX_FILE}.config

# Download split files
aws s3api get-object \
  --bucket k3s-ha-cluster-assembly \
  --key split-files/${PREFIX_FILE}.csv \
  ${PREFIX_FILE}.csv

cp ${PREFIX_FILE}.csv /tmp/${PREFIX_FILE}.csv

# Get client name from SLA_CONFIG
CLIENT=$(grep @output ${PREFIX_FILE}.config | cut -d ' ' -f 3 | awk -F"/" '{print $1}')
mkdir $CLIENT


# Create bucket (folder) if it doesn't exist
if aws s3api head-object --bucket k3s-ha-cluster-assembly --key "$CLIENT/" 2>/dev/null; then
  echo "Folder $CLIENT already exists."
else
  aws s3api put-object --bucket k3s-ha-cluster-assembly --key "$CLIENT/"
  echo "Folder $CLIENT created successfully."
fi

# Sync back S3 to local
aws s3 sync s3://k3s-ha-cluster-assembly/$CLIENT $CLIENT 

# Run Java application with SLA_CONFIG and SPLIT_FILE

# Start a background sync process to upload chunks as they are created every 5 minutes
echo "Starting background sync process..."
(
  while true; do
    echo "Running aws s3 sync at $(date)"
    aws s3 sync $CLIENT s3://k3s-ha-cluster-assembly/$CLIENT
    if [ $? -ne 0 ]; then
      echo "Error during aws s3 sync at $(date)" >&2
    fi
    echo "Completed sync at $(date)"
    sleep 900
  done
) &

set +x
echo "Job is running..."
echo "CAPTURED_CLIENT_NAME: $CLIENT CAPTURED_PREFIX_FILE: $PREFIX_FILE CAPTURED_STATUS=RUNNING"
kubectl patch configmap $CONFIGMAP_NAME -n $NAMESPACE -p '{"data": {"CAPTURED_STATUS": "RUNNING"}}'
set -x
java -Xmx${MAX_MEMORY} -Xms${MAX_MEMORY} -XX:MetaspaceSize=${METASPACE_SIZE} -XX:MaxMetaspaceSize=${METASPACE_SIZE} \
  -XX:CompressedClassSpaceSize=${COMPRESSED_CLASS_SPACE_SIZE} -XX:+TieredCompilation -XX:+SegmentedCodeCache -XX:NonNMethodCodeHeapSize=${NON_METHOD_CODE_HEAP_SIZE} \
  -XX:ProfiledCodeHeapSize=${PROFILED_CODE_HEAP_SIZE} -XX:NonProfiledCodeHeapSize=${NON_PROFILED_CODE_HEAP_SIZE} \
  -XX:ReservedCodeCacheSize=${RESERVED_CODE_CACHE_SIZE} \
  -jar /app/SalesResourceAllocation-4.1.4a.jar ${PREFIX_FILE}.config ${PREFIX_FILE}.csv

# Kill the background sync process after Java application finishes
kill $!

# Upload configuration file to folder S3. If the application fails, upload to config-failed folder and vice versa
if [ $? -eq 0 ]; then
    TIME_STAMP=$(date +"%Y%m%d%H%M%S")
    aws s3 cp /tmp/${PREFIX_FILE}.config s3://k3s-ha-cluster-assembly/config-successful/${PREFIX_FILE}.config
    # Upload output files to S3
    # aws s3 cp $CLIENT s3://k3s-ha-cluster-assembly/$CLIENT --recursive
    aws s3 sync $CLIENT s3://k3s-ha-cluster-assembly/$CLIENT
    # Put split file to S3
    aws s3 cp /tmp/${PREFIX_FILE}.csv s3://k3s-ha-cluster-assembly/split-successful/${PREFIX_FILE}.csv
    set +x
    echo "CAPTURED_CLIENT_NAME: $CLIENT CAPTURED_PREFIX_FILE: $PREFIX_FILE CAPTURED_STATUS=SUCCESS"
    kubectl patch configmap $CONFIGMAP_NAME -n $NAMESPACE -p '{"data": {"CAPTURED_STATUS": "SUCCESS"}}'
    set -x
else
    TIME_STAMP=$(date +"%Y%m%d%H%M%S")
    aws s3 cp /tmp/${PREFIX_FILE}.config s3://k3s-ha-cluster-assembly/config-failure/${PREFIX_FILE}.config
    # Put split file to S3
    aws s3 cp /tmp/${PREFIX_FILE}.csv s3://k3s-ha-cluster-assembly/split-failure/${PREFIX_FILE}.csv
    set +x
    echo "CAPTURED_CLIENT_NAME: $CLIENT CAPTURED_PREFIX_FILE: $PREFIX_FILE CAPTURED_STATUS=FAILED"
    kubectl patch configmap $CONFIGMAP_NAME -n $NAMESPACE -p '{"data": {"CAPTURED_STATUS": "FAILED"}}'
    set -x    
fi

# Remove split files from S3
aws s3 rm s3://k3s-ha-cluster-assembly/split-files/${PREFIX_FILE}.csv

# Remove configmap contain message
kubectl delete configmap $CONFIGMAP_NAME -n $NAMESPACE

set +x
echo "Job is stopping..."
echo "CAPTURED_CLIENT_NAME: $CLIENT CAPTURED_PREFIX_FILE: $PREFIX_FILE CAPTURED_STATUS=STOPPED"
set -x
