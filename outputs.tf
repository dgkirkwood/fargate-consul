output "consul_gui" {
  value = "http://${aws_instance.consul-server.public_ip}:8500"
}

output "test_server_address" {
  value = aws_instance.test-server.public_ip
}