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

# resource "aws_apigatewayv2_integration" "lambda_sendvendor" {
#   api_id             = aws_apigatewayv2_api.websocket_api_gateway.id
#   integration_uri    = aws_lambda_function.sendvendor.invoke_arn
#   integration_type   = "AWS_PROXY"
#   integration_method = "POST"
# }

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

# resource "aws_apigatewayv2_route" "_sendvendor" {
#   api_id    = aws_apigatewayv2_api.websocket_api_gateway.id
#   route_key = "$default"
#   target    = "integrations/${aws_apigatewayv2_integration.lambda_sendvendor.id}"
# }

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





# Create 3 routes
# Create 3 lambda integrations


# resource "aws_apigatewayv2_route" "default" {
#     api_id               = aws_apigatewayv2_api.udemyvendorapigateway.id
#     route_key            = "$default"
#     target               = "integrations/${aws_apigatewayv2_integration.websocket_integration.id}"  
# }









# #========================================================================
# // lambda setup
# #========================================================================

# resource "aws_lambda_function" "lambda_sqs_websocket_response" {
#     function_name                  = "${var.lambda_name}-${random_string.random.id}"
#     description                    = "serverlessland pattern"
#     s3_bucket                      = aws_s3_bucket.lambda_bucket.id
#     s3_key                         = aws_s3_object.lambda.key
#     source_code_hash               = data.archive_file.lambda_source.output_base64sha256
#     runtime                        = "python3.8"
#     handler                        = "app.lambda_handler"
#     role                           = aws_iam_role.lambda_execution.arn
#     timeout                        = 15

#     environment {
#         variables = {
#             "ApiGatewayEndpoint" = "https://${aws_apigatewayv2_api.my_websocket_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_apigatewayv2_stage.production.name}"
#         }
#     }

#     timeouts {}

#     tracing_config {
#         mode = "PassThrough"
#     }
#     depends_on = [aws_cloudwatch_log_group.lambda_logs, aws_apigatewayv2_stage.production]
# }

# resource "aws_cloudwatch_log_group" "lambda_logs" {
#   name = "/aws/lambda/${var.lambda_name}-${random_string.random.id}"

#   retention_in_days = var.lambda_log_retention
# }


# resource "aws_lambda_event_source_mapping" "apigwy_sqs" {
#     event_source_arn = aws_sqs_queue.fifo_queue.arn
#     function_name    = aws_lambda_function.lambda_sqs_websocket_response.arn
# }

# // S3 for Lambda
# resource "aws_s3_bucket" "lambda_bucket" {
#   bucket_prefix = var.s3_bucket_prefix
#   force_destroy = true
# }

# resource "aws_s3_bucket_acl" "private_bucket" {
#   bucket = aws_s3_bucket.lambda_bucket.id
#   acl    = "private"
# }

# data "archive_file" "lambda_source" {
#   type = "zip"
#   source_dir  = "${path.module}/src"
#   output_path = "${path.module}/src.zip"
# }

# resource "aws_s3_object" "lambda" {
#   bucket = aws_s3_bucket.lambda_bucket.id
#   key    = "source.zip"
#   source = data.archive_file.lambda_source.output_path
#   etag = filemd5(data.archive_file.lambda_source.output_path)
# }
