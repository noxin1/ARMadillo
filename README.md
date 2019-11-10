# ARMadillo

"ARMadillo" is a "pet project", created to provide a way to deploy Kubernetes cluster on Raspberry Pi in both a single and a multi-master topologies, all using simple bash scripts and leveraging the native capabilities of the [kubeadm project](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm/).

This repo provide the software stack of ARMadillo. For an overview of the hardware stack and the buildout process, please visit the [ARMadillo](http://thewalkingdevs.io/tag/armadillo/) page on my personal blog.

## Architecture

![ARMadillo Kubernetes Multi-Master Deployment](img/architecture/multi_master_logical.png)

![ARMadillo Kubernetes Single-Master Deployment](img/architecture/single_master_logical.png)

## Perquisites

### Preparing the Pi's

1. Download the Raspbian OS zip image. ARMadillo was tested working on both [raspbian stretch](https://downloads.raspberrypi.org/raspbian/images/raspbian-2019-04-09/) and [raspbian buster lite](https://www.raspberrypi.org/downloads/raspbian/).

![raspbian stretch download page](img/raspbian/stretch.png)

![raspbian buster lite download page](img/raspbian/buster.png)

2. The LAN the Pi's are connected to needs to be DHCP-enabled. 

3. Flashing the Pi and the deploy Raspbian is easy. First, download and install [balenaEtcer](https://www.balena.io/etcher/?ref=etcher_footer).
    -   Insert SD card to your SD card reader.
    -   Selecet the Raspbian zip file you've just downloaded.
    -   Select the SD card and hit the "Flash!".
    -   Once flashing is done, re-insert the SD card to your SD card reader.
    -   Create *ssh* file and copy it to the */boot* partition. This is required to be able ssh the Pi. 
    -   Insert the card back to the Pi and power it on.
    -   Repeat these steps for each Pi in your cluster.  

![card reader](img/balenaEtcer/reader.jpg)
![balenaEtcer01](img/balenaEtcer/01.png)
![balenaEtcer02](img/balenaEtcer/02.png)
![balenaEtcer03](img/balenaEtcer/03.png)
![balenaEtcer04](img/balenaEtcer/04.png)
![balenaEtcer05](img/balenaEtcer/05.png)
![balenaEtcer06](img/balenaEtcer/06.png)
![ssh](img/balenaEtcer/ssh.png)

4. Now that each PI has it's own DHCP-allocated IP address, ssh to the PI and upgrade its firmware using the ```sudo rpi-update``` command.

	<https://github.com/weaveworks/weave/issues/3717>
    
	<https://github.com/Hexxeh/rpi-update>

### Edit the *env_vars* file

1. Fork this repo :-)

2. The env_vars.sh file is the most important file as it will the determine the environment variables for either the single or multi-master deployment. Edit the *deploy/multi_master/env_vars.sh* file based on your environment and push the changes to your forked repo.

3. Edit your local hosts file where you will connect to the PI's from and add the HAProxy, masters and workers nodes hostname and IP based on the changes you just made to the *env_vars* file. 

## Multi-Master Deployment

1. SSH to the HAProxy node using the allocated DHCP address and the default *raspberry* password.

2. Clone ARMadillo github repository

	```git clone https://github.com/likamrat/ARMadillo.git```

3. 

4. Run the "haproxy_config_hosts.sh" script and wait for the host to restart.

	```./ARMadillo/deploy/multi_master/haproxy_config_hosts.sh```

5. Test successful login using the new hostname/IP and the username/password you allocated in step 3.

5. Repeat steps 1-4 for all remaining masters and workers node. Run the "<node_name>_config_hosts" script on each master/worker respectively:

    - On MASTER01 run: ./ARMadillo/deploy/multi_master/master01_config_hosts.sh
    - On MASTER02 run: ./ARMadillo/deploy/multi_master/master02_config_hosts.sh
    - On MASTER03 run: ./ARMadillo/deploy/multi_master/master03_config_hosts.sh
    - On WORKER01 run: ./ARMadillo/deploy/multi_master/worker01_config_hosts.sh
    - On WORKER02 run: ./ARMadillo/deploy/multi_master/worker02_config_hosts.sh

### Install HAProxy & generate certificates

6. Run the HAProxy installation and certificates generation script.

./ARMadillo/deploy/multi_master/haproxy_install.sh

### Kubernetes nodes perquisites 

7. Run the perquisites script on all masters and workers nodes (no need to run this on the HAProxy Pi)

This step can ~5-10min per node as the script upgrade and update the Pi OS and install kubeadm.  

./ARMadillo/deploy/multi_master/all_k8s_nodes_install_prereq.sh

Before moving to next step, wait for all masters and workers nodes to restart. 

### Install kubeadm

8. On *MASTER01 only*, run the kubeadm initialization script.

./ARMadillo/deploy/multi_master/master01_kubeadm_init.sh

Results should like this:

<ADD_PIC>