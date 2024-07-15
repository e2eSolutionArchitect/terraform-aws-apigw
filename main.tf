resource "aws_api_gateway_rest_api" "this" {
  name = var.apigw_name
  tags = var.tags
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "this" {
  for_each    = var.resource_paths
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value
  rest_api_id = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_method" "this" {
  for_each         = var.http_methods
  authorization    = var.authorization
  http_method      = each.value
  resource_id      = aws_api_gateway_resource.this.id
  rest_api_id      = aws_api_gateway_rest_api.this.id
  api_key_required = var.api_key_required
  depends_on       = [aws_api_gateway_resource.this]
}

resource "aws_api_gateway_integration" "this" {
  for_each                = var.integration_types
  http_method             = aws_api_gateway_method.this.http_methods
  resource_id             = aws_api_gateway_resource.this.id
  rest_api_id             = aws_api_gateway_rest_api.this.id
  type                    = each.value
  uri                     = data.aws_lambda_function.lambda.invoke_arn
  integration_http_method = aws_api_gateway_method.this.http_methods
}

data "aws_lambda_function" "lambda" {
  for_each      = var.lambda_functions
  function_name = each.value
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_methods
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_methods
  status_code = aws_api_gateway_method_response.response_200.status_code
  depends_on = [aws_api_gateway_integration.this
  ]
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  depends_on  = [aws_api_gateway_method.this, aws_api_gateway_integration.this]
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = var.apigw_method_path_all
  settings {
    metrics_enabled = var.apigw_metrics_enabled
    logging_level   = var.apigw_logging_level
  }
}

# Lambda Integration

resource "aws_lambda_permission" "permission" {
  for_each      = var.lambda_functions
  statement_id  = "AllowExecApiGWFor${each.value}"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = var.usage_plan_name
  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = aws_api_gateway_stage.this.stage_name
  }
}

resource "aws_api_gateway_api_key" "api_key" {
  name = var.api_key_name
}

resource "aws_api_gateway_usage_plan_key" "plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = var.api_key_type
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}

resource "aws_wafv2_web_acl" "this" {
  name  = var.web_acl_name
  scope = var.waf_scope
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 1

    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = var.webacl_web_acl_cloudwatch_metrics_enabled
      metric_name                = var.metric_name
      sampled_requests_enabled   = var.webacl_sampled_requests_enabled
    }
  }

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = var.webacl_web_acl_cloudwatch_metrics_enabled
    metric_name                = var.metric_name
    sampled_requests_enabled   = var.webacl_sampled_requests_enabled
  }

}