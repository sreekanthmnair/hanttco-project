# Deployment Guide

This document outlines the AWS deployment process for setting up a VPC using Terraform. The setup includes a private subnet, a public subnet, an Internet Gateway, a NAT Gateway, and an EC2 instance within the VPC. In the second phase, Nginx servers were installed and configured, and a sample website was deployed on the EC2 instance using a self-signed SSL certificate and Ansible playbooks.

This project is based on the provided practical test requirements and has been intentionally simplified, omitting high availability and load balancers for clarity and ease of implementation
