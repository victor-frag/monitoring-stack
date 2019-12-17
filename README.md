# Windows Setup Tooling


- Download and install Docker CE for Windows Edge release on https://download.docker.com/win/edge/41561/Docker%20Desktop%20Installer.exe

- Download the kubeclt client https://kubernetes.io/docs/tasks/tools/install-kubectl/

- Download Helm 2.x on https://github.com/helm/helm and setup it on the PATH variable

# Windows Setup configuration


## Docker / Kubernetes
Right click on the the Docker CE for Windows(close to the clock on windows) icon and select the option settings. Go tot he Kubernetes Section and select the options:

- Enable Kubernetes
- Deploy Docker Stacks to Kubernetes by default
- Show system containers (advanced)

After all the containers started, execute the following scripts:

- dashboard.sh
- helm.sh

After setup the dashboard and Helm, it's time to setup the a LoadBalancer, follow the simple steps on this link: https://medium.com/@JockDaRock/kubernetes-metal-lb-for-docker-for-mac-windows-in-10-minutes-23e22f54d1c8

## Sample Application


I forked a [sample application](https://github.com/victor-frag/todo-app-client-server-kubernetes) which is a MERN stack to use on the monitoring stack.


## Monitoring stack


# Prometheus

Talk about prometheus

# Grafana

Talk about grafana