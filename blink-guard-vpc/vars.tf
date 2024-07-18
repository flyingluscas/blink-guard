variable "name" {
  type    = string
  default = "blink-guard"
}

variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "az" {
  type    = string
  default = "us-east-1a"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.101.0/24"
}
