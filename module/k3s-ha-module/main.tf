locals {
  prefix_master = "k3s-master"
  tags = merge(var.tags, {
    ProvisionBy = "Terraform"
  })
}

resource "tls_private_key" "k3s_master_instance_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "k3s_master_instance_key" {
  key_name   = "k3s-master-key"
  public_key = tls_private_key.k3s_master_instance_key.public_key_openssh
}


module "k3s_master_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"
  for_each = toset(["primary","secondary","tertiary"])
  name    = "${local.prefix_master}-${each.key}"

  iam_instance_profile   = aws_iam_instance_profile.valuead_instance_profile.name
  ami                    = data.aws_ami.ubuntu_ami.id
  instance_type          = var.k3s_master_instance_type
  key_name               = aws_key_pair.k3s_master_instance_key.key_name
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.allow_k3s_master.id]
  subnet_id              = var.k3s_master_private_subnet_id

  user_data                   = data.template_file.k3s_master_startup_script.rendered
  user_data_replace_on_change = true

  disable_api_stop        = false
  disable_api_termination = false

  root_block_device = [
    {
      volume_size = var.k3s_master_instance_volume_size
      volume_type = "gp3"
      throughput  = 200
    },
  ]

  depends_on = [ 
    aws_key_pair.k3s_master_instance_key,
    aws_lb.k3s_server_lb
  ]

  tags = local.tags


}