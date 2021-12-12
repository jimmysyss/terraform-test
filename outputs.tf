# output "url" {
#   value = cloudflare_record.www.hostname
# }

output "db_hostname" {
  value = module.rds.db_instance_address
}
