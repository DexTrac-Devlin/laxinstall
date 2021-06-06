## Directions

This project creates a Chainlink node running on an Ubuntu 20.04 EC2 instance using docker. The Chainlink node runs in a private subnet and can be accessed via a bastion host which is also created. The template creates a VPC and associated networking in addition to a private key which is stored in SSM Parameter store.



## Accessing the private key

The private key can be downloaded by means of the AWS CLI. You need the private key to initiate a SSH connection from your computer to the EC2 instance. Please note that the defualt format in your AWS config needs to be set to json for this to work. You'll need the private key for access to the bastion host and the Chainlink node.

# print the private key
aws ssm get-parameter --name /Chainlink/default/private-key --with-decryption | jq -r '.Parameter.Value'
# copy the private key to the clipboard
aws ssm get-parameter --name /Chainlink/default/private-key --with-decryption | jq -r '.Parameter.Value' | pbcopy
# writing the private key to 'Chainlink.pem'
aws ssm get-parameter --name /Chainlink/default/private-key --with-decryption | jq -r '.Parameter.Value' > chainlink.pem



*special thanks to https://github.com/thodges-gh*
