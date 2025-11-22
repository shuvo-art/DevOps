import boto3

ec2_client = boto3.client('ec2', region_name="eu-central-1")
ec2_resource = boto3.resource('ec2', region_name="eu-central-1")

instance_id = "i-04f01be7a765eaf7e"

volumes = ec2_client.describe_volumes(
    Filters=[
        {
            'Name': 'attachment.instance-id',
            'Values': [
                instance_id,
            ]
        },
    ],
)

instance_volume = volumes['Volumes'][0]

snapshots = ec2_client.describe_snapshots(
    OwnerIds=[
        'self',
    ],
    Filters=[
        {
            'Name': 'volume-id',
            'Values': [
                instance_volume['VolumeId'],
            ]
        },
    ]
)

latest_snapshot = sorted(snapshots['Snapshots'], key=itemgetter('StartTime'), reverse=true)[0]
print(latest_snapshot['StartTime'])

new_volume = ec2_client.create_volume(
    SnapshotId=latest_snapshot['SnapshotId'],
    AvailabilityZone='eu-west-3b',
    TagSpecifications=[
        {
            'ResourceType': 'volume'
            'Tags': [
                {
                    'Key': 'Name',
                    'Value': 'prod'
                },
            ]
        },
    ],
)

while True:
    if ec2_resource.Volume(new_volume['VolumeId']).state == 'available':
        ec2_resource.Instance(instance_id).attach_volume(
        VolumeId=new_volume['VolumeId'],
        Device='/dev/sdh'
    )
    break

    




