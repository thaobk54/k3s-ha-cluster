locals {
  prefix_worker = "k3s-worker"
  worker_node_settings = var.worker_node_settings
}
resource "tls_private_key" "k3s_worker_instance_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "macaddress" "k3s-workers" {
}

resource "proxmox_vm_qemu" "k3s-workers" {

  target_node = var.proxmox_node
  name        = "k3s-worker-proxmox"
  clone = var.node_template
  full_clone = true
  scsihw = "virtio-scsi-pci"

  # Cloud-init
  os_type = "cloud-init"
  ipconfig0 = "ip=dhcp"
  ciuser = "ubuntu"
  ciupgrade = true
  sshkeys = tls_private_key.k3s_worker_instance_key.public_key_openssh
  # Boot
  boot     = "c"
  # Possible values are: network,disk,cpu,memory,usb
  hotplug  = "network,disk,usb"
  # Default boot disk
  bootdisk = "scsi0"
  # cores = 2
  cores   = local.worker_node_settings.cores
  sockets = local.worker_node_settings.sockets
  memory  = local.worker_node_settings.memory

  agent = 1

  disks {
    scsi {
        scsi0 {
            disk {
                # slot    = local.worker_node_settings.slots
                # type    = local.worker_node_settings.storage_type
                storage = local.worker_node_settings.storage_id
                size    = local.worker_node_settings.disk_size
                discard = "true"
            }
        }

    }
    ide {
        ide2 {
            cloudinit {
                storage = local.worker_node_settings.storage_id
            }
        }
    }

  }

  network {
    bridge    = local.worker_node_settings.network_bridge
    firewall  = false
    link_down = false
    macaddr   = upper(macaddress.k3s-workers.address)
    model     = "virtio"
    queues    = 0
    rate      = 0
    tag       = local.worker_node_settings.network_tag
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      host        = self.default_ipv4_address
      user        = "ubuntu"
      private_key = tls_private_key.k3s_worker_instance_key.private_key_pem
      timeout     = "5m"
    }

    source      = local_file.k3s_worker_startup_script.filename
    destination = "/home/ubuntu/install-k3s-worker-proxmox.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.default_ipv4_address
      user        = "ubuntu"
      private_key = tls_private_key.k3s_worker_instance_key.private_key_pem
    }

    inline = [
      # Create the cron job
      "echo '*/2 * * * * root sh /home/ubuntu/install-k3s-worker-proxmox.sh && rm -f /etc/cron.d/install-k3s-worker-proxmox' | sudo tee /etc/cron.d/install-k3s-worker-proxmox > /dev/null",
      
      "sudo cat /etc/cron.d/install-k3s-worker-proxmox",
      # Ensure the cron job file has correct permissions
      "sudo chmod 644 /etc/cron.d/install-k3s-worker-proxmox",

      # Reload cron service to apply changes
      "sudo systemctl restart cron || sudo systemctl reload cron",

      # Optional: Output confirmation
      "echo 'Cron job created and scheduled successfully.'"
    ]
  }

  depends_on = [
    tls_private_key.k3s_worker_instance_key
  ]
}