param location string = 'eastus2'
param storageAccountName string = 'ecommercelaunchapp${uniqueString(resourceGroup().id)}'
param appServiceAppName string ='ecommerceapplaunch${uniqueString(resourceGroup().id)}'

var appServicePlanName ='ecommerce-launch-server-plan'



resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' ={
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' ={
  location: location
  sku: {
    name: 'F1'
  }
  name: appServicePlanName
}


resource appServiceApp 'Microsoft.Web/sites@2024-04-01' ={
  name: appServiceAppName
location: location
properties: {
  serverFarmId: appServicePlan.id
  httpsOnly: true
}
}

