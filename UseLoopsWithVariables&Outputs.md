# Using Loops with Variables and Outputs in Bicep

## Introduction
Our ecommerce company is expanding and we need to deploy multiple vnets, subnets, and storage accounts without manually creating each resource. We can use loops to simplify the deployment process. 

+ **Variable Loops**: you can create reusable lists (arrays) for resources.
+ **Output Loops**: you can retrieve details about deployed resources & use them later.

##  Variable Loops
You need to create a virtual network with multiple subnets, and you want a simple way to add more subnets in the future.

**How it works**:
+ You define an array ```(subnets)``` with simple names and IP ranges.
+ Then, you transform that array into the format required by Azure using a loop.

## Bicep Example
```bicep
param addressPrefix string = '10.10.0.0/16'
@description('define the base network address space')

param subnets array = [
    { name: 'frontend', ipAddressRange: '10.10.0.0/24' }
    { name: 'backend'. ipAddressRange: '10.10.1.0/24' }
]
@description('list the subnets')

var subnetsProperty = [for subnet in subnets: {
    name: subnet.name
    properties: {
        addressPrefix: subnet.ipAddressRange
    }
}]
@description('Convert simmple subnet list into Azure comtable format')

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
    name: 'ecommerce-vnet' //vnet name
    location: resourceGroup().location
    properties: {
        addressSpace: {
            addressPrefixes: [addressPrefix] // assign main network range
        }
        subnets: subnetsProperty // add dynamically created subnets
    }
}

@description('Creates the virtual network')
```

##  Output Loops
You need to deploy multiple storage accounts across different Azure regions and want to retrieve key details, like their names and endpoints.

**How it works**:
+ You loop through the list of regions ```(locations)``` to create storage accounts dynamically.
+ Then, you use an output loop to get their details (name, location, endpoints).

## Bicep Example
```bicep
param locations array = [
    'eastus'
    'eastus2'
    'centralus'
]
@description('List of Azure regions where storage accounts will be deployeed')

resource storageAccounts 'Microsoft.Storage/storageAccounts@2023-05-01' = [for location in locations: {
    name: 'ecommerce${uniqueString(resourceGroup().id, location)}'
    location: location
    kind: 'StorageV2'
    sku: {
        name: 'Standard_LRS'
    }
}]
@description('Deploys storage accounts in multiple regions/dynamically')

output storageEndpoints array = [for i in range(0, length(locations)): {
    name: storageAccounts[i].name
    location: storageAccounts[i].location
    blobEndpoint: storageAccounts[i]properties.primaryEndpoints.blob
    fileEndpoint: storageAccounts[i].properties.primaryEndpoints.file
}]
@description('Outputs storage account details dynamically')
``` 
🚨 Remember, don't use outputs to return secrets, access keys, or passwords. Outputs are logged and not designed to handle sensitive data. 

## Putting it all together

### Add VNET to Bicep File
1. Open the *main.bicep* file from the previous lab we did on [Deploying Resources Conditionally](./DeployResourcesConditionally.md).
2. Below the parameter section, add these additional parameters and variables.

```bicep
@description('The IP address range for all VNETs to use')
param virtualNetworkAddressPrefix string = '10.10.0.0/16'

@description('The name and IP address range for each subnet in the VNET')
param subnets array = [
  {
    name: 'frontend'
    ipAddressRange: '10.10.5.0/24'
  }
  {
    name: 'backend'
    ipAddressRange: '10.10.10.0/24'
  }
]
```
3. Below parameters, add the following ```subnetProperties``` variable loop:
```bicep
var subnetProperties = [for subnet in subnets: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.ipAddressRange
  }
}]
```
4. At the bottom of the file, underneath ```databases``` module, add the following resource loop:
```bicep
resource virtualNetworks 'Microsoft.Network/virtualNetworks@2024-05-01' = [for location in locations: {
  name: 'ecommerce-${location}'
  location: location
  properties:{
    addressSpace:{
      addressPrefixes:[
        virtualNetworkAddressPrefix
      ]
    }
    subnets: subnetProperties
  }
}]
```
5. Save the file.

## Add outputs to database module
1. Open the *database.bicep* file from the previous lab we did on [Deploying Resources Conditionally](./DeployResourcesConditionally.md). 
2. Add the following output loop to the bottom of the file:
```bicep
output serverName string = sqlServer.name
output location string = location
output serverFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
```
3. Save the file.

## Flow outputs through the parent/main Bicep file
1. Open the *main.bicep* file.
2. Add the following output loop to the bottom of the file:
```bicep
output serverInfo array = [for i in range(0, length(locations)): {
  name: databases[i].outputs.serverName
  location: databases[i].outputs.location
  fullyQualifiedDomainName: databases[i].outputs.serverFullyQualifiedDomainName
}]
```
3. Save the file.

## Deploy the Bicep Template
1. Open the terminal in Visual Studio Code.
2. Run the following command to deploy the Bicep template:
```bash
New-AzResourceGroupDeployment -Name main -TemplateFile main.bicep
```
⚠️ Please make sure you continue to use the same login & password previously used to avoid any issues with the deployment.

## Verify the Deployment
1. Go to the Azure portal and navigate to your resource group.
2. Verify that the VNETs have been deployed to the regions specified in the *main.bicep* file.

![alt text](https://i.imgur.com/bh4yF71.png)
3. Click on the VNET to view the subnets that were created.

![alt text](https://i.imgur.com/Mk6xCtG.png)

You see that the subnets deployed have the names and IP addresses specified in the ```subnets``` parameters default value. 

Next, run this command to see the FDQN of the servers:
```bash
Get-AzSqlServer -ResourceGroupName homelab-sqlserver-eastus2-rg
```

![alt text](https://i.imgur.com/CxJGkg0.png)

## Key Takeaways
+ **Variable Loops**: Turn simple input lists into Azure-compatible objects dynamically.
+ **Output Loops**: Retrieve details about deployed resources for future use.
+ **Scalability**: Easily add more subnets or storage accounts without changing the code.
+ **Copy Loops**: enables you to deploy multiple resources that are identical or have minor differences. 

### What we covered
+ [Conditional Deployment](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/conditional-resource-deployment)
+ [Bicep Loops](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/loops)
+ [Resources](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/resource-declaration?tabs=azure-powershell)
+ [Modules](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/modules)
+ [Variables](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/variables)
+ [Outputs](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/outputs)