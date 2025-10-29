package trivy.ignore

# Ignore public ALB
ignore[reason] {
  input.resource_type == "aws_lb"
  input.attributes.internal == false
  input.attributes.https_listener == true
  reason := "Public ALB with HTTPS is allowed by design."
}
