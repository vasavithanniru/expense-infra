variable "environment" {
    default = "dev"
}

variable "project_name" {
    default = "expense"
}

variable "common_tags" {
    default = {
        project = "expense"
        Environment = "dev"
        Terraform = true
    }
}

variable "app_alb_tags" {
    default = {
        Component = "app_alb"
    }
}

variable "zone_name" {
   default = "vasavi.online"
}

