data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-ecs-hvm-*-kernel-6.1-x86_64"]
  }
}

data "aws_iam_policy_document" "assume_ecs_instance_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ec2_container_service_role_policy" {
  name = "AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role" "ecs_instance_role" {
  name               = "${var.name}-ecs-instance-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs_instance_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = data.aws_iam_policy.ec2_container_service_role_policy.arn
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.name}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_security_group" "blink_guard" {
  name        = var.name
  description = "Allow wireguard traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "udp"
    cidr_blocks = var.allowed_peers_ip
  }

  ingress {
    from_port   = var.web_ui_port
    to_port     = var.web_ui_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_admins_ip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ecs_instance" {
  ami                  = data.aws_ami.ecs_ami.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name
  security_groups      = [aws_security_group.blink_guard.id]
  subnet_id            = var.public_subnet_id
  source_dest_check    = false

  user_data = base64encode(templatefile("${path.module}/ecs-instance-user-data.sh.tftpl", {
    cluster_name = aws_ecs_cluster.blink_guard.name
  }))

  tags = {
    Name = "${var.name}-ecs-instance"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp2"
  }

  depends_on = [aws_ecs_cluster.blink_guard]
}
