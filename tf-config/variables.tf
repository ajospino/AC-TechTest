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

variable "db_instance_type" {
  description = "Instance type for RDS deployment"
  type = string
  default = "db.t3.micro"
}

variable "db_user" {
    description = "User for Database access"
    type = string
    sensitive = true
}
