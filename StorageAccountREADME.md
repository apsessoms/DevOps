# BICEP Storage Account Template



### Prerequisites

+ Visual Studio Code (VSS), Windows Powershell ISE, or your preferred integrated development environment (IDE).
+ Azure CLI: Make sure you have the Azure CLI installed and configured.
+ BICEP CLI: Ensure BICEP CLI is installed. If not, install it using Azure CLI with the command `az bicep install`.

### BICEP Template
+ Open BICEP template in an IDE. If using VSS, install BICEP extension. This template contains parameters and variables needed in order to create a storage account within the DOI-BLM requirements. 

## Parameters & Variables 
This will specify the name of the Azure Storage account & adhere to the BLM naming standard. 
+ `param ProjectNameUsageCase string`
+ `var storageAccountNamePrefix = 'ilmz` 

This will use the resource group location for a default parameter value. A common use of the resourceGroup function is to create resources in the same location as the resource group. 
+ `param location string = resourceGroup().location`

Encryption key type to be used for encryption service. Account key implies that an account-scoped encryption key will be used. Service key type implies that a default service key is used.
+ `var keyTypeForTableAndQueueEncryption = 'Account'`

Resource identifier of the userAssignedidentity to be associated with server-side encryption on the storage account. Can be found in JSON view of Key Vault associated with storage account OR via Azure Portal: Key Vaults>Access Control> Role Assignments>Key Vault Crypto Service Encryption User. 
+ `param userAssignedIdentity string =`



# 🦾Bicep - for testing

This folder is for our Bicep files as we go through the microsoft training - a place for our dev files to share with the team.

# Azure Bicep
For official guidance, check out the [Bicep documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/).

# What is Bicep?
Bicep is a Domain Specific Language for deploying Azure resources and the goal is to simplify the coding experience with cleaner syntax, intellisense, and better support for code re-use. [The Bicep Playground](https://azure.github.io/bicep/) is a great tool that compares Bicep code side by side with JSON code. This can help you understand the syntax and ease the learning curve for beginners.  

![image](https://github.com/DOI-BLM/blm-azure/assets/152536988/e0b5be66-b90b-4f1d-a744-1692ecfc493f)


## Contributing

Just place your testing Bicep files here

## License

This project is MIT licensed.
