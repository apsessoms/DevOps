# Making Parameters Secure 🔑

*This guide is building off the [Modules Guide](./Modulesreadme.md) if you have been following along.*

<h1> Introduction </h1>

If you are working in an enterprise environment, you will likely need to secure your parameters. This guide will show you how to store your secrets and pass them securely to your Bicep template. You need to make sure that the secret values are not logged and that the person deploying them does not have access to them.

## Best Practice 
+ Because of the security risks associated with using credentials in plain text, it is best practice to either not use them at all, store them in a secure location, or use a service principal/manged identity. ✅
+ Avoid using parameter files for secrets. Parameters are often used in CI/CD pipelines which means many people might have access to it in the future. Sensitve information should **never** be stored in a version control system. ✅
+ Secrets can be called in even if they are in different resource groups or subscriptions. ✅

## How to define a secure parameter

You can apply the ```@secure``` decorator to string and object parameters that contain secret values. This won't publish the values to the deployment logs in Azure. If you use the CLI and enter the values manually during deployment, they will be masked. 

## Example

```@secure()
param adminPasswordLogin string

@secure()
param adminPassword string
```
🚨 Remember, don't store secret values in plain site within your template. 

## Key Vaults 

Azure Key Vault is a service that lets you securely store and manage access to secrets. You can reference Azure Key Vault in a parameter file associated with the secret. The the template is deployed, the Azure Resource manager will talk to the key vault and retrieve the secret without every exposing the value in the template or logs during deployment. 

This is a good visual representation of how it works from **Microsoft Learn:**

![Alt Text](https://learn.microsoft.com/en-us/training/modules/build-reusable-bicep-templates-parameters/media/5-parameter-file-key-vault.png)

## Putting it all together

We want to make our template work across multiple environments. In order to do that, we will provide the Azure App Service Plan SKU details in a parameter file. In your main bicep file that we created in previous steps, add these parameters under the existing parameters. 



![Alt Text](https://i.imgur.com/w5ahhKP.png)

+ There are no default values specified for the admin username and password as well as no default values for the SKU. They will be specified in the parameter file.

![Alt Text](https://i.imgur.com/PrwvcD6.png)

+ Add the variables for the server name and database name underneath the existing variables in the main bicep file. 

## Create SQL server and database

In the main file, add the following resources to the bottom of the file. 

[alt text](blob:https://imgur.com/1995a730-6a29-4b0c-9ac8-cd6b25a33009)

## Create a new parameters file

In the same folder where the  main.bicep file is, create a new file titled "main.parameters.dev.json". Manually type this code in their for muscle memory. 

[alt text](https://i.imgur.com/u5N817A.png)

## Deploy the template

In the terminal, run the following command to deploy the template. 

```
New-AzResourceGroupDeployment -Name main -TemplateFile main.bicep -TemplateParameterFile. main.parameters.dev.json
```

You will be prompted to enter values for adminUsername and adminPassword 

![Alt Text](https://i.imgur.com/HChoPjl.png)

+ Notice how the values are masked in the screenshot above
+ Remember to write down the values you enter for the adminUsername and adminPassword. You will need them later.

## Create Key Vault and secrets 

Using the command below, create a new key vault. 

```
$keyVaultName = 'YOUR-KEY-VAULT-NAME'
$login = Read-Host "Enter the login name" -AsSecureString
$password = Read-Host "Enter the password" -AsSecureString

New-AzKeyVault -VaultName $keyVaultName -Location eastus -EnabledForTemplateDeployment
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'sqlServerAdministratorLogin' -SecretValue $login
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'sqlServerAdministratorPassword' -SecretValue $password
```
+ Note that the ```-EnabledForTemplateDeployment``` setting on the key vault is required for the template to access the secrets. If you don't have this setting enabled, the template will not be able to access the secrets.

Run the last three lines separately and you should see the following output:

![alt text](https://i.imgur.com/fUCrmdq.png)

## How to reference the Key Vault in the parameter file

You will need to reference the resource ID of the key vault. 

```
(Get-AzKeyVault -Name $keyVaultName).ResourceId
```

It should look something like this: 

![alt text](https://i.imgur.com/is0fmmw.png)

Copy it and paste it into the  **main.parameters.dev.json** file. 

```
"sqlServerAdministratorLogin": {
      "reference": {
        "keyVault": {
          "id": "YOUR-KEY-VAULT-RESOURCE-ID"
        },
        "secretName": "sqlServerAdministratorLogin"
      }
    },
    "sqlServerAdministratorPassword": {
      "reference": {
        "keyVault": {
          "id": "YOUR-KEY-VAULT-RESOURCE-ID"
        },
        "secretName": "sqlServerAdministratorPassword"
      }
    }
  }
}
```

## Deploy the template with parameters file

Run the following command to deploy the template with the parameters file. 

```
New-AzResourceGroupDeployment -ResourceGroupName "homelab-webapp-eastus-rg" -TemplateFile "main.bicep" -TemplateParameterFile "main.parameters.dev.json"
```

In the Azure Portal, navigate to the resource group where the resources were deployed. You should see the SQL server and database resources. Click on the deployment called **main** and you will see the adminUsername and adminPassword values are blank because we used the ```@secure()``` decorator.

![alt text](https://i.imgur.com/cVB6Bui.png)

## Conclusion

+ The ```@secure()``` decorator is used to secure parameters that contain secret values.
+ Parameter files override default parameter values. Any values specified in the parameter files are overridden by the values you specify **explicitly** when you go to deploy the template.

## Knowledge recap
+ **Parameter** values can be overridden at deployment time. ✅
+ **Variables** cannot. 🚫
+ Limit lengths of parameters with ```@minLength()``` and ```@maxLength()```. (resource names)
+ Limit input value with ```@minValue()``` and ```@maxValue()```. (instance count)
+ Allowed values for ```environmentName``` (dev or prod)
  + Be careful with ```@allowed decorator``` as it can block deployments if you don't keep up with the list.

+ Use templates with parameters for values that might change between deployments.
+ Variables have the same value, so they don't really change between deployments. 
```+ param siteName string = 'mysite-${uniqueString(resourceGroup().id)}'``` shows that when a template is deployed to the same RG in the same subscription over and over again, the siteName parameters default value will always be the same. The only thing that will change will be a few characters at the end of the name. 

## Conclusion
+ Secure Parameters with the ```@secure()``` decorator to ensure sensitive values (e.g. passwords, API keys) are not exposed during deployment/in logs.
+ **Avoid Storing Secrets in Parameter Files**. Use Azure Key Vault to store secrets and reference them in your parameter files. 
+ **Deploy with Secure Secrets** - Reference Azure Key Vault secrets in your main.parameters.dev.json file and deploy templates securely via Powershell. 
+ **Modules** are reusable components that encapsulate a set of related resources. They allow you to break down complex deployments into smaller, manageable pieces.
+ **Parameter** values can be overridden at deployment time. ✅
+ **Variables** cannot. 🚫
+ Limit lengths of parameters with ```@minLength()``` and ```@maxLength()```. (resource names)
+ Limit input value with ```@minValue()``` and ```@maxValue()```. (instance count)
+ Allowed values for ```environmentName``` (dev or prod)
  + Be careful with ```@allowed decorator``` as it can block deployments if you don't keep up with the list.

+ [Loops & Conditions in Bicep](./LoopsConditions.md)