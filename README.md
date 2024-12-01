# Deployment Guide

This document outlines the AWS deployment process for setting up a VPC using Terraform. The setup includes a private subnet, a public subnet, an Internet Gateway, a NAT Gateway, and an EC2 instance within the VPC. In the second phase, Nginx servers were installed and configured, and a sample website was deployed on the EC2 instance using a self-signed SSL certificate and Ansible playbooks. Additionally  released a packer template to build custom Ami with NGNIX Installed and public website published. 

This project is based on the provided practical test requirements and has been intentionally simplified, omitting high availability and load balancers for clarity and ease of implementation

# Folders

    1) IaC-TF - 
       (Terraform templates for ASW Resource creation)
    2) Config-Ansible -
       (Ansible code to deploy nginx on EC2 and publish sample website with self-signed certificate)
    3) Packer-Ubuntu-ami -
       (packer template to build custom Ami with NGNIX Installed and public website published)
             
## Deployment - Terraform
      
      Requried A valid user id with keyapir which has has necessary permission on Cloud 
      (Programmatic Access) 
       
     1) Download Deployment folder "IaC-TF" from or clone from Github Repo.
     2) Copy  Folder IaC-TF  Locally. Contain below folders and files inside.
     3) Open the code with visual code or any IDE tool. Update the terraform.tfvars file with desired        
        values based on the requirements.
      <aws_region,project_name,instance_name,instance_type,ami_id,key_name,public_subnets,public_subnet>
     4) Open terminal and connect to aws console 9aws configure using Access Key and Secret Key of User has   
        necessary  permission on Cloud ( Programmatic Access) , and open the soruce folder
     5) Init the terraform using terraform init
     6) Validate the code using terraform apply validate  
     7) Apply the code  using  “terraform apply –auto-approve”
     8) Login to cloud portal and validate the desired Cloud instances are created. VPC,Subnets,EC2<   
        internet gateway, NAT Gateway etc
        
## Deployment - Ansible

        Requried Access and secret key which has root permission on EC2 Instacne Created
        
     1) Download Deployment folder "Config-Ansible"  or clone from below Github Repo.  
     2) Login  to ec2 instance via ssh (use public IP address of ec2 instance crated)
     3) Create a folder called “ansible-project”in home folder
     4) Create a folder called “templates” under “ansible-project”
     5) Create a file called “install-nginx-playbook.yml” under “ansible-project”
     6) Create a file called  “nginx_default_ssl.j2” under “ansible-project/templates/”
     7) Copy the content of “install-nginx-playbook.yml” to “ansible-project/install-nginx-playbook.yml”   
        file
     8) Copy the content of “nginx_default_ssl.j2” to “ansible-project/templates/nginx_default_ssl.j2”      
        file
     9) On EC2 Instance Change the location to  “ansible-project” Directory, and run the ansible playboo
    10) Validate the ansible playbook syntax once 
          “sudo ansible-playbook install-nginx-playbook.yml --syntax-check”
    11) Run the ansible play book playbook
          “sudo ansible-playbook install-nginx-playbook.yml”
    12) Access the sample website from public using ec2 public ip , <https://publicip/>    

## Deployment - Packer Image ( Ubuntu ami with nginx public website)

    Requried A valid user id with keyapir which has has necessary permission on Cloud 
      (Programmatic Access) 
      
     1) Download Deployment folder "Packer-Ubuntu-ami" from or clone from Github Repo.
     2) Copy  Folder "Packer-Ubuntu-ami" Locally. Contain below folders and files inside.
     3) Open the code with visual code or any IDE tool. 
     4) Open terminal and connect to aws console 9aws configure using Access Key and Secret Key of User has   
        necessary  permission on Cloud ( Programmatic Access) , and open the soruce folder
     5) validate the packer template "packer validate ."   
     6) Build image with the packer templates "packer build ." , wait for the completion
     7) locate the custom ami under my ami in aws amazon ami catalog
     8) create a sample ec2 instance and validate the public wesbite using ec2 public ip           
        <https://publicip/>  