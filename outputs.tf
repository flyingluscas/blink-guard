output "admin_dashboard_url" {
  value = "http://${module.blink_guard_wireguard.ecs_instance.public_ip}"
}
