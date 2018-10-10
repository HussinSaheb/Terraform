

resource "aws_route_table" "hussindb" {
  vpc_id = "${var.vpc_id}"
  tags{
    Name = "hussin-dbRT"
  }
}

resource "aws_subnet" "hussindb" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.8.1.0/24"
  availability_zone = "eu-west-3a"
  map_public_ip_on_launch = false
  tags {
    Name = "Hussin-db-subnet"
  }
}


resource "aws_security_group" "hussindb" {
  name = "hussin-db"
  description = "Hussin db Security Group"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = "27017"
    to_port =  "27017"
    protocol = "tcp"
    security_groups = ["${var.app_sg}"]
  }
  egress {
    from_port = 0
    to_port =  0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "hussin-db"
  }
}

resource "aws_route_table_association" "hussindb" {
  subnet_id      = "${aws_subnet.hussindb.id}"
  route_table_id = "${aws_route_table.hussindb.id}"
}

resource "aws_network_acl" "hussindb" {
  vpc_id = "${var.vpc_id}"

  ingress {
    rule_no = 100
    protocol = "tcp"
    action = "allow"
    cidr_block = "${var.app_cidr_block}"
    from_port = 27017
    to_port = 27017
  }
  egress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }
  subnet_ids = ["${aws_subnet.hussindb.id}"]

  tags {
    Name = "HussindbNACL"
  }
}


#  launch an instance
resource "aws_instance" "hussin-TF-db" {
  ami = "${var.db_ami_id}"
  subnet_id = "${aws_subnet.hussindb.id}"
  vpc_security_group_ids = ["${aws_security_group.hussindb.id}"]
  instance_type = "t2.micro"
  tags {
    Name = "hussin-tf-db"
  }
}
