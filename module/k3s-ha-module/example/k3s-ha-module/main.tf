module "k3s-ha-module" {
  source = "../../"
  # Database
  k3s_database_endpoint = var.k3s_database_endpoint
  k3s_database_user = var.k3s_database_user
  k3s_database_password = var.k3s_database_password
  k3s_database_name = var.k3s_database_name
  # K3s
  k3s_version = var.k3s_version
  k3s_cluster_cidr = var.k3s_cluster_cidr
  k3s_service_cidr = var.k3s_service_cidr
  k3s_cluster_dns = var.k3s_cluster_dns
  k3s_token = var.k3s_token
  
  # Nebula
  nebula_token = var.nebula_token
  nebula_network_id = var.nebula_network_id

  # VPC
  vpc_id = var.vpc_id
  k3s_master_private_subnet_id = var.k3s_master_private_subnet_id
  lb_k3s_master_public_subnet_id = var.lb_k3s_master_public_subnet_id
  k3s_master_authorized_cidr_blocks = var.k3s_master_authorized_cidr_blocks

  # S3 cred to push kubeconfig
  aws_access_key_id = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  region = var.region
  s3_bucket_kubeconfig = var.s3_bucket_kubeconfig  
}
