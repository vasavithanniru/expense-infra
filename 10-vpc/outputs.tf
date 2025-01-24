output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_sunnet_ids" {
    value = module.vpc.private_subnet_ids
}