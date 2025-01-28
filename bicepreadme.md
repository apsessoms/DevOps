# What is Bicep? 🦾

Bicep lets you define your Azure resources using a simple language that looks like JSON, but is easier to write and understand. It makes setting up resources easier and faster. 

## Example scenario

You work for a large enterprise that operates under federal regulations. They are just now migrating over to the cloud and need to bring their infrastructure and applications with them. You know from past experience that sometimes you don't get a lot of time to set up resources quickly. **This is where Bicep comes in.** You decide to build reusable templates for your team to use so they can quickly deploy resources in Azure. 🛫

## Define a resource 🖥️
![Alt Text](https://i.imgur.com/O5AZ07N.png)
+ **"resource"** is the keyword that tells Bicep you are defining a resource.
+ **"storageAccount"** is a symbolic name for the resource which just means they are used withiin the Bicep code to refer to the resource. 
+ **"Microsoft.Storage/storageAccounts"** is the resource type & API version.

The other details of the resource can be set based on your requirements. 

## Dependencies 📦

Bicep templates are not standalone files. They often have resources that depend on each other. If you deploy a Web App, you will need a server to host it. The App Service Plan is a Server that can host the Web App and its declared in your bicep file like this:

![Alt Text](https://i.imgur.com/tUvs3jT.png)
+ **"resource"** is telling Bicep you want to deploy an App Service Plan.
+ **"appServicePlan**" is the symbolic name for the web server. 
+ **"Microsoft.Web/serverFarms"** is the resource type & API version.

The plan resource is named **"ecommerce-launch-server-plan"**, its deployed to the eastus region, and its using the free pricing tier.

## Next steps
You have your App Service Plan and Storage Account defined in your Bicep file. Next, we need to declare the web app that will be hosted on the server. 

![Alt Text](https://i.imgur.com/yveqMnm.png)
+ **"resource"** is telling Bicep you want to deploy a Web App.
+ **"appServiceApp"** is the symbolic name for the resource.
+ **"Microsoft.Web/sites"** is the resource type & API version.


In the properties section, it includes the **Appervice plans symbolic name** (the previous resource we declared) on line: "serverFarmId: appServicePlan.id". This line will get the App Service plan resource ID during deployment. 

![Alt Text](https://i.imgur.com/4qfsIJe.png)

By calling app **resource** using the symbolic name, it points to the App Service Plan because Azure understands the dependency between the **App Service App (web app) and the App Service Plan**.

## Deploy your Bicep file 🚀

Run this command in your terminal to create a new resource group:
```
az group create --name homelab-webapp-eastus-rg --location eastus2
```

![Alt Text](https://i.imgur.com/PPVTIG7.png)

Then run this command to deploy your Bicep file:
```
New-AzResourceGroupDeployment -TemplateFile main.bicep
```

![Alt Text](https://i.imgur.com/DXRdrgn.png)

## Verify your deployment 🧐

You can verify your deployment by checking the Azure portal.

![Alt Text](https://i.imgur.com/seREQzD.png)

Notice that the App Service, App Service Plan, and Storage account were deployed together in the same region as declared in the Bicep template file. 

## Common troubleshooting tips 🛠   

If you run into issues during deployment, check the following:
+ **Location**: Make sure all resources are deployed in the same region.
+ **Duplicate resources**: Check for duplicate resources that may have been created during deployment (even if it failed).
+ **Quotas**: Check if you have reached your subscription limits for resources.
+ **Policy**: Check if there are any policies that may be blocking the deployment. This is extremely common in enterprise environments. 

As always, you can go to Azure monitor to check the logs for more information on what went wrong during deployment.

## Conclusion 

