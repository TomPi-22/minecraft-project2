# Input variables for the AWS EC2 build
# Allows for variable updates without manual reconfiguration

variable "instance_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "minecraft-server"
}

variable "region" {
  description = "AWS region for instance"
  type        = string
  default     = "us-west-2"
}

variable "ami_id" {
  description = "Ubuntu 24.04 (us-west-2)"
  type        = string
  default     = "ami-05cf1e9f73fbad2e2"
}

variable "instance_type" {
  description = "The EC2 instance's type"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Name of the AWS key for SSH connections"
  type        = string
}
