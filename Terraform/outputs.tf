# Output values that will be utilized by Ansible

output "instance_public_ip" {
  description = "Public IP of the server"
  value       = aws_instance.minecraft_server.public_ip
}

output "instance_id" {
  description = "Id of the EC2 instance"
  value       = aws_instance.minecraft_server.id
}
