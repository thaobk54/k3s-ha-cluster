module "k3s-ha" {
    count  = true ? 1 : 0
    source = "./module/k3s-ha-module"
    # Database
    k3s_database_endpoint = var.k3s_database_endpoint
    k3s_database_user = var.k3s_database_user
    k3s_database_password = var.k3s_database_password
    k3s_database_name = var.k3s_database_name

    # K3s
    k3s_version = "v1.28.4+k3s1"
    k3s_cluster_cidr = "10.1.0.0/16"
    k3s_service_cidr = "10.2.0.0/16"
    k3s_cluster_dns = "10.2.0.10"
    k3s_master_instance_volume_size = var.k3s_master_instance_volume_size
    k3s_master_instance_type = var.k3s_master_instance_type

    # Nebula
    netbird_key = var.netbird_key_k3s_master

    # VPC
    vpc_id = module.vpc.vpc_id
    k3s_master_private_subnet_id = module.vpc.private_subnets[0]  # Select the first private subnet, change as needed
    lb_k3s_master_public_subnet_id = module.vpc.public_subnets[0]
    k3s_master_authorized_cidr_blocks = ["0.0.0.0/0"]

    # S3 cred to push kubeconfig
    s3_bucket_kubeconfig = var.s3_bucket_kubeconfig

}
