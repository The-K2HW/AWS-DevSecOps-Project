############################################
# AMI Lookup for Amazon Linux 
############################################

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

############################################
# Launch Template for EC2 instances
############################################

resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.al2023.image_id
  instance_type = "t3.micro"
  key_name      = "bastion-key"

  # Least-privilege EC2 role
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  metadata_options {
    http_tokens               = "required"  
    http_endpoint             = "enabled"
    http_put_response_hop_limit = 1
  }

  # Cloud-init user data to install stack and deploy app 
  user_data = base64encode(<<-EOF
        #!/bin/bash
        set -xe

        # Basic updates and packages
        dnf -y update --allowerasing
        dnf -y install httpd php php-cli php-mysqlnd php-json git unzip --allowerasing

        # Install SSM Agent
        dnf -y install amazon-ssm-agent
        systemctl enable amazon-ssm-agent
        systemctl start amazon-ssm-agent

        # Enable and start Apache
        systemctl enable httpd
        systemctl start httpd

        # Install Composer
        curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
        php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
            
        # Deploy application
        cd /var/www
        rm -rf html
        mkdir -p html
        cd /var/www/html

        # Pull your app from GitHub
        git clone --branch ${var.app_repo_branch} ${var.app_repo_url} /tmp/app
        # Ensure vendor dir exists and install AWS SDK for PHP
        # (your app code calls 'require aws-autoloader.php', which comes from this package)
        cp -r /tmp/app/app/* /var/www/html/
        cd /var/www/html
        composer require aws/aws-sdk-php --no-progress --no-interaction

        # Permissions for Apache
        chown -R apache:apache /var/www/html
        find /var/www/html -type d -exec chmod 755 {} \\;
        find /var/www/html -type f -exec chmod 644 {} \\;

        # Restart Apache after deployment
        systemctl restart httpd
    EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-app"
    }
  }
}

############################################
# Target Group For ALB 
############################################

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.project_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/index.php"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

############################################
# ALB (public)
############################################

resource "aws_lb" "app_alb" {
  # trivy:ignore:AVD-AWS-0106
  # justification: This ALB is intentionally public to serve HTTP/HTTPS traffic for the web application.

  name               = "${var.project_name}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  internal = false
  drop_invalid_header_fields = true
  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  tags = {
    Name = "${var.project_name}-alb"
  }
}

############################################
# HTTPS Listener and HTTP redirect
############################################

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = "arn:aws:acm:us-east-1:430286381815:certificate/71066e24-9cc8-4962-80a8-42b816690c07"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

############################################
# Auto Scaling Group (private subnet)
############################################

resource "aws_autoscaling_group" "app_asg" {
  name             = "${var.project_name}-asg"
  max_size         = 2
  min_size         = 1
  desired_capacity = 1
  vpc_zone_identifier = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  health_check_type         = "EC2"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

############################################
# Output : ALB DNS NAME
############################################

output "alb_dn_name" {
  description = "Public DNS name of ALB"
  value       = aws_lb.app_alb.dns_name
}