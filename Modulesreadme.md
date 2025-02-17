# Bicep Modules 

## Introduction

*Continuing from[Reusable Templates](./ReusableTemplate.md)in your Bicep files.*

This guide will cover:

+ Seperating code into seperate files for different resources: (Networking, VMs, Storage, etc.)
+ Using parameters between modules to be reused in different deployments.
+  Keep your main bicep file clean and organized with high-level structure and let the granular details be handled in the modules.

## Outputs
After you deploy a template, you often need to retrieve information about the resources that were created. This is where outputs come in. For example:
+ If you deploy a VM, you might want to output the public IP address to SSH back into it. 
+ Your template generates a name dynamically, and you need the output of that name so a script or automation tool can use it in the next step (deploying an applicaiton to that service.)

Modules in Bicep are reusable components that encapsulate a set of related resources. They allow you to break down complex deployments into smaller, manageable pieces. This makes your code more modular, easier to understand, and maintain.

```
output appServiceAppName string = appServiceAppName
```
+ **"output":** The keyword that tells Bicep you are defining an output.
+ **"appServiceAppName"** is the outputs name. When the end user deploys the template successfully, the output value include the name you provided.
+ **"string"** is the output type. Theyy support the same types as parameters. They must always have values, unlike parameters. 

💡You should let Azure provide actual values for resource properties instead of manually guessing or constructing them yourself. If you need to have an output for App Service apps URL, use the app's "defaultHostName" property insteaf of creating a string for the URL yourself. Sometimes these assumptions aren't valid in different environments, or the way the resource works changes, so it's safer to have the resource tell you its own properties.

❌ Do not create outputs for secret values like keys or connection string. Outputs are not secure and can be accessed by anyone who has access to the resource group.

## Define a module
When you want your template to reference a module file, use the ```module``` keyword. It looks similar to a resource declaration, but it has a few key differences:

```bicep
module myModule 'modules/parameters.bicep' = {
  name: 'parameters'
  params: {
    location: location
  }
}
```
+ **"module"** you're about to use another Bicep file as a module. 
+ **"myModule"** is the symbolic name for the module. You can use this name to refer to the module in the rest of your template.
+ **"modules/parameters.bicep"** is the path to the module file. This is a relative path to the module file from the main Bicep file. 
+ **"name"** is the name of the module.
+ **"params"** You can specify any parameters of the module you want. 

## Best Practices for Modules
**Clear Purpose** – Each module should focus on a specific function, like monitoring resources or databases.

**Group Related Resources** – Don’t make a module for every single resource, but combine related ones for better organization.

**Useful Parameters & Outputs** – Keep inputs and outputs simple and logical. Decide if the module should process values or just receive them from the parent template.

**Self-Contained** – Keep variables inside the module instead of defining them in the parent template.

**No Secrets in Outputs** – Never output sensitive data like connection strings or keys for security reasons.

## Break it down
Building upon the previous bicep files we created [Parameters](./ParametersGuide.md) and [Bicep](./bicepreadme.md), we will create a new folder called "modules" in the same folder where we created the main.bicep file. 

![Alt Text](https://i.imgur.com/KsDzuZg.png)

+ Please note that we copied the **parameters** and **variables** from the main.bicep template because the appService.bicep module will have everything it neeeds to work on its own without relying on the main.bicep file. (I will repeat this again later for clarity)



## Reference the module from the parent template
Now that the module handles App Service deployment, you can reference it in the parent template and remove the related resources and variables from the main template.

We will continue to update the templates previously created so that it uses a module for the Azure App Service resources. Modules help keep the main template clear and concise. Our next steps are:
+ Add a new module & move the App Service resources to it.
+ Reference that module from the main.bicep temaplate
+ Add and output for the App Service apps's name name, and remove it from the module and template deployments

## New Module Folder and File
Create a new folder called **"modules"** in the same folder where you created the main.bicep file. Inside the modules folder, create a new file called **"appService.bicep".**

+ Add the follow content into the appService.bicep file but be sure to change the **appserviceplan** to match your own naming convention. 

![Alt Text](https://i.imgur.com/KsDzuZg.png)

It is important to see that the **parameters** and **variables** are copied from the main.bicep template, because the appService.bicep module will have everything it needs to work on its own without relying on the main.bicep file.

💡 This is also known as being "self-contained" and is a best practice for modules. It ensures that the module works independently without breaking if the parent template changes.

## Referenece the module from the parent template
Now that the App Service module is complete, reference it in main.bicep and remove the related **resources and variables** only. 

In the main.bicep **delete:**
+ appServiceApp
+ appServicePlan

**Keep:**
+ StorageAccount

**Add to the bottom of the main.bicep file:**

![Alt Text](https://i.imgur.com/uIgwfgX.png)

The red arrows indicate where you specify parameters for the module by referencing the parameters in the template. 

## Add the host name as an output

Add the following code to the bottom of the main.bicep file to output the App Service app's name:

```bicep
output appServiceAppHostName string = appServiceApp.properties.defaultHostName
```
✔️ This means the module (appService.bicep) provides the App Service hostname as an output.

 **Remember, it is good practice to allow Azure to provide the actual values for resource properties instead of manually guessing or constructing them yourself.** (This is a lab environment and we have not set up a domain name, so the URL will be a default Azure URL)

In the main.bicep file, add the following code to the bottom of the file:

```bicep
output appServiceAppHostName string = appService.outputs.appServiceAppHostName
```
✔️ This takes the output from the module (appService.bicep) and makes it available in main.bicep.

## Validate your Bicep file using What-If 🤔
The ```what-if``` command lets you preview what changes a Bicep template will make before actually deploying it.

![Alt Text](https://i.imgur.com/zDvzJrP.png)

## See the results 

![Alt Text](https://i.imgur.com/VZiZtAJ.png)

You can see next to outputs that the app ServiceAppHostName was created and is named "ecomappv3w24tmhx5whg.azurewebsites.net" This was a result of adding ```output appServiceAppHostName string = appServiceApp.properties.defaultHostName```  to the bottom of the appService.bicep file.


## Conclusion 
+ **Modules** are reusable components that encapsulate a set of related resources. They allow you to break down complex deployments into smaller, manageable pieces.
+ **Parameter** values can be overridden at deployment time. ✅
+ **Variables** cannot. 🚫
+ Limit lengths of parameters with ```@minLength()``` and ```@maxLength()```. (resource names)
+ Limit input value with ```@minValue()``` and ```@maxValue()```. (instance count)
+ Allowed values for ```environmentName``` (dev or prod)
  + Be careful with ```@allowed decorator``` as it can block deployments if you don't keep up with the list.

Next up, we will cover [Securing Parameters](./SecureParameters.md) in your Bicep files.
