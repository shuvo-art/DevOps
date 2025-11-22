import boto3

eks_client = boto3.client('eks', region_name="eu-central-1")
eks_cluster_name_list = eks_client.list_clusters()['clusters']

for cluster_name in eks_cluster_name_list:
    response = eks_client.describe_cluster(name=cluster_name)
    cluster_status = response['cluster']['status']
    cluster_endpoint = response['cluster']['endpoint']
    cluster_version = response['cluster']['version']

    print(f"cluster name: {cluster_name}, status: {cluster_status}, endpoint: {cluster_endpoint}, version: {cluster_version}")
    


