param location string = 'eastus2'
param storageAccountName string = 'ecomapp${uniqueString(resourceGroup().id)}'
param appServiceAppName string ='ecomapp${uniqueString(resourceGroup().id)}'

@allowed([
  'nonprod'
  'prod'
])
param environmentType string 


var appServicePlanName ='ecommerce-launch-server-plan'
var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'
var appServicePlanSkuName = (environmentType == 'prod') ? 'P2v3' : 'F1'


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01'={
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
}

resource AppServiceApp 'Microsoft.Web/sites@2024-04-01' ={
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}


