resource "aws_apigatewayv2_api" "udemyvendorapigateway" {
  name                       = "udemy-vendor-we"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_api" "websocket_api_gateway" {
  name                         = "${var.app_name}"
  description                  = "Send websocket data from twitter service to connected clients"
  protocol_type                = "WEBSOCKET"
  route_selection_expression   = "$request.body.action"
}

resource "aws_apigatewayv2_integration" "websocket_integration" {
    api_id                                    = aws_apigatewayv2_api.websocket_api_gateway.id
    connection_type                           = "INTERNET"
    credentials_arn                           = aws_iam_role.websocket_task_execution_role.arn
    integration_method                        = "POST"
    integration_type                          = "AWS"
    integration_uri                           = "arn:aws:apigateway:${var.aws_region}:sqs:path/${local.account_id}/${var.sqs_name}"
    passthrough_behavior                      = "NEVER"
    request_parameters                        = {
        "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
    }
    request_templates                         = {
        "$default" = "Action=SendMessage&MessageGroupId=$input.path('$.MessageGroupId')&MessageDeduplicationId=$context.requestId&MessageAttribute.1.Name=connectionId&MessageAttribute.1.Value.StringValue=$context.connectionId&MessageAttribute.1.Value.DataType=String&MessageAttribute.2.Name=requestId&MessageAttribute.2.Value.StringValue=$context.requestId&MessageAttribute.2.Value.DataType=String&MessageBody=$input.json('$')"
    }
    template_selection_expression             = "\\$default"
    timeout_milliseconds                      = 29000
    depends_on = [
    aws_iam_role.websocket_task_execution_role,  
    ]
}

resource "aws_apigatewayv2_stage" "production" {
  api_id          = aws_apigatewayv2_api.udemyvendorapigateway.id
  name            = "production"
  auto_deploy     = true
}

resource "aws_apigatewayv2_route" "default" {
    api_id               = aws_apigatewayv2_api.udemyvendorapigateway.id
    route_key            = "$default"
    target               = "integrations/${aws_apigatewayv2_integration.websocket_integration.id}"  
}









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