output "app_cidr_block" {
  value = "${aws_subnet.hussinapp.cidr_block}"
}
output "app_sg" {
  value = "${aws_security_group.hussinapp.id}"
}
output "app_subnet_id" {
  value = "${aws_subnet.hussinapp.id}"
}
