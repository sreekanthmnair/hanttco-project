packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source.
source "amazon-ebs" "hantt_co-windows-image" {
  ami_name      = "hantt_co-windows-image-${local.timestamp}"
  communicator  = "winrm"
  instance_type = "t2.micro"
  region        = "${var.region}"
  source_ami_filter {
    filters = {
      name                = "Windows_Server-2022-English-Full-Base-2024.11.13"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  user_data_file = "./bootstrap_win.txt"
  winrm_password = "SuperS3cr3t!!!!"
  winrm_username = "Administrator"
}

# a build block invokes sources and runs provisioning steps on them.
build {
  name    = "hannt_co-W_image-build"
  sources = ["source.amazon-ebs.hantt_co-windows-image"]

  provisioner "powershell" {
  
    inline = [
    "New-Item -ItemType Directory -Path C:\\Nginx -Force",
    "Invoke-WebRequest -Uri https://nginx.org/download/nginx-1.25.2.zip -OutFile C:\\Nginx\\nginx.zip",
    "Expand-Archive -Path C:\\Nginx\\nginx.zip -DestinationPath C:\\Nginx -Force",
    "Rename-Item -Path C:\\Nginx\\nginx-1.25.2 -NewName C:\\Nginx\\nginx",
    "New-Item -ItemType Directory -Path C:\\Nginx\\nginx\\html -Force",
    "Set-Content -Path C:\\Nginx\\nginx\\html\\index.html -Value '<html><body><h1>Wecome Hantt co Site -Windows AMI Test!</h1></body></html>'",
    "$cert = New-SelfSignedCertificate -DnsName 'localhost' -CertStoreLocation Cert:\\LocalMachine\\My",
    "Export-Certificate -Cert $cert -FilePath C:\\Nginx\\nginx\\ssl.crt -Force"
    ]
  }

provisioner "powershell" {
    inline = [
        "Set-Content -Path 'C:\\Nginx\\nginx\\conf\\nginx.conf' -Value @(",
        "'events {',",
        "'    worker_connections  1024;',",
        "'}',",
        "'http {',",
        "'    server {',",
        "'        listen       443 ssl;',",
        "'        server_name  localhost;',",
        "'',",
        "'        ssl_certificate      C:\\Nginx\\nginx\\ssl.crt;',",
        "'        ssl_certificate_key  C:\\Nginx\\nginx\\ssl.key;',",
        "'',",
        "'        location / {',",
        "'            root   C:\\Nginx\\nginx\\html;',",
        "'            index  index.html;',",
        "'        }',",
        "'    }',",
        "'}'",
        ")",
        "Write-Host 'nginx.conf has been updated successfully.'"
    ]
}


provisioner "powershell" {
    inline = [
        "$serviceScript = '",
        "  <#",
        "  .SYNOPSIS",
        "  Starts the Nginx server.",
        "  #>",
        "  Param (",
        "      [string]$ExecutablePath",
        "  )",
        "",
        "  Start-Process -NoNewWindow -FilePath $ExecutablePath",
        "'",
        "Set-Content -Path 'C:\\Nginx\\Start-Nginx.ps1' -Value $serviceScript -Force",
        "New-Service -Name 'Nginx' -BinaryPathName 'powershell.exe -File C:\\Nginx\\Start-Nginx.ps1 C:\\Nginx\\nginx\\nginx.exe' -DisplayName 'Nginx Web Server' -Description 'Nginx Web Server on Windows' -StartupType Automatic",
        "Start-Service Nginx",
        "Write-Host 'Nginx service started successfully.'"
    ]
}


  # provisioner "powershell" {
  #   environment_vars = ["DEVOPS_LIFE_IMPROVER=PACKER"]
  #   inline           = ["Write-Host \"HELLO NEW USER; WELCOME TO $Env:DEVOPS_LIFE_IMPROVER\"", "Write-Host \"You need to use backtick escapes when using\"", "Write-Host \"characters such as DOLLAR`$ directly in a command\"", "Write-Host \"or in your own scripts.\""]
  # }
  provisioner "windows-restart" {
  }
  provisioner "powershell" {
    environment_vars = ["VAR1=A$Dollar", "VAR2=A`Backtick", "VAR3=A'SingleQuote", "VAR4=A\"DoubleQuote"]
    script           = "./sample_script.ps1"
  }
}
