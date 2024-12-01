
#Define Desired Region
aws_region = "us-east-1"

#Define Project Name which will be suffixed to the resources
project_name = "hanttco"

#Define Desired Instance Name and Type
instance_name = "hanttco-ec2"
instance_type = "t2.micro"

# Define Required AMI ID of Desired EC2 Instance   
ami_id           = "ami-0866a3c8686eaeeba"     

 # Define Required SSH key pair name, This needs to be creted prior to setup
key_name         = "ec2-hantt"

#Define desired VPC CIDR Block
vpc_cidr="192.168.0.0/16"

#Define AZ and Public Subnet CIDR Blocks
public_subnets={
    "us-east-1a" = "192.168.1.0/24" # Add more Zone and Subnet in same format if required
}

#Define  AZ and Private Subnet CIDR Block
private_subnets = {
    "us-east-1a" = "192.168.2.0/24"  # Add more Zone and Subnet in same format if required
}
