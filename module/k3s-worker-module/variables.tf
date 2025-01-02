variable "proxmox_node" {
  description = "Proxmox node to create the worker nodes on"
  type        = string
}

variable "node_template" {
  description = "Proxmox node template to use for the worker nodes"
  type        = string
}

variable "worker_node_settings" {
  description = "Settings for the worker nodes"
  type        = any
  default     = {
    cores          = 2
    sockets        = 1
    memory         = 4096
    storage_type   = "disk"
    storage_id     = "px6-300d"
    disk_size      = "73932M"
    user           = "k3s"
    network_bridge = "vmbr0"
    network_tag    = -1
  }
}

variable "k3s_token" {
  description = "K3s token"
  type        = string
}


variable "k3s_server_lb_dns_name" {
  description = "K3s server load balancer DNS name"
  type        = string
}

variable "k3s_version" {
  description = "K3s version"
  type        = string
  default     = "v1.28.4+k3s1"
}


variable "netbird_key" {
  
}