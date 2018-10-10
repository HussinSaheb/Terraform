

resource "aws_subnet" "hussinapp" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.8.0.0/24"
  availability_zone = "eu-west-3a"
  map_public_ip_on_launch = false
  tags {
    Name = "Hussin-app-subnet"
  }
}
resource "aws_route_table" "hussinapp" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.igid}"
  }
  tags{
    Name = "hussin-appRT"
  }
}

resource "aws_route_table_association" "hussinapp" {
  subnet_id      = "${aws_subnet.hussinapp.id}"
  route_table_id = "${aws_route_table.hussinapp.id}"
}


resource "aws_security_group" "hussinapp" {
  name = "hussin-app"
  description = "Hussin App Security Group"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = "80"
    to_port =  "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port =  0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "hussin-app"
  }
}

resource "aws_network_acl" "hussinapp" {
  vpc_id = "${var.vpc_id}"

  egress {
    rule_no = 100
    protocol = "tcp"
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }
  egress {
    rule_no = 120
    protocol = "tcp"
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }
  ingress {
    protocol = "tcp"
    rule_no = 120
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }
  subnet_ids = ["${aws_subnet.hussinapp.id}"]

  tags {
    Name = "HussinAppNACL"
  }
}
