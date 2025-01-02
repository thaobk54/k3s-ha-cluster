# data "aws_ssm_parameter" "k3s_database_endpoint" {
#   name = var.k3s_database_endpoint
# }

# data "aws_ssm_parameter" "k3s_database_user" {
#   name = var.k3s_database_user
# }

# data "aws_ssm_parameter" "k3s_database_password" {
#   name = var.k3s_database_password
# }

# data "aws_ssm_parameter" "k3s_database_name" {
#   name = var.k3s_database_name
# }

resource "random_password" "k3s_token" {
  length           = 32                 # Length of the token
  special          = false              # Exclude special characters
  upper            = true               # Include uppercase letters
  lower            = true               # Include lowercase letters
  min_upper        = 1                  # At least one uppercase character
  min_lower        = 1                  # At least one lowercase character
  min_numeric      = 1                  # At least one numeric character
}

# k3s template init
data "template_file" "k3s_master_startup_script" {
  template = file("${path.module}/templates/install-k3s-server.sh.tftpl")
  vars = {
    k3s_version  = var.k3s_version
    k3s_cluster_cidr = var.k3s_cluster_cidr
    k3s_service_cidr = var.k3s_service_cidr
    k3s_cluster_dns  = var.k3s_cluster_dns
    k3s_token        = random_password.k3s_token.result

    alt_names    = "${aws_lb.k3s_server_lb.dns_name}"
    node_labels  = "--node-label host=aws --node-label role=master"
    mode         = "server"
    netbird_key  = var.netbird_key
    k3s_database_user      = var.k3s_database_user
    k3s_database_password  = var.k3s_database_password
    k3s_database_name      = var.k3s_database_name
    k3s_database_endpoint      = var.k3s_database_endpoint
    # k3s_database_user      = data.aws_ssm_parameter.k3s_database_user.value
    # k3s_database_password  = data.aws_ssm_parameter.k3s_database_password.value
    # k3s_database_name      = data.aws_ssm_parameter.k3s_database_name.value
    # k3s_database_endpoint      = data.aws_ssm_parameter.k3s_database_endpoint.value
    s3_bucket_kubeconfig = var.s3_bucket_kubeconfig
  }
}

data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["099720109477"] // Canonical's AWS account ID
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20241113"] // Pattern for Ubuntu 22.04 LTS
  }
}
