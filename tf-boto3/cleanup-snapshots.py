import boto3
from operator import itemgetter

ec2_client = boto3.client('ec2', region_name="eu-central-1")

volumes = ec2_client.describe_volumes(
    Filters=[
        {
            'Name': 'tag:Name',
            'Values': [
                'prod'
            ]
        }
    ]
)
for volume in volumes['Volumes']:
    snapshots = ec2_client.describe_snapshots(
        OwnerIds=[
            'self',
        ],
        Filters=[
            {
                'Name': 'volume-id',
                'Values': [
                    volume['VolumeId']
                ]
            }
        ]
    )

    sorted_snapshots_by_date = sorted(snapshots['Snapshots'], key=itemgetter('StartTime'), reverse= true)

    for snapshot in snapshots['Snapshots']:
        print(snapshot['StartTime'])

    print("############")

    for snapshot in sorted_snapshots_by_date:
        print(snapshot['StartTime'])

    for snapshot in sorted_snapshots_by_date[2:]:
        print(snapshot['SnapshotId'])
        print(snapshot['StartTime'])
        response = client.delete_snapshot(
            SnapshotId = snapshot['SnapshotId']
        )
        print(response)