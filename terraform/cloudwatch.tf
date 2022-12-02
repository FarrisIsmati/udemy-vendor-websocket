# Create CloudWatch Log Groups so we can set default retentions
resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.websocket_api_gateway.name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "lambda_main" {
  name              = "/aws/lambda/${var.app_name}"
  retention_in_days = 7
}