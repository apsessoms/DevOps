# Deploy Multiple Resources Using Loops in Bicep

*This guide is building off the [Loops & Conditions Guide](./Loops%26Conditions.md) if you have been following along.*
## Overview  
Extend your Bicep template to deploy multiple Azure SQL logical servers across different regions.

---

## Steps  

###  Move Resources into a Module  
1. In **Visual Studio Code**, create a new folder called `modules`.  
2. Move your `main.bicep` file into this folder.  
3. Rename `main.bicep` to `database.bicep`.  

---

###  Create a New Main Bicep File  
1. In the modules folder, create a new main.bicep file. 
2. Add the following parameters:  

```bicep
@description('Azure regions for deployment.')
param locations array = [
  'westus'
  'eastus2'
]

@secure()
@description('SQL server admin login.')
param sqlServerAdministratorLogin string

@secure()
@description('SQL server admin password.')
param sqlServerAdministratorLoginPassword string
```
###  Add a Module declaration to loop over the regions

```bicep
module databases 'modules/database.bicep' = [for location in locations: {
  name: 'database-${location}'
  params: {
    location: location
    sqlServerAdministratorLogin: sqlServerAdministratorLogin
    sqlServerAdministratorLoginPassword: sqlServerAdministratorLoginPassword
  }
}]
```
### What's happening here?
+ **locations**: is an array containing different locations [east us, east us 2].
+ **for location in locations**: loops over each location in the array.
+ **name**: 'database-${location}': creates a unique name for each database based on the location.
+ **params**: passes the location, admin login, and password to the ```modules/database.bicep``` file.

 Save the file.

## Verify database file
Ensure that your ```database.bicep``` file has the following code:

```bicep
@description('Azure region for deployment.')
param location string

@secure()
@description('SQL server admin login.')
param sqlServerAdministratorLogin string

@secure()
@description('SQL server admin password.')
param sqlServerAdministratorLoginPassword string

@description('SQL database SKU.')
param sqlDatabaseSku object = {
  name: 'Standard'
  tier: 'Standard'
}

@description('Deployment environment.')
@allowed(['Development', 'Production'])
param environmentName string = 'Development'

@description('Audit storage SKU.')
param auditStorageAccountSkuName string = 'Standard_LRS'

var sqlServerName = 'teddy${location}${uniqueString(resourceGroup().id)}'
var sqlDatabaseName = 'TeddyBear'
var auditingEnabled = environmentName == 'Production'
var auditStorageAccountName = take('bearaudit${location}${uniqueString(resourceGroup().id)}', 24)

resource sqlServer 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorLoginPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2024-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: sqlDatabaseSku
}

resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = if (auditingEnabled) {
  name: auditStorageAccountName
  location: location
  sku: { name: auditStorageAccountSkuName }
  kind: 'StorageV2'  
}

resource sqlServerAudit 'Microsoft.Sql/servers/auditingSettings@2024-05-01-preview' = if (auditingEnabled) {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    storageEndpoint: environmentName == 'Production' ? auditStorageAccount.properties.primaryEndpoints.blob : ''
    storageAccountAccessKey: environmentName == 'Production' ? auditStorageAccount.listKeys().keys[0].value : ''
  }
}
```

## Deploy the template

Run the following command to deploy the template:

```
 New-AzResourceGroupDeployment -Name main -TemplateFile main.bicep
 ```
 + Use the same login and password from previous deployments.
 
 ## Verify the deployment

+ Go to the Azure portal and navigate to the resource group where the resources were deployed.
+ You should see the SQL server and database resources deployed across the regions you specified.

![alt text](https://i.imgur.com/5RsSvpd.png)

## Conclusion



Next up, we will cover [Deploying Resources Conditionally in Bicep](./DeployResourcesConditionally.md)