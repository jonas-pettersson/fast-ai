#!/bin/bash

#============================================================
#    FILE:  setup_aws_spot_w_remount.sh
#
#    USAGE:  ./setup_aws_spot_w_remount.sh
#
#    DESCRIPTION: sets up a new aws spot instance and
#                 mounts an existing volume to root
#                 1) Reqest new AWS Spot Instance
#                 2) Attach existing volume to new instance
#                 3) Execute remount-root-script on new instance
#                 4) Login to new instance
#
#    PREREQUISITES:
#    - there exists an aws volume named as AWS_ROOT_VOL_NAME below
#    - configure specification.json to meet your needs
#    - set AWS_MAX_SPOT_PRICE below
#    - spot instance OS must match volume OS
#
#    PLEASE NOTE:
#    - Swapping the root volume is a potentially dangerous operation!
#    - Please test the script on a non-critical volume before using
#      for critical data
#    - spot instance must be set up in same availability zone as volume!
#    - default specification.json is set up to create spot instance with
#          + AMI of OS Ubuntu Server 16.04 LTS (HVM)
#          + Instance type p2.xlarge
#          + Availability zone us-west-2b
#
#    AUTHOR:  Jonas Pettersson, j.g.f.pettersson@gmail.com
#    CREATED:  26/02/2017
#============================================================

# Interrupt if any error occurs
set -e

# Name of the AWS Volume to mount
AWS_ROOT_VOL_NAME="spot"

AWS_MAX_SPOT_PRICE="0.3"
echo "AWS_MAX_SPOT_PRICE="${AWS_MAX_SPOT_PRICE}

# launch-specification file with JSON syntax described here:
# http://docs.aws.amazon.com/cli/latest/reference/ec2/request-spot-instances.html
AWS_CONF_FILE="file://specification.json"
echo "AWS_CONF_FILE="${AWS_CONF_FILE}

# Fetch AWS Volume ID
export AWS_ROOT_VOLUME_ID=`aws ec2 describe-volumes --filters Name=tag-key,Values="Name" Name=tag-value,Values="$AWS_ROOT_VOL_NAME" --query="Volumes[*].VolumeId" --output="text"`
echo "AWS_ROOT_VOLUME_ID="${AWS_ROOT_VOLUME_ID}

# Fetch AWS Availability Zone of the AWS Volume
# export AWS_AVAILABILITY_ZONE=`aws ec2 describe-volumes --volume-ids $AWS_ROOT_VOLUME_ID --query="Volumes[*].AvailabilityZone"`
# echo "AWS_AVAILABILITY_ZONE="${AWS_AVAILABILITY_ZONE}

# If setting up a spot fleet, use these lines (not thoroughly tested).
# Please note that configuration file has another format!
# AWS_SPOT_REQUEST_ID=$(aws ec2 request-spot-fleet --spot-fleet-request-config $AWS_CONF_FILE)
# echo "AWS_SPOT_REQUEST_ID="${AWS_SPOT_REQUEST_ID}

echo "Requesting new AWS Spot Instance"
aws ec2 request-spot-instances --spot-price $AWS_MAX_SPOT_PRICE --launch-specification $AWS_CONF_FILE

# Fetch AWS Spot ID. Assumes that the recently created request is the only one active! (if not change the filter)
# export AWS_SPOT_ID=`aws ec2 describe-spot-instance-requests --filters Name=state,Values="active" --query="SpotInstanceRequests[*].InstanceId" --output="text"`
# echo "AWS_SPOT_ID="${AWS_SPOT_ID}

# Fetch AWS Spot Request Id. Assumes that the recently created request is the only one active! (if not change the filter)
# Note that the exported AWS_SPOT_REQUEST_ID is needed by the remove_aws_spot.sh script when terminating!
export AWS_SPOT_REQUEST_ID=`aws ec2 describe-spot-instance-requests --filters Name=state,Values="active" --query="SpotInstanceRequests[*].SpotInstanceRequestId" --output="text"`
echo "AWS_SPOT_REQUEST_ID="${AWS_SPOT_REQUEST_ID}

echo "Waiting for AWS Spot Request to fulfill"
aws ec2 wait spot-instance-request-fulfilled --spot-instance-request-ids $AWS_SPOT_REQUEST_ID

# Fetch AWS Instance ID of the newly created AWS Spot Instance
# Assumes that the recently created request is the only one active! (if not change the filter)
# Note that the exported AWS_INSTANCE_ID is needed by the remove_aws_spot.sh script when terminating!
export AWS_INSTANCE_ID=`aws ec2 describe-spot-instance-requests --filters Name=state,Values="active" --query="SpotInstanceRequests[*].InstanceId" --output="text"`
echo "AWS_INSTANCE_ID="${AWS_INSTANCE_ID}

echo "Waiting for AWS Spot Instance to start and initialize"
aws ec2 wait instance-status-ok --instance-ids $AWS_INSTANCE_ID

# Fetch AWS Volume ID of the newly created AWS Spot Instance
# Note that the exported AWS_VOLUME_ID is needed by the remove_aws_spot.sh script when terminating!
export AWS_VOLUME_ID=`aws ec2 describe-instances --instance-ids $AWS_INSTANCE_ID --query="Reservations[*].Instances[*].BlockDeviceMappings[*].Ebs.VolumeId"`
echo "AWS_VOLUME_ID="${AWS_VOLUME_ID}

echo "Attaching existing AWS Volume to new AWS Instance"
aws ec2 attach-volume --volume-id $AWS_ROOT_VOLUME_ID --instance-id $AWS_INSTANCE_ID --device /dev/sdf
echo "Waiting for AWS Volume to attach and initialize"
aws ec2 wait volume-in-use --volume-ids $AWS_ROOT_VOLUME_ID

# Fetch Public DNS of new AWS Instance
export AWS_INSTANCE_PUBLIC_DNS=`aws ec2 describe-instances --instance-ids $AWS_INSTANCE_ID --query="Reservations[*].Instances[*].PublicDnsName"`
echo "AWS_INSTANCE_PUBLIC_DNS="${AWS_INSTANCE_PUBLIC_DNS}

echo "Fething remount-script to new AWS Instance"
ssh -i ~/.ssh/aws-key.pem ubuntu@$AWS_INSTANCE_PUBLIC_DNS "wget https://raw.githubusercontent.com/jonas-pettersson/fast-ai/master/scripts/remount_root.sh"
ssh -i ~/.ssh/aws-key.pem ubuntu@$AWS_INSTANCE_PUBLIC_DNS "chmod +x ~/remount_root.sh"

echo "Executing remount-script on new AWS Instance"
ssh -i ~/.ssh/aws-key.pem ubuntu@$AWS_INSTANCE_PUBLIC_DNS "sudo ~/remount_root.sh"

echo "Waiting for AWS Spot Instance to reboot"
aws ec2 wait instance-status-ok --instance-ids $AWS_INSTANCE_ID

# It is necessary to remove the SSH key because we have a new volume - otherwise they will not match
echo "Removes all SSH keys belonging to new instance from known_hosts file"
ssh-keygen -R $AWS_INSTANCE_PUBLIC_DNS

echo "Login to new instance"
ssh -i ~/.ssh/aws-key.pem ubuntu@$AWS_INSTANCE_PUBLIC_DNS
