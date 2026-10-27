output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.pr_tracker_server.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.pr_tracker_server.public_ip
}

output "public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.pr_tracker_server.public_dns
}

output "ssh_command" {
  description = "SSH connection string for Ansible or manual administration"
  value       = "ssh -i pr-tracker.pem ubuntu@${aws_instance.pr_tracker_server.public_ip}"
}

output "client_url" {
  description = "PR Tracker Client Web Application URL"
  value       = "http://${aws_instance.pr_tracker_server.public_ip}"
}

output "api_gateway_url" {
  description = "PR Tracker API Gateway URL"
  value       = "http://${aws_instance.pr_tracker_server.public_ip}:5000"
}

output "nagios_dashboard_url" {
  description = "Nagios Monitoring Web Dashboard URL"
  value       = "http://${aws_instance.pr_tracker_server.public_ip}:8080"
}
