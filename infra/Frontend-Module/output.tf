
output "Public_IP" {
  value = module.sahaba-gcp-Frontend.load_balancer_ip
}

output "bucket_name" {
  value = module.sahaba-gcp-Frontend.bucket_name 
}