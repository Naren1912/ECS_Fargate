aws_region = "ap-southeast-1"

VpcId = "x567hhdz"
PublicSubnetIds = {"pub--7eqwhyn6rn", "pub--54wxuuz4yz", "pub--y5wdouvoar"}
PrivateSubnetIds = {"priv--whyn6rn7eq", "priv--uuz4yz54wx", "priv--uvoary5wdo"}
Route53HostedZoneId = "xcf4435z"
Route53HostedZoneName = "mmt_tech_test_zone"
AcmCertificateArn = "arn:aws:acm:eu-west-1:8877665544:certificate/123456789012-1234-1234-1234-12345678"

# Input from SSM paramter store
VpcIdSSM = /mmt/vpc/vpc_id
PrivateSubnetIdsSSM = /mmt/subnets/private/subnet-ids
PublicSubnetIdsSSM = /mmt/subnets/public/subnet-ids
Route53HostedZoneIdSSM = /mmt/dns/r53_zone_id
Route53HostedZoneNameSSM = /mmt/dns/r53_zone_name
AcmCertificateArnSSM = /mmt/acm/tech_test_ssl_arn

#env_type = "prod" # default 'dev'
