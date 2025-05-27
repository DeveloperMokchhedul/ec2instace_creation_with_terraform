output "aws_instance_public_id" {
    value = aws_instance.server1.public_ip
  
}
output "aws_instance_private_ip" {
    value = aws_instance.server1.private_ip
  
}