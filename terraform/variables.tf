variable "region" {
  description = "Region to deploy AWS resources in"
  type        = string
  default     = "ap-southeast-2"
}

variable "ssh_public_key" {
  description = "SSH public key to be added onto all EC2 instances"
  type        = string
}

variable "owner" {
  description = "Name of owner of created resource"
  type        = string
}

variable "apim_ami" {
  description = "AMI ID for NGINX API Management instance"
  type        = string
}

variable "apim_nms_admin_password" {
  description = "Admin password for NMS"
  type        = string
  sensitive   = true
}

variable "apim_nms_lic_b64" {
  description = "Base64 encoded content of NMS-NIM license file"
  type        = string
  sensitive   = true
}

variable "apigw_ami" {
  description = "AMI ID for NGINX API gateway instance"
  type        = string
}


variable "devportal_ami" {
  description = "AMI ID for NGINX Dev Portal instance"
  type        = string
}
