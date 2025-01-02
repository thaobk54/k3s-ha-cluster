data "aws_ssm_parameter" "k3s_token" {
  name = var.k3s_token
}
data "aws_ssm_parameter" "k3s_server_lb_dns_name" {
  name = var.k3s_server_lb_dns_name
}

data "template_file" "k3s_worker_startup_script" {
  template = file("${path.module}/templates/install-k3s-worker-proxmox.sh.tftpl")
  vars = {
    k3s_version  = var.k3s_version
    k3s_token        = data.aws_ssm_parameter.k3s_token.value
    k3s_server_lb_dns_name = data.aws_ssm_parameter.k3s_server_lb_dns_name.value
    node_labels  = "--node-label host=proxmox --node-label role=worker"
    host_defined = local.prefix_worker
    netbird_key = var.netbird_key
  }
}

resource "local_file" "k3s_worker_startup_script" {
  content  = data.template_file.k3s_worker_startup_script.rendered
  filename = "${path.module}/templates/install-k3s-worker-proxmox.sh"
}