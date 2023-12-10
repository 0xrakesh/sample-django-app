# Define AWS provider
provider "aws" {
  region = "us-east-1"  # Update with your preferred region
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create a security group for EC2 instance
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.my_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch EC2 instance
resource "aws_instance" "django_instance" {
  ami           = "ami-02ba40905b081bd48"  # Update with the correct AMI ID
  instance_type = "t3.micro"  # Update with the desired instance type
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              <powershell>
              # Update system
              Install-Module -Name PowerShellGet -Force -AllowClobber
              Install-Module -Name AWS.Tools.Installer -Force -AllowClobber
              Install-AWSToolsModule -Force -AllowClobber

              # Install Python
              choco install python -y
              
              # Install Django
              pip install django

              # Clone or copy your Django project code
              git clone https://github.com/yourusername/your-django-project.git C:\path\to\your\project
              cd C:\path\to\your\project

              # Install project dependencies
              pip install -r requirements.txt

              # Apply migrations and start Django development server
              python manage.py migrate
              Start-Process python -ArgumentList "manage.py runserver 0.0.0.0:80" -NoNewWindow
              </powershell>
              EOF

  tags = {
    Name = "django-instance"
  }
}


# Output the public DNS of the EC2 instance
output "public_dns" {
  value = aws_instance.django_instance.public_dns
}
