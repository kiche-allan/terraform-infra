output "instance_public_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP of the web instance"
}

output "instance_id" {
  value = aws_instance.web.id
}

output "ami_id" {
  value = data.aws_ami.amazon_linux.id
}

output "website_url" {
  value = "http://${aws_instance.web.public_ip}"
}