# API Gateway
resource "aws_iam_role" "websocket_task_execution_role" {
  name               = "${var.app_name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name             = "${var.app_name}-iam-role"
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "websocket_sqs_recieve_message" {
  name = "${var.app_name}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sqs:ReceiveMessage",
            "Resource": "arn:aws:sqs:${var.aws_region}:${local.account_id}:${var.sqs_name}",
            "Effect": "Allow"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "websocket_policy" {
  role       = aws_iam_role.websocket_task_execution_role.name
  policy_arn = aws_iam_policy.websocket_sqs_recieve_message.arn
}

# Lambda
resource "aws_iam_role" "lambda_main" {
  name               = "${var.app_name_generic}-lambda-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_fn_assume_role.json
}

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

# Allow lambda to write to CloudFront Logs
resource "aws_iam_role_policy_attachment" "lambda_main" {
  role       = aws_iam_role.lambda_main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# These are our permissions, we are using S3 objects to store the state of our Websockets
data "aws_iam_policy_document" "lambda_rw_connection_store" {
  # Create/Read Websocket connection ID objects
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.connection_store.bucket}/${local.connection_store_prefix}/*",
    ]
  }
  # List all of the Websocket connection ID objects
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.connection_store.bucket}",
    ]
  }

  # Send a message to Websocket clients via "execute-api", a component of API Gateway
  statement {
    effect = "Allow"
    actions = [
      "execute-api:ManageConnections"
    ]
    resources = [
      "${aws_apigatewayv2_api.main.execution_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "lambda_rw_connection_store" {
  name   = local.app_name_full
  policy = data.aws_iam_policy_document.lambda_rw_connection_store.json
}

resource "aws_iam_role_policy_attachment" "lambda_rw_connection_store" {
  policy_arn = aws_iam_policy.lambda_rw_connection_store.arn
  role       = aws_iam_role.lambda_main.name
}

# // IAM Role for lambda
# resource "aws_iam_role" "lambda_execution" {
#   name = "WebsocketApi-${var.lambda_name}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Sid    = ""
#       Principal = {
#         Service = "lambda.amazonaws.com"
#       }
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "lambda_exec_role" {
#   name = "SQSWebsocketResponseServiceRole"

#   policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "execute-api:ManageConnections",
#             "Resource": "${aws_apigatewayv2_stage.production.execution_arn}/POST/*",
#             "Effect": "Allow"
#         },
#         {
#             "Action": [
#                 "sqs:ReceiveMessage",
#                 "sqs:ChangeMessageVisibility",
#                 "sqs:GetQueueUrl",
#                 "sqs:DeleteMessage",
#                 "sqs:GetQueueAttributes"
#             ],
#             "Resource": "arn:aws:sqs:${var.aws_region}:${local.account_id}:${var.sqs_name}",
#             "Effect": "Allow"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "logs:CreateLogGroup",
#                 "logs:CreateLogStream",
#                 "logs:PutLogEvents"
#             ],
#             "Resource": "*"
#         }
#     ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "lambda_policy" {
#   role       = aws_iam_role.lambda_execution.name
#   policy_arn = aws_iam_policy.lambda_exec_role.arn
# }

