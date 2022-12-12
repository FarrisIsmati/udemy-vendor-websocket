resource "aws_lambda_function" "connect" {
  function_name = "${var.app_name}-connect"
  description   = "Websocket connect store data in dynamodb"
  role          = aws_iam_role.lambda_main.arn
  handler       = "aws_simple_websocket.handler.handler"
  image_uri     = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/connect:${var.image_tag}"
  package_type = "image"
  timeout       = 10

  # For terraform but shouldn't matter because container is in 16
  runtime       = "nodejs14.x"
}
