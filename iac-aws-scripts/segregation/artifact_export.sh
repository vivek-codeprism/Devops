#!/bin/bash
printf "{\n\"access_key\": $(terraform output -json -module=management access_key | jq '.value'),"    > ../account.auto.tfvars.json
printf  "\n\"secret_key\": $(terraform output -json -module=management secret_key | jq '.value')\n}" >> ../account.auto.tfvars.json
printf "[default]\n" > ../.key/backend.credentials
printf     "aws_access_key_id=$(terraform output -module=management backend_access_key)\n" >> ../.key/backend.credentials
printf "aws_secret_access_key=$(terraform output -module=management backend_secret_key)\n" >> ../.key/backend.credentials
printf "zone = \"$(terraform output -module=management zone)\"\n" > ../zone.auto.tfvars
printf "[default]\n" > ../packer/.key/packer.credentials
printf     "aws_access_key_id=$(terraform output -module=management packer_access_key)\n" >> ../packer/.key/packer.credentials
printf "aws_secret_access_key=$(terraform output -module=management packer_secret_key)\n" >> ../packer/.key/packer.credentials
