# import caller identify information
data "aws_caller_identity" "current" {}

# import prometheus ami
data "aws_ami" "prometheus" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }

  owners = [
    "${var.ami_owner}",
  ]
}
