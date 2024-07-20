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

variable "resources" {
  description = "resource config map"
  type = map(object({
    resource_path           = string
    http_method             = string
    integration_type        = string
    integration_http_method = string
    lambda_function         = string
  }))
  default = {}
}

variable "method_responses" {
  description = "method_responses"
  type        = map(string)
  default     = {}
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

variable "http_methods" {
  description = "http_methods"
  type        = map(string)
  default     = {}
}

variable "integration_types" {
  description = "integration_types"
  type        = map(string)
  default     = {} #"MOCK", AWS_PROXY
}

variable "integration_http_methods" {
  description = "integration_http_methods"
  type        = map(string)
  default     = {}
}


variable "lambda_functions" {
  description = "lambda_function"
  type        = map(string)
  default     = {}
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

variable "is_waf_enable" {
  description = "is_waf_enable"
  type        = bool
  default     = true
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

variable "domain_name" {
  description = "API GW domain_name"
  type        = string
  default     = null
}