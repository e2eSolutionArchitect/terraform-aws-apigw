
resource "aws_acm_certificate_validation" "cert" {
  count           = (var.domain_name != null && var.domain_name != "null") ? 1 : 0
  certificate_arn = data.aws_acm_certificate.issued[count.index].arn
}

resource "aws_api_gateway_domain_name" "domain" {
  count                    = (var.domain_name != null && var.domain_name != "null") ? 1 : 0
  regional_certificate_arn = aws_acm_certificate_validation.cert[count.index].certificate_arn
  domain_name              = var.domain_name
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Find a certificate that is issued
data "aws_acm_certificate" "issued" {
  count    = (var.domain_name != null && var.domain_name != "null") ? 1 : 0
  domain   = var.domain_name
  statuses = ["ISSUED"]
}



resource "aws_api_gateway_base_path_mapping" "mapping" {
  count       = (var.domain_name != null && var.domain_name != "null") ? 1 : 0
  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = aws_api_gateway_domain_name.domain[count.index].domain_name
}