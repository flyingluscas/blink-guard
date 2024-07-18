variable "name" {
  type    = string
  default = "blink-guard"
}

variable "timezone" {
  type    = string
  default = "America/Sao_Paulo"
}

variable "port" {
  type    = number
  default = 51820
}

variable "web_ui_port" {
  type    = number
  default = 80
}

variable "peers" {
  type    = list(string)
  default = ["desktop", "phone"]
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "allowed_peers_ip" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "allowed_admins_ip" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "lang" {
  type    = string
  default = "en"
}

variable "web_ui_password" {
  type      = string
  default   = "admin"
  sensitive = true
}
