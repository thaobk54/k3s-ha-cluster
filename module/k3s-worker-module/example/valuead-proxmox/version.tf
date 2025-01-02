terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc4"
    }
    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.0"
    }
  }
}

provider "proxmox" {
  pm_api_url   = "https://192.168.1.105:8006/api2/json"
  pm_user      = "Thao@pve"
  pm_password  = "7hG!2B$r5Lq@9Wz"
  pm_tls_insecure = true
}