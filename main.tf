provider "aws" {
  region = "eu-west-3"
}

resource "aws_vpc" "hussin" {
  cidr_block = "10.8.0.0/16"
  tags {
    Name = "Hussin-TF-vpc"
  }
}

resource "aws_internet_gateway" "hussin" {
  vpc_id = "${aws_vpc.hussin.id}"
  tags{
    Name = "hussin-TF-IG"
  }
}


module "db" {
  source = "./modules/db_tier"
  app_cidr_block = "${module.app.app_cidr_block}"
  app_sg = "${module.app.app_sg}"
  vpc_id = "${aws_vpc.hussin.id}"
}
module "app" {
  source = "./modules/app_tier"
  vpc_id = "${aws_vpc.hussin.id}"
  dbip = "${module.db.dbip}"
  igid = "${aws_internet_gateway.hussin.id}"
  user_data = "${data.template_file.app_init.rendered}"
}

# load the init template
data "template_file" "app_init" {
   template = "${file("./scripts/app/setup.sh.tpl")}"
   vars {
      dbip="mongodb://${module.db.dbip}:27017/posts"
   }
}

resource "aws_launch_configuration" "hussinLC" {
  name          = "HussinApp"
  image_id      = "${var.app_ami_id}"
  instance_type = "t2.micro"
  security_groups = ["${module.app.app_sg}"]
  user_data = "${data.template_file.app_init.rendered}"
  associate_public_ip_address = false
}

resource "aws_autoscaling_group" "hussinAS" {
  vpc_zone_identifier = ["${module.app.app_subnet_id}"]
  availability_zones = ["eu-west-3a"]
  name                 = "hussinAS"
  launch_configuration = "${aws_launch_configuration.hussinLC.name}"
  min_size             = 2
  max_size             = 2
  target_group_arns = ["${aws_lb_target_group.hussinTG.arn}"]
  tag {
    key= "Name"
    value= "hussinAS"
    propagate_at_launch = true
  }
}


resource "aws_lb_target_group" "hussinTG" {
  name     = "hussinTG"
  port     = 80
  protocol = "TCP"
  vpc_id   = "${aws_vpc.hussin.id}"
}

resource "aws_lb" "hussinLB" {
  name               = "hussinLB"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["${module.app.app_subnet_id}"]
  tags {
    Name = "HussinLB"
  }
}

resource "aws_lb_listener" "HussinLB-Listener" {
  load_balancer_arn = "${aws_lb.hussinLB.arn}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.hussinTG.arn}"
    type             = "forward"
  }
}
resource "aws_route53_record" "hussinapp" {
  zone_id = "Z3CCIZELFLJ3SC"
  name    = "hussinapp.spartaglobal.education"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.hussinLB.dns_name}"]
}
