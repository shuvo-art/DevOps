import boto3
import schedule

ec2_client = boto3.client('ec2', region_name="eu-central-1")

def create_volume_snapshots():
    volumes = ec2_client.describe_volumes(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': [
                    'prod','staging'
                ]
            }
        ]
    )
    for volume in volumes['Volumes']:
        try:
            new_snapshot = ec2_client.create_snapshot(
                VolumeId = volume['VolumeId']
            )
            print(new_snapshot)
        except:
            # handle error here

schedule.every().day.at("10:30").do(create_volume_snapshots)

while True:
    schedule.run_pending()
