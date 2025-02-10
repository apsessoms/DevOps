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
param appServicePlanSku object

@description('The region where resources will be deployed. Params can be overidden. ')
param location string = 'eastus2'

@secure()
@description('The admin login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlSeverAdministratorPassword string

@secure()
@description('The name and tier of the SQL database SKU.')
param sqlDatabaseSku object

@description('variables are hard coded and cannot be overriden')
var appServicePlanName = '${environmentName}-${solutionName}-plan'
var appServiceAppName = '${environmentName}-${solutionName}-app'
var sqlServerName = '${environmentName}--${solutionName}--sql'
var sqlDatabaseName = 'Employees'

 

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

resource sqlServer 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlSeverAdministratorPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2024-05-01-preview' ={
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: sqlDatabaseSku.name
    tier: sqlDatabaseSku.tier
  }
}
