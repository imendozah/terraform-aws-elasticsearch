### Requirements
Requires `terraform` version 0.12.13 or higher. Currently, this setup requires
you to specify an AMI with Java and Elasticsearch installed. In the provisioning
phase, some system parameters are configured and Elasticsearch is started
(see `elasticsearch.tf`). Also, this setup assumes you want to place the stack
in an existing VPC.

### Usage
The usage is best explained using an example. Say you want to create a two node cluster.

The first thing you need to do, is to create the appropriate configuration files for
Elasticsearch. Create two new directories under `config` and call them `node1` and `node2`
(you can name them however you like, but it's important that you use these names in the
next step of the process).

Add `elasticsearch.yml`, `jvm.options` and `log4j2.properties` config files to each of
the node directories. These configuration files will be copied to the nodes by
provisioners when creating the instances. These three configuration files need to be
present.

The next step is to tell Terraform what you want the nodes to look like.
Terraform expects a `nodes` variable, so using a `.tfvars` file, you could write:
```hcl
nodes = {
  node1 = {
    instance_type: "t2.micro"
    subnet_id: "subnet-12345"
    volume_type: "io1"
    volume_size: 50
  }
  node2 = {
    instance_type: "t2.micro"
    subnet_id: "subnet-12345"
    volume_type: "io1"
    volume_size: 50
  }
}
```
As mentioned above, the naming is important. Your config directory names need to match
the keys in the `nodes` object. In our example, our cluster will consist of two
`t2.micro` instances.
