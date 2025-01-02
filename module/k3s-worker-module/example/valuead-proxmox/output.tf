output "k3s_worker_instance_key" {
  value = module.k3s-worker.k3s_worker_instance_key
  sensitive = true    

  # depends_on = [ module.k3s-worker ]
}