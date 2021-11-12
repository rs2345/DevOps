#!/bin/bash

sudo hostnamectl set-hostname k8s-worker2

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

append_host
cont_d_conf
cont_d_inst
dis_swap
kube_setup