
variable "region" {
  description = "AWS region for hosting our your network"
  default     = "us-east-1"
}
variable "public_key_path" {
  description = "Enter the path to the SSH Public Key to add to AWS."
  default     = "/Users/ibz/Downloads/ANDDigital.pem"
}
variable "key_name" {
  description = "Key name for SSHing into EC2"
  default     = "ANDDigital"
}

variable "amis" {
  description = "Base AMI to launch the instances"
  default = {
    us-east-1 = "ami-0947d2ba12ee1ff75"
  }
}

variable "instance_type" {
  description = "Enter the machine being used"
  default = "t2.micro"
}