import boto3

ec2_client_paris = boto3.client('ec2', region_name="eu-west-3")
ec2_resource_paris = boto3.resource('ec2', region_name="eu-west-3")

ec2_client_frankfurt = boto3.client('ec2', region_name="eu-central-1")
ec2_resource_frankfurt = boto3.resource('ec2', region_name="eu-central-1")

instance_id_paris = []
instance_id_frankfurt = []

reservations_paris = ec2_client_paris.describe_instances()['Reservations']
for reservation in reservations_paris:
    instances = reservation['Instances']
    for instance in instances:
        instance_id_paris.append(instance['InstanceId'])

response = ec2_resource_paris.create_tags(
    Resources=instance_id_paris,
    Tags=[
        {
            'Key': 'environment',
            'Value': 'prod'
        },
    ]
)

reservations_frankfurt = ec2_client_frankfurt.describe_instances()['Reservations']
for reservation in reservations_frankfurt:
    instances = reservation['Instances']
    for instance in instances:
        instance_id_frankfurt.append(instance['InstanceId'])

response = ec2_resource_frankfurt.create_tags(
    Resources=instance_id_frankfurt,
    Tags=[
        {
            'Key': 'environment',
            'Value': 'dev'
        },
    ]
)
