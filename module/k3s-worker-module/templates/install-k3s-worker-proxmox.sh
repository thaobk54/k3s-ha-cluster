#!/bin/bash


# Generate a UUID
UUID=$(uuidgen)
HOST=$(hostname)
# Create a short version (first 8 characters) using cut
SHORT_UUID=$(echo $UUID | cut -d'-' -f1)

# Create a hostname using the short UUID
HOSTNAME="$HOST-$SHORT_UUID"

# Create a tag using the short UUID
TAG="k3s-worker:proxmox"


# Check if jq is installed, and install it if not
if ! command -v jq &> /dev/null; then
    log "jq is not installed. Installing jq..."
    sudo apt-get update && sudo apt-get install -y jq uuid awscli
    if [ $? -ne 0 ]; then
        log "Failed to install jq and uuid"
        exit 1
    fi
fi

install_netbird() {
    curl -fsSL https://pkgs.netbird.io/install.sh | sh
    netbird up --setup-key 2B9B2976-444E-440B-8BA1-B6E3820AA305

    OVERLAY_IP=$(ip -4 addr show dev wt0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
}

install_k3s() {
    log "Installing k3s..."
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.28.4+k3s1" sh -s - agent \
    --token "K1028c3fecaabdc1f094447f0e9040177e9a70494579ea96d2d67bf43aed27174c9::server:qZtAnurkLHX2KsgEAHTyvCr0azpLS4hL" \
    --node-label host=proxmox --node-label role=worker \
    --server "https://k3s-master-lb-f634149ebe211a04.elb.us-east-1.amazonaws.com:6443" \
    --log $HOME/.k3s-install-log.txt \
    --node-ip=$OVERLAY_IP \
    --node-name=$HOSTNAME \
    --flannel-iface=wt0
}

# install_datadog() {
#     DD_API_KEY=bc62b74e937697d3c971a080717b0749 \
#     DD_SITE="ap1.datadoghq.com" \
#     bash -c "$(curl -L https://install.datadoghq.com/scripts/install_script_agent7.sh)"
#     sudo -u dd-agent -- datadog-agent integration install -t datadog-ping==1.0.2
#     sudo apt-get install iputils-ping
#     sudo tee /etc/datadog-agent/conf.d/ping.d/config.yaml > /dev/null <<EOF
# init_config:
# instances:
#     - host: 100.120.0.246
#       collect_response_time: true
#       timeout: 4.0
#       tags:
#         - k3s-master-1:true
#     - host: 100.120.0.247
#       collect_response_time: true
#       timeout: 4.0
#       tags:
#         - k3s-master-2:true
#     - host: 100.120.0.248
#       collect_response_time: true
#       timeout: 4.0
#       tags:
#         - k3s-master-3:true            
# EOF

#     sudo systemctl restart datadog-agent
# }

install_netbird
install_k3s
# install_datadog