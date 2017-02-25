#!/bin/bash
# configure specification.json so that instance will be in same availability zone as your volume!

export ROOT_VOL_NAME="spot"
export ROOT_VOLUME_ID=`aws ec2 describe-volumes --filters Name=tag-key,Values="Name" Name=tag-value,Values="$ROOT_VOL_NAME" --query="Volumes[*].VolumeId" --output="text"`
echo $ROOT_VOLUME_ID

# export AVAILABILITY_ZONE=`aws ec2 describe-volumes --volume-ids $ROOT_VOLUME_ID --query="Volumes[*].AvailabilityZone"`
# echo $AVAILABILITY_ZONE

# SPOT_REQUEST_ID=$(aws ec2 request-spot-fleet --spot-fleet-request-config file://config.json)
# echo $SPOT_REQUEST_ID

# SPOT_REQUEST_ID=$(aws ec2 request-spot-instances --spot-price "0.3" --availability-zone-group $AVAILABILITY_ZONE --launch-specification file://specification.json)
# SPOT_REQUEST_ID=$(aws ec2 request-spot-instances --spot-price "0.3" --launch-specification file://specification.json)
# echo $SPOT_REQUEST_ID

aws ec2 request-spot-instances --spot-price "0.3" --launch-specification file://specification.json

export SPOT_REQUEST_ID=`aws ec2 describe-spot-instance-requests --filters Name=state,Values="active" --query="SpotInstanceRequests[*].InstanceId" --output="text"`
echo $SPOT_REQUEST_ID

export SPOT_ID=`aws ec2 describe-spot-instance-requests --filters Name=state,Values="active" --query="SpotInstanceRequests[*].SpotInstanceRequestId" --output="text"`
echo $SPOT_ID

aws ec2 wait spot-instance-request-fulfilled --spot-instance-request-ids $SPOT_ID

export INSTANCE_ID=`aws ec2 describe-spot-instance-requests --filters Name=state,Values="active" --query="SpotInstanceRequests[*].InstanceId" --output="text"`
echo $INSTANCE_ID
aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID

export A_VOLUME_ID=`aws ec2 describe-instances --instance-ids $INSTANCE_ID --query="Reservations[*].Instances[*].BlockDeviceMappings[*].Ebs.VolumeId"`
echo $A_VOLUME_ID

aws ec2 attach-volume --volume-id $ROOT_VOLUME_ID --instance-id $INSTANCE_ID --device /dev/sdf

export INSTANCE_PUBLIC_DNS=`aws ec2 describe-instances --instance-ids $INSTANCE_ID --query="Reservations[*].Instances[*].PublicDnsName"`
echo $INSTANCE_PUBLIC_DNS
ssh-keygen -R $INSTANCE_PUBLIC_DNS
ssh -i ~/.ssh/aws-key.pem ubuntu@$INSTANCE_PUBLIC_DNS
