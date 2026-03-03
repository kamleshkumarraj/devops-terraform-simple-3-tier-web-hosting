resource "aws_route53_zone" "viharfood_zone" {
  name = "viharfood.in"
  tags = local.hosted_zone_tags
}

resource "aws_route53_record" "ecommerce_alb" {
  zone_id = aws_route53_zone.viharfood_zone.zone_id
  name    = "ecommerce.viharfood.in"
  type    = "A"

  alias {
    name                   = var.ecommerce_alb_dns
    zone_id                = var.ecommerce_alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ecommerce_api_alb" {
  zone_id = aws_route53_zone.viharfood_zone.zone_id
  name    = "api.ecommerce.viharfood.in"
  type    = "A"

  alias {
    name                   = var.ecommerce_alb_dns
    zone_id                = var.ecommerce_alb_zone_id
    evaluate_target_health = true
  }
}