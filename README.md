# ARMadillo

## Perquisites

1. Edit your local hosts file where you will connect to the PI's from and add the HAProxy, masters and workers nodes hostname and IP. 

2. 



## Multi-Master Deployment

1. Login to the HAProxy node using the allocated DHCP address and the default "raspberry" password.

ssh pi@<DHCP ADDRESS>

2. on the HAProxy node, create and run the git repo clone script.

sudo nano git_clone_private.sh

Copy the content of scripts/git_clone_private.sh and save.

sudo chmod +x git_clone_private.sh

./git_clone_private.sh

3. Run the "haproxy_config_hosts.sh" script and wait for the host to restart.

./armadillo/deploy/multi_master/haproxy_config_hosts.sh

4. Test successful login using the new hostname/IP allocated and the username/password you edited in the env_vars.sh file (if was changed).

5. Repeat steps 1-4 for all remaining masters and workers node. Run the "<node_name>_config_hosts" script on each master/worker respectively:

    - On MASTER01 run: ./armadillo/deploy/multi_master/master01_config_hosts.sh
    - On MASTER02 run: ./armadillo/deploy/multi_master/master02_config_hosts.sh
    - On MASTER03 run: ./armadillo/deploy/multi_master/master03_config_hosts.sh
    - On WORKER01 run: ./armadillo/deploy/multi_master/worker01_config_hosts.sh
    - On WORKER02 run: ./armadillo/deploy/multi_master/worker02_config_hosts.sh

### Install HAProxy & generate certificates

6. Run the HAProxy installation and certificates generation script

./armadillo/deploy/multi_master/haproxy_install.sh

### Kubernetes nodes perquisites 

7. Run the perquisites script on all masters and workers nodes (no need to run this on the HAProxy Pi)

This step can ~5-10min per node as the script upgrade and update the Pi OS and install kubeadm.  

./armadillo/deploy/multi_master/all_k8s_nodes_install_prereq.sh

Before moving to next step, wait for all masters and workers nodes to restart. 

### Install kubeadm on MASTER01

8. 