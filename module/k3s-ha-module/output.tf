output "lb_dns_name" {
  value = aws_lb.k3s_server_lb.dns_name
}

output "k3s_master_instance_key" {
  description = "The private key for the K3s Master instance"
  value       = tls_private_key.k3s_master_instance_key.private_key_pem
  sensitive = true
}

output "k3s_token" {
  description = "The token for the K3s Master instance"
  value       = random_password.k3s_token.result
  sensitive = true
}
