@description('The name of the environment. This must be dev or prod')
@allowed([
  'dev'
  'prod'
])
param environmentName string = 'dev'


@description('The unique name of the solution. The makes sure that resource names are unique')
@minLength(4)
@maxLength(25)
param solutionName string = 'ecomhr${uniqueString(resourceGroup().id)}'

@description('The number of instances for the App Service plan')
@minValue(1)
@maxValue(5)
param appServicePlanInstanceCount int = 1

@description('The name and tier of the App Service Plan sku')
param appServicePlanSku object = {
  name: 'F1'
  tier: 'Free'
}

@description('The region where resources will be deployed. Params can be overidden. ')
param location string = 'eastus2'

@description('variables are hard coded and cannot be overriden')
var appServicePlanName = '${environmentName}-${solutionName}-plan'
var appServiceAppName = '${environmentName}-${solutionName}-app'

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku.name
    tier: appServicePlanSku.tier
    capacity: appServicePlanInstanceCount
  }
}

resource appServiceApp 'Microsoft.Web/sites@2024-04-01' ={
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }  
}
