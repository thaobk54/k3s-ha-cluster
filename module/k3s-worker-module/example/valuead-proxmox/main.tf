module "k3s-worker" {
    source = "../../"

    # Worker Settings
    worker_node_settings = var.worker_node_settings
    # Proxmox Settings
    proxmox_node = var.proxmox_node
    node_template = var.node_template

    # K3s Settings
    k3s_server_lb_dns_name = var.k3s_server_lb_dns_name
    k3s_token = var.k3s_token
    
    netbird_key = var.netbird_key
}

