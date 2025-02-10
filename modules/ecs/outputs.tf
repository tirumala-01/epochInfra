output "subnet_d_id" {
  value = aws_subnet.subnet_d.id
}

output "subnet_e_id" {
  value = aws_subnet.subnet_e.id
}

output "subnet_f_id" {
  value = aws_subnet.subnet_f.id
}

output "load_balancer_security_group_id" {
  value = aws_security_group.load_balancer_security_group.id
}

output "service_security_group_id" {
  value = aws_security_group.service_security_group.id

}