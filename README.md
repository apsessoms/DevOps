# DevOps
This repository is a collection of Azure Bicep code templates and guides to help you get started with Infrastructure as Code (IaC) using Bicep. The goal is to provide you with a set of resources that you can use to deploy Azure resources in a consistent, repeatable, and automated way. ✅

# 🦾 Azure Bicep 

For official guidance, check out the [Bicep documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/).

# What is Bicep?
Bicep is a Domain Specific Language for deploying Azure resources and the goal is to simplify the coding experience with cleaner syntax, intellisense, and better support for code re-use. [The Bicep Playground](https://azure.github.io/bicep/) is a great tool that compares Bicep code side by side with JSON code. This can help you understand the syntax and ease the learning curve for beginners.  

![image](https://github.com/apsessoms/DevOps/assets/99392512/720d2a1e-4fa1-4b49-bfc9-ea0db26f4f5d)

## Contributions 
- The [BicepReadMe](./bicepreadme.md) provides a guide on how to deploy a web app with dependencies using Bicep.
- The [Parameters Guide](./ParametersGuide.md) breaks down how to use parameters, variables, default values, and how to deploy your template using the ```what-if``` command. It also contains some more advanced topics. Check it out!
- The [Modules Guide](./Modulesreadme.md) goes through how to use them to create smaller, reusable templates.
- The [Reusable Template](./ReusableTemplate.md) guide will go over objects, tags, and arrays. It will also show you how to restrict values for various parameters. This is helpful if you need to implement naming conventions or other restrictions.
- The [vnet.md walkthrough](./vnet.md) guide provides step-by-step instructions on deploying a basic Virtual Network (VNet) in Microsoft Azure using a BICEP template and Visual Studio Code, ensuring a clear and straightforward process for setting up network infrastructure. It covers the installation of required tools, writing BICEP code, deploying the template, and optional cleanup steps, all with the aim of creating a functional VNet in Azure.
- The [CreateStorageAcc&VnetREADME](./CreateStorageAcct&VnetREADME.md) provides guidance on how to deploy a simple virtual network (VNET) using a BICEP file. 
