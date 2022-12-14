resource "aws_apigatewayv2_api" "websocket_api_gateway" {
  name                         = "${var.app_name}"
  description                  = "Send websocket data from twitter service to connected clients"
  protocol_type                = "WEBSOCKET"
  route_selection_expression   = "$request.body.action"
}

resource "aws_apigatewayv2_integration" "lambda_connect" {
  api_id             = aws_apigatewayv2_api.websocket_api_gateway.id
  integration_uri    = aws_lambda_function.connect.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "lambda_disconnect" {
  api_id             = aws_apigatewayv2_api.websocket_api_gateway.id
  integration_uri    = aws_lambda_function.disconnect.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "lambda_sendvendor" {
  api_id             = aws_apigatewayv2_api.websocket_api_gateway.id
  integration_uri    = aws_lambda_function.sendvendor.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# Forward special requests ($connect, $disconnect) to our Lambda function so we can manage their state 
resource "aws_apigatewayv2_route" "_connect" {
  api_id    = aws_apigatewayv2_api.websocket_api_gateway.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_connect.id}"
}

resource "aws_apigatewayv2_route" "_disconnect" {
  api_id    = aws_apigatewayv2_api.websocket_api_gateway.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_disconnect.id}"
}

resource "aws_apigatewayv2_route" "_sendvendor" {
  api_id    = aws_apigatewayv2_api.websocket_api_gateway.id
  route_key = "sendvendor"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_sendvendor.id}"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id      = aws_apigatewayv2_api.websocket_api_gateway.id
  name        = "primary"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
}

# Allow the API Gateway to invoke Lambda function
resource "aws_lambda_permission" "api_gw_main_lambda_main" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.connect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api_gateway.execution_arn}/*/*"
}
