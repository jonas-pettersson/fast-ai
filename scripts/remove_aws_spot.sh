#!/bin/bash

#============================================================
#    FILE:  remove_aws_spot.sh
#
#    USAGE: ./remove_aws_spot.sh
#
#    DESCRIPTION: cancels the spot request,
#                 terminates the instance, and
#                 deletes the volume
#
#    PREREQUISITES:
#    - AWS_SPOT_REQUEST_ID, AWS_INSTANCE_ID, AWS_VOLUME_ID set
#    - These variables should have been set by the
#      setup_aws_spot_w_remount.sh script
#
#    AUTHOR:  Jonas Pettersson, j.g.f.pettersson@gmail.com
#    CREATED:  26/02/2017
#============================================================

set -e

# If using a spot fleet, use these lines instead (not thoroughly tested).
# aws ec2 cancel-spot-fleet-requests --spot-fleet-request-ids $AWS_SPOT_REQUEST_ID --terminate-instances

echo "Canceling AWS Spot Instance Request" $AWS_SPOT_REQUEST_ID
aws ec2 cancel-spot-instance-requests --spot-instance-request-ids $AWS_SPOT_REQUEST_ID

echo "Terminating AWS Spot Instance" $AWS_INSTANCE_ID
aws ec2 terminate-instances --instance-ids $AWS_INSTANCE_ID
echo "Waiting for AWS Spot Instance to terminate"
aws ec2 wait instance-terminated --instance-ids $AWS_INSTANCE_ID

echo "Deleting AWS Volume" $AWS_VOLUME_ID
aws ec2 delete-volume --volume-id $AWS_VOLUME_ID
echo "Waiting for AWS Volume to be deleted" $AWS_VOLUME_ID
aws ec2 wait volume-deleted --volume-ids $AWS_VOLUME_ID
