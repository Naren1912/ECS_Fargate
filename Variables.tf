variable "aws_region" {
    description = "AWS Region"
}

variable "VpcId" {
    description = "Main VPC"
}

variable "PublicSubnetIds" {
  type = map(string)
}

variable "PrivateSubnetIds" {
  type = map(string)
}

variable "Route53HostedZoneId" {
  type = map(string)
}

variable "Route53HostedZoneName" {
  type = list(string)
}

variable "AcmCertificateArn" {
  type = list(string)
}
