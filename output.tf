output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "k3s_master_instance_key" {
  value = module.k3s-ha[0].k3s_master_instance_key
  sensitive = true
}

# output "k3s_token" {
#   value = module.k3s-ha[0].k3s_token
#   sensitive = true
#   depends_on = [ module.k3s-ha ]
# }