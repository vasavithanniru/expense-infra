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

variable "backend_tags" {
    default = {
        Component = "backend"
    }
  
}