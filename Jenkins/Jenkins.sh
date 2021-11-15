#!/bin/bash

#Script to deploy jenkins into Worker 1
#These scripts depend on the namespace 'devops-tools' to function
#If you change the namespace, it'll need to be changed in the YAML


function deploy_jenkins {
    
kubectl create ns devops-tools
kubectl apply -f serviceAccount.yaml --validate=false
kubectl create -f volume.yaml
kubectl apply -f deployment.yaml --validate=false
kubectl apply -f service.yaml --validate=false

}

deploy_jenkins

echo "Use the command 'kubectl logs -n devops-tools jenkins-### to gather the Jenkins Password"
echo "Use http:<node ip>:32000 to log into jenkins"
echo "Create Username/Password"