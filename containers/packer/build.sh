#!/bin/bash

#packer build -var-file=frontend.pkrvars.hcl app_template.pkr.hcl
#packer build -var-file=payments.pkrvars.hcl app_template.pkr.hcl
#packer build -var-file=checkout.pkrvars.hcl app_template.pkr.hcl
packer build -var-file=frontend.pkrvars.hcl consul_envoy_template.pkr.hcl
packer build -var-file=checkout.pkrvars.hcl consul_envoy_template.pkr.hcl
packer build -var-file=payments.pkrvars.hcl consul_envoy_template.pkr.hcl
packer build -var-file=ingress.pkrvars.hcl consul_envoy_template.pkr.hcl