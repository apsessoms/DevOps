# Reusable Bicep Templates

*Continuing from the [ParametersGuide](./ParametersGuide.md), if you are following along.*


## Quick Recap
+ **Parameters** are used for stuff that can change between deployments (environment-specific settings, pricing skus, sizing for your resources, and API keys to access external systems.)
+ **Variables** typically have the same value are are consistent across deployments. 

Example of a param **WITHOUT A DEFAULT VALUE.** This <u>requires</u> a user to provide a value when deploying.

![Alt Text](https://i.imgur.com/ys06YFA.png)



Example of a param **WITH** a default value. This is known as "hardcoding" a value. Depending on the situation, this can be a good or bad practice. It is good practice when you know the value will not change often.

![Alt Text](https://i.imgur.com/IUoSL7N.png)

## Parameters and handling sensitive data

Parameters can be configured to retrieve sensitive data like passwords, certificates, or API keys. In this guide, we will build a reusable template that will define our previously made App Service Plan and an app. It will also define a SQL server and a database. We create a parameter file to specify values for our environment and secure them by using Azure Key Vault. 🗝️

+ **Pro tip:** place parameters at the top of your file so your Bicep is easy to read ✅

## Parameters 

```bicep
param environmentName string 
````
+ **"param"** tells bicep you're declaring a parameter.
+ **"environmentName"** is the name of the parameter and their names must be unique when used inside of the same template. 
+ **"string"** is the data type of the parameter.

💡Remember, **parameters** are for settings that change between deployments & **variables** can be used for settings that do not. 

💪🏼 I am instilliing muscle memory here in case you had not caught on yet. 

## Different parameter types:<br>
<em>**string**</em> - Text values<br>
<em>**int**</em> - Whole numbers<br>
<em>**bool**</em> - True or False<br>
<em>**object & array**</em> - JSON objects


## Objects ⏹️
In bicep, object parameters can hold multiple values together in one place. You can make it optional by giving it a **default value** which means that if you don't provide one, Azure will. ☁️

```bicep
param storageConfig object = {
  name: 'mystorage'
  sku: 'Standard_LRS'
}
```

## Tags 🏷️
Tags are a special type of object that can be used to add metadata to resources. You will usually use different tags for each environment, but best practice is to reuse same tag values on all resources within your template. 

```bicep
param resourceTags object = {
    EnvironmentName: 'Prod'
    CostCenter: '100'
    Team: 'DevOps'
    }
```

Whenever you define a resource in your Bicep file, you can reuse it wherever you want define the **tags** property. 

```bicep
resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceAppName
  location: location
  tags: resourceTags
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
  }
   }
```

## Arrays 📝
An array is a list of items & you might use an array of string values to declare a list of storage account locations.
```bicep
param cosmosDBAccountLocations array = [
  {
    locationName: 'australiaeast'
  }
  {
    locationName: 'southcentralus'
  }
  {
    locationName: 'westeurope'
  }
]
```
When you declare your Storage Account resource, you can reference the array parameter to set the location property. 

```bicep
resource account 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' = {
  name: accountName
  location: location
  properties: {
    locations: cosmosDBAccountLocations
  }
}
```

## Allowed values ✅
In order to stay within a certain budget, you might decide that your App Service plans should only be deployed with a certain pricing tier. To enforce this, you use the ```@allowed``` parameter <strong> decorator</strong>. This is an example of how to restrict the pricing tier to only three options:

```bicep
@allowed([
  'P1v3'
  'P2v3'
  'P3v3'
])
param appServicePlanSkuName string
````
💡Pro tip: use this sparingly as it could block deployments if you don't keep up with the list. Pricing tiers change constantly, so it would be your responsbility to ensure these stayed up to date. 

## Naming conventions & parameter lenghts 📛
Use @minLength and @maxLength to enforce a minimum and maximum length for a parameter. This is useful for ensuring that your resources are named correctly and consistently. 

For example, you can enforce a minimum length of 4 characters and a maximum length of 24 characters for a storage account name:

```bicep
@minLength(5)
@maxLength(24)
param storageAccountName string
```

## How do I remember all this? 🤔
Add descriptions to parameters! This is a good practice to help users understand what the parameter is for and what values are allowed. The @description decorator makes it easy to leave comments about a parameter in human-readable form.  

```bicep
@description('The name of the storage account. Must be globally unique.')
param storageAccountName string

@description('The SKU (pricing tier) for the storage account. Choose between Standard_LRS, Standard_GRS, or Premium_LRS.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Premium_LRS'
])
param storageAccountSku string

@description('The list of Azure regions where the storage accounts should be deployed.')
param storageAccountLocations array = [
  'eastus'
  'westus'
]
```
## Feeling stuck?   🤯
You can refer to Template Specs in the Azure portal to see the parameters and descriptions for a template. This is a great way to see how other templates are structured and what parameters they use. [Click here for Template Specs](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-specs). 

## Putting it all together
For this guide, you will need to have Visual Studio Code installed. 
+ Create a new folder and name it **"scripts"**.
+ Create a new file and name it **"main.bicep"**.

Enter the following bicep manually so you can learn how the Bicep extension works in VS Code. 

![Alt Text](https://i.imgur.com/U6XZfiX.png)
+ **"param environmentName string"** says the environment we are using is dev.
+ **"param solutionName string"** followed by the ```uniqueString()``` function creates a globally unique resource name. It returns a string thats the same on every deployment within the same <em>resource group</em> but different across other resource groups or subscriptions.

The variables you defined will create the names of the Azure App Service Plan and App Service App. 

**Remember** ⚠️ parameter values can be overridden. Variables cannot. ⚠️

## Allowed values for parameters

![Alt Text](https://i.imgur.com/Nv25CQz.png)

Under the environmentName parameter, add the following code to restrict the values to only "dev" and "prod". See above for example. Also, add an @description decorator to explain what the parameter is for.

```bicep
@allowed([
  'dev'
  'prod'
])
```

## Input Lengths
![Alt Text](https://i.imgur.com/QWptCAr.png)

In the main.bicep file, limit the length of the solutionName by adding the @minLength and @maxLength decorators. 

## Restrict Instance Count
![alt text](https://i.imgur.com/YWvkBxd.png)

This restricts users from only deploying between 1 and 5 instances which is a good practice if you have new users deploying resources. Cloud costs can add up quickly! 💵

## Time to Deploy 🚀

+ Open the terminal in VS Code or Azure CLI
+ Set the location where you saved your template, in this case, the "scripts" folder.

![Alt Text](https://i.imgur.com/dRtxGTQ.png)

+ Run the following command to deploy your Bicep file:

```
New-AzResourceGroupDeployment -ResourceGroupName 'homelab-webapp2-eastus2-rg' -TemplateFile main.bicep
```
![Alt Text](https://i.imgur.com/9jg29UT.png)

You can see from the output that the deployment was successful. Under the parameters section, you can see the values that were passed to the template:
+ **environmentName** is set to "dev"
+ **solutionName** produced a unique string of "ececomhrr74nbzhrebkdi"
+ **appServicePlanInstanceCount** deployed 1 instance
+ **appServicePlanSku** object is the free tier option. 
+ **location** is set to "eastus2"

## Conclusion
+ **Parameter** values can be overridden at deployment time. ✅
+ **Variables** cannot. 🚫
+ Limit lengths of parameters with ```@minLength()``` and ```@maxLength()```. (resource names)
+ Limit input value with ```@minValue()``` and ```@maxValue()```. (instance count)
+ Allowed values for ```environmentName``` (dev or prod)
  + Be careful with ```@allowed decorator``` as it can block deployments if you don't keep up with the list.

Next up, we will group resources rogether using [Modules](./Modulesreadme.md).
