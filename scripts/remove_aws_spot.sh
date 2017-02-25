#!/bin/bash
# aws ec2 cancel-spot-fleet-requests --spot-fleet-request-ids $SPOT_REQUEST_ID --terminate-instances
aws ec2 cancel-spot-instance-requests --spot-instance-request-ids $SPOT_ID
aws ec2 terminate-instances --instance-ids $INSTANCE_ID
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID

aws ec2 delete-volume --volume-id $A_VOLUME_ID
aws ec2 wait volume-deleted --volume-ids $A_VOLUME_ID
