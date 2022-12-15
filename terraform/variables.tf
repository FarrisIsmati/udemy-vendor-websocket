variable "app_name" {
  type        = string
  description = "Application Name"
  default     = "udemy-vendor-websocket"
}

variable "app_name_generic" {
  type        = string
  description = "Application Name"
  default     = "udemy-vendor"
}

variable "sqs_name" {
  type        = string
  description = "Name of queue"
  default     = "udemy-twitter-queue"
}

variable "websocket_table_name" {
  type        = string
  description = "Name of the web socket connection table in dynamo db"
  default     = "WebSocketConnections"
}

variable "aws_region" {}

variable "image_tag" {}
