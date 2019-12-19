# Windows Setup Tooling

## Docker CE For Windows
- Download and [install Docker CE for Windows Edge release](https://download.docker.com/win/edge/41561/Docker%20Desktop%20Installer.exe) 

## Kube Controller
- Download the [kubeclt client](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Helm
- Download [Helm 2.x](https://github.com/helm/helm) and setup it on the PATH variable

# Windows Setup configuration

## Docker / Kubernetes
Right click on the Docker CE for Windows (close to the clock on windows) icon and select the option settings. Go tot he Kubernetes Section and select the options:

- Enable Kubernetes
- Deploy Docker Stacks to Kubernetes by default
- Show system containers (advanced)

After all containers started, run the following scripts:

- [dashboard.sh](https://github.com/victor-frag/monitoring-stack/blob/master/dashboard.sh)
- [helm.sh](https://github.com/victor-frag/monitoring-stack/blob/master/helm.sh)

## MetalLB
Kubernetes does not offer an implementation of network load-balancers (Services of type LoadBalancer) for bare metal clusters.

After setting up the dashboard and Helm, it's time to set up a network LoadBalancer for baremetal enviroments, follow the simple steps on this [link](https://medium.com/@JockDaRock/kubernetes-metal-lb-for-docker-for-mac-windows-in-10-minutes-23e22f54d1c8)

If you wish to know more about the MetalLB, check on the [official page](https://metallb.universe.tf/)

## NGINX
Follow the instructions on the NGINX Installation guide, feel free to install using the kubectl or the helm. Remember that our setup here is using a Baremetal, so there is specific instructions for the Baremetal environment.

- https://kubernetes.github.io/ingress-nginx/deploy/

Since we're using a Baremetal solution and we are using the MetalLB as a LoadBalancer solution for baremetal environment, i decide to change the service of the NGINX to be LoadBalancer instead of NodePort, this change is very simple, you just need to replace the word "NodePort" by "LoadBalancer" on the NodePort service template:

https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/service-nodeport.yaml

This will expose the NGINX with an IP produced by the MetalLB.

## Sample Application
The application required for this work needs to have a Proxy, Frontend, Backend and Database.

I forked a [sample application](https://github.com/victor-frag/todo-app-client-server-kubernetes) which is a MERN stack to use on this monitoring stack.

Before you install the application on your Kubernetes there are a few important things that are necessary to setup on the sample application intallation:

1. One of the steps it's to set the server address in the client's dockerfile, so you need to setup this ip address depending on what kind of service you create to access the server. In this case, just for testing purpouse, I created the service as a LoadBalancer.
2. In the configmap which the server uses, there is an environment variable which represents the address that will have the access granted to the server, so you need to setup this url depending on how you will access your application. In this case i used the URL http://todo.app.com/ but you need to do a few things in order to use a URL like this.
3. You need to add a new configuration on the hosts file to map the IP of the NGINX Controller to the name todo.app.com.
4. Since we are going to access the application trought the address todo.app.com, this will be the URL that needs to be set on the configmap.

If you just try to access the todo.app.com now, it will not work because there is no Ingress resource created in the Ingress Controller to resolve this name, so, the next step will be the Ingress resource creation.

Since this sample application does not use a proxy, we need to create an Ingress resource to set up the route for our application in the Ingress Controller. This file is on this repository. Use the following command to create it:

- kubectl create -f ingress.yaml

After that, you should be able to access the application using the url http://todo.app.com/

## Login Screen
![alt text](https://github.com/victor-frag/monitoring-stack/blob/master/pics/App_login.PNG "Login Screen")

## Signup Screen
![alt text](https://github.com/victor-frag/monitoring-stack/blob/master/pics/App_signup.PNG "Signup Screen")

## Logged Screen
![alt text](https://github.com/victor-frag/monitoring-stack/blob/master/pics/App_logged.PNG "Logged Screen")

# Monitoring stack

## Prometheus
To install Prometheus on our cluster, we will use the [official helm repo](https://github.com/helm/charts) and use the [Prometheus chart](https://github.com/helm/charts/tree/master/stable/prometheus).

Before we install Prometheus, i did some modifications on the values.yaml to comply our local kubernetes, here are the list of changes:

- Disabled the PVC's(it was causing some problems to bound the volume with the prometheus-server POD, so i just disabled for our test purpouse) for the alert manager and the server
- Disabled the RBAC
- Changed the service port of the server to 8081
- Changed the service type of the server to LoadBalancer
- Enabled Ingress for the server
- Added the nginx class annotation on the Ingress resource
- Added the host prometheus.app.com on the Ingress resource

The values.yaml with these values modified it is on this repository.

Since we are using the NGINX to access the Prometheus, it is necessary to do the same procedure that we did with the Sample Application on the host file. It is necessary to add an entry mapping the NGINX external ip to the name prometheus.app.com

To install the Prometheus, run the command below using the values.yaml on this repository.

- helm install stable/prometheus --name prometheus --namespace monitoring

You should be able to access the Prometheus page by accessing the address http://prometheus.app.com/

![alt text](https://github.com/victor-frag/monitoring-stack/blob/master/pics/Prometheus.PNG "Prometheus")

## Grafana
To install Grafana on our cluster, we will use the [official helm repo](https://github.com/helm/charts) and use the [Grafana chart](https://github.com/helm/charts/tree/master/stable/grafana).

Before we install Grafana, i did some modifications on the values.yaml to comply our local kubernetes, here are the list of changes:

- Disabled the RBAC
- Changed the service port of the server to 8082
- Changed the service type of the server to LoadBalancer
- Enabled Ingress on the Grafana
- Added the nginx class annotation on the Ingress resource
- Added the host grafana.app.com on the Ingress resource

The values.yaml with these values modified it is on this repository.

Since we are using the NGINX to access the Grafana, it is necessary to do the same procedure that we did with the Sample Application on the host file. It is necessary to add an entry mapping the NGINX external ip to the name grafana.app.com

To install the Grafana, run the command below using the values.yaml on this repository.

- helm install stable/grafana --name grafana --namespace monitoring

You should be able to access the Grafana page by accessing the address http://grafana.app.com/

You will need the user and password for the first login, in order to grab the password, you need to consult the generated secret on the Grafana installation, use the following command:

- kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

After grab the password, try to log with the user: admin

As soon as you log into Grafana, you need to setup a datasource, in our case, it will be Prometheus. When you get to the Prometheus condifuration inside the grafana, you have a couple options to use as URL, but it's a good practice to use the [DNS that Kubernetes](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/) offer for us for the services, in our case we can use the http://prometheus-server.monitoring:8081.

Now you can create a dashboard or import one, for just test purpouse you can import a dashboard with ID 1621 just to check if it is working.

![alt text](https://github.com/victor-frag/monitoring-stack/blob/master/pics/Grafana_kubernetes.PNG "Grafana Kubernetes")

There is a dashboard for capture metrics of NGINX Controller when he is installed inside a Kubernetes, you just need to import a JSON from [this repo](https://github.com/kubernetes/ingress-nginx/tree/master/deploy/grafana/dashboards) and you will get a NGINX dashboard.

![alt text](https://github.com/victor-frag/monitoring-stack/blob/master/pics/Grafana_nginx.PNG "Grafana NGINX")
