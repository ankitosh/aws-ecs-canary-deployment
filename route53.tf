resource "aws_route53_zone" "myzone" {
  name = "${var.domain_name}"
}

resource "aws_route53_record" "blue" {
  zone_id = "${aws_route53_zone.myzone.zone_id}"
  name    = "blue.1.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_alb.blue-lb.dns_name}"
    zone_id                = "${aws_alb.blue-lb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "green" {
  zone_id = "${aws_route53_zone.myzone.zone_id}"
  name    = "green.1.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_alb.blue-lb.dns_name}"
    zone_id                = "${aws_alb.blue-lb.zone_id}"
    evaluate_target_health = true
  }
}
