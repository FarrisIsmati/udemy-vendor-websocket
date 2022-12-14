# This assume_role_policy data source, grants an entity permission to assume the role
# This is to generate temp credentials to act with the privileges granted by the access policies associated with that role
# This is so the resource can assume it's role with my temp credentials sts in this case, it can make calls on my behalf
# Note: you cannot use a normal aws_iam_policy resource for this but can use a data source

# Role 1 - Lambda Role
data "aws_iam_policy_document" "lambda_fn_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "lambda_main" {
  name               = "${var.app_name_generic}-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_fn_assume_role.json 
}

# Policy 1 - Basic lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_main" {
  role       = aws_iam_role.lambda_main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Policy 2 - Lambda WS & Dynamodb, & SQS connection
data "aws_iam_policy_document" "lambda_ws" {
  # Send a message to Websocket clients via "execute-api", a component of API Gateway
  statement {
    effect = "Allow"
    actions = [
      "execute-api:ManageConnections",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      "arn:aws:sqs:${var.aws_region}:${local.account_id}:${var.sqs_queue_name}",
      "${aws_apigatewayv2_api.websocket_api_gateway.execution_arn}/*",
      "arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/${var.websocket_table_name}",
      "arn:aws:dynamodb:${var.aws_region}:${local.account_id}:table/${var.dynamodb_vendor_table_name}"
    ]
  }
}

resource "aws_iam_policy" "lambda_ws" {
  name        = "${var.app_name}-lambda_ws"
  description = "Websocket lambda functions can communicate with Dynamodb and api gateway to perform actions"
  policy      = data.aws_iam_policy_document.lambda_ws.json
}

resource "aws_iam_role_policy_attachment" "lambda_ws" {
  policy_arn = aws_iam_policy.lambda_ws.arn
  role       = aws_iam_role.lambda_main.name
}
