output "alb_dns" {
    value = "${aws_alb.blue-lb.dns_name}"
}

# output "rds_db" {
#   value = "${aws_db_instance.default.address}"
# }
