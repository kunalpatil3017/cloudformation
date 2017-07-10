unset  AWS_SESSION_TOKEN

temp_role=$(aws sts assume-role --role-arn "arn:aws:iam::724644326612:role/kunaltest" --role-session-name "client_role_vsts" --query 'Credentials.[SecretAccessKey,AccessKeyId,SessionToken]' --output text)
 
# get the aws_secret_access_key
export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | cut -f1 -d ' ')
 
# get the aws_secret_access_key
export AWS_ACCESS_KEY_ID=$(echo $temp_role | cut -f2 -d ' ')
 
# get the aws_secret_access_key
export AWS_SESSION_TOKEN=$(echo $temp_role | cut -f3 -d ' ')

env | grep -i AWS_

#Inputs
CustomerPrefix=$1
Region=$2
Environment=$3
CIDR=$4

#Values
StackName=$CustomerPrefix"-"$Environment"-vpc-cfs"

#Launch Cloudformation template
aws cloudformation create-stack --stack-name $StackName --template-body file://SingleVPC.template --parameters ParameterKey=CustomerPrefix,ParameterValue=$CustomerPrefix ParameterKey=Region,ParameterValue=$Region ParameterKey=Environment,ParameterValue=$Environment ParameterKey=CIDR,ParameterValue=$CIDR --region $Region

#Wait for Template to complete
aws cloudformation wait stack-create-complete --stack-name $StackName --region $Region
