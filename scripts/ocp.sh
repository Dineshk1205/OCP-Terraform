# OCP Deployment Requied Parametes   -- Update Parameters based on your env and requirements . 
vCenter_Server='vcenter.kdinesh.in'          
OPENSHIFT_VER='4.11.26'                      
DOMAIN='kdinesh.in'                           
Compute_Plane_Node_count='2'
CPU='8'
MEMORY='16384'
DISK_SIZE='120'
CONTROL_PLANE_COUNT='3'
ClusterNetwork_CIDR='10.128.0.0/14'
MachineNetwork_CIDR='172.120.0.0/24'
Network_CNI='OpenShiftSDN'
ServiceNetwork_CIDR='172.30.0.0/16'
Openshift_Cluster_Name='ocp4'
VCenter_User='administrator@vsphere.local'
vCenter_Password='xxxxxx'
vCenter_DC='DC-HYD'
vCenter_DataStore='disk1'
Network='dhcp'
vCenter_Cluster='mgmt'
Openshift_ApiVIP='172.100.0.203'
Openshift_IngressVIP='172.100.0.204'
SSH_PUBLICKEY='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJt8c5wP2TFYGl679lFvwFT3r6OJppqAp102wQkn0870 root@linux.kdinesh.in'
PullSecret='{"auths":{"cloud.openshift.com":{"auth":"xxxxxxxxxxxxxxxxxxxxx"}}}'

# OCP Deployement 
yum install -y unzip curl 
curl -O -k https://"$vCenter_Server"/certs/download.zip
unzip download.zip
cp certs/lin/* /etc/pki/ca-trust/source/anchors
update-ca-trust extract    
curl --silent --location "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/"$OPENSHIFT_VER"/openshift-install-linux.tar.gz" | tar xz -C /tmp 
mv /tmp/openshift-install /usr/local/bin 
curl --silent --location "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/"$OPENSHIFT_VER"/openshift-client-linux.tar.gz" | tar xz -C /tmp 
mv /tmp/oc /usr/local/bin 
mv /tmp/kubectl /usr/local/bin 
mkdir ocp    
cd ocp/
cat << EOF > install-config.yaml
apiVersion: v1
baseDomain: $DOMAIN
compute: 
- hyperthreading: Enabled 
  name: worker
  replicas: $Compute_Plane_Node_count
  platform:
    vsphere: 
      cpus: $CPU
      coresPerSocket: 2
      memoryMB: $MEMORY
      osDisk:
        diskSizeGB: $DISK_SIZE
controlPlane: 
  hyperthreading: Enabled 
  name: master
  replicas: $CONTROL_PLANE_COUNT
  platform:
    vsphere: 
      cpus: $CPU
      coresPerSocket: 2
      memoryMB: $MEMORY
      osDisk:
        diskSizeGB: $DISK_SIZE
metadata:
  name: $Openshift_Cluster_Name
networking:
  clusterNetwork:
  - cidr: $ClusterNetwork_CIDR
    hostPrefix: 23
  machineNetwork:
  - cidr: $MachineNetwork_CIDR
  networkType: $Network_CNI 
  serviceNetwork:
  - $ServiceNetwork_CIDR
platform:
  vsphere:
    vcenter: $vCenter_Server
    username: $VCenter_User
    password: $vCenter_Password
    datacenter: $vCenter_DC
    defaultDatastore: $vCenter_DataStore
    diskType: thin
    network: $Network
    cluster: $vCenter_Cluster
    apiVIP: $Openshift_ApiVIP
    ingressVIP: $Openshift_IngressVIP
fips: false
pullSecret: '$PullSecret'
sshKey: '$SSH_PUBLICKEY'
EOF
openshift-install create cluster --log-level=DEBUG


