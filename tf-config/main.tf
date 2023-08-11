resource "aws_launch_template" "ac_tt_script" {
    name_prefix   = "ac-tt-instance"
    image_id      =  data.aws_ami.ubuntu
    instance_type =  var.instance_type

    block_device_mappings {
      device_name = "/dev/sdf"
      ebs {
        volume_size = 20
      }
    }

    user_data = filebase64("../launch_script.sh")
    
    vpc_security_group_ids = [ aws_security_group.ac_tt.id ]
    
    network_interfaces {
      subnet_id = aws_subnet.ac_tt.id
    }

}

resource "aws_autoscaling_group" "ac_tt_instances" {
    desired_capacity   = 1
    max_size           = 5
    min_size           = 1

    launch_template {
      id      = aws_launch_template.ac_tt_script.id
      version = "$Latest"
    }

    vpc_zone_identifier = [ aws_subnet.ac_tt.id ]
}

resource "aws_db_subnet_group" "ac_tt" {
  name       = "main"
  subnet_ids = [ aws_subnet.ac_tt.id ]

  tags = {
    Name = "Main DB subnet group"
  }
}

resource "aws_db_instance" "ac_tt" {
  allocated_storage    = 10
  db_name              = "ac_tt_db"
  engine               = "postgres"
  engine_version       = "13.2"
  instance_class       = var.db_instance_type
  
  username             = var.db_user
  manage_master_user_password = true
  
  skip_final_snapshot  = true

  vpc_security_group_ids = [ aws_security_group.ac_tt.id ]
  db_subnet_group_name = aws_db_subnet_group.ac_tt.name
}

resource "aws_vpc" "ac_tt" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "ac_tt" {
  vpc_id = aws_vpc.ac_tt.id
  cidr_block = "10.10.0.0/24"
}

resource "aws_internet_gateway" "ac_tt" {
  vpc_id = aws_vpc.ac_tt.id
}

resource "aws_route_table" "ac_tt" {
    vpc_id = aws_vpc.ac_tt.id

    route {
        cidr_block = aws_subnet.ac_tt.cidr_block
        gateway_id = aws_internet_gateway.ac_tt.id
    }

    tags = {
        Name = "main-rt"
    }
}

resource "aws_security_group" "ac_tt" {
        
    name        = "ac_tt_sg"
    description = "Allows specific application ports and specific IP addresses for SSH (And TLS)"
    vpc_id      = aws_vpc.ac_tt.id

    ingress {
        description      = "SSH from local network ports"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["181.131.210.140/32"]
    }

    ingress {
        description      = "Allow TLS access"
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        cidr_blocks      = ["181.131.210.140/32"]
    }

    ingress {
        description      = "Allow HTTP access"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["181.131.210.140/32"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "main_security_group"
    }
}
