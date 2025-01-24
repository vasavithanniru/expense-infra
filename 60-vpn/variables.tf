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

variable "vpn_tags" {
    default = {
        Component = "vpn"
    }
}


