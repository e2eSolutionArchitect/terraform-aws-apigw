output "id" {
  value       = try(aws_api_gateway_rest_api.this.id, "")
  description = "aws_api_gateway_rest_api id"
}

output "arn" {
  value       = try(aws_api_gateway_rest_api.this.arn, "")
  description = "aws_api_gateway_rest_api arn"
}


output "execution_arn" {
  value       = try(aws_api_gateway_rest_api.this.execution_arn, "")
  description = "aws_api_gateway_rest_api execution_arn"
}

output "api_key" {
  value       = try(aws_api_gateway_api_key.api_key.id, "")
  description = "aws_api_gateway_api_key.api_key.id"
}
