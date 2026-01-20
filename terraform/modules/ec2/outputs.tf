output "public_ec2_ip" {
  value = aws_instance.public.public_ip
}

output "private_ec2_ip" {
  value = aws_instance.private.private_ip
}
