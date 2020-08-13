#Security groups applied to the Consul server
resource "aws_security_group" "consul" {
  name_prefix = "${var.cluster_name}_consul"
  description = "Security group for Consul server"
  vpc_id      = module.vpc.vpc_id
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = var.cluster_name
  }
}


resource "aws_security_group_rule" "allow_server_rpc_inbound" {
  type        = "ingress"
  from_port   = 8300
  to_port     = 8300
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "allow_cli_rpc_inbound" {
  type        = "ingress"
  from_port   = 8400
  to_port     = 8400
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "allow_serf_lan_tcp_inbound" {
  type        = "ingress"
  from_port   = 8301
  to_port     = 8301
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "allow_serf_lan_udp_inbound" {
  type        = "ingress"
  from_port   = 8301
  to_port     = 8301
  protocol    = "udp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "allow_http_api_inbound" {
  type        = "ingress"
  from_port   = 8500
  to_port     = 8500
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "allow_dns_tcp_inbound" {
  type        = "ingress"
  from_port   = 8600
  to_port     = 8600
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "allow_dns_udp_inbound" {
  type        = "ingress"
  from_port   = 8600
  to_port     = 8600
  protocol    = "udp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "allow_grpc_inbound" {
  type        = "ingress"
  from_port   = 8502
  to_port     = 8502
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "allow_serf_WAN_inbound" {
  type        = "ingress"
  from_port   = 8302
  to_port     = 8302
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "allow_serf_WAN_UDP_inbound" {
  type        = "ingress"
  from_port   = 8302
  to_port     = 8302
  protocol    = "udp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "envoy_ports" {
  from_port         = 21000
  protocol          = "tcp"
  security_group_id = aws_security_group.consul.id
  to_port           = 21255
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  type = "ingress"
}

resource "aws_security_group_rule" "allow_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.consul.id
}
resource "aws_security_group_rule" "allow_http_in" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.consul.id
  to_port           = 80
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  type = "ingress"
}

resource "aws_security_group_rule" "allow_https_in" {
  protocol  = "tcp"
  from_port = 443
  to_port   = 443
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.consul.id
  type              = "ingress"
}

resource "aws_security_group_rule" "allow_ingress" {
  from_port         = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.consul.id
  to_port           = 8080
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  type = "ingress"
}

resource "aws_security_group_rule" "allow_egress_all" {
  security_group_id = aws_security_group.consul.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = [
  "0.0.0.0/0"]
}