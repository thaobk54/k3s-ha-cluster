resource "aws_security_group" "allow_k3s_master" {
  name        = "k3s-master"
  description = "ingress rules for k3s master"
  vpc_id      = var.vpc_id

  tags = local.tags
}

# SSH access
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  for_each = length(var.k3s_master_authorized_cidr_blocks) > 0 ? toset(var.k3s_master_authorized_cidr_blocks) : toset([])

  security_group_id = aws_security_group.allow_k3s_master.id
  cidr_ipv4         = each.value  # Be cautious with this - consider restricting to specific IP ranges
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  depends_on = [ aws_security_group.allow_k3s_master ]
}

# Additional inbound rules for specific applications

# TCP 6443 (K3s supervisor and Kubernetes API Server)
resource "aws_vpc_security_group_ingress_rule" "allow_k3s_api" {
  security_group_id = aws_security_group.allow_k3s_master.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 6443
  ip_protocol       = "tcp"
  to_port           = 6443

  depends_on = [ aws_security_group.allow_k3s_master ]
}

# TCP 6444 (K3s supervisor and Kubernetes API Server)
resource "aws_vpc_security_group_ingress_rule" "allow_k3s_api_6444" {
  security_group_id = aws_security_group.allow_k3s_master.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 6444
  ip_protocol       = "tcp"
  to_port           = 6444

  depends_on = [ aws_security_group.allow_k3s_master ]
}

# UDP 8472 (Flannel VXLAN)
resource "aws_vpc_security_group_ingress_rule" "allow_flannel_vxlan" {
  security_group_id = aws_security_group.allow_k3s_master.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8472
  ip_protocol       = "udp"
  to_port           = 8472

  depends_on = [ aws_security_group.allow_k3s_master ]
}

# TCP 10250 (Kubelet metrics)
resource "aws_vpc_security_group_ingress_rule" "allow_kubelet_metrics" {
  security_group_id = aws_security_group.allow_k3s_master.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 10250
  ip_protocol       = "tcp"
  to_port           = 10250

  depends_on = [ aws_security_group.allow_k3s_master ]
}

# UDP 51820 (Flannel Wireguard with IPv4)
resource "aws_vpc_security_group_ingress_rule" "allow_flannel_wireguard_ipv4" {
  security_group_id = aws_security_group.allow_k3s_master.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 51820
  ip_protocol       = "udp"
  to_port           = 51820

  depends_on = [ aws_security_group.allow_k3s_master ]
}

# UDP 51821 (Flannel Wireguard with IPv6)
resource "aws_vpc_security_group_ingress_rule" "allow_flannel_wireguard_ipv6" {
  security_group_id = aws_security_group.allow_k3s_master.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 51821
  ip_protocol       = "udp"
  to_port           = 51821

  depends_on = [ aws_security_group.allow_k3s_master ]
}

# All outbound traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_k3s_master.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  depends_on = [ aws_security_group.allow_k3s_master ]
}
