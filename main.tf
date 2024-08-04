resource "aws_api_gateway_rest_api" "this" {
  name               = var.apigw_name
  binary_media_types = ["application/json"]
  tags               = var.tags
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "this" {
  for_each    = var.resources
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value.resource_path
  rest_api_id = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_method" "this" {
  for_each         = var.resources
  authorization    = var.authorization
  http_method      = each.value.http_method
  resource_id      = aws_api_gateway_resource.this[each.value.resource_path].id
  rest_api_id      = aws_api_gateway_rest_api.this.id
  api_key_required = var.api_key_required
  depends_on       = [aws_api_gateway_resource.this]
}

resource "aws_api_gateway_integration" "this" {
  for_each                = var.resources
  http_method             = aws_api_gateway_method.this[each.value.resource_path].http_method
  resource_id             = aws_api_gateway_resource.this[each.value.resource_path].id
  rest_api_id             = aws_api_gateway_rest_api.this.id
  type                    = each.value.integration_type
  uri                     = data.aws_lambda_function.lambda[each.value.resource_path].invoke_arn
  integration_http_method = each.value.integration_http_method #aws_api_gateway_method.this[each.value.resource_path].http_method
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  # request_templates = {
  #   "application/json" = ""
  #   "application/xml"  = "#set($inputRoot = $input.path('$'))\n{ }"
  # }

  request_templates = {
    "application/json" = <<EOF
##  See https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-mapping-template-reference.html
##  This template will pass through all parameters including path, querystring, header, stage variables, and context through to the integration endpoint via the body/payload
#set($allParams = $input.params())
{
"content": "$input.body",
"body-json" : $input.json('$'),
"params" : {
#foreach($type in $allParams.keySet())
    #set($params = $allParams.get($type))
"$type" : {
    #foreach($paramName in $params.keySet())
    "$paramName" : "$util.escapeJavaScript($params.get($paramName))"
        #if($foreach.hasNext),#end
    #end
}
    #if($foreach.hasNext),#end
#end
},
"stage-variables" : {
#foreach($key in $stageVariables.keySet())
"$key" : "$util.escapeJavaScript($stageVariables.get($key))"
    #if($foreach.hasNext),#end
#end
},
"context" : {
    "account-id" : "$context.identity.accountId",
    "api-id" : "$context.apiId",
    "api-key" : "$context.identity.apiKey",
    "authorizer-principal-id" : "$context.authorizer.principalId",
    "caller" : "$context.identity.caller",
    "cognito-authentication-provider" : "$context.identity.cognitoAuthenticationProvider",
    "cognito-authentication-type" : "$context.identity.cognitoAuthenticationType",
    "cognito-identity-id" : "$context.identity.cognitoIdentityId",
    "cognito-identity-pool-id" : "$context.identity.cognitoIdentityPoolId",
    "http-method" : "$context.httpMethod",
    "stage" : "$context.stage",
    "source-ip" : "$context.identity.sourceIp",
    "user" : "$context.identity.user",
    "user-agent" : "$context.identity.userAgent",
    "user-arn" : "$context.identity.userArn",
    "request-id" : "$context.requestId",
    "resource-id" : "$context.resourceId",
    "resource-path" : "$context.resourcePath"
    }
}
  EOF
  }
}

data "aws_lambda_function" "lambda" {
  for_each      = var.resources
  function_name = each.value.lambda_function
}

resource "aws_api_gateway_method_response" "response_200" {
  for_each    = var.resources
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this[each.value.resource_path].id
  http_method = aws_api_gateway_method.this[each.value.resource_path].http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "this" {
  for_each    = var.resources
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this[each.value.resource_path].id
  http_method = aws_api_gateway_method.this[each.value.resource_path].http_method
  status_code = aws_api_gateway_method_response.response_200[each.value.resource_path].status_code
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
  for_each      = var.resources
  statement_id  = "AllowExecApiGWFor${each.value.lambda_function}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function
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
  count = (var.is_waf_enable == true ? 1 : 0)
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