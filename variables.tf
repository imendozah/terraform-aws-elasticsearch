variable "profile" {
  type = string
  default = "default"
}

variable "region" {
  type = string
  default = "eu-central-1"
}

variable "user" {
  type = string
  default = "ec2-user"
}

variable "elasticsearch_folder" {
  type = string
}

variable "key_name" {
  type = string
}

variable "private_key" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
  default = null
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

# Mapping of node name => properties
# Possible properties:
# - instance_type (required)
# - subnet_id (required) 
variable "nodes" {
  type = map(object({
    instance_type = string
    subnet_id = string
  }))
}
