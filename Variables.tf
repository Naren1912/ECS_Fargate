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



variable "VpcIdSSM" {
    description = "Main VPC"
}

variable "PublicSubnetIdsSSM" {
  type = map(string)
}

variable "PrivateSubnetIdsSSM" {
  type = map(string)
}

variable "Route53HostedZoneIdSSM" {
  type = map(string)
}

variable "Route53HostedZoneNameSSM" {
  type = list(string)
}


variable "AcmCertificateArnSSM" {
  type = list(string)
}
