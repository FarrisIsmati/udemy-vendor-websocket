# Two app names incase one has a variable ending for udemy-vendor
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

variable "sqs_queue_name" {
  type        = string
  description = "Queue name"
  default     = "udemy-twitter-queue"
}

variable "aws_region" {
    type        = string
    description = "aws region"
    default     = "us-east-1"
}

variable "api_gateway_stage_name" {
    type        = string
    description = "dev stagename (could add more)"
    default     = "primary"
}

variable "image_tag" {}
