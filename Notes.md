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


## 3. How to Manage Terraform State
- what is terraform state
- shared storage for state files 
- Limitations with Terraform's backends
- State file isolation
    - Isolation via workspaces
    - Isolation via layout
- The terraform_remote_state data source

# 4. How to Create Reusable Infrastructure with Terraform Modules

# 5. Terraform Tips & Tricks: Loops, if-statements, Deployment and Gotchas

# 6. Managing Secrets in Terraform

# 7. Working with multiple providers

# 8. Production-Grade Terrafrom code

# 9. How to Test Terraform Code

# 10. How to Use Terraform as a Team