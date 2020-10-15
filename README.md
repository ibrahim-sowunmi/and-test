# and-test

I did manage to spin up two instances, that autoscale across availability zones with an ELB but I can't seem to be able to produce healthy instances unfortunately. I've also left comments on the code. The VPC goes into default subnets. The host is linux running apache. I attempted to use my personal website as the ELB domain ended up deleting my website (and its s3) with terraform destroy! Lessons learnt!
