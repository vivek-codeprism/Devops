#!/bin/bash
# sudo yum install pip
# sudo pip install aws
# grant aws user with action "sts:DecodeAuthorizationMessage" on resource "*"
# copy-paste message to out.tmp file
aws sts decode-authorization-message --encoded-message $(cat out.tmp) | jq '.DecodedMessage | fromjson'
