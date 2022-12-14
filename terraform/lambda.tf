resource "aws_lambda_function" "connect" {
  function_name = "${var.app_name}-connect"
  description   = "Websocket connect adds connection data in dynamodb connection table"
  role          = aws_iam_role.lambda_main.arn
  image_uri     = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/connect:${var.image_tag}"
  package_type = "Image"
  timeout       = 10
}

resource "aws_lambda_function" "disconnect" {
  function_name = "${var.app_name}-disconnect"
  description   = "Websocket disconnect removes connection data in dynamodb connection table"
  role          = aws_iam_role.lambda_main.arn
  image_uri     = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/disconnect:${var.image_tag}"
  package_type = "Image"
  timeout       = 10
}

resource "aws_lambda_function" "sendvendor" {
  function_name = "${var.app_name}-sendvendor"
  description   = "Websocket sends vendor message to api gateway websocket for those connected to recieve"
  role          = aws_iam_role.lambda_main.arn
  image_uri     = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/sendvendor:${var.image_tag}"
  package_type = "Image"
  timeout       = 10
}
