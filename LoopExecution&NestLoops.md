# Controlling Loop Execution and Nesting in Bicep

## Introduction

*This guide is from [Deploy Resources Conditionally](./DeployResourcesConditionally.md) if you have been following along*

Loops in Bicep allow for dynamic and efficient resource deployment. "By default, Azure Resource Manager (ARM) deploys resources in loops **in parallel** and in a **non-deterministic order**." 

This is a fancy way of saying that Azure creates multiple resources at the same time instead (**in parallel**) and in no specific order (**non-deterministic**). This helps reduce deployment time.

However, there will be scenarios where **controlling loop execution** is necessary:
- Deploying resources **sequentially**.
- Deploying in **batches**.
- Using **loops within resource properties**.
- **Nesting loops** for complex deployments.

This guide covers how to achieve these goals using **Bicep loops**.

---

## Controlling Loop Execution


### Deploying All Resources in Parallel
```bicep
resource appServiceApp 'Microsoft.Web/sites@2024-04-01' = [for i in range(1,3): {
  name: 'app${i}'
}]
```
💡 *All resources are deployed simultaneously. No ```@batchSize``` decorator used.*

![alt text](https://i.imgur.com/BgBad6B.png)

*Credit:Microsoft Learn*
### Deploying in Batches
To **control batch size**, use `@batchSize(n)`:
```bicep
@batchSize(2)
resource appServiceApp 'Microsoft.Web/sites@2024-04-01' = [for i in range(1,3): {
  name: 'app${i}'
}]
```
💡 *Deploys resources in groups of **2** (batch execution).*
+ **range(1,3)**: means start at 1 & stop before 3 (i.e., 1, 2).
+ **${i}**: is a string interpolation to create unique app names (app1, app2).

![alt text](https://i.imgur.com/Aj6rFjd.png)

*Credit:Microsoft Learn*

If app2 finishes before app1, Bicep will **wait** for app1 to finish before deploying app3.

### Deploying Sequentially
To **force sequential execution**, set `@batchSize(1)`:
```bicep
@batchSize(1)
resource appServiceApp 'Microsoft.Web/sites@2024-04-01' = [for i in range(1,3): {
  name: 'app${i}'
}]
```
💡 *Each resource **waits** for the previous one to finish before deployment starts.*

![alt text](https://i.imgur.com/C4awUAl.png)

*Credit:Microsoft Learn*

---

## Using Loops for Resource Properties
Loops can be used within a resource's **property values**. VNETs must specify subnets which require a unique name and address prefix. Use a **parameter** with an **array of objects** to specify different subnets. 

```bicep
param subnetNames array = [
  'api'
  'worker'
]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'teddybear'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [for (subnetName, i) in subnetNames: {
      name: subnetName
      properties: {
        addressPrefix: '10.0.${i}.0/24'
      }
    }]
  }
}
```
💡 *This dynamically assigns subnet names and address prefixes.*
+ **for (subnetName, i) in subnetNames:**: goes through each subnet name in the list ```subnetNames```.
+ **addressPrefix: '10.0.${i}.0/24'**: Every subnet gets a unique third ocet where {i} is the index of the subnet name. 
+ **Example Output**: (if = subnetNames = ['subnet-dev', 'subnet-prod', 'subnet-test'])
  + **subnet-dev**: 10.0.0.0/24
  + **subnet-prod**: 10.0.1.0/24
  + **subnet-test**: 10.0.2.0/24
---

## Nested Loops
Nested loops allow for complex deployments, such as creating **multiple networks**, each with **multiple subnets**.

### Step 1: Deploy Virtual Networks
```bicep
param locations array = [
  'westeurope'
  'eastus2'
  'eastasia'
]

var subnetCount = 2

resource virtualNetworks 'Microsoft.Network/virtualNetworks@2024-05-01' = [for (location, i) in locations : {
  name: 'vnet-${location}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.${i}.0.0/16'
      ]
    }
  }
}]
```
💡 *Creates virtual networks for each region, ensuring unique address prefixes.*

### Step 2: Add Nested Loops for Subnets
```bicep
resource virtualNetworks 'Microsoft.Network/virtualNetworks@2024-05-01' = [for (location, i) in locations : {
  name: 'vnet-${location}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.${i}.0.0/16'
      ]
    }
    subnets: [for j in range(1, subnetCount): {
      name: 'subnet-${j}'
      properties: {
        addressPrefix: '10.${i}.${j}.0/24'
      }
    }]
  }
}]
```
💡 *Each virtual network gets two unique subnets.*

---

## Summary
| Virtual Network | Location | Address Prefix | Subnets |
|----------------|----------|---------------|----------------|
| vnet-westeurope | westeurope | 10.0.0.0/16 | 10.0.1.0/24, 10.0.2.0/24 |
| vnet-eastus2 | eastus2 | 10.1.0.0/16 | 10.1.1.0/24, 10.1.2.0/24 |
| vnet-eastasia | eastasia | 10.2.0.0/16 | 10.2.1.0/24, 10.2.2.0/24 |

---

## Key Takeaways
✅ **Use `@batchSize` to control loop execution**
- Default: **Parallel execution**
- `@batchSize(n)`: **Batches** of `n`
- `@batchSize(1)`: **Sequential execution**

✅ **Loops can be used inside resource properties** to define dynamic values.

✅ **Nested loops allow complex deployments**, such as multiple virtual networks with multiple subnets.

---

## Next Steps
- Experiment with modifying batch sizes.
- Try customizing subnet configurations.
- Explore nesting additional resource types within loops.

Next guide [Use Loops with Variables & Outputs](./UseLoopsWithVariables&Outputs.md)
