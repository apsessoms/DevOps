# Introduction 

*This guide is building off the [Modules Guide](./Modulesreadme.md) if you have been following along.*

With **conditions**, you can deploy resources only when specific constraints are in place. And with **loops**, you can deploy multiple resources that have similar properties.

## Use Case
Let's say you work for an enterprise organization that is migrating from on-premise to the cloud. 
They're expanding their network of weather stations and need to deploy a set of Azure resources for each new station.
With each weather station you deploy, you deploy them to a production environment & you need to ensure that <em>auditing is enabled</em> for your Azure SQL logical servers.
But when you deploy resources to development environments, you <em>don't want to enable auditing.</em> You want to use a single template to deploy resources to all your environments.

## Conditions
In Bicep, use ```if``` followed by a ```true/false``` condition to control resource deployment.  <bold>true</bold> deploys the resource, <bold>false</bold> skips it.

+ The following example will deploy a storage acccount **only** if the ```deployStorageAccount``` is set to "true"
```bicep
param deployStorageAccount bool

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = if (deployStorageAccount) {
  name: 'teddybearstorage'
  location: resourceGroup().location
  kind: 'StorageV2'
  // ...
}
```

You will notice that the true value isn't inside the Bicep code itself.  It's provided when you deploy the Bicep template.

Think of ```deployStorageAccount``` as a variable that gets its value from outside the Bicep file.  You, or a deployment tool, set that value when you run the deployment.

## Conditions w/ expressions
```bicep
@allowed([
  'Development'
  'Production'
])
param environmentName string

var auditingEnabled = environmentName == 'Production'

resource auditingSettings 'Microsoft.Sql/servers/auditingSettings@2024-05-01-preview' = if (environmentName == 'Production') {
  parent: server
  name: 'default'
  properties: {
  }
}
```

+ This code deploys a SQL auditing resource only when the ```environmentName``` parameter value is set to Production
+ It is good practice to use a ```@var``` decorator to create a variable for the expression that you're using as a condition. It makes your template easier to understand.

**Important**:  Azure Resource Manager evaluates the property expressions **before** the conditionals on the resources. If you don't have this expression in your template, the deployment will fail with a ```ResourceNotFound``` error.
+ You can't define two resources with the same name in the same Bicep file and then conditionally deploy only one of them. This is a conflict according to the resource manager and the deployment will fail. If you have several resources using the same condition for deployment, use **modules**.
+  You can create a module that deploys all of your resources & add a condition on the module declaration in your main Bicep file.

+  ## Putting it altogether
+  


## Next up
[Deploy Multiple Resources Using Loops in Bicep](./DeployMultipleResources.md)