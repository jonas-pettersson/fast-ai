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
#    - AWS_SPOT_REQUEST_ID, AWS_INSTANCE_ID, AWS_VOLUME_ID saved
#      in .aws_spot_profile
#    - These variables should have been set by the
#      setup_aws_spot_w_remount.sh script.
#      If this is not the case you can create the file manually
#
#    AUTHOR:  Jonas Pettersson, j.g.f.pettersson@gmail.com
#    CREATED:  26/02/2017
#============================================================

set -e

# Set variables from profile file
FILE=".aws_spot_profile"
if [ -f $FILE ]; then
    source .aws_spot_profile
    echo "Variables read from .aws_spot_profile"  
else
    echo "File $FILE does not exist."
fi

echo "Following variables are set:"
echo "AWS_SPOT_REQUEST_ID="${AWS_SPOT_REQUEST_ID}
echo "AWS_INSTANCE_ID="${AWS_INSTANCE_ID}
echo "AWS_VOLUME_ID="${AWS_VOLUME_ID}

read -n1 -p "Continue? [y,n]" doit
case $doit in
    y|Y) echo ;;
    n|N) echo; exit 0 ;;
    *) echo; exit 0 ;;
esac

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
