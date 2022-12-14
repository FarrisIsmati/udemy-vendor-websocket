# Create CloudWatch Log Groups so we can set default retentions
# THIS MIGHT BE DELETED NOT NECESSARY? No logs get added to this
# Okay maybe they're needed?
resource "aws_cloudwatch_log_group" "api_gw_ws" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.websocket_api_gateway.name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "api_gw_http" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.http_api_gateway.name}"
  retention_in_days = 7
}

# Manually create a log group for your lambdas if it doesn't get made
resource "aws_cloudwatch_log_group" "lambda_getvendors" {
  name              = "/aws/lambda/${var.app_name}-getvendors"
  retention_in_days = 7
}