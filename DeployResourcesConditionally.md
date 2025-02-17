# Introduction 

With **conditions**, you can deploy resources only when specific constraints are in place. And with **loops**, you can deploy multiple resources that have similar properties.

## Use Case
Let's say you work for an enterprise organization that is migrating from on-premise to the cloud. 
They're expanding their network of weather stations and need to deploy a set of Azure resources for each new station.
With each weather station you deploy, you deploy them to a production environment & you need to ensure that <em>auditing is enabled</em> for your Azure SQL logical servers.
But when you deploy resources to development environments, you <em>don't want to enable auditing.</em> You want to use a single template to deploy resources to all your environments.

## Conditions
In Bicep, use ```if``` followed by a ```true/false``` condition to control resource deployment.  

<bold>true</bold> deploys the resource ✅
<bold>false</bold> skips it. 🚫

+ The following example will deploy a storage acccount **only** if the ```deployStorageAccount``` is set to "true"
```
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
```@allowed([
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

+ This code deploys a SQL auditing resource only when the ```environmentName``` parameter value is set to **Production**
+ It is good practice to use a ```@var``` decorator to create a variable for the expression that you're using as a condition. It makes your template easier to understand.

**Important**:  Azure Resource Manager evaluates the property expressions **before** the conditionals on the resources. If you don't have this expression in your template, the deployment will fail with a ```ResourceNotFound``` error.
+ You can't define two resources with the same name in the same Bicep file and then conditionally deploy only one of them. This is a conflict according to the resource manager and the deployment will fail. If you have several resources using the same condition for deployment, use **modules**.
+  You can create a module that deploys all of your resources & add a condition on the module declaration in your main Bicep file.

## Putting it altogether

Open visual studio code or your favorite editor and create a new file called ```main.bicep``` and save it in a new folder called ```Bicep Templates```.

Add this code to your file to define a logical server and a database, including necessary parameters and variables. Type it manually to see how the Bicep tooling helps you write the code. If you want to copy and paste, use this [link](https://learn.microsoft.com/en-us/training/modules/build-flexible-bicep-templates-conditions-loops/3-exercise-conditions?pivots=powershell).

![alt text](https://i.imgur.com/y2AzQvr.png)

## Add Storage Account
In the auditing settings, a storage account is required to store auditing data. Update your ```main.bicep``` file to create this storage account **only when auditing is enabled.**

Add these **parameters** below the existing parameter declarations & the **variables** below the existing variable declarations:

![alt text](https://i.imgur.com/9gELNzq.png)

+ the ```var sqlServername``` variable is used to create a unique SQL server name.
  + ${location} inserts the deployment region
  + ${uniqueString(resourceGroup().id)} generates a random string based on the resource group ID & ensures the SQL server name is globally unique. 
  + take(24) makes sure the storage account name is no longer than 24 characters.

 Add this code below the resources for the storage account:

 ![alt text](https://i.imgur.com/zNhgnCm.png)

 This storage account is only created **if** ```auditingEnabled = true``` is defined. This is a deployment condition. 

 ## Audit Settings

  Add the following code below the storage account resource:
  ![alt text](https://i.imgur.com/ETC1mbr.png)

This enables auditing for an SQL sever only **if** ```auditingEnabled = true``` is defined. This is a deployment condition.

  
The `if` condition ensures that the auditing settings deploy only when required, just like the storage account. The `?` (ternary) operator prevents errors by setting valid values. Without it, Azure would try to access the storage account even when it doesn't exist, causing a deployment failure.




# Validate your Bicep file using What-If 🤔
You can use the ```az deployment group what-if``` command to see what resources will be deployed before actually deploying them. This is a great way to validate your Bicep file and ensure that it will deploy the resources you expect.

Run the following command to see what resources will be deployed when you run the deployment:

```
 New-AzResourceGroupDeployment -ResourceGroupName "homelab-sqlserver-eastus2-rg" -TemplateFile "main.bicep" -WhatIf
 ```

Make sure you change your resource group name to match the one you created earlier. 

![alt text](https://i.imgur.com/mmM4Moi.png)

We can see that there will be 2 resources created when we run the deployment. The admin login and password are masked for security reasons. Everything looks good with no errors or warnings.



## Verify the deployment
Go to the Azure portal and navigate to your resource group. You should see the resources that were deployed by your Bicep file.
+ Select overview to see the resources that were deployed.