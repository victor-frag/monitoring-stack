#!/bin/sh
echo "Creating Service Account tiller..."
kubectl create sa tiller --namespace=kube-system

echo "Creating a Cluster Roling Binding with the cluster role admin-cluster for the service account tiller..."
kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

echo "Installing tiller on the minikube.."
helm init --service-account tiller --tiller-namespace kube-system