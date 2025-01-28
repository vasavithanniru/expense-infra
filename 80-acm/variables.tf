variable "environment" {
    default = "dev"
}

variable "project_name" {
  default = "expense"
}

variable "common_tags" {
  default = {
    Environment = "dev"
    Project = "exense"
    Terraform = "true"
  }
}


variable "zone_name" {
  default = "vasavi.online"
}

variable "zone_id" {
  default = "Z04805221YTNAM0LILIIJ"
}