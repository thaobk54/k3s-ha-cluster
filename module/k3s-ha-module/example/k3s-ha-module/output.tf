output "lb_dns_name" {
  value = module.k3s-ha-module.lb_dns_name
}

output "k3s_master_instance_key" {
  description = "The private key for the K3s Master instance"
  value       = module.k3s-ha-module.k3s_master_instance_key
  sensitive = true
}
