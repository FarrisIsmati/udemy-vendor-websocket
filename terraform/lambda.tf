resource "aws_lambda_function" "connect" {
  function_name = "${var.app_name}-connect"
  description   = "Websocket connect store data in dynamodb"
  handler       = "aws_simple_websocket.handler.handler"
  role          = aws_iam_role.lambda_main.arn
  runtime       = "nodejs12.x"
  timeout       = 10
  package_type = "Image"
  image_uri     = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/connect:${var.image_tag}"

  lifecycle {
    ignore_changes = [image_uri]
  }
}
