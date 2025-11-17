// create ec2-instance, configure security group with ssh key-pair

$ brew install awscli // for macOS
$ aws --version

$ aws configure
// AWS Access Key ID [None]: YOUR_AWS_ACCESS_KEY_ID
// AWS Secret Access Key [None]: YOUR_AWS_SECRET_ACCESS_KEY
// Default region name [None]: us-east-1
// Default output format [None]: json

$ ls -l ~/.aws
// config  credentials
$ cat ~/.aws/config
// [default]
// region = us-east-1
// output = json
$ cat ~/.aws/credentials
// [default]
// aws_access_key_id = YOUR_AWS_ACCESS_KEY_ID
// aws_secret_access_key = YOUR_AWS_SECRET_ACCESS_KEY

$ aws ec2 aa
// aws ec2 help

$ aws iam bb
// aws iam help

$ aws ec2 run-instances
      --image-id ami-xxxxxxxx // collext id from any choosen operating-system like: ami-0c3d23d707737957d
      --count 1
      --instance-type t2-micro
      --key-name MyKeyCli
      --security-group-ids sg-903004f8 // creating a new security group
      --subnet-id subnet-6e7f829e // existing any Subnet per Availability Zone

// list of security group available:
$ aws ec2 describe-security-groups

$ aws ec2 describe-vpcs
// collect vpc-id

$ aws ec2 create-security-group --group-name my-sg --description "My SG" --vpc-id vpc-0254784d
// GroupId collect and paste "--security-group-ids sg-903004f8"

$ aws ec2 describe-security-group --group-ids sg-89846598s78f

$ aws ec2 authorize-security-group-ingress \
> --group-id sg-89846598s78f \
> --protocol tcp \
> --port 22 \
> --cidr 178.191.156.151/32

$ aws ec2 create-key-pair \
> --key-name MyKpCli \
> --query 'KeyMaterial' \
> --output text > MyKpCli.pem

$ ls MyKpCli.pem

$ aws ec2 describe-subnets
// collect any subnets-id in any availability-zone

$ aws ec2 describe-instances
// collect "PublicIpAddress"

$ ssh -i MyKpCli.pem ec2-user@35.180.23.198
$ ls -l MyKpCli.pem
$ chmod 400 MyKpCli.pem
$ ls -l MyKpCli.pem


// Filter and Query
$ aws ec2 describe-instances --filters "Name=instance-type,Values=t2.micro" --query "Reservations[].Instances[].InstanceId"
$ aws ec2 describe-instances --filters "Name=tag:Type,Values=Web Server with Docker" --query "Reservations[].Instances[].InstanceId"


// Create AWS User, User Group, Assign Policy permission to that group
$ aws iam create-group  --group-name MyGroupCli
// use descriptive groupname like: System Administrator Group, K8s Admin Group, Jenkins Admin Group

$ aws iam create-user --user-name MyUserCli

$ aws iam add-user-to-group --user-name MyUserCli --group-name MyGroupCli

$ aws iam get-group --group-name MyGroupCli

// Give permission for EC2 service for groups or users
// Policy arn >> IAM > Policies > Filter-policies search: EC2 > AmazonEC2FullAccess > Policy ARN
$ aws iam list-policies --query 'Policies[?PolicyName==`AmazonEC2FullAccess`].{ARN:arn}' --output text

$ aws iam attach-group-policy --group-name MyGroupCli --policy-arn arn:aws:iam:aws:policy/AmazonEC2FullAccess

$ aws iam list-attached-group-policies --group-name MyGroupCli

$ aws iam create-login-profile --user-name MyUserCli --password Mypwd123test --password-reset-required

$ aws iam get-user --user-name MyUserCli
// collect account number from ARN

// create policy and assign to group

$ vim changePwdPolicy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:GetAccountPasswordPolicy",
            "Resource": "*"
        },
        {
            "Effect": "Allow", 
            "Action": "iam:ChangePassword",
            "Resource": "arn:aws:iam::664574038682:user/${aws:username}"
        }
    ]
}

$ aws iam create-policy --policy-name changePwd --policy-document file://changePwdPolicy.json

$ aws iam attach-group-policy --group-name MyGroupCli --policy-arn arn:aws:iam::664574038682:policy/changePwd

$ aws iam create-access-key --user-name MyUserCli
// AccessKeyId and SecretAccessKey collect
// save it in ~/.aws/credentials file for that user

'aws configure' with new user creds
$ aws configure set aws_access_key_id default_access_key
$ aws configure set aws_secret_access_key default_secret_key
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_DEFAULT_REGION=us-west-2

$ aws ec2 describe-instances
$ aws iam create-user --user-name test // AccessDenied error

// Delete User, Group, Policy
$ aws ec2 ss
$ aws iam ss
$ aws iam detach-group-policy --group-name MyGroupCli --policy-arn arn:aws:iam::664574038682:policy/changePwd





// Minikube on Mac Os
$ brew update
$ brew install hyperkit
$ brew install minikube
$ kubectl
$ minikube

$ minikube start --vm-driver=hyperkit

$ minikube get nodes

$ minikube status

$ kubectl version

// Minikube CLI for start up/deleting the cluster
// Kubectl CLI for configuring the minikube cluster

$ kubect get nodes

$ kubectl get pod

$ kubectl get services

$ kubectl create -h

// Deployment - abstraction over Pods
$ kubectl create deployment nginx-depl --image=nginx
$ kubectl get deployment
$ kubectl get pod
$ kubectl get replicaset // managing how many replicas of a pod

$ kubectl edit deployment nginx-depl
$ kubectl get deployment
$ kubectl get pod
$ kubectl get replicaset

$ kubectl logs [podname]

$ kubectl create deployment mongo-depl --image=mongo
$ kubectl get pod
$ kubectl describe pod [podname]

// Whats happening inside pod
$ kubectl exec -it [podname] -- bin/bash // inside the container

$ kubectl delete deployment mongo-depl
$ #kubectl apply -f [filename]
$ touch nginx-deployment.yaml
$ vim nginx-deployment.yaml

$ kubectl apply -f nginx-deployment.yaml
$ kubectl get pod
$ kubectl get deployment
// After any changes to nginx-deployment.yaml file
$ kubectl apply -f nginx-deployment.yaml

$ kubectl apply -f nginx-service.yaml
$ kubectl get pod
$ kubectl get service
$ kubectl describe service nginx-service
$ kubectl get pod -o wide

$ kubectl get deployment -o yaml > nginx-deployment-result.yaml

$ kubectl delete -f [filename] 
$ kubectl delete -f nginx-deployment.yaml

// All the components running inside cluster
$ kubectl get all

// base-64 encoded secret
$ echo -n 'username' | base64

$ kubectl apply -f mongo-secret.yaml
$ kubectl get secret

$ kubectls apply -f mongo.yaml
$ kubectl get all
$ kubectl get pod --watch
$ kubectl describe pod [podname]

$ kubectl apply -f mongo.yaml
$ kubectl get service
$ kubectl describe service [servicename]
$ kubectl get pod -o wide
$ kubectl get all | grep mongodb

$ kubectl apply -f mongo-configmap.yaml
$ kubectl apply -f mongo-express.yaml
$ kubectl get pod
$ kubectl logs [podname]

// nodePort open to browser
$ kubectl apply -f mongo-express.yaml
$ kubectl get service
$ minikube service mongo-express-service
// get the url

// NameSpace
$ kubectl get namespace
$ kubectl cluster-info

$ kubectl create namespace my-namespace
$ kubectl get namespace

$ kubectl api-resources --namespace=false
$ kubectl api-resources --namespace=true

$ kubectl apply -f mysql-configmap.yaml
$ kubectl get configmap -n my-namespace

$ kubectl get all -n my-namespace

$ brew install kubectx
$ kubens
$ kubens my-namespace

$ kubectl get pod -o wide
$ kubectl get endpoints

$ minikube addons enable ingress
$ kubectl get pod -n kube-system
$ kubectl get ns
$ kubectl get all -n kubernetes-dashboard

$ kubectl apply -f dashboard-ingress.yaml
$ kubectl get ingress -n kubernetes-dashboard --watch

$ sudo vim /ect/hosts
// 192.168.64.5 => dashboard.com

$ kubectl describe ingress dashboard-ingress -n kubernetes-dashboard

// ConfigMap and Secret
$ kubectl apply -f mosquitto-without-volumes.yaml
$ kubectl get pod
$ kubectl exec -it mosquitto-938djlk9dk-sfxba -- /bin/sh
>> ls
>> cat /mosquitto/config/mosquitto.config

$ kubectl delete -f mosquitto-without-volumes.yaml

$ kubectl apply -f config-file.yaml
$ kubectl apply -f secret-file.yaml
$ kubectl get secret
$ kubectl get configmap

$ kubectl apply -f mosquitto.yaml
$ kubectl get pod
$ kubectl exec -it mosquitto-938djlk9dk-sfxba -- /bin/sh
>> cat /mosquitto/secret/secret.file
>> cat /mosquitto/config/mosquitto.config

$ helm install <chartname>
$ helm install --values=my-values.yaml <chartname>
$ helm install --set version=2.0.0

$ helm install <chartname>
$ helm upgrade <chartname>
$ helm rollback <chartname>

// Deploy managed K8s cluster on Linode
$ cd downloads/
// set kubeconfig.yaml file as an environment variable
$ export KUBECONFIG=test-kubeconfig.yaml
$ kubectl get node
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm search repo bitnami
$ helm install my-release bitnami/<chart>
$ helm search repo bitnami/mongo

$ helm install [ourname] --values [values file name] [chartname]
$ helm install mongodb --values test-mongodb.yaml bitnami/mongodb
$ kubectl get pod
$ kubectl get all
$ kubectl get secret
$ kubectl get secret mongodb -o yaml // mongodb-root-password: base64 encoded

$ kubectl apply -f test-mongo-express.yaml
$ kubectl get pod
$ kubectl logs [mongoexpress_podname]


// Helm Chart repository for nginx-ingress controller
$ helm repo add stable https://kubernetes-charts.storage.googleapis.com/
$ helm install nginx-ingress stable/nginx-ingress --set controller.publishService.enabled=true
$ kubectl get pod
$ kubectl get svc
$ kubectl apply -f test-ingress.yaml
$ kubectl get ingress

$ kubectl scale --replicas=0 statefulset/mongodb
$ kubectl get pod
$ kubectl scale --replicas=3 statefulset/mongodb
$ kubectl get pod

$ helm ls
$ helm uninstall mongodb
$ kubectl get pod

// Lesson-135
$ docker login [options] [docker-repo]
$ aws ecr get-login
// copy the output as next command
$ docker login -u AWS -p sdklsd.... -e none https://664574038682.dkr.ecr.eu-central-1.amazonaws.com

$ cat .docker/config.json
$ minikube ssh
$ pwd
$ ls -la
$ docker login -u AWS -p sdklsd.... https://664574038682.dkr.ecr.eu-central-1.amazonaws.com

$ ls -a
$ cat .docker/config.json
// "auth":token

// only for minikube
$ scp -i $(minikube ssh-key) docker@$(minikube ip):.docker/config.json .docker/config.json
$ cat .docker/config.json | base64

$ kubectl create secret generic my-registry-key \
> --from-file=.dockerconfigjson=.docker/config.json \
> --type=kubernetes.io/dockerconfigjson
$ kubectl get secret
$ kubectl get secret -o yaml

// create secret in one step
$ kubectl create secret docker-registry my-registry-key-two \
> --docker-server=https://664574038682.dkr.ecr.eu-central-1.amazonaws.com \
> --docker-username=AWS \
> --docker-password=sdklsd....
$ kubectl get secret
$ docker images | grep 664574038682

// For testing my-app-deployment.yaml without secret
$ kubectl apply -f Documents/my-app-deployment.yaml
$ kubectl get pod
$ kubectl logs [podname]
$ kubectl delete -f Documents/my-app-deployment.yaml

// with secrets
$ kubectl apply -f Documents/my-app-deployment.yaml
$ kubectl get pod
$ kubectl describe [podname]

// Lesson-137
$ kubectl get pod // check clean state for minikube
$ helm install prometheus stable/prometheus-operator
$ kubectl get pod
$ kubectl get all
$ kubectl get configmap
$ kubectl get secret
$ kubectl get crd

$ kubectl get statefulset
$ kubectl describe statefulset prometheus-prometheus-prometheus-oper-prometheus > prom.yaml
$ kubectl describe statefulset alertmanager-prometheus-prometheus-oper-alertmanager > alert.yaml
$ kubectl get deployment
$ kubectl describe deployment prometheus-prometheus-oper-operator > oper.yaml
$ kubectl get configmap
$ kubectl get secret
$ kubectl get secret prometheus-prometheus-prometheus-oper-prometheus -o yaml > secret.yaml
$ open .
$ kubectl get configmap prometheus-prometheus-prometheus-oper-prometheus-rulefiles-0 -o yaml > config.yaml
$ kubectl get service // prometheus-grafana
$ kubectl get deployment
$ kubectl get pod
$ kubectl logs prometheus-grafana-67596ff846-p8t6s -c grafana
$ kubectl port-forward deployment/prometheus-grafana 3000
// Grafana login UI: Grafana operator documentation for admin user:"prom-operator"
$ minikube ip

$ kubectl port-forward prometheus-prometheus-prometheus-oper-prometheus-0 9090
$ kubectl apply -f developer-role.yaml
$ kubectl get roles
$ kubectl describe role developer
$ kubectl auth can-i create deployments --namespace dev

// Lesson-140-download kubeconfig file
$ chmod 400 ~/Downloads/online-shop-microservice-kubeconfig.yaml
$ ls -l ~/Downloads/online-shop-microservice-kubeconfig.yaml
$ export KUBECONFIG=~/Downloads/online-shop-microservice-kubeconfig.yaml
$ kubectl get pod
$ kubectl get node
$ ls
$ kubectl create ns microservices
$ kubectl apply -f config.yaml -n microservices
$ kubectl get pod -n microservices
$ kubectl get svc -n microservices

$ kubectl get pod -w //check READY state
$ kubectl logs [podname] -f

// Lesson-142 Helm Chart for MS
$ helm create microservice
// check valid template file using chartname
$ helm template -f email-service-values.yaml microservice
$ helm template -f email-service-values.yaml --set appReplicase=3 microservice
// check errors or warning
$ helm lint -f email-service-values.yaml microservice
// deploy email service
$ kubectl get pod 
$ helm install -f email-service-values.yaml emailservice microservice
// install a chart   override values file     release-name   chart-name
$ helm ls
$ kubectl get pod

$ helm install -f recommendation-service-values.yaml recommendationservice microservice
$ cd charts
$ helm create redis

$ helm template -f values/redis-values.yaml charts/redis
// Another way to check template
$ helm install --dry-run -f values/redis-values.yaml rediscart charts/redis

// Lessaon-143
$ chmod u+x install.sh
$ ./install.sh
$ kubectl get pod
$ helm ls
$ chmod u+x uninstall.sh
$ ./uninstall.sh
$ helm ls
$ kubectl get pod

$ brew install helmfile
$ kubectl get pod
$ helmfile sync
$ helmfile list
$ kubectl get pod
$ helmfile destroy
$ helm ls
$ kubectl get pod

// Lesson-146 Connect EKS-cluster using kubectl from local machine
$ aws configure list
$ aws eks update-kubeconfig --name eks-cluster-test
$ cat .kube/config
$ kubectl get nodes
$ kubectl get ns
$ kubectl cluster-info // show API server endpoint
// Worker Nodes
$ kubectl get nodes
// Lesson-147
$ kubectl apply -f https://githubsercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
$ kubectl get deployment -n kube-system cluster-autoscaler
$ kubectl edit deployment -n kube-system cluster-autoscaler
// In annotations:
        ...
        cluster-autoscaler.kubernetes.io/safe-to-evict= "false"
    spec:
        containers:
        - command:
            ...
            <eks-cluster-name> - eks-cluster-test
            - --balance-similar-node-groups
            - --skip-nodes-with-system-pods=false
            image: k8s.gcr.io/autoscaling/cluster-autoscaler:v1.18.3

$ kubectl get ns
$ kubectl get pod -n kube-system
$ kubectl get pods -n kube-system
$ kubectl get pod cluster-autoscaler-795cb7944-bhfp4 -n kube-system -o wide
$ kubectl logs -n kube-system cluster-autoscaler-795cb7944-f26hr
$ kubectl logs -n kube-system cluster-autoscaler-795cb7944-f26hr > as-logs.txt

$ kubectl get nodes

$ kubectl apply -f nginx-config.yaml
$ kubectl get pod
$ kubectl get svc

$ kubectl edit deployment nginx
// increase replicas: 20
$ kubectl get pod
$ kubectl get pod -n kube-system
$ kubectl logs cluster-autoscaler-795cb7944-f26hr -n kube-system -f

$ kubectl get nodes
$ kubectl get pod
// In AWS console LoadBalancer also have 3 instances

// Lesson - 148
$ kubectl get pod
$ kubectl get node
$ kubectl get ns
$ kubectl create ns dev
$ kubectl apply -f nginx-config.yaml
$ kubectl get pods -n dev
$ kubectl get nodes
// After changing nginx-config.yaml file
$ kubectl apply -f nginx-config.yaml
$ kubectl get pods -n default
$ kubectl get pods -n default -o wide
// Again change and recheck pods
$ kubectl apply -f nginx-config.yaml
$ kubectl get pods -n dev
$ kubectl get pods -n dev -o wide
$ kubectl get nodes

// Lesson - 149
$ curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(unar....)"
$ sudo mv /tmp/eksctl /usr/local/bin

$ brew tap weaveworks/tap
$ brew install weaveworks/tap/eksctl

$ chocolatey install eksctl
$ aws configure list

// https://eksctl.io
$ eksctl create cluster -f eks-cluster.yaml
$ eksctl create cluster \
> --name demo-cluster \
> --version 1.17 \
> --region eu-west-3 \
> --nodegroup-name demo-nodes \
> --node-type t2.micro \
> --nodes 2 \
> --nodes-min 1 \
> --nodes-max 3 

$ kubectl get nodes
$ kubectl get pod

// Lesson - 150
$ kubectl get pod
$ ls .kube/config
$ aws-iam-authenticator --help
$ kubectl get node
$ ssh root@139.59.140.177
$ docker ps
$ docker exec -u 0 -it 0c73a1692b75 or jenkins/jenkins:lts bash
$ curl -L0 https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl;
$ chmod +x ./kubectl;
$ mv ./kubectl /usr/local/bin/kubectl
$ kubectl version
$ curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
$ ls
$ chmod +x ./aws-iam-authenticator
$ mv ./aws-iam-authenticator /usr/local/bin
$ aws-iam-authenticator --help

// Digital Ocean Droplet:
$ root@ubuntu-s-2vcpu-4gb-fra1-01:~# vim config
$ cat .kube/config => copy base64-certificate-authority-data
$ root@ubuntu-s-2vcpu-4gb-fra1-01:~# docker exec -it 0c73a1692b75 bash
$ jenkins@0c73a1692b75:/$ cd ~
$ jenkins@0c73a1692b75:/$ pwd
$ jenkins@0c73a1692b75:/$ mkdir .kube
$ root@ubuntu-s-2vcpu-4gb-fra1-01:~# docker cp config 0c73a1692b75:/var/jenkins_home/.kube/
// 139.59.140.177:8080/job/java-maven-app/credentials/store/folder/domain...
$ aws configure list
$ git add .
$ git commit -m "kubectl deploy through jenkins"
$ git push
$ kubectl get pod // nginx-deployment



// Lesson - 151 (LKE)
$ export KUBECONFIG=~/Downloads/test-kubeconfig.yaml
$ kubectl get node
$ git checkout -b deploy-to-lke
$ git add .
$ git commit -m "add kubectl deploy to lke"
$ git push --set-upstream origin deploy-to-lke
// Go to jenkins click "configure" and "filter by name: deploy-to-lke"
// check new deploy Stage View pipeline
// Build History and Console output
$ kubectl get pod

// Lesson -153 (Complete CI/CD Pipeline - Part 1)
$ git checkout jenkins-jobs
$ ssh root@139.59.140.177
$ docker exec -u 0 -it 0c73a1692b75 bash
root@0c73a1692b75:/# apt-get update
root@0c73a1692b75:/# apt-get install gettext-base
root@0c73a1692b75:/# envsubst
root@0c73a1692b75:/# exit
$ kubectl get node
// Another option to create secret for docker-registry in Jenkinsfile pipeline
$ kubectl create secret docker-registry my-registry-key-jenkins \
> --docker-server=https://664574038682.dkr.ecr.eu-central-1.amazonaws.com \
> --docker-username=AWS \
> --docker-password=sdklsd....
$ kubectl create secret docker-registry my-registry-key \
> --docker-server=docker.io \
> --docker-username=shuvo83qn \
> --docker-password=sdklsd....
$ kubectl get secret
$ git add .
$ git commit -m "add kubectl deploy stage with envsubst"
$ git push
// Go to jenkins click "configure" and in Branch Sources click "Filter by name: jenkins-jobs"
// Scan Multibranch Pipeline logs
// Build History and Console output
$ kubectl get pod
$ kubectl describe pod java-maven-app-66b2384729sdfb-5k7lz
$ kubectl get deployment
$ kubectl get service

// Lesson-154 (Complete CI/CD Pipeline - Part 2)
// Create ECR repository: https://664574038682.dkr.ecr.eu-central-1.amazonaws.com/java-maven-app
$ aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 664574038682.dkr.ecr.eu-central-1.amazonaws.com
// Go to Jenkins > Credentials > System > Global credentials > Add Credentials
// 139.59.140.177:8080/job/java-maven-app/credentials/store/system/domain/_/global/configure
// Create Global credentials 
// Kind: Username with password
// Scope: Global
// Username: AWS
// Password: sdklsd.... > $ aws ecr get-login-password --region eu-central-1
// ID: ecr-credentials

// Create Secret for ECR
$ kubectl get secret
$ kubectl create secret docker-registry aws-registry-key \
> --docker-server=https://664574038682.dkr.ecr.eu-central-1.amazonaws.com \
> --docker-username=AWS \
> --docker-password=sdklsd....
$ kubectl get secret
// Execute Jenkins pipeline and check the deployment
$ git add .
$ git commit -m "add ecr repo stage in jenkinsfile"
$ git push
$ git pull -r
$ kubectl get pod
// Jenkins > Pipeline jenkins-jobs on jenkins-jobs branch > Build Now
// Build History and Console output and check version upgrade in ECR repo
$ kubectl get pod
$ kubectl describe pod java-maven-app-66b2384729sdfb-5k7lz

// Lesson-157 ( Install Terraform )
$ brew install terraform
$ terraform -v
$ brew update
$ brew upgrade terraform
$ terraform -v

// Lesson-158 ( Terraform Provider )
$ pwd ( must be in terraform directory )
$ terraform init
// Initializing the backend...
// Initializing provider plugins...
// Terraform has been successfully initialized!


// Lesson-159 ( Terraform Resources and Data Sources )
$ pwd ( must be in terraform directory )
$ terraform apply
// Plan: 3 to add, 0 to change, 0 to destroy.
// Do you want to perform these actions?
// Terraform will perform the actions described above.
// Only 'yes' will be accepted to approve.
// Enter a value: yes
// Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
// For newly created resources
$ terraform apply

// Lesson-160 ( Changing Resources )
$ terraform apply
$ terraform destroy -target aws_subnet.dev-subnet-2

// Lesson-161 ( Terraform Commands )
$ terraform plan
$ terraform apply -auto-approve
// Destroy all resources
$ terraform destroy 

// Lesson-162 ( Terraform State )
$ terraform apply -auto-approve
$ terraform state
$ terraform state list
$ terraform state show aws_subnet.dev-subnet-1
$ terraform apply -auto-approve
$ terraform state list

// Lesson-163 ( Terraform Outputs )
$ terraform state show
$ terraform plan
$ terraform apply -auto-approve
$ terraform output
$ terraform output dev-vpc-id
$ terraform output dev-subnet-id

// Lesson-164 ( Terraform Variables )
$ terraform apply
// var.subnet_cidr_block
// Enter a value: 10.0.20.0/24
$ terraform apply -var "subnet_cidr_block=10.0.30.0/24"
$ terraform apply -var-file="terraform-dev.tfvars"
$ terraform apply -var-file terraform-dev.tfvars

// Lesson-165 ( Environment variables for Terraform )
$ export AWS_SECRET_ACCESS_KEY=dkajla+KSkdsklfsowe897sdjfksd
$ export AWS_ACCESS_KEY_ID=AKJLKSOEIOWESDJFLKDI
$ terraform apply -var-file terraform-dev.tfvars
// switched to another terminal
$ env | grep AWS
// Global
$ ls ~/.aws/credentials
$ aws configure
// Enter access key, secret key, region, output format
$ terraform apply -var-file terraform-dev.tfvars

$ export TF_VAR_avail_zone="eu-west-3a"
$ terraform apply -var-file terraform-dev.tfvars

// Lesson-166 ( Git and Terraform )
$ pwd ( must be in terraform directory )
$ git init
$ git remote add origin git@gitlab.com:nanuchiku/terraform-learn.git
$ git status
$ git add .
$ git commit -m "initial commit of terraform files"
$ git push -u origin master

// Lesson-167 ( Project:Auto AWS Infrastructure:Part-1 )
$ terraform plan
$ terraform apply -auto-approve
// If any changes
$ terraform plan
$ terraform apply -auto-approve
$ terraform apply -auto-approve
$ terraform state show aws_vpc.myapp-vpc
$ terraform plan
$ terraform apply -auto-approve
$ terraform plan
$ terraform apply -auto-approve
$ terraform plan
$ terraform apply -auto-approve

// Lesson-168 ( Project:Auto AWS Infrastructure:Part-2 )
$ terraform plan
// Create server-key-pair.pem file from AWS EC2 Dashboard
$ mv ~/Downloads/server-key-pair.pem ~/.ssh/
$ ls -l ~/.ssh/server-key-pair.pem
$ chmod 400 ~/.ssh/server-key-pair.pem // Without this aws reject
$ ls -l ~/.ssh/server-key-pair.pem

$ terraform plan
$ terraform apply -auto-approve

$ ssh -i ~/.ssh/server-key-pair.pem ec2-user@52.47.179.234 // public ip address

// Automate SSH key-pair
$ cd ~
$ ls -la .ssh/id_rsa
$ ssh-keygen
$ ls .ssh/id_rsa
$ cat .ssh/id_rsa.pub

$ terraform plan
$ terraform state show aws_instance.myapp-server

$ ssh -i ~/.ssh/id_rsa ec2-user@15.237.150.226
$ exit
$ ssh ec2-user@15.237.150.226
$ rm .ssh/server-key-pair.pem
// Delete from server-key-pair from AWS EC2 Dashboard

// Lesson-169 ( Project:Auto AWS Infrastructure:Part-3 )
$ terraform plan
$ terraform apply -auto-approve
$ ssh ec2-user@15.237.60.176
$ docker ps
// In web browser 15.237.60.176:8080
$ terraform plan
$ terraform apply -auto-approve
// Commit to on new feature branch
$ git checkout -b feature/deploy-to-ec2-default-components
$ git add .
$ git commit -m "add deploy to ec2 default components"
$ git push --set-upstream origin feature/deploy-to-ec2-default-components

// Lesson-170 ( Provisioners in Terraform )
$ git checkout -b feature/provisioners
$ terraform plan
$ terraform apply -auto-approve
$ ssh ec2-user@35.180.137.101
$ ls

// Lesson-172 ( Terraform Modules )
$ git checkout -b feature/modules
$ cd ../terraform-ec2-project/
$ cd modules/
$ cd webserver/
$ touch main.tf variables.tf outputs.tf
$ cd ../subnet/
$ touch main.tf
$ touch variables.tf
$ touch outputs.tf

// Create/Change in Modules
$ terraform init
$ terraform plan
$ terraform apply -auto-approve

// Lesson-173 ( Modules - Part 3 )
$ terraform plan
$ terraform init
$ terraform plan
$ terraform plan
// crash.log file created
$ terraform apply -auto-approve
$ ssh ec2-user@15.188.238.237
$ docker -v

// Lesson-174 ( Terraform and AWS EKS Part-1 )
$ git checkout -b feature/eks
$ terraform init
$ terraform plan

// Lesson-175 ( Terraform and AWS EKS Part-2 )
$ terraform init
// To download local, template, random, kubernetes ...
// .terraform/modules/eks/aws_auth.tf >>> resource "kubernetes_config_map" "aws_auth" {
$ terraform plan
$ terraform apply -auto-approve

// Lesson-176 ( Terraform and AWS EKS Part-3 )
// Connect kubectl with EKS cluster kubeconfig file at ~/.kube/config => contains cluster endpoint and certificate-authority-data, token, iam authenticator
// Prerequisite: AWS CLI, kubectl, aws-iam-authenticator installed in local machine
$ aws eks update-kubeconfig --name myapp-eks-cluster --region eu-west-2
$ kubectl get node
$ kubectl get pod
$ kubectl apply -f ~/Documents/nginx-config.yaml
$ kubectl get pod
$ kubectl get svc // nginx-service-LoadBalancer
$ cat ~/Documents/nginx-config.yaml

// Destroy all resources
$ terraform destroy -auto-approve
$ terraform state list
// terraform.tfstate file resource array is empty now


