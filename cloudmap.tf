resource "aws_service_discovery_private_dns_namespace" "this" {
  count       = var.allow_private_access ? 1 : 0
  name        = var.name_prefix
  description = "DNS Namespace for ${var.name_prefix}"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "this" {
  count = var.allow_private_access ? 1 : 0

  name = var.ecs_service_container_name

  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.this.0.id
    routing_policy = "MULTIVALUE"

    # NOTE for bridge networks, DNS record type must be SRV
    dns_records {
      ttl  = 60
      type = var.ecs_network_mode == "awsvpc" ? "A" : "SRV"
    }
  }
}

resource "aws_route53_zone_association" "cloudmap" {
  count = var.allow_private_access ? length(var.cloudmap_associate_vpc_ids) : 0

  zone_id = aws_service_discovery_private_dns_namespace.this.0.hosted_zone
  vpc_id  = var.cloudmap_associate_vpc_ids[count.index]
}
