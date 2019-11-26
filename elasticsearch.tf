provider "aws" {
  profile = var.profile
  region = var.region
}

# Security group for the nodes.
resource "aws_security_group" "node" {
  name = "Elasticsearch node"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 9300
    to_port = 9300
    protocol = "tcp"
    security_groups = var.vpc_security_group_ids
  }

  ingress {
    from_port = 9200
    to_port = 9200
    protocol = "tcp"
    security_groups = var.vpc_security_group_ids
  }
}

# Cluster nodes
resource "aws_instance" "node" {
  # Loop over all nodes.
  for_each = var.nodes

  # Set node specific values.
  instance_type = each.value.instance_type
  subnet_id = each.value.subnet_id

  ebs_block_device {
    device_name = "Elasticsearch volume"
    volume_type = each.value.volume_type
    volume_size = each.value.volume_size
  }

  # Set attributes that are applicable to all nodes.
  ami = var.ami
  vpc_security_group_ids = concat(var.vpc_security_group_ids, [aws_security_group.node.id])
  key_name = var.key_name
  iam_instance_profile = "${aws_iam_instance_profile.node.name}"

  # Connection for all provisioners.
  connection {
    host = self.public_ip
    type = "ssh"
    user = var.user
    private_key = file(var.private_key) 
  }

  # Copy the configuration files.
  provisioner "file" {
    source = "config/${each.key}/elasticsearch.yml"
    destination = "${var.elasticsearch_folder}/config/elasticsearch.yml"
  }

  provisioner "file" {
    source = "config/${each.key}/jvm.options"
    destination = "${var.elasticsearch_folder}/config/jvm.options"
  }

  provisioner "file" {
    source = "config/${each.key}/log4j2.properties"
    destination = "${var.elasticsearch_folder}/config/log4j2.properties"
  }

  # Configure system parameters.
  provisioner "remote-exec" {
    inline = [
      # Upgrade the maximum number of file descriptors.
      "echo '*  hard  nofile  65535' | sudo tee -a /etc/security/limits.conf",
      # Upgrade the maximum number of threads.
      "echo '*  hard  nproc   4096' | sudo tee -a /etc/security/limits.conf",
      # Reduce the kernel's tendency to swap.
      "sudo sysctl -w vm.swappiness=1",
      # Increase limits on mmap counts.
      "sudo sysctl -w vm.max_map_count=262144",
      # Install the Elasticsearch EC2 discovery plugin.
      "${var.elasticsearch_folder}/bin/elasticsearch-plugin install --batch discovery-ec2"
    ]
  }

  # Start the node in a different provisioner so the system parameters
  # take effect.
  provisioner "remote-exec" {
    inline = [
      # Start elasticsearch.
      "nohup ${var.elasticsearch_folder}/bin/elasticsearch -d"
    ]
  }

  # Properly take the node out of the cluster before shutting
  # it down.
  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "echo 'Destroying'"
    ]
  }

  tags = {
    Name = "Elasticsearch"
  }
}
