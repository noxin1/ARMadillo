#!/bin/bash
exec &> >(tee -a kubeadm_run.log)

# Source env vars
source ARMadillo/deploy/multi_master/env_vars.sh

# Create kubeadm config file and start kubeadm init
sudo cat <<EOT >> kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: stable
controlPlaneEndpoint: "$LOAD_BALANCER_IP:6443"
EOT

echo "Wait, pulling k8s images needed..."
sudo kubeadm config images pull
sudo kubeadm init --config=kubeadm-config.yaml

# Creating scripts for joining the rest of the masters and workers
grep "kubeadm join\|--discovery-token-ca-cert-hash\|--control-plane" kubeadm_run.log > join_master.sh
sed -i 's/^ *//' join_master.sh
sed -i '1s/^/sudo /' join_master.sh
sed -i '4,5d' join_master.sh
sed -i '$d' join_master.sh
sudo sed -i 's/[[:space:]]*$//' join_master.sh
sudo chmod +x join_master.sh

grep "kubeadm join\|--discovery-token-ca-cert-hash" kubeadm_run.log > join_worker.sh
sed -i '3,4d' join_worker.sh
sed -i 's/^ *//' join_worker.sh
sed -i '1s/^/sudo /' join_worker.sh
sed -i '$d' join_worker.sh
sed -i '$d' join_worker.sh
sudo sed -i 's/[[:space:]]*$//' join_worker.sh
sudo chmod +x join_worker.sh

# Creating .kube directory
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Installing Weave CNI
sudo sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# Copy K8s certs generated by kubeadm init, load-balancer certs and the kubeadm_join_master script to other masters 
unset MASTER01_HOSTNAME
for host in ${MASTERS_HOSTS}; do
    sudo sshpass -p $Pi_PASSWORD rsync -p -a --chmod=+x join_master.sh $Pi_USERNAME@$host:
    sudo sshpass -p $Pi_PASSWORD rsync -a .kube/config $Pi_USERNAME@$host:
    sudo sshpass -p $Pi_PASSWORD rsync -a /etc/kubernetes/pki/ca.crt $Pi_USERNAME@$host:
    sudo sshpass -p $Pi_PASSWORD rsync -a /etc/kubernetes/pki/ca.key $Pi_USERNAME@$host:
    sudo sshpass -p $Pi_PASSWORD rsync -a /etc/kubernetes/pki/sa.key $Pi_USERNAME@$host:
    sudo sshpass -p $Pi_PASSWORD rsync -a /etc/kubernetes/pki/sa.pub $Pi_USERNAME@$host:
    sudo sshpass -p $Pi_PASSWORD rsync -a /etc/kubernetes/pki/front-proxy-ca.crt $Pi_USERNAME@$host:
    sudo sshpass -p $Pi_PASSWORD rsync -a /etc/kubernetes/pki/front-proxy-ca.key $Pi_USERNAME@$host:
    sudo sshpass -p $Pi_PASSWORD rsync -a /etc/kubernetes/pki/etcd/ca.crt $Pi_USERNAME@$host:etcd-ca.crt
    sudo sshpass -p $Pi_PASSWORD rsync -a /etc/kubernetes/pki/etcd/ca.key $Pi_USERNAME@$host:etcd-ca.key
    sudo sshpass -p $Pi_PASSWORD rsync -a /etc/kubernetes/admin.conf $Pi_USERNAME@$host:
done

# Copy join_worker script and cluster config file to workers 
for host in ${WORKERS_HOSTS}; do
    sudo sshpass -p $Pi_PASSWORD rsync -p -a --chmod=+x join_worker.sh $Pi_USERNAME@$host:
    sudo sshpass -p $Pi_PASSWORD rsync -a .kube/config $Pi_USERNAME@$host:
done

kubectl get nodes
echo "Almost there, waiting for all pods to run and for the master node to be in Ready state (sleeping 90s)"
sleep 90

kubectl get pod -n kube-system
kubectl get nodes
