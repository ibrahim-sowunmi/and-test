### prints the ids of the EC2 instances
output "instance_ids" {
    value = ["${aws_instance.public.*.public_ip}"]
}

### Produces the link for the ELB

output "elb_dns_name" {
  value = "${aws_elb.example.dns_name}"
}