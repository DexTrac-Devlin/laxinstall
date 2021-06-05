## Directions

This project creates a Chainlink node running on an Ubuntu 20.04 EC2 instance using docker. The Chainlink node runs in a private subnet and can be accessed via a bastion host which is also created. The template creates a VPC and associated networking in addition to a private key which is stored in SSM Parameter store.



Accessing the private key

The private key can be downloaded by means of the AWS CLI. You need the private key to initiate a SSH connection from your computer to the EC2 instance.

# print the private key
aws ssm get-parameter --name /bastion/default/private-key --with-decryption | jq -r '.Parameter.Value'
# copy the private key to the clipboard
aws ssm get-parameter --name /bastion/default/private-key --with-decryption | jq -r '.Parameter.Value' | pbcopy
# writing the private key to 'bastion.pem'
aws ssm get-parameter --name /bastion/default/private-key --with-decryption | jq -r '.Parameter.Value' > bastion.pem

Setting up SSH

To setup an SSH connection you need access to the private key. The private key file needs 0600 permission. To login type make create && make ssh or type:

DNSNAME=`sceptre --output json describe-stack-outputs example vpc | jq -r '.[] | select(.OutputKey=="BastionHostPublicDnsName") | .OutputValue'`
ssh -i bastion.pem ec2-user@$DNSNAME
COPY


*special thanks to https://github.com/thodges-gh*
