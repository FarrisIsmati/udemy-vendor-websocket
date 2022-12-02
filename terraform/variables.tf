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

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "sqs_name" {
  type        = string
  description = "Name of queue"
  default     = "udemy-twitter-queue"
}

variable "image_tag" {}
