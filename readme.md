# service-mesh CLI
`service-mesh` cmdlets consists of a BASH based REST-client for interacting with the **VMware NSX Service Mesh** platform API.  
It provides a series of CLI commands for NSX-SM registration, ISTIO lifecycle and cluster deletion.  

It is intended to be stupidly simple.  
Ideal for lab or demo purposes.  

## SETUP
#### 1: Ensure you have JQ and CURL installed
Ensure you meet the pre-requisites on linux to execute to scripts.  
Currently, these have been tested on Centos/Fedora.  

##### Centos
```shell
yum install curl jq
```

##### Ubuntu
```shell
apt-get install curl jq
```

##### Mac OSX
Install brew
```shell
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
```

Install curl & jq
```shell
brew install curl jq
```

#### 2: Clone this repository
Perform the following command to download the scripts - this will create a directory `service-mesh` on your local machine
```shell
git clone https://github.com/apnex/service-mesh
```

#### 3: Configure VKE and NSX-SM environment parameters
Modify the `parameters` file to reflect your correct environment and authentication tokens.

#### parameters
```
# NSX Service Mesh Parameters
SMHOST="staging-1.servicemesh.biz"
SMTOKEN="<insert-service-mesh-token-here>"

# VKE Cloud Services Organisation Details
CSP_ORGANIZATION_ID="12345678-1234-1234-1234-123456781234"
CSP_REFRESH_TOKEN="12345678-1234-1234-1234-123456781234"
```

## USAGE
The following examples leverage the Cloud PKS (VKE) platform.  
If you have another Kubernetes cluster, use the appropriate `kubectl` commands.  
We will leverage the VKE cluster named `dc-cluster-east` in these examples.  
Refer to **SYNTAX** for full individual command descriptions.  

### Onboard new VKE Cluster into NSX Service Mesh
#### 1: Login to VKE Cluster
```shell
./cmd.clusters.login.sh dc-cluster-east
```

This will authenticate to the VKE platform and set the local `kubectl` context.  

#### 2: Download the NSX Service Mesh onboarding YAML script
```shell
./cmd.clusters.script.get.sh dc-cluster-east
```

This will download the registration YAML file `nsx-sm_dc-cluster-east.yaml` to the current working directory.  

#### 3: Apply registration script to cluster
```shell
kubectl apply -f nsx-sm_dc-cluster-east.yaml
```

This will deploy the NSX-SM proxy and initiate registration to the service.  

#### 4: Watch registration process on cluster
```shell
watch -n 5 "kubectl get pods --all-namespaces"
```

This will monitor NSX-SM proxy pod creation on your cluster.  

#### (Optional) Instead perform steps 2-4 with demo-magic
```shell
./01-register.sh dc-cluster-east
```

This will execute each of the steps 2-4 upon pressing the enter key (useful for demos).  

#### 5: Monitor registration progress in NSX Service Mesh
```shell
watch -c -n 5 "./cmd.clusters.status.sh 2>/dev/null"
```

This will monitor cluster registration process to the NSX-SM service.  

Upon successful registration the following status will appear:  
```shell
id               state       details
--               -----       -------
dc-cluster-east  LIVE_NO_SM  connected, but not aware of istio in this cluster
```

#### 6: Initiate installation of ISTIO
```shell
./cmd.clusters.instance.install.put.sh dc-cluster-east
```

This will kick off an asynchronous ISTIO data-plane installation for your cluster.  
```shell
id               state       details
--               -----       -------
dc-cluster-east  INSTALLING  installing istio
```

Upon successful installation - cluster status will be "LIVE".  
```shell
id               state  details
--               -----  -------
dc-cluster-east  LIVE 
```

ISTIO can now be enabled per namespace using the following syntax:  
```shell
kubectl label namespace default istio-injection=enabled --overwrite=true
```

This enables the `default` namespace for ENVOY proxy injection.  

You can validate this setting as per:  

```shell
kubectl get namespace -L istio-injection
```

Cluster `dc-cluster-east` is now fully onboarded to NSX-SM.  

You can now deploy your application onto your cluster and into the NSX service mesh.  

### Remove existing VKE Cluster from NSX Service Mesh  
#### 1: Login to VKE Cluster
```shell
./cmd.clusters.login.sh dc-cluster-east
```

This will authenticate to the VKE platform and set the local `kubectl` context.  

#### 2: Initiate removal of ISTIO from cluster
```shell
./cmd.clusters.instance.install.delete.sh dc-cluster-east
```

This will kick off an asynchronous ISTIO data-plane removal for your cluster.  
```shell
id               state         details
--               -----         -------
dc-cluster-east  UNINSTALLING  uninstalling istio
```

Upon successful ISTIO removal - cluster status will be "LIVE_NO_SM".  
```shell
id               state       details
--               -----       -------
dc-cluster-east  LIVE_NO_SM  connected, but not aware of istio in this cluster
```

ISTIO is now removed from your cluster, but remains registered to NSX Service Mesh.  

#### 3: Delete cluster from NSX Service Mesh
```shell
./cmd.clusters.instance.delete.sh dc-cluster-east
```

This will remove the cluster entirely from the NSX Service Mesh platform.  

#### (Optional) Instead perform steps 2-3 in a single command
```shell
./cmd.clusters.instance.delete.sh dc-cluster-east
```

This will execute both steps 2-3 in a single command.  

#### 4: Download the NSX Service Mesh onboarding YAML script
```shell
./cmd.clusters.script.get.sh dc-cluster-east
```

This will download the registration YAML file `nsx-sm_dc-cluster-east.yaml` to the current working directory.  

#### 5: Initiate removal of NSX Service Mesh proxy from cluster
```shell
kubectl delete -f nsx-sm_dc-cluster-east.yaml
```

This will remove the the NSX-SM proxy deployment from your cluster.  

#### 6: Watch de-registration process on cluster
```shell
watch -n 5 "kubectl get pods --all-namespaces"
```

This will monitor NSX-SM proxy pod deletion from your clusters.  

#### (Optional) Instead perform steps 4-6 with demo-magic
```shell
./02-unregister.sh dc-cluster-east
```

This will execute each of the steps 4-6 upon pressing the enter key (useful for demos).  

#### 6: Verify cluster now removed from NSX Service Mesh platform
```shell
./cmd.clusters.status.sh
```

This will show that the cluster `dc-cluster-east` has been completely removed from NSX Service Mesh.  

## SYNTAX
The following is the individual command reference.  

### clusters.login
This command logs you into your Cloud PKS (VKE) cluster.  
It sets the local context for all further `kubectl` commands.  

command usage: **cmd.clusters.login.sh `<cluster.name>`**  
**Where:**  
- `<cluster.name>` is the name for your VKE Kubernetes cluster

### clusters.get
This command lists the names of clusters registered to the NSX Service Mesh platform.  
For more verbose information, use `clusters.status` instead.  

command usage: **cmd.clusters.get.sh**

### clusters.script.get
This command downloads the NSX Service Mesh registration YAML file to the current working directory.  
The file name will be in the format `nsx-sm_<cluster.name>.yaml`.  
Apply this against your Kubernetes cluster using the appropriate `kubectl apply -f <filename>` command.  

command usage: **cmd.clusters.script.get.sh `<cluster.name>`**  
**Where:**  
- `<cluster.name>` is the globally-unique name for your Kubernetes cluster

### clusters.instance.install.put
This command initiates the local ISTIO data-plane installation into your Kubernetes cluster.  
This action will return immediately and perform the install asynchronously in the background.  

command usage: **cmd.clusters.instance.install.put.sh `<cluster.name>`**  
**Where:**  
- `<cluster.name>` is the globally-unique name for your Kubernetes cluster

### clusters.instance.install.delete
This command initiates the local ISTIO data-plane removal from your Kubernetes cluster.  
This action will return immediately and perform the removal asynchronously in the background.  

command usage: **cmd.clusters.instance.install.delete.sh `<cluster.name>`**  
**Where:**  
- `<cluster.name>` is the globally-unique name for your Kubernetes cluster

### clusters.instance.delete
This command will de-register and delete the Kubernetes cluster from the NSX Service Mesh platform.  
This action will return immediately and perform the removal asynchronously in the background.  

**Note:** If ISTIO is deployed into the cluster, NSX Service Mesh will also trigger its removal prior to deletion.  
This removal is equivalent to performing the `clusters.instance.install.delete` action.  

command usage: **cmd.clusters.instance.delete.sh `<cluster.name>`**  
**Where:**  
- `<cluster.name>` is the globally-unique name for your Kubernetes cluster

## License

MIT © [Andrew Obersnel](https://github.com/apnex)

