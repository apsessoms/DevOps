resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01'={
  name: 'penderecommercestorag2'
  location: 'eastus2'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: 'ecommerce-launch-server-plan'
  location: 'eastus2'
  sku: {
    name: 'F1'
  }
}

resource AppServiceApp 'Microsoft.Web/sites@2024-04-01' ={
  name: 'ecommerce-launch-app'
  location: 'eastus2'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}
