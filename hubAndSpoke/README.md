# Hub and Spoke deployment

## Overview

This set of Bicep files deploys a basic hub and spoke network architecture.

## Purpose

This can be used to create initial network architecture in Azure.

## Deployment Overview

- Hub virtual network
    - Address Space: 192.168.0.0/16
    - Peering to spoke virtual network(s)
- Spoke virtual network(s) (Specify number of spokes)
    - Address space: 172.*n*.0.0/16
    - Peering back to hub virtual network

`az deployment sub create --location <REGION> --name <NAMEOFDEPLOYMENT> --template-file ./hubAndSpoke/main.bicep --verbose`