variable "ami_name" {
  type        = "string"
  description = "ami name filter"
}

variable "ami_owner" {
  type        = "string"
  description = "ami account filter"
}

variable "config_prefix" {
  type        = "string"
  description = "ssm prefix for prometheus configuration"
}

variable "desired_capacity" {
  type        = "string"
  description = "desired number of instances"
}

variable "instance_type" {
  type        = "string"
  description = "aws region"
}

variable "key_name" {
  type        = "string"
  description = "ssh key name"
}

variable "max_size" {
  type        = "string"
  description = "maximum number of instances"
}

variable "min_size" {
  type        = "string"
  description = "minimum number of instances"
}

variable "name" {
  type        = "string"
  description = "unique stack name"
}

variable "region" {
  type        = "string"
  description = "aws region"
}

variable "security_groups" {
  type        = "list"
  description = "list of security groups to assign to instances"
  default     = []
}

variable "subnet_ids" {
  type        = "list"
  description = "list of subnet ids for instance placement"
  default     = []
}

variable "volume_size" {
  type        = "string"
  description = "ebs volume size"
  default     = 100
}
