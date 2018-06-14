output "instance_role_arn" {
  value = "${aws_iam_role.prometheus.arn}"
}

output "instance_role_name" {
  value = "${aws_iam_role.prometheus.name}"
}
