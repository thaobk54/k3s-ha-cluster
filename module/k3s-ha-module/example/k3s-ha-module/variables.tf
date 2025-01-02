# K3S parameters
variable "k3s_version" {
  type = string
}
variable "k3s_cluster_cidr" {
  type = string
}
variable "k3s_service_cidr" {
  type = string
}
variable "k3s_cluster_dns" {
  type = string
}
variable "k3s_token" {
  type = string
}
variable "nebula_token" {
  type = string
}
variable "nebula_network_id" {
  type = string
}

# Database parameters
variable "k3s_database_endpoint" {
  type = string
}
variable "k3s_database_user" {
  type = string
}
variable "k3s_database_password" {
  type = string
}
variable "k3s_database_name" {
  type = string
}

# VPC parameters
variable "vpc_id" {
  type = string
}
variable "lb_k3s_master_public_subnet_id" {
  type = string
}
variable "k3s_master_private_subnet_id" {
  type = string
}

variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(any)
  default     = {}
}

variable "k3s_master_authorized_cidr_blocks" {
  type = list(string)
}


variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "region" {
  type = string
}

variable "s3_bucket_kubeconfig" {
  type = string
}