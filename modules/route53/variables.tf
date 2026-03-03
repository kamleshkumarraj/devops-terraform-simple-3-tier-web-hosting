variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}

variable "ecommerce_alb_dns" {
  type = string
  description = "The DNS name of the ecommerce ALB"
}

variable "ecommerce_alb_zone_id" {
  type = string
  description = "The zone ID of the ecommerce ALB"
}