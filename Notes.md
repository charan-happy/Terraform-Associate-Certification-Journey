# 1. why Terraform ?

# 2. Getting Started with Terraform

# 3. How to Manage Terraform State

# 4. How to Create Reusable Infrastructure with Terraform Modules

# 5. Terraform Tips & Tricks: Loops, if-statements, Deployment and Gotchas

# 6. Managing Secrets in Terraform

# 7. Working with multiple providers

# 8. Production-Grade Terrafrom code

# 9. How to Test Terraform Code

# 10. How to Use Terraform as a Team



### 1. why Terraform ?
- Software isn't done until you deliver it to the end user. software delivery consists of all the work you need to do make the code available to a customer, such as running code on production servers, making the code resilient to outages and traffic spikes, and protecting the code from attackers.

Before diving deeping into the terraform, first lets learn about devops. **Devops** has multiple definitions from multiple persons/organisations. For me devops is a combination of tools & technologies and involvement of different people from different departments to speed up the software delivery process.

- In these chapter, we will learn about topics 

```
- what is infrastructure as code ?
- what are benefits of infrastructure as code ?
- How does terraform work ?
- How does Terraform different from other infrastructure as code tools in the market ?
```

#### what is infrastructure as code ?
- The idea behind infrastructure as code (IAC) is that you write and execute code to define,deploy, update and destory your infrastructure. 
- There are Five broad categories of IAC tools :

``` 
1. Adhoc scripts Ex: Bash, Ruby, Python
2. Configuration management tools Ex: Ansible,puppet, chef
3. Server templating tools Ex: Docker, packer, Vagrant
4. Orchestration tools Ex: Kubernetes, Marathon/Mesos, Amazon Elastic Container Service (ECS), Docker Swarm and nomad
5. Provisioning tools EX: Terraform, cloud-formation, openstack heat, pulumni
```

setup-webserver.sh
```sh
sudo apt-get update
sudo apt-get install -y php apache2
sudo git clone https://github.com/brikis98/php-app.git /var/www/html/app
sudo service apache2 start
```

setup-webserver.yml
```yml
---
- name: update the apt-get cache
  apt:
    update_cache: yes

- name: Install PHP
  apt:
    name: php

- name: Install Apache
  apt:
    name: apache2

- name: copy the code from the repository
  git: repo=https://github.com/brikis98/php-app.git dest=/var/www/html/app

- name: Start Apache
  service:
    name: apache2
    state: started
    enabled: yes
```

```
- Instead of launching a bunch of servers and configuring them by running the same code on each one, the idea behind server templating tools is to create an image of a server that captures fully self-contained "snapshot" of the operating system (os), the software, files, and all other relevant details. You can use some other IAC tool to install that image on all of your servers.
- there are two broad categories of tools for working with images. They are 1. virtual machines and 2. Containers
- Different server templating tools have different purposes. **packer** is typically used to create images that you run directly on top of production servers, such as an AMI that you run in your production AWS Account. **vagrant** is typically used to create images that you run in your development computers, such as a VirtualBox image that you run on your Mac or Windows laptop. **Docker** is typically used to create images of individual applications. You can run docker images on production or development computers, as long as some other tool has configured that computer with Docker Engine.

- A common pattern is to use Packer to create an AMI that has the Docker Engine installed, deploy that AMI on a cluster of servers in your AWS account, and then deploy individual Docker containers across that cluster to run your applications
```

```yml 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example-app
spec:
  selector:
    matchlabels:
      app: example-app
  replicas: 3
  strategy:
    rollingUpdate:
      maxSurge: 3
      maxUnavailable: 8
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: example-app
    spec:
      containers:
        - name: example-app
          image: httpd:2.4:39
          ports:
            - containerPort: 80
```

```hcl
resource "aws_instance" "app" {
  instance_type = "t2.micro"
  availability_zone = "us-east-2a"
  ami = "ami-0fb653ca2d3203ac1"

  user_data = <<-EOF
              #!/bin/Bash
              sudo service apache2 start
              EOF 
}
```

#### Benefits of Infrastructure as Code :
1. self-service <br>
2. Speed and safety <br>
3. Documentation <br>
4. Version Control <br>
5. validation <br>
6. Reuse <br>

#### How does Terraform Work ?
- Terraform is an opensource tool created by Hashicorp and written in Go programming language.
- The Go code compiles down into a single binary. We can use this binary to deploy infrastructure from laptop or a build server 
- Terraform binary makes API calls on behalf of us to one or more providers such as AWS, Azure, Google Cloud, Digital Ocean, Openstack etc. This means that terraform gets to leverage the infrastructure those providers are already running for their API servers, as well as the authentication mechanisms you're already using with those providers 

**How does terraform knows what API calls to make ? 🤔** The answer for it was that we create Terraform configuration, which are text files which specify what infrastructure you want to create. Below is the example for Terraform configuration 

```
resource "aws_instance" "example" {
  ami = "ami-0fb56kf8874f"
  instance_type = "t2.micro"
}
```
- Terraform allows you to deploy interconnected resources across multiple cloud providers.
- The terraform binary parses your code, translates it into a series of API calls to the cloud providers specified in the code, and makes those API calls as efficiently as possible on your behalf.

**Is Transparent Portability between cloud providers possible ?** no, because cloud providers don't offer exactly the same type of infrastructure. The functionality in one cloud doesnot exists exactly in the same way in another cloud providers.

#### How Does Terraform Compare to Other IAC Tools ?

Below are the main trade-offs to consider while selecting the tool :  
1. Configuration Management vs Provisioning
2. Mutuable Infrastructure vs Immutable Infrastructure
3. Procedural Languages vs Declarative Languages
4. Master vs Masterless
5. Agent vs Agentless
6. Paid vs Free offering
7. Large community vs small community
8. Mature vs Cutting-edge
9. Use of Multiple Tools together

## 2. Getting Started with Terraform
- setting up your AWS account
- Installing Terraform
- Deploying a single server
- Deploying a single web server
- Deploying a configurable web server
- Deploying a cluster of web servers
- Deploying a load balancer

**Deploying a single server**
- For each type of provider, there are many different kinds of resources that you can create, such as servers, databases and loadbalancers. The general sytax for creating a resource in Terraform as follows:
```
resource "<provider>_<type>" "<Name>" {
  [CONFIG...]
}
```
- An expression in terraform is anything that returns a value. Simplest type of expressions, literals such as strings (ex: "ami-xvxxx") and numbers (ex: 8). Terraform supports many other types of expressions. 
- One particularly useful type of expression is a `reference` which allows you to access values from other parts of your code. 
Ex: To access the ID of the security group resource, you are going to need to use a resource attribute reference, which uses the following syntax : `<provider>_<type>.<Name>.<Attribute>`
```
Network security
---------------
- A vpc is partitioned into one or more subnets, each with its own IP addresses. The subnets in Default VPC are all public subnets, which means they get IP addresses that are accessible from the public internet. 
```

**Deploying a single web server**
- To allow you to make your code more DRY and more configurable. Terraform allows you to define `input variables`, Here is the syntax for declaring a variable:

```
variable "NAME" {
  [CONFIG...]
}
```

Optional Parameters in Terraform variable are as follows:

1. Description
2. Default
3. Type
4. Validation
5. Sensitive

```hcl
variable "number_example" {
  description = "An example of number variable in Terraform"
  type = number
  default = 34
}


variable "list_example" {
  description = "An example of a list in Terraform"
  type = List
  default = ["a", "b", "c"]
}

variable "list_numeric_example" {
  description = "An example of a numeric list in Terraform"
  type = list(string)
  default = ["1", "2", "3"]
}

variable "map_example" {
  description = "An example of a map in Terraform"
  type = map(string)

  default = {
    key1 = "value1"
    key2 = "value2"
    key3 = "value3"
  }
}

variable "object_example" {
  description = "An example of a structural type in Terraform"
  type = object({
    name = string
    age = number
    tags = list(string)
    enabled = bool
  })

  default = {
    name = "value1"
    age = "43"
    tags = ["a", "b", "c"]
    enabled = true
  }
}
```

```
variables as input parameters ways:
-------------------------------
1. if we don't give default value in variable file then it will prompt us to enter the value
2. -var command line option ex: `terraform plan -var "server_port=8080`
3. via environmental variable TF_VAR_<Name>ex: export TF_VAR_server_port=8080
4. Default value in variable file
```
- `Interpolation` is one of the type in terraform expression, which takes any valid reference within curly braces and terraform will convert it into a string.


**Deploying a configurable web server**

**Deploying a cluster of web servers**
```
resource "aws_launch_configuration" "example" {
  ami = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  user_data_replace_on_change = true
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


```

- A **datasource** represents a piece of read-only information that is fetched from provider everytime you run Terraform. Adding a  datasource to your terraform does not create anything new, its just a way to query the provider's APIs for data and make that data available to the rest of the terraform code. Each Terraform provider exposes a variety of data sources.

- The syntax for using a datasource is simmilar to the syntax of a resource.

data "<provider>_<type>" "Name" {
  [CONFIG...]
}
 
 - To get the data out of a datasource, you use the following attribute reference syntax:
 `data.<provider>_<type>.<Name>.<Attribute>`
 - To get ID of the VPC from the aws_vpc data source, you would use the following:
 `data.aws_vpc.default.id`


**Deploying a load balancer**
- AWS offers 3 types of loadbalancers:
1. **Application Load Balancer (ALB)**: Best for load balancing of HTTP and HTTPS traffic. Operates at the application layer (layer 7) of the open systems interconnection (OSI) model.

2. **Network Load Balancer (NLB)**: Best suited for load balancing of TCP, UDP and TLS traffic. can scale up and down in response to load faster than the ALB (NLB is designed to scale to tens of millions of requests per second). Operates at the transport layer (layer 4) of the OSI model

3. **Classic Load Balancer (CLB)**: This is legacy loadbalancer that predates the both ALB and NLB. It can handle HTTP, HTTPS, TCP, TLS Traffic but with far fewer features than either ALB or NLB. Operates at the both application layer (layer 7) and transport layer (layer 4) of the OSI Model.

``` 
ALB Loadbalancer constitutes:
-----------------------------
1. Listener: Listens on specific port (e.g;80) and protocol(e.g:HTTP)
2. Listener Rule : Takes requests that come into a listener and sends those that match specific paths (e.g: /foo and /bar) or hostnames (e.g: foo.example.com and bar.example.com) to specific target groups
3. Target groups: one or more servers that receive requests from the load balancer. The target group also performs health checks on these servers and sends requests only to healthy nodes.
```


## 3. How to Manage Terraform State
- what is terraform state
- shared storage for state files 
- Limitations with Terraform's backends
- State file isolation
    - Isolation via workspaces
    - Isolation via layout
- The terraform_remote_state data source

**what is terraform state ?**
- Everytime you run terraform, it records information about what infrastructure it created in a terraform state file. 
- The extension for terraform state file will be ".tfstate".
- these '.tfstate' extension file consists a custom JSON format that records a mapping from the terraform resources in your configuration files to the representation of those resources in the real world.


**shared storage for state files**
- Storing Terraform state file in version control is a bad idea. Due to following reasions :
1. Manual error
2. Locking 
3. secrets

instead of using version control, the best way to manage shared storage for state files is to use Terraform's built-in support for remote backends. 
- A terraform's backend determines how terraform loads and stores state. The default backend is **local backend** which stores the state file on your local disk
- **Remote backends** allows you to store the state file in a remote, shared store ex: Amazon S3, Azure storage, google cloud storage and Hashicorp's terraform cloud and Terraform enterprise

- Remote backends solves the manual errors, locking, secrets issues. 

if we are using AWS as a cloud then AWS S3 is the best bet for remote backends. Due to below reasons
- It is managed service. So, we don't need to deploy and manage extra infrastructure to use it
- It is designed for 99.999999% durability and 99.99% availability. Which means you don't need to worry too much about data loss or outages
- It supports encryption, which reduces worries about storing sensitive data in state files. you still have to be very careful who on your team can access the S3 bucket, but atleast the data will be encrypted at rest(Amazon S3 supports server-side encryption using AES-256) and in transit (Terraform uses TLS when talking to Amazon s3)
- It supports locking via DynamoDB
- It supports versioning. So every revision of your state file is stored, and you can roll back to an older version if something goes wrong
- It's Inexpensive, with most Terraform usage easily fitting into the AWS Free Tier 

- **DynamoDB** is Amazon's distribution key-value store. It supports strongly consistent reads and conditional writes, which are all the ingredients you need for a distributed lock system. Moreover, it's completely managed, so you don't have any infrastructure to run yourself, and it's inexpensive, with most Terraform usage easily fitting into the AWS Free Tier.



**Limitations with Terraform's backends**

**state file isolation**

**The terrraform_remote_state datasource**

# 4. How to Create Reusable Infrastructure with Terraform Modules

# 5. Terraform Tips & Tricks: Loops, if-statements, Deployment and Gotchas

# 6. Managing Secrets in Terraform

# 7. Working with multiple providers

# 8. Production-Grade Terrafrom code

# 9. How to Test Terraform Code

# 10. How to Use Terraform as a Team