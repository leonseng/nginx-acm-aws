variable "region" {
  description = "Region to deploy AWS resources in"
  type        = string
  default     = "ap-southeast-2"
}

variable "acm_ami" {
  description = "AMI ID for NGINX ACM Management instance"
  type        = string
}

variable "apigw_ami" {
  description = "AMI ID for NGINX API gateway instances"
  type        = string
}

variable "apigw_count" {
  description = "Number of NGINX API gateway instances to be deployed"
  type        = number
  default     = 2
}

variable "devportal_ami" {
  description = "AMI ID for NGINX Dev Portal instance"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key to be loaded onto all EC2 instances for SSH access"
  type        = string
}

variable "resource_tags" {
  description = "Additional tags to add to resources created by Terraform"
  type        = map(any)
  default = {
    Project = "nginx-nginx-acm"
  }
}

variable "nginx_repo_cert_path" {
  description = "Local path to NGINX repo certificate file."
  type        = string
}

variable "nginx_repo_key_path" {
  description = "Local path to NGINX repo certificate file."
  type        = string
}

variable "nms_admin_password" {
  description = "Admin password for NMS. If unset, a random password is automatically generated."
  type        = string
  sensitive   = true
  default     = ""
}

variable "nms_license_b64" {
  description = "Base64 encoded content of NMS license file. If unset, NMS will not be activated as part of terraform apply."
  type        = string
  sensitive   = true
  default     = ""
}

variable "route53_zone" {
  description = "Existing registered Route53 zone used to configure DNS entries for EC2 instances, e.g. 'example.acm.com.' If unset, no DNS entries will be created."
  type        = string
  default     = ""
}
