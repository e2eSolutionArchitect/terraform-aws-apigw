resource "aws_api_gateway_domain_name" "domain" {
  regional_certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
  domain_name              = var.domain_name #"api.domain.com"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Find a certificate that is issued
data "aws_acm_certificate" "issued" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.issued.arn
}

resource "aws_api_gateway_base_path_mapping" "mapping" {
  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = aws_api_gateway_domain_name.domain.domain_name
}