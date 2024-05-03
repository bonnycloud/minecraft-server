# Minecraft Server on AWS ECS Fargate using Terraform

![Host your own Minecraft Server on AWS ECS Fargate using Terraform](https://miro.medium.com/v2/resize:fit:1400/format:webp/0*1jHjSrp5L1ZjWHiV.png)

This Terraform main deploys a Minecraft server on AWS ECS using the Fargate launch type. The Minecraft server is deployed in a VPC with public subnets and a security group that allows incoming traffic on port 25565. The ECS task definition specifies the resources to be used by the Minecraft server, including CPU, memory, and the Docker image to run. The ECS service manages the deployment and scaling of the Minecraft server tasks.

## Requirements

- AWS CLI v2
- Terraform v0.13 or later.
- An AWS account with sufficient permissions to create the different resources.

## Configuration

The Terraform `vars.tf` can be configured by modifying the values in the following variables:

- AWS region: The AWS region where the resources will be deployed.
- Application name: The name to be used for the VPC, ECS cluster, and other resources.
- Docker image: The DOcker image you want to use to provide a Minecraft server.

## Usage

1. Clone this repository:

``` bash
git clone git@github.com:bonnycloud/minecraft-server.git
cd minecraft-server
```

2. Optional - Update the Docker image:
``` bash
docker buildx build \
    -t phbasin/minecraft-server:main \
    -f Docker/Dockerfile \
    .
```

3. Initialize Terraform and download the required providers:
``` bash
terraform init
```

4. Create an execution plan:

``` bash
terraform plan -out tf.plan
```

5. Apply the Terraform configuration:

``` bash
terraform apply tf.plan
```

## Access Minecraft Server

1. Connect to the Minecraft server using the public IP address of the ECS task and port 25565.
	1. You can easily grab your new Minecraft Server endpoint navigating to the AWS ECS console.
	1. Navigate to the Tasks tab to see the `minecraft-server` task. Drill into the task to see the public IP and Enjoy.


## Customizing the Minecraft Server

If you want to customize the server: plugins, mods, ... see the following repository: [itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server)

It provides a comprehensive guide on how to customize the Minecraft server, and includes examples for various use cases.

## Note

The Minecraft server version specified in the Terraform `vars.tf` is 1.20.5. This version may become outdated over time, and you may need to update the version to the latest release. You can do this by modifying the `Dockerfile` using the information provided in the following link:
[Download Minecraft: Java edition server](https://www.minecraft.net/en-us/download/server)

## Clean

To remove the resources created by this Terraform `main.tf`, run the following command:

``` bash
terraform destroy
```
