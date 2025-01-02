
output "k3s_worker_instance_key" {
  description = "The private key for the K3s Worker instance"
  value       = tls_private_key.k3s_worker_instance_key.private_key_pem
  sensitive = true
}
