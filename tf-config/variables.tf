variable "region" {
  description = "AWS region for resources"
  type = string
  default = "us-east-2"
}

variable "instance_type" {
  description = "Instance type for deployment"
  type = string
  default = "t2.micro"
}