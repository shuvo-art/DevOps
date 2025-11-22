import boto3

ec2_client = boto3.client('ec2', region_name="eu-central-1")
ec2_resource = boto3.resource('ec2', region_name="eu-central-1")

new_vpc = ec2_resource.create_vpc(
    CidrBlock='10.0.0.0/16'
)
new_vpc.create_subnet(
    CidrBlock='10.0.1.0/24'
)
new_vpc.create_subnet(
    CidrBlock='10.0.2.0/24'
)
new_vpc.create_tags(
    Tags=[
        {
            'Key': 'Name',
            'Value': 'my-vpc'
        }
    ]
)

all_available_vpcs = ec2_client.describe_vpcs()
vpcs = all_available_vpcs["Vpcs"]

for vpc in vpcs:
    print(vpc["VpcId"])
    cidr_block_assoc_sets = vpc["CidrBlockAssociationSet"]
    for assoc_set in cidr_block_assoc_sets:
        print("  " + assoc_set["CidrBlockState"])


""" 
{
    'NextToken': 'string',
    'Vpcs': [
        {
            'OwnerId': 'string',
            'InstanceTenancy': 'default'|'dedicated'|'host',
            'Ipv6CidrBlockAssociationSet': [
                {
                    'AssociationId': 'string',
                    'Ipv6CidrBlock': 'string',
                    'Ipv6CidrBlockState': {
                        'State': 'associating'|'associated'|'disassociating'|'disassociated'|'failing'|'failed',
                        'StatusMessage': 'string'
                    },
                    'NetworkBorderGroup': 'string',
                    'Ipv6Pool': 'string',
                    'Ipv6AddressAttribute': 'public'|'private',
                    'IpSource': 'amazon'|'byoip'|'none'
                },
            ],
            'CidrBlockAssociationSet': [
                {
                    'AssociationId': 'string',
                    'CidrBlock': 'string',
                    'CidrBlockState': {
                        'State': 'associating'|'associated'|'disassociating'|'disassociated'|'failing'|'failed',
                        'StatusMessage': 'string'
                    }
                },
            ],
            'IsDefault': True|False,
            'EncryptionControl': {
                'VpcId': 'string',
                'VpcEncryptionControlId': 'string',
                'Mode': 'monitor'|'enforce',
                'State': 'enforce-in-progress'|'monitor-in-progress'|'enforce-failed'|'monitor-failed'|'deleting'|'deleted'|'available'|'creating'|'delete-failed',
                'StateMessage': 'string',
                'ResourceExclusions': {
                    'InternetGateway': {
                        'State': 'enabling'|'enabled'|'disabling'|'disabled',
                        'StateMessage': 'string'
                    },
                    'EgressOnlyInternetGateway': {
                        'State': 'enabling'|'enabled'|'disabling'|'disabled',
                        'StateMessage': 'string'
                    },
                    'NatGateway': {
                        'State': 'enabling'|'enabled'|'disabling'|'disabled',
                        'StateMessage': 'string'
                    },
                    'VirtualPrivateGateway': {
                        'State': 'enabling'|'enabled'|'disabling'|'disabled',
                        'StateMessage': 'string'
                    },
                    'VpcPeering': {
                        'State': 'enabling'|'enabled'|'disabling'|'disabled',
                        'StateMessage': 'string'
                    },
                    'Lambda': {
                        'State': 'enabling'|'enabled'|'disabling'|'disabled',
                        'StateMessage': 'string'
                    },
                    'VpcLattice': {
                        'State': 'enabling'|'enabled'|'disabling'|'disabled',
                        'StateMessage': 'string'
                    },
                    'ElasticFileSystem': {
                        'State': 'enabling'|'enabled'|'disabling'|'disabled',
                        'StateMessage': 'string'
                    }
                },
                'Tags': [
                    {
                        'Key': 'string',
                        'Value': 'string'
                    },
                ]
            },
            'Tags': [
                {
                    'Key': 'string',
                    'Value': 'string'
                },
            ],
            'BlockPublicAccessStates': {
                'InternetGatewayBlockMode': 'off'|'block-bidirectional'|'block-ingress'
            },
            'VpcId': 'string',
            'State': 'pending'|'available',
            'CidrBlock': 'string',
            'DhcpOptionsId': 'string'
        },
    ]
} """