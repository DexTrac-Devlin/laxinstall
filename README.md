## Overview

This project creates a secure Chainlink node running on an Ubuntu 20.04 EC2 instance using docker. The Chainlink node runs in a private subnet and can be accessed via internal networking from a bastion host which is also created. The template creates a VPC and associated networking in addition to a private key which is stored in SSM Parameter store.

## Installation

Upload cl-install.cfn to Cloudformation to create the resources. Fill in the required values for installation. You'll need an Ethereum node that runs either Ropsten or Mainnet.

## Accessing the Private Key

The private key created by the template can be downloaded by means of the AWS CLI. You need the private key to initiate a SSH connection from your computer to the EC2 instance. Please note that the default format in your AWS config on your local machine needs to be set to json for this to work, and jq needs to be installed. You'll need the private key for access to both the bastion host and the Chainlink node. The key is created automatically on the bastion host, so you'll only need to run this on your local machine.

# Writing the Private Key to 'chainlink.pem'
aws ssm get-parameter --name /Chainlink/default/private-key --with-decryption | jq -r '.Parameter.Value' > chainlink.pem


References:
https://github.com/devlintrace/laxinstall
*special thanks to https://github.com/thodges-gh*
