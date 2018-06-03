# define launch configuration
resource "aws_launch_configuration" "prometheus" {
  name_prefix          = "${var.name}"
  image_id             = "${data.aws_ami.prometheus.id}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${var.security_groups}"]
  user_data            = "${data.template_file.userdata.rendered}"
  key_name             = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.prometheus.id}"

  ebs_block_device = {
    volume_type           = "gp2"
    volume_size           = "8"
    delete_on_termination = "true"
    device_name           = "/dev/xvda"
  }

  ebs_block_device = {
    volume_type           = "gp2"
    volume_size           = "${var.volume_size}"
    delete_on_termination = "true"
    device_name           = "/dev/xvdcz"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# render userdata
data "template_file" "userdata" {
  template = "${file("${path.module}/userdata.sh")}"

  vars {
    config_prefix = "${var.config_prefix}"
  }
}

# define placement group for autoscaling instances
resource "aws_placement_group" "prometheus" {
  name     = "${var.name}"
  strategy = "spread"
}

# define instance profile
resource "aws_iam_instance_profile" "prometheus" {
  name = "${var.name}"
  role = "${aws_iam_role.prometheus.name}"
}

# define instance role
resource "aws_iam_role" "prometheus" {
  name               = "${var.name}"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

# define assume role policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "prometheus" {
  name   = "${var.name}"
  policy = "${data.aws_iam_policy_document.prometheus.json}"
}

# define instance policy
data "aws_iam_policy_document" "prometheus" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]

    effect = "Allow"

    resources = [
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter${var.config_prefix}",
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter${var.config_prefix}/*",
    ]
  }
}

# attach policy to role
resource "aws_iam_role_policy_attachment" "prometheus" {
  role       = "${aws_iam_role.prometheus.name}"
  policy_arn = "${aws_iam_policy.prometheus.arn}"
}

# define autoscaling group
resource "aws_autoscaling_group" "prometheus" {
  name                      = "${var.name}"
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = "${var.desired_capacity}"
  force_delete              = true
  placement_group           = "${aws_placement_group.prometheus.id}"
  launch_configuration      = "${aws_launch_configuration.prometheus.name}"
  vpc_zone_identifier       = ["${var.subnet_ids}"]

  timeouts {
    delete = "15m"
  }

  lifecycle {
    create_before_destroy = true
  }
}
