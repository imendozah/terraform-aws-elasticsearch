# Make sure the load balancer can be reached on the right port.
resource "aws_security_group" "load_balancer" {
  name = "Elasticsearch load-balancer"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 9200
    to_port = 9200
    protocol = "tcp"
    security_groups = var.vpc_security_group_ids
  }
}

# Get all subnets available in the VPC for
# the load balancer.
data "aws_subnet_ids" "available_subnets" {
  vpc_id = "${var.vpc_id}"
}

# Load balancer
resource "aws_lb" "load_balancer" {
  name = "Elasticsearch"
  internal = false
  security_groups = concat(var.vpc_security_group_ids, [aws_security_group.load_balancer.id])

  # Set all subnets available in the VPC
  subnets = data.aws_subnet_ids.available_subnets.ids

  tags = {
    Name = "Elasticsearch"
  }
}

# Target group for the nodes.
resource "aws_lb_target_group" "nodes" {
  name = "Elasticsearch"
  port = 9200
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"
}

# Listener for incoming connections.
resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_lb.load_balancer.arn}"
  port = 9200
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.nodes.arn}"
  }
}
# Connects the nodes to the target group.
resource "aws_lb_target_group_attachment" "node_attachment" {
  # Loop over all nodes.
  for_each = aws_instance.node

  target_id = "${each.value.id}"
  target_group_arn = "${aws_lb_target_group.nodes.arn}"
}
