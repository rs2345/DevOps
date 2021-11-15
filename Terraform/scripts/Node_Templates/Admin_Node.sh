#!/bin/bash

sudo hostnamectl set-hostname k8s-control


#Revise a better way to inject these values
#sudo vi /etc/hosts
function append_host {

	sudo -- sh -c "echo ADMIN_IP k8s-control >> /etc/hosts"
	sudo -- sh -c "echo NODE_ONE k8s-worker1 >> /etc/hosts"
	sudo -- sh -c "echo NODE_TWO k8s-worker2 >> /etc/hosts"
	
}

function cont_d_conf {
	cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
	overlay
	br_netfilter
EOF

	sudo modprobe overlay

	sudo modprobe br_netfilter

	cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
	net.bridge.bridge-nf-call-iptables  = 1
	net.ipv4.ip_forward                 = 1
	net.bridge.bridge-nf-call-ip6tables = 1
EOF

	sudo sysctl --system
}

function cont_d_inst {
	sudo apt-get update && sudo apt-get install -y containerd

	sudo mkdir -p /etc/containerd

	sudo containerd config default | sudo tee /etc/containerd/config.toml

	sudo systemctl restart containerd
}

function dis_swap {
	sudo swapoff -a

	sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
}

function kube_setup {
	sudo apt-get update && sudo apt-get install -y apt-transport-https curl

	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

	cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
	deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

	sudo apt-get update

	sudo apt-get install -y kubelet=1.21.0-00 kubeadm=1.21.0-00 kubectl=1.21.0-00

	sudo apt-mark hold kubelet kubeadm kubectl
}

#Control Node Only#

function kube_acc {
	sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.21.0

	mkdir -p $HOME/.kube

	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

	sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

function confirm {
	kubectl get nodes
	echo "THIS IS A TEST!!  IF THIS DOES NOT WORK, REVISE"
}

function cali_install {
	kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
}

function kube_node_join {
	ssh-keyscan -H NODE_ONE >> ~/.ssh/known_hosts
	ssh-keyscan -H NODE_TWO >> ~/.ssh/known_hosts
	export JOIN=$(kubeadm token create --print-join-command)
	chmod 400 Dev_Terra.pem 
	ssh -i Dev_Terra.pem ubuntu@NODE_ONE "sudo $JOIN --ignore-preflight-errors=all"
	ssh -i Dev_Terra.pem ubuntu@NODE_TWO "sudo $JOIN --ignore-preflight-errors=all"

}

echo "You need to work in the following commands and try to get their outputs to a text file and sed the join command"

echo "kubeadm token create --print-join-command"
echo "sudo kubeadm join ..."
echo "kubectl get nodes"

append_host
cont_d_conf
cont_d_inst
dis_swap
kube_setup
kube_acc
confirm
cali_install
sleep 50s
kube_node_join

##To be added##
