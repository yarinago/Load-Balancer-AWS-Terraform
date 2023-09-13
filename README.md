<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#Summary">Summary</a></li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#How to use">How to use</a></li>
      </ul>
    </li>
    <li><a href="#How to Check">How to Check</a></li>
  </ol>
</details>


# Summary
This is a terraform project (which use a docker provider) that create a set of clusters (1 or more) on AWS cloud with the following architecture:
| Service   | Sub-services          |
| :-------: |:----------------------|
|**`VPC`**  |right foo              |
|           |nat gateways           |
|           |internet gateway       |
|           |private/public subnets |
|           |route tables           |
|           |elastic ips            |
|**`ALB`**  |Target Group           |
|           |Listeners              |
|           |Security groups        |
|**`EC2`**  |key Pair               |
|           |X Instances            |


Each instance run an apache web server that show this message `Hello from web-server (1..X)``
The instances are managed by an ALB with a round-robin type of load balancing.
The ALB and the instances has a health endpoint: 
* *ALB* - `/health`, return the name of the Alb
* *EC2* - `/`, return "web-server-X" (X = the number of instance)


#### Shell Script
Attached to this project there is a bash script to manage the clusters.<br />
Manage actions could be installation/start/stop/status


# Getting Started
This is how you run the code. Make sure that you follow the step correctly and you have your `Prerequisites` before going to `Installation`
## Prerequisites
* Create an AWS Profile named `beaconcure-terraform` to use as a login profile for your aws cloud.
Follow this [link](https://medium.com/@nicksanders41/setting-up-aws-profiles-for-vscode-9257a865e042)
* In this version of the code you will not need it.<br /> 
But do know that if you want to use your own public key you will need to create Pam (key) file. 
This [link](https://www.suse.com/support/kb/doc/?id=000018152) could be helpful
## How to use

The easiest way to run the code is to use the `manage-cluster.sh` script. <br />
Copy the script to a text file and save the file as a shell script (.sh)<br /><br />
The script expect 4 variables:
1. **TERRAFORM_VERSION** - the version of the terraform to install (if -1 then do not install)
2. **AWSCLI_VERSION** - the aws cli version to install (if -1 then do not install)
3. **CLUSTER_NUMBER** - the cluster to work on (1 - first cluster / 2 - second / ...)
4. **ACTION** - install/start/stop/status
#### Install
In the same folder you saved the script you can run this example:
```sh
./manage-cluster.sh 0.12.24 2.0.30 1 install
```
#### Start
In the same folder you saved the script you can run this example:
```sh
./manage-cluster.sh -1 -1 1 start
```
#### Stop
In the same folder you saved the script you can run this example:
```sh
./manage-cluster.sh -1 -1 1 stop
```
#### Status
In the same folder you saved the script you can run this example:
```sh
./manage-cluster.sh -1 -1 1 status
```

# How to Check
1. Take your `ALB DNS` and enter it to a new tab (you can find it in your AWS cloud under the ALB service)
2. In the same tab with the same DNS enter `/[YOUR_ALB_HEALTH_CHECK_PATH]` (default is `/health`)
3. We can see that the EC2 is healthy by looking at the target group. <br />
If we want to enter the actual health entrypoint than we need to crate a bastion instance and give permission to it through the route tables.