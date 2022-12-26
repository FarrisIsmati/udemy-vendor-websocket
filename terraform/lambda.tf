# Note AWS_REGION is a reserved key that cannot be used so adding _name (for env variables)
# Lambda connect
resource "aws_lambda_function" "connect" {
  function_name = "${var.app_name}-connect"
  description   = "Websocket connect adds connection data in dynamodb connection table"
  role          = aws_iam_role.lambda_main.arn
  image_uri     = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/connect:${var.image_tag}"
  package_type = "Image"
  timeout       = 30
  environment {
    variables = {
      AWS_TABLE_NAME = "WebSocketConnections"
      AWS_REGION_NAME = "us-east-1"
    }
  }
}

resource "aws_lambda_permission" "api_gw_main_lambda_connect" { # Provides permission to invoke
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.connect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api_gateway.execution_arn}/*/*"
}

# Lambda disconnect
resource "aws_lambda_function" "disconnect" {
  function_name = "${var.app_name}-disconnect"
  description   = "Websocket disconnect removes connection data in dynamodb connection table"
  role          = aws_iam_role.lambda_main.arn
  image_uri     = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/disconnect:${var.image_tag}"
  package_type = "Image"
  timeout       = 30
  environment {
    variables = {
      AWS_TABLE_NAME = "WebSocketConnections"
      AWS_REGION_NAME = "us-east-1"
    }
  }
}


resource "aws_lambda_permission" "api_gw_main_lambda_disconnect" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.disconnect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api_gateway.execution_arn}/*/*"
}


# Lambda send vendor
resource "aws_lambda_function" "sendvendor" {
  function_name = "${var.app_name}-sendvendor"
  description   = "Websocket sends vendor message to api gateway websocket for those connected to recieve"
  role          = aws_iam_role.lambda_main.arn
  image_uri     = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/sendvendor:${var.image_tag}"
  package_type = "Image"
  timeout       = 30
  environment {
    variables = {
      AWS_TABLE_NAME = "WebSocketConnections"
      AWS_REGION_NAME = var.aws_region
      AWS_SQS_URL = "https://sqs.${var.aws_region}.amazonaws.com/${local.account_id}/${var.sqs_queue_name}"
      AWS_WEBSOCKET_URL = "wss://${aws_apigatewayv2_api.api_id}.execute-api.${var.aws_region}.amazonaws.com/${var.stage_name}"
    }
  }
}

# Adds trigger
resource "aws_lambda_event_source_mapping" "sendvendor_sqs_trigger" {
  event_source_arn  = "arn:aws:sqs:${var.aws_region}:${local.account_id}:${var.sqs_queue_name}"
  function_name     = aws_lambda_function.sendvendor.arn
}

resource "aws_lambda_permission" "sendvendor_sqs_trigger" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sendvendor.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = "arn:aws:sqs:${var.aws_region}:${local.account_id}:${var.sqs_queue_name}"
}

# # NO NEED FOR WEBSOCKET TRIGGER BECAUSE IT SHOULD ONLY BE TRIGGERED BY SQS MESSAGE 
# resource "aws_lambda_permission" "api_gw_main_lambda_sendvendor" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.sendvendor.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_apigatewayv2_api.websocket_api_gateway.execution_arn}/*/*"
# }
