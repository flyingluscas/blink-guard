resource "aws_ecs_cluster" "blink_guard" {
  name = var.name
}

resource "aws_ecs_task_definition" "blink_guard" {
  family                   = var.name
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  volume {
    name      = "lib-modules"
    host_path = "/lib/modules"
  }

  container_definitions = jsonencode([
    {
      name  = "wg-easy"
      image = "ghcr.io/wg-easy/wg-easy"
      linuxParameters = {
        capabilities = {
          add = ["NET_ADMIN", "SYS_MODULE"]
        }
        sysctls = {
          "net.ipv4.ip_forward" : "1",
          "net.ipv4.conf.all.src_valid_mark" : "1",
        }
      }
      environment = [
        { name : "LANG", value : var.lang },
        { name : "WG_HOST", value : aws_instance.ecs_instance.public_ip },
        { name : "PASSWORD_HASH", value : bcrypt(var.web_ui_password, 12) },
        { name : "WG_PORT", value : tostring(var.port) },
        { name : "UI_TRAFFIC_STATS", value : "true" },
        { name : "UI_CHART_TYPE", value : "1" },
      ]
      portMappings = [
        {
          containerPort = var.port
          hostPort      = var.port
          protocol      = "udp"
        },
        {
          containerPort = 51821
          hostPort      = var.web_ui_port
          protocol      = "tcp"
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "lib-modules"
          containerPath = "/lib/modules"
        }
      ]
    }
  ])

  depends_on = [aws_instance.ecs_instance]
}

resource "aws_ecs_service" "blink_guard" {
  name            = var.name
  cluster         = aws_ecs_cluster.blink_guard.id
  task_definition = aws_ecs_task_definition.blink_guard.arn
  desired_count   = var.desired_count
  launch_type     = "EC2"
}
