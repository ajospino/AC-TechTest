resource "aws_launch_template" "ac_tt_script" {
    name_prefix   = "ac-tt-instance"
    image_id      =  data.aws_ami.ubuntu.id
    instance_type =  var.instance_type

    key_name = "mainKey"
    block_device_mappings {
      device_name = "/dev/sdf"
      ebs {
        volume_size = 20
      }
    }

    user_data = filebase64("../launch_script.sh")
    
    network_interfaces {
      subnet_id = aws_subnet.ac_tt.id
      security_groups = [ aws_security_group.ac_tt.id ]
      associate_public_ip_address = true
    }

}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "mainKey"      
  public_key = tls_private_key.pk.public_key_openssh

}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.kp.key_name}.pem"
  content = tls_private_key.pk.private_key_pem
}

resource "aws_autoscaling_group" "ac_tt_instances" {
    desired_capacity   = 1
    max_size           = 5
    min_size           = 1

    name = "ac-tt"

    launch_template {
      id      = aws_launch_template.ac_tt_script.id
      version = "$Latest"
    }

    vpc_zone_identifier = [ aws_subnet.ac_tt.id ]
}

resource "aws_db_subnet_group" "ac_tt" {
  name       = "main"
  subnet_ids = [ aws_subnet.ac_tt.id, aws_subnet.ac_tt_2.id]

  tags = {
    Name = "Main DB subnet group"
  }
}

resource "aws_db_instance" "ac_tt" {
  allocated_storage    = 10
  db_name              = "ac_tt_db"
  engine               = "postgres"
  engine_version       = "12.15"
  instance_class       = var.db_instance_type
  publicly_accessible = true
  
  username             = var.db_user
  password             = var.db_password
  
  skip_final_snapshot  = true

  vpc_security_group_ids = [ aws_security_group.ac_tt.id ]
  db_subnet_group_name = aws_db_subnet_group.ac_tt.name
}

resource "aws_vpc" "ac_tt" {
  cidr_block = "10.10.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "ac_tt" {
  vpc_id = aws_vpc.ac_tt.id
  cidr_block = "10.10.10.0/24"
  availability_zone = "us-east-2b"
}

resource "aws_subnet" "ac_tt_2" {
  vpc_id = aws_vpc.ac_tt.id
  cidr_block = "10.10.12.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_internet_gateway" "ac_tt" {
  vpc_id = aws_vpc.ac_tt.id
}

resource "aws_route_table_association" "ac_tt" {
  subnet_id = aws_subnet.ac_tt.id
  route_table_id = aws_route_table.ac_tt.id
}

resource "aws_route_table" "ac_tt" {
    vpc_id = aws_vpc.ac_tt.id

    route {
        cidr_block = "0.0.0.0/0"
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
        cidr_blocks      = ["181.131.210.140/32", "191.156.0.0/16"]
    }

    ingress {
        description      = "Allow TLS access"
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        cidr_blocks      = ["181.131.210.140/32", "191.156.0.0/16"]
    }

    ingress {
        description      = "Allow HTTP access"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["181.131.210.140/32", "191.156.0.0/16"]
    }

    ingress {
        description      = "PostgreSQL port"
        from_port        = 5432
        to_port          = 5432
        protocol         = "tcp"
        cidr_blocks      = ["181.131.210.140/32", "191.156.0.0/16"]
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
