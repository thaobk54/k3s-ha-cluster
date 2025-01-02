# Stage 1: Build stage with AWS CLI and OpenJDK 11
FROM ubuntu:24.04 AS builder

# Install AWS CLI
RUN apt update && apt install -y curl unzip jq openjdk-17-jre-headless \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# Download the Amazon Trust Services root CA certificates
RUN curl -o /etc/ssl/certs/AmazonRootCA1.pem https://www.amazontrust.com/repository/AmazonRootCA1.pem
RUN curl -o /etc/ssl/certs/AmazonRootCA2.pem https://www.amazontrust.com/repository/AmazonRootCA2.pem
RUN curl -o /etc/ssl/certs/AmazonRootCA3.pem https://www.amazontrust.com/repository/AmazonRootCA3.pem
RUN curl -o /etc/ssl/certs/AmazonRootCA4.pem https://www.amazontrust.com/repository/AmazonRootCA4.pem
RUN curl -o /etc/ssl/certs/SFSRootCAG2.pem https://www.amazontrust.com/repository/SFSRootCAG2.pem

# Combine the certificates into a single CA bundle
RUN cat /etc/ssl/certs/AmazonRootCA1.pem \
/etc/ssl/certs/AmazonRootCA2.pem \
/etc/ssl/certs/AmazonRootCA3.pem \
/etc/ssl/certs/AmazonRootCA4.pem \
/etc/ssl/certs/SFSRootCAG2.pem > /etc/ssl/certs/ca-bundle.crt

WORKDIR /app
COPY ./SalesResourceAllocation-4.1.4a.jar /app/SalesResourceAllocation-4.1.4a.jar
COPY ./entrypoint.sh /app/entrypoint.sh
# Make sure the script is executable
RUN chmod +x /app/entrypoint.sh

# Run the entrypoint script when the container starts
ENTRYPOINT ["/app/entrypoint.sh"]