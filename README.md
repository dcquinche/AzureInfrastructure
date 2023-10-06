# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com)
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
 1. [The Policy](#the-policy)
 2. [Packer](#packer)
 3. [Terraform](#terraform)


#### The Policy
  You can create the policy with the following commands, bearing in mind that it is located in the policy.json file.

  ```
  az policy definition create --name tagging-policy --mode Indexed --rules policy.json

  ```

  ```
  az policy assignment create --name tagging-policy --policy tagging-policy

  ```

#### Packer
  First, you should export the environment variables. For this project, make sure you export the ARM_CLIENT_ID, ARM_CLIENT_SECRET and ARM_SUBSCRIPTION_ID variables. In a linux system you could do it like this.

  ```
  export ARM_CLIENT_ID=<client-application-id>

  ```

  ```
  export ARM_CLIENT_SECRET=<client-secret-key>

  ```

  ```
  export ARM_SUBSCRIPTION_ID=<client-subscription-id>

  ```

  Second, you can run the following command to create the packer image, bearing in mind that it is located in the server.json file.

  ```
  packer build server.json

  ```

#### Terraform

First, you should init the terraform environment and that will add a foleder and some files in your project.

  ```
  terraform init

  ```

Before you plan and deploy you project, you could verify for an existing group resource if you want to deploy with that one. With the following command, you can get the client subscription id and use it on the next step.

  ```
  az group show --name <resource-group-name> --query id --output tsv

  ```

In this case, I deployed the project on an existing resource group, so I imported it using the client subscription id.

  ```
  terraform import azurerm_resource_group.<resource-group-name> /subscriptions/<client-subscription-id>/resourceGroups/<resource-group-name>

  ```

Now, you can plan and deploy the project using the following commands.

  ```
  terraform plan -out solution.plan

  ```

  ```
  terraform apply solution.plan

  ```

The process shown above was run in the powershell terminal with the exception of the packer part which was run in the bash terminal.

### Output
**Your words here**

