# Security groups applied to my EC2 instances
resource "aws_security_group" "frontend_allow_group" {
  name_prefix = "${var.cluster_name}_frontend_sg"
  description = "Security group for app frontend access"
  vpc_id      = module.vpc.vpc_id
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = var.cluster_name
  }
}

resource "aws_security_group_rule" "allow_web" {
  type      = "ingress"
  from_port = 5000
  to_port   = 5000
  protocol  = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.frontend_allow_group.id
}

resource "aws_security_group_rule" "allow_egress_frontend" {
  security_group_id = aws_security_group.frontend_allow_group.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = [
  "0.0.0.0/0"]
}
