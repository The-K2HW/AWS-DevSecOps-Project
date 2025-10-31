package trivy.ignore

# Ignore public ALB 
ignore[reason] {
  input.resource_type == "aws_lb"
  input.attributes.internal == false
  input.attributes.https_listener == true
  reason := "Public ALB with HTTPS is allowed by design."
}

# Ignore HTTP listener without HTTPS 
ignore[reason] {
  input.resource_type == "aws_lb_listener"
  input.resource_name == "http_listener"
  input.rule_id == "AVD-AWS-0054"
  reason := "HTTP-only ALB listener intentionally used for educational lab; HTTPS termination is out of scope."
}
