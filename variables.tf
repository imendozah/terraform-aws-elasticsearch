variable "profile" {
  type = string
  default = "default"
  description = "The name of the AWS profile to use"
}

variable "region" {
  type = string
  default = "eu-central-1"
  description = "The AWS region"
}

variable "user" {
  type = string
  default = "ec2-user"
  description = "The user that can provision the nodes"
}

variable "elasticsearch_folder" {
  type = string
  description = "The Elasticsearch folder on the node (no trailing slash)"
}

variable "key_name" {
  type = string
  description = "The name of the keypair to use for provisioning"
}

variable "private_key" {
  type = string
  description = "The local path to the private key used for provisioning"
}

variable "vpc_id" {
  type = string
  description = "The ID of the VPC to launch everything in"
}

variable "vpc_security_group_ids" {
  type = list(string)
  default = null
  description = "The IDs of the VPC security groups"
}

variable "ami" {
  type = string
  description = "The ID of the AMI to use for the nodes"
}

# Mapping of node name => properties
# Properties:
# - instance_type
# - subnet_id
# - volume_size
# - volume_type
variable "nodes" {
  type = map(object({
    instance_type = string
    subnet_id = string
    volume_size = number
    volume_type = string
  }))
  description = "An object containing node_name => node_values mappings. Node values are 'instance_type' and 'subnet_id'"
}
