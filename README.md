# tf-prometheus
a [terraform](https://terraform.io) module for deploying [prometheus](https://prometheus.io/) on AWS in an autoscaling group

## Usage
```hcl
terraform {}

# define aws provider
provider "aws" {
  region = "${var.region}"
}

# import caller identify information
data "aws_caller_identity" "current" {}

# import default vpc
data "aws_vpc" "vpc" {
  default = true
}

# import subnets for default vpc
data "aws_subnet_ids" "subnets" {
  vpc_id = "${data.aws_vpc.vpc.id}"
}

# define prometheus autoscaling group
module "prometheus" {
  source           = "git::git@github.com:cludden/tf-prometheus//terraform?ref=<version>"
  ami_name         = "prometheus-v0.1.1"
  ami_owner        = "${data.aws_caller_identity.current.account_id}"
  config_prefix    = "${var.config_prefix}"
  desired_capacity = 2
  instance_type    = "t2.micro"
  key_name         = "<key_name>"
  max_size         = 2
  min_size         = 2
  name             = "prometheus"
  region           = "${var.region}"
  security_groups  = ["${aws_security_group.prometheus.id}"]
  subnet_ids       = ["${data.aws_subnet_ids.subnets.ids}"]
  volume_size      = 100
}

# create security group with ssh access and port 
resource "aws_security_group" "prometheus" {
  name = "${var.name}"
}

# allow all outbound
resource "aws_security_group_rule" "egress" {
  security_group_id = "${aws_security_group.prometheus.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# allow inbound ssh access
resource "aws_security_group_rule" "ssh" {
  security_group_id = "${aws_security_group.prometheus.id}"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# allow inbound prometheus access
resource "aws_security_group_rule" "prometheus" {
  security_group_id = "${aws_security_group.prometheus.id}"
  type              = "ingress"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# define ssm configuration
resource "aws_ssm_parameter" "global_scrape_interval" {
  name      = "${var.config_prefix}/global/scrape_interval"
  type      = "String"
  value     = "15s"
  overwrite = true
}

# render mm-account job
data "template_file" "foo" {
  template = "${file("${path.module}/foo.json")}"

  vars {
    region = "${var.region}"
  }
}

resource "aws_ssm_parameter" "foo" {
  name      = "${var.config_prefix}/scrape_configs/foo"
  type      = "String"
  value     = "${data.template_file.foo.rendered}"
  overwrite = true
}
```

## Contributing
1. [Fork it](https://github.com/cludden/tf-prometheus/fork)
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes using [conventional changelog standards](https://github.com/bcoe/conventional-changelog-standard/blob/master/convention.md) (`git commit -am 'feat: adds my new feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Ensure linting/security/tests are all passing
1. Create new Pull Request

## License
Copyright (c) 2018 Chris Ludden

Licensed under the [MIT License](LICENSE.md)