#!/bin/bash
SVC_ACCT=vl71
FOLDER_ID=b1g97nk43unle0o4u325
ACCT_ID=$(yc iam service-account get $SVC_ACCT | grep ^id | awk '{print $2}')
yc resource-manager folder add-access-binding --id $FOLDER_ID --role editor --service-account-id $ACCT_ID
