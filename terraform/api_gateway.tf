# Creates the websocket gateway
resource "aws_apigatewayv2_api" "websocket_api_gateway" {
  name                         = "${var.app_name}_websocket"
  description                  = "Send websocket data from twitter service to connected clients"
  protocol_type                = "WEBSOCKET"
  route_selection_expression   = "$request.body.action"
}

# Creates the link between lambda function and gateway
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

# Sets up api stage, required to make calls (used to set up where calls can be made dev/qa/prod)
resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.websocket_api_gateway.id
  name        = var.api_gateway_stage_name
  auto_deploy = true

  # Enables logs for aws/apigateway/udemy-vendor-websocket (I DONT THINK THIS IS NECESSARY MIGHT REMOVE)
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_ws.arn
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

# Creates the http gateway
resource "aws_apigatewayv2_api" "http_api_gateway" {
  name                         = "${var.app_name}_http"
  description                  = "Send vendor data to connected clients"
  protocol_type                = "HTTP"
  cors_configuration { // Allow CORS it's necessary
    allow_origins = ["*"]
    allow_methods = ["POST", "GET", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age = 300
  }
}

# # Enable CORs
# module "cors" {
#   source = "squidfunk/api-gateway-enable-cors/aws"
#   version = "0.3.3"

#   api_id          = aws_apigatewayv2_api.http_api_gateway.
#   api_resource_id = aws_apigatewayv2_api.http_api_gateway.id
# }

# Creates the link between lambda function and gateway
resource "aws_apigatewayv2_integration" "lambda_getvendors" {
  api_id             = aws_apigatewayv2_api.http_api_gateway.id
  integration_uri    = aws_lambda_function.getvendors.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# Forward special requests ($connect, $disconnect) to our Lambda function so we can manage their state 
resource "aws_apigatewayv2_route" "_getvendors" {
  api_id    = aws_apigatewayv2_api.http_api_gateway.id
  route_key = "GET /vendors"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_getvendors.id}"
}

# Sets up api stage, required to make calls (used to set up where calls can be made dev/qa/prod)
resource "aws_apigatewayv2_stage" "http_main" {
  api_id      = aws_apigatewayv2_api.http_api_gateway.id
  name        = var.api_gateway_stage_name
  auto_deploy = true

  # Enables logs for aws/apigateway/udemy-vendor-websocket (I DONT THINK THIS IS NECESSARY MIGHT REMOVE)
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_http.arn
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


