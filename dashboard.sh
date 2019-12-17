#!/bin/sh
echo "Starting the kubectl proxy in background..."
kubectl proxy &

proxy_pid=$!

until curl -fsSL http://localhost:8001/ > /dev/null; do
    echo "Waiting for kubectl proxy to start..." >&2
    sleep 5
    # TODO add max retries so you can break out of this
done

echo "-------------------"
echo "| Proxy PID: $proxy_pid |"
echo "-------------------"

echo "Applying the kubernetes dashboard to minikube..."
#Install the Kubernetes dashboard on your minikube
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

echo "Recovering the token value from the default secret object in the minikube..." 
IFS=' '
read -ra TOKEN <<< $(kubectl -n kube-system describe secret default | grep "token:")

echo "Updating the config file with the token value for the user docker-desktop..."
kubectl config set-credentials docker-desktop --token="${TOKEN[1]}"

echo "--------------------------------------------------------"
echo "| If you want to stop the Proxy run the command below: |"
echo "| kill -9 $proxy_pid                                         |"
echo "--------------------------------------------------------"
echo "--------------------------------------------------------------------------------------------------------------------------------"
echo "| You need to use the config file located on the .kube folder inside on your user path.                                        |"
echo "| To access the dashboard, copy this URL to your browser and select the option to use config file:                             |"
echo "| http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default |"
echo "--------------------------------------------------------------------------------------------------------------------------------"
