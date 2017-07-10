#Use temporary Role to login to AWS using AWS Roles
temp_role=$(aws sts assume-role --role-arn "arn:aws:iam::724644326612:role/kunaltest" --role-session-name tets --query 'Credentials.[SecretAccessKey,AccessKeyId,SessionToken]' --output text)
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
AZ=$4
Zone=$5
AppPrefix=$6
Tier=$7
InstanceType=$8
WindowsVersion=$9
Count=$10
echo "$CustomerPrefix $Region $Environment $AZ $Zone $AppPrefix $Tier $InstanceType $Count"
#Values
StackName=$CustomerPrefix"-"$Environment"-"$Region$AZ"-"$Zone"-"$AppPrefix"-ec2-cfs"
Keyname=$CustomerPrefix"_"$Environment"_"$Region$AZ"_"$Zone"_"$AppPrefix"-key"
#Find VPC ID using Tags
Command="aws ec2 describe-vpcs --filters Name=tag:Name,Values=$CustomerPrefix"'_'"$Environment-vpc --output text --query Vpcs[*].VpcId --region $Region"
VPCID=$($Command)
echo "VPC ID : $VPCID"
#Find Subnet ID using Tags
Command="aws ec2 describe-subnets --filters Name=tag:Name,Values=$CustomerPrefix"'_'"$Environment"'_'"$Region$AZ"'_'"$Zone-subnet --output text --query Subnets[*].SubnetId --region $Region"
SubnetID=$($Command)
echo "Subnet ID : $SubnetID"
#Find Security Group ID
Command="aws ec2 describe-security-groups --filters Name=tag:Name,Values=$CustomerPrefix"'_'"$Environment"'_'"$Region$AZ"'_'"$Zone"'_'"$AppPrefix"'_'"$Tier-sg --output text --query SecurityGroups[*].GroupId --region $Region"
SecurityGroupID=$($Command)
echo "Security Group ID : $SecurityGroupID"
#Create & copy Keypair to S3 Private Bucket
aws ec2 create-key-pair --key-name $Keyname --region $Region
#Launch Cloudformation template
aws cloudformation create-stack --stack-name $StackName --template-body file://SingleWindowsunderVPC.template --parameters ParameterKey=CustomerPrefix,ParameterValue=$CustomerPrefix ParameterKey=Region,ParameterValue=$Region ParameterKey=Environment,ParameterValue=$Environment ParameterKey=AZ,ParameterValue=$AZ ParameterKey=Zone,ParameterValue=$Zone ParameterKey=VPCID,ParameterValue=$VPCID ParameterKey=SubnetID,ParameterValue=$SubnetID ParameterKey=SecurityGroupID,ParameterValue=$SecurityGroupID ParameterKey=AppPrefix,ParameterValue=$AppPrefix ParameterKey=KeyName,ParameterValue=$Keyname ParameterKey=Tier,ParameterValue=$Tier ParameterKey=InstanceType,ParameterValue=$InstanceType ParameterKey=WindowsVersion,ParameterValue=$WindowsVersion ParameterKey=Count,ParameterValue=$Count --region $Region
#Wait for Template to complete
aws cloudformation wait stack-create-complete --stack-name $StackName --region $Region
