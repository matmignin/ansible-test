provider "aws" {
  region     = "us-east-2"
}


 #  ____________________________________ INSTANCE STUFF ________________

resource "aws_instance" "ants-instance" {
  count = 3 
  ami           = "ami-0f65671a86f061fcd"
  instance_type = "t2.micro"
  key_name = "antskp"  

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get install -y python",
    ]
    connection {
        type = "ssh"
        user = "ubuntu"
    } 
  }
  tags {
    Name = "ants-${count.index}"
  }
}


#________________________________elb security group stuff____________

resource "aws_security_group" "ants_elb" {
  name = "ants_elb"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port =443 
    to_port =443 
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#           ____________________  Load Balancer stuff _____________

resource "aws_elb" "ants-lb" {
  name    = "ants-lb"
  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
  instances       = ["${aws_instance.ants-instance.*.id}"]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:80/"
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 4
}


output "instance_ips" {
  value = ["${aws_instance.ants-instance.*.public_ip}"]
}

output "address" {
  value = "${aws_elb.ants-lb.dns_name}"
}



