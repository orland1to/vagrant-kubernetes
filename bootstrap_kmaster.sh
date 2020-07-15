#!/bin/bash

# Initialize Kubernetes
echo "[TASK 1] Initialize Kubernetes Cluster"
swapoff -a
kubeadm init --apiserver-advertise-address=172.42.42.100 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 

# Copy Kube admin config
echo "[TASK 2] Copy kube admin config to Vagrant user .kube directory"
mkdir /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

# Deploy Calico network
echo "[TASK 3] Deploy Calico network"
su - vagrant -c "kubectl create -f https://docs.projectcalico.org/v3.9/manifests/calico.yaml"

# Generate Cluster join command
echo "[TASK 4] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh

#install Knative
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.16.0/serving-crds.yaml
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.16.0/serving-core.yaml

kubectl create namespace ambassador
kubectl apply --namespace ambassador \
  --filename https://getambassador.io/yaml/ambassador/ambassador-rbac.yaml \
  --filename https://getambassador.io/yaml/ambassador/ambassador-service.yaml
kubectl patch clusterrolebinding ambassador -p '{"subjects":[{"kind": "ServiceAccount", "name": "ambassador", "namespace": "ambassador"}]}'
kubectl set env --namespace ambassador  deployments/ambassador AMBASSADOR_KNATIVE_SUPPORT=true
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress.class":"ambassador.ingress.networking.knative.dev"}}'
kubectl --namespace ambassador get service ambassador
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.16.0/serving-default-domain.yaml