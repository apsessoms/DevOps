# DevOps
Contains bicep templates, ARM templates, &amp; more...

# 🦾 Azure Bicep 

For official guidance, check out the [Bicep documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/).

# What is Bicep?
Bicep is a Domain Specific Language for deploying Azure resources and the goal is to simplify the coding experience with cleaner syntax, intellisense, and better support for code re-use. [The Bicep Playground](https://azure.github.io/bicep/) is a great tool that compares Bicep code side by side with JSON code. This can help you understand the syntax and ease the learning curve for beginners.  

![image](https://github.com/apsessoms/DevOps/assets/99392512/720d2a1e-4fa1-4b49-bfc9-ea0db26f4f5d)

# BICEP Modules 🧱

Azure Bicep Modules allow you to encapsulate and reuse your code which in return makes a more manageable repo. Here are a few reasons why you might use them:
+ **Code Reusability:** Modules allow you to write a piece of code once and then reuse it in multiple places. This can significantly reduce the amount of code you need to write and maintain.
+ **Code Organization:** Organize your code into logical units. Each module can be responsible for deploying a specific resource or set of resources, making your code easier to understand and manage.
+ **Parameterization:** Modules can accept parameters, allowing you to customize their behavior. This makes them flexible and adaptable to different scenarios.
+ **Separation of Concerns:** By encapsulating code into modules, you can separate the details of how resources are created from the higher-level logic of your infrastructure. This makes your code easier to reason about.
+ **Sharing and Collaboration:** Modules can be shared across projects and teams, promoting collaboration and consistency. You can also use modules from the Bicep Module Registry, which contains modules contributed by the community.

![image](https://github.com/apsessoms/DevOps/assets/99392512/d1344e55-9470-48e8-8d2b-be88409cfe8c)

## What are the benefits? 
+ It creates smaller building blocks for your code
+ Easier to maintain because if something breaks, you have smaller units to trace the issue back to
+ Better IaC design that follows best practices

## Best Practices for Module Design 
+ **Single Purpose:** Each module should have a single responsibility and manage a single type of resource or a closely related set of resources. This makes modules easier to understand, test, and reuse.
+ **Parameters:** Make your modules flexible by using parameters. This allows you to customize the behavior of the module for different scenarios.
+ **Security:** Consider security in your module design. Avoid exposing sensitive data like passwords or connection strings in outputs or logs. Make sure a module does NOT output secrets (keys, connection strings, etc)
+ **Versioning:** If you're sharing your modules across multiple projects or teams, consider versioning them. This allows you to make changes without breaking existing users of the module.

## Contributions 
- The **vnet.md walkthrough** guide provides step-by-step instructions on deploying a basic Virtual Network (VNet) in Microsoft Azure using a BICEP template and Visual Studio Code, ensuring a clear and straightforward process for setting up network infrastructure. It covers the installation of required tools, writing BICEP code, deploying the template, and optional cleanup steps, all with the aim of creating a functional VNet in Azure.
- The **CreateStorageAcc&VnetREADME.md** provides guidance on how to deploy a simple virtual network (VNET) using a BICEP file. 
