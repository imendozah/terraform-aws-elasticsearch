resource "aws_iam_role" "node" {
  name = "Elasticsearch-node"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "node" {
  name = "Elasticsearch-node"
  role = "${aws_iam_role.node.name}"
}

# Make sure the nodes can describe instances for the
# Elasticsearch discovery-ec2 plugin
resource "aws_iam_policy" "node" {
  name = "Elasticsearch-node"
  policy = <<EOF
{
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_policy_attachment" "node" {
  name = "Elasticsearch-node"
  roles = ["${aws_iam_role.node.name}"]
  policy_arn = "${aws_iam_policy.node.arn}"
}
