variable "instance_count" {
  default = "1"
}
variable "aws_region" {
  type        = string
  description = "AWS region used for all resources"
  default     = "eu-central-1"
}

variable "ubuntu" {
   type        = string
   description = "Ubuntu 18.04 server"
   default     = "ami-04a402dd83831f85b"
}

variable "sles" {
   type        = string
   description = "suse-sles-15-sp5-v20230620-hvm-ssd-x86_64"
   default     = "ami-0218729cdd19e8d66"
}

variable "instance_type" {
   type        = string
   description = "Instance type"
   default     = "t3.xlarge"
}

variable "name_tag" {
   type        = string
   description = "Name of the EC2 instance"
   default     = "victim"
}

variable "aws_zone" {
  type        = string
  description = "AWS zone used for all resources"
  default     = "eu-central-1a"
}

