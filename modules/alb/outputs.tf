output aws_lb_listener {
  value       = aws_lb_listener.listener
}

output alb_target_group_arn {
  value       = aws_lb_target_group.target_group.arn
  sensitive   = true
  description = "ALB target group arn"
}
