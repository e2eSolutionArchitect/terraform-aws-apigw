# -------------------------------------------
# Common Variables
# -------------------------------------------


variable "tags" {
  description = "Tag map for the resource"
  type        = map(string)
  default     = {}
}


variable "apigw_name" {
  description = "API GW Name"
  type        = string
  default     = null
}

variable "api_key_name" {
  description = "api_key_name"
  type        = string
  default     = null
}

variable "api_key_type" {
  description = "api_key_type"
  type        = string
  default     = null
}

variable "authorization" {
  description = "authorization"
  type        = string
  default     = null #COGNITO_USER_POOLS
}

variable "path_part" {
  description = "path_part"
  type        = string
  default     = null
}

variable "stage_name" {
  description = "stage_name"
  type        = string
  default     = "dev"
}


variable "apigw_method_path_all" {
  description = "apigw_method_path_all"
  type        = string
  default     = null
}

variable "http_method" {
  description = "http_method"
  type        = string
  default     = null
}

variable "integration_type" {
  description = "integration_type"
  type        = string
  default     = null #"MOCK", AWS_PROXY
}

variable "integration_http_method" {
  description = "integration_http_method"
  type        = string
  default     = null
}


variable "lambda_function_name" {
  description = "lambda_function_name"
  type        = string
  default     = null
}

variable "api_key_required" {
  type    = bool
  default = false
}

variable "apigw_metrics_enabled" {
  description = "apigw_metrics_enabled"
  type        = bool
  default     = false
}

variable "apigw_logging_level" {
  description = "apigw_logging_level"
  type        = string
  default     = null
}

variable "usage_plan_name" {
  description = "usage_plan_name"
  type        = string
  default     = null
}


variable "web_acl_name" {
  description = "web_acl_name"
  type        = string
}
variable "waf_scope" {
  description = "waf_scope"
  type        = string
  default     = "REGIONAL" # expected scope to be one of ["CLOUDFRONT" "REGIONAL"]
}

variable "webacl_web_acl_cloudwatch_metrics_enabled" {
  description = "webacl_web_acl_cloudwatch_metrics_enabled"
  type        = bool
  default     = false
}

variable "metric_name" {
  description = "metric_name"
  type        = string
}

variable "webacl_sampled_requests_enabled" {
  description = "webacl_sampled_requests_enabled"
  type        = bool
  default     = false
}