# vpc
vpc_cidr = "10.0.0.0/16"
vpc_available_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
vpc_public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

# K3s master
k3s_database_endpoint = "54.163.21.40:3306"
k3s_database_user = "k3s"
k3s_database_password = "Testing39!"
k3s_database_name = "k3s_db"
netbird_key_k3s_master = "422F281C-10CF-48E8-9CF6-87B99DFC54D1"
s3_bucket_kubeconfig = "k3s-ha-cluster-assembly"
k3s_master_instance_type = "t2.medium"
k3s_master_instance_volume_size = "20"