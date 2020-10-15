# Terraform a load balanced web front end in AWS, GCP or Azure.
# The solution should incorporate a number of elements
# There should be a minimum of 2 instances and they need to be able to scale across availability zones.
# Ideally the web page should be secure.
# The Vpc should be appropriately split into the required subnets.
# The hosts should be running Linux and the choice of web server is down to the individual
# The use of modules would be a good step but the focus should be on good terraform structure.​

provider "aws" {
  region = "${var.region}"
}

provider "aws" {
  region ="${var.region}"
  alias = "us_east"
}

data "aws_availability_zones" "available" {
  state = "available"
}

### Creating EC2 instance
resource "aws_instance" "public" {
  ami                    = "${var.amis.us-east-1}"
  count                  = 2
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  source_dest_check      = false
  instance_type          = "${var.instance_type}"
  
}
### Creating Security Group for EC2
resource "aws_security_group" "instance" {
  name = "terraform-example-instance2"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
## Creating Launch Configuration
resource "aws_launch_configuration" "example" {
  image_id        = "${var.amis.us-east-1}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.instance.id}"]
  key_name        = "${var.key_name}"
  user_data = <<-EOF
              #!/bin/bash
              yum -y install httpd
              echo "Hello, from Terraform" > /var/www/html/index.html
              service httpd start
              chkconfig httpd on
              EOF

  lifecycle {
    create_before_destroy = true
  }
}
## Creating AutoScaling Group
resource "aws_autoscaling_group" "ec2-sow-scaling-group" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones   = data.aws_availability_zones.available.names
  min_size             = 2
  max_size             = 4
  load_balancers       = ["${aws_elb.example.name}"]
  health_check_type    = "ELB"
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}
## Security Group for ELB
resource "aws_security_group" "elb" {
  name = "terraform-example-elb2"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
### Creating ELB
resource "aws_elb" "example" {
  name               = "terraform-asg-example2"
  security_groups    = ["${aws_security_group.elb.id}"]
  availability_zones = data.aws_availability_zones.available.names
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:8080/"
  }
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "8080"
    instance_protocol = "http"
  }
}


resource "aws_vpc" "example-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true" #gives you an internal domain name
    enable_dns_hostnames = "true" #gives you an internal host name
    enable_classiclink = "false"
    instance_tenancy = "default"    
    
}

### Accessing default VPC & Subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}