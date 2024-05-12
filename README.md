# swisscom-terraform-assignment

ASSIGNMENT: 

In this assignment we kindly ask you to provision some AWS resources by using Terraform.
We'd like to track a list of files that have been uploaded. For this we require:
- A S3 Bucket to where we upload files
- A DynamoDb table called `Files` with an attribute `FileName`
- A Stepfunction that writes to the DynamoDb table
- A Lambda that get's triggered after a file upload and then executes the stepfunction.

Pre-Requisite

1) Python
2) Docker
3) Docker Compose
4) AWS CLI
5) Terraform 1.8.3
6) Terraform Provider 5.48/5.49

##############################

### NOTE: I updated the version of localstack from 1.3.1 to 3.4, because locastack 1.3.1 was not compatible to work with latest terraform API. 
#### Creating step-function was giving error to provision so after troubleshooting I upgraded the version of localstack so it can work with the latest version of terraform provider.
        

#############################

To Run the Stack

####Step 1) Clone the repository using below URL

https://github.com/ibrahim9t5/swisscom-terraform-assignment.git

####Step 2) go to the repository using ssh terminal

####Step 3) In repo terminal run local stack using docker:

docker-compose up

####Step 4) Make sure AWS is authenticated in local stack using:

export AWS_ACCESS_KEY_ID=foobar 
export AWS_SECRET_ACCESS_KEY=foobar 
export AWS_REGION=eu-central-1

####Step 5) Run below aws command to initialize terraform: #### make sure you are in the repo #####

terraform init

####Step 6) Run below command to checked the resources that are going to provision using terraform:

terraform plan

####Step 7) Run below command to provision resources and apply all the changes with approval

terraform apply --auto-approve

####Step 8) After terraform is applied with all resources provisioned, Run below command:

aws --endpoint-url http://localhost:4566 s3 cp README.md s3://test-bucket/

#### This command will copy file to s3 bucket, which will then trigger lambda function that will execute step-function that will add entry in dynamodb table

####STEP 8) Run below command to list and check step-function that is provisioned

aws --endpoint-url http://localhost:4566 stepfunctions list-state-machines

####STEP 9) Run below command to chekc if step-function executed properly and wrote the entry in dynamodb table

aws --endpoint-url http://localhost:4566 dynamodb scan --table-name Files

##########################

### NOTE: 
1) to restart docker in case of any error during docker up run: docker-compose restart
2) Make DEBUG = 1 to enable terraform debugging
3) Run export TF_LOG=DEBUG to enable debug logging