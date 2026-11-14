#!/bin/bash

# 1. Create Resource Groups
az group create -n rg-network-hub -l canadacentral
az group create -n rg-spoke-web -l canadacentral
az group create -n rg-spoke-db -l canadacentral

# 2. Create Hub VNet & Bastion Subnet
az network vnet create -g rg-network-hub -n vnet-hub --address-prefix 10.0.0.0/16 \
  --subnet-name AzureBastionSubnet --subnet-prefix 10.0.0.0/26

# 3. Create Spoke VNets & Subnets
az network vnet create -g rg-spoke-web -n vnet-web --address-prefix 10.1.0.0/16 \
  --subnet-name snet-web --subnet-prefix 10.1.1.0/24

az network vnet create -g rg-spoke-db -n vnet-db --address-prefix 10.2.0.0/16 \
  --subnet-name snet-db --subnet-prefix 10.2.1.0/24

# 4. Peer Hub and Web Spoke
az network vnet peering create -g rg-network-hub -n hub-to-web --vnet-name vnet-hub \
  --remote-vnet $(az network vnet show -g rg-spoke-web -n vnet-web --query id -o tsv) --allow-vnet-access

az network vnet peering create -g rg-spoke-web -n web-to-hub --vnet-name vnet-web \
  --remote-vnet $(az network vnet show -g rg-network-hub -n vnet-hub --query id -o tsv) --allow-vnet-access

# 5. Peer Hub and Database Spoke
az network vnet peering create -g rg-network-hub -n hub-to-db --vnet-name vnet-hub \
  --remote-vnet $(az network vnet show -g rg-spoke-db -n vnet-db --query id -o tsv) --allow-vnet-access

az network vnet peering create -g rg-spoke-db -n db-to-hub --vnet-name vnet-db \
  --remote-vnet $(az network vnet show -g rg-network-hub -n vnet-hub --query id -o tsv) --allow-vnet-access
