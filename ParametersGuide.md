# Parameters and Variables in Bicep Templates
*This guide is building off the [Bicep Readme](./bicepreadme.md) guide that introduces you to the basics of Bicep and creates a <em>main.bicep</em> file. 

## Enhance Flexibility with Parameters and Variables

Utilize parameters and variables to increase the adaptability and reusability of your Bicep templates. By using these elements, you can create flexible deployments that are more customizable and easier to maintain.


## Parameters

Parameters allow you to pass values into your Bicep template at deployment time. If you have ever used PowerShell or Azure CLI, you are asked to provide values for various parameters as seen in the image below:

![Alt Text](https://i.imgur.com/ukGn1h7.png)

You can also make a [parameter file](./Parameters.bicep) that lists all the parameters and values you want to use for the deployment. If you are using an automated process like a deployment pipeline, the pipeline can give the parameter values.

### Variables

**Variables** are used to store values in one place and refer to it throughout the template.

## When to use Parameters & Variables

Best practice for using parameters is for things that can change between deployments:
+ **Location:** You might want to deploy resources in different regions.
+ **Privileged Access:** You might want to deploy resources with different levels of access.
+ **Resource Names:** Your organization might have a naming convention for resources.
+ **Prices:** You might want to deploy resources with different pricing tiers.

**Variables** are usually consistent values for each deployment, but you want to make a value reusable throughout the template.

### Example withOUT a default value

```bicep
param appServiceAppName string
```
+ This <u>requires</u> a user to provide a value when deploying.


### Example WITH a default value

```bicep
param appServiceAppName string = 'ecommerce-launch-app'
```
+ This is known as "hardcoding" a value. Depending on the situation, this can be a good or bad practice. It is good practice when you know the value will not change often.

### Parameters in temaplates
![Alt Text](https://i.imgur.com/b1nWPTt.png)

Now that we have defined a parameter, we can refer to it throughout the rest of the template. 

## Variables

Variables are used to store values that you can reuse throughout your Bicep template. They help to simplify your template and avoid repetition.

![Alt Text](https://i.imgur.com/HoXfub0.png)

+ Using **var** to define a variable.

## Expressions
The opposite of hardcoding. You can use expressions to ask the user for a value during deployment. Expressions also allow you to calculate or retrieves when the template runs. 


### Example
Instead of manually setting the region to 'eastus2' like we did in previous steps, we can use the expression as seen below to deploy **everything in the same region as the resource group:**

![Alt Text](https://i.imgur.com/PqT9M2l.png)

That ```resourceGroup()``` is a function that gives you access to all the information about the resource group. <u>It is best practice to deploy resources in the same Azure region as the resource group</u>.

## Unique Names
Some Azure resources like Storage Accounts and App Services need globally unique names. Instead of asking the user to find an available name (which is annoying),there is another function ```unniqueString()``` that can help with this. 

![alt text](https://i.imgur.com/tyW3ujf.png)

+  If you deploy to the same resource group, ```uniqueString()``` will always return the same value every time.
+ If you deploy to a different resource group, ```uniqueString()``` will return a different value because each resource group has a unique ID. 
+ If you have two resource groups with the same name but exhist in different subscriptions, ```uniqueString()``` will still generate different values because the subscription ID is different.

💡Using template expressions for resource names is helpful because Azure has specific rules for name length and characters. By generating names in the template, users don’t have to worry about following these rules themselves.

## Combining Strings
String interpolation lets you combine text and dynamic values in Bicep. This helps you create meaningful and unique names for your resources.

![alt text](https://i.imgur.com/IX4O3mo.png)

+ **ecommmercelunchapp** is a hard-coded value and easy understand its puspose. 
+ **'${uniqueString(resourceGroup().id)}'** generates a unique string based on the resource group ID. 

## Dev vs Prod
You can require users to choose between a dev environment and a prod environment when deploying:
```
@allowed([
  'dev',
  'prod'
])
param environmentType string
```
You can also set pricing tiers based on the environment type to avoid deploying expensive resources in the dev environment:
```
var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'
var appServicePlanSku = (environmentType == 'prod') ? 'P2V3' : 'F1'
````
## Putting it all together
In the <em>main</em> bicep file, add the following code to the top of the file:
```
param location string = 'eastus2' // 👆🏼 Sets the deployment location to eastus region
param storageAccountName string = 'ecommapp${uniqueString(resourceGroup().id)}' // 👆🏼 Generates a unique storage account name
param appServiceAppName string = 'ecommapp${uniqueString(resourceGroup().id)}' // 👆🏼 Creates globally unique web app names 

@allowed([
  'nonprod'
  'prod'
])
param environmentType string // 👆🏼 Allows users to choose between nonprod and prod environments

var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS' // ✅ Automatically sets the SKU based on the environment type being prod or nonprod
var appServicePlanSkuName = (environmentType == 'prod') ? 'P2v3' : 'F1' // ✅ Uses P2v3 (Premium) for prod and F1 (Free) for nonprod 

```




## Validate your Bicep file using What-If 🤔
You can use the ```az deployment group what-if``` command to see what resources will be deployed before actually deploying them. This is a great way to validate your Bicep file and ensure that it will deploy the resources you expect.

If you are following along, your main.bicep file should look like this example:
![alt text](https://i.imgur.com/Qv3RB5d.png)

The what if command will show you the resources that will be deployed, the changes that will be made, and any errors or warnings that may occur during deployment. Here is the command to run the what-if operation:

![alt text](https://i.imgur.com/W9eOvc1.png)

Summary of changes: 1 resource will be modified (the web app ecommapp3w24tmhx5whg) and 3 other resources are identified, but remain the same aka the deployment "was successful". It is safe to remove the ```--what-if``` flag and deploy the resources. 

![alt text](https://i.imgur.com/yFHhqmx.png)

You have succesfully validated and deployed your Bicep file with parameters and variables! 🙌🏼

## Best Practices

- Use parameters for values that might change between deployments.
- Use variables for values that are derived from parameters or are constants within the template.
- Provide default values for parameters when possible to simplify deployments.

## Conclusion

Understanding how to use parameters and variables effectively in Bicep templates can greatly enhance the flexibility and maintainability of your Azure resource deployments.
