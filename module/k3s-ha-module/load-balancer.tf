# Existing Load Balancer
resource "aws_lb" "k3s_server_lb" {
  name               = "k3s-master-lb"
  load_balancer_type = "network"
  internal           = "false"
  subnets            = [var.lb_k3s_master_public_subnet_id]
  enable_http2       = false
  enable_cross_zone_load_balancing = true
  enable_xff_client_port = true
  tags = local.tags
}

# Listener for Port 6443 (Existing)
resource "aws_lb_listener" "k3s_server_lb_listener_kubeapi" {
  load_balancer_arn = aws_lb.k3s_server_lb.arn

  protocol = "TCP"
  port     = 6443

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k3s_server_tg.arn
  }

  tags = local.tags
}

# Target Group for Port 6443 (Existing)
resource "aws_lb_target_group" "k3s_server_tg" {
  port     = 6443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  depends_on = [
    aws_lb.k3s_server_lb
  ]

  health_check {
    protocol = "TCP"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

# Target Group Attachments for Port 6443 (Existing)
resource "aws_lb_target_group_attachment" "k3s_server_tg_attachment" {
  for_each = module.k3s_master_instance
  target_group_arn = aws_lb_target_group.k3s_server_tg.arn
  target_id        = each.value.id
  port             = 6443

  depends_on = [
    aws_lb_target_group.k3s_server_tg
  ]
}
