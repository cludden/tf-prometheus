#!/bin/bash

EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
export AWS_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"

confd --onetime --backend ssm