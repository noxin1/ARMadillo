# Set env vars

# Pi creds
export  Pi_USERNAME="pi"          # Pi default OS username is "pi"
export  Pi_PASSWORD="raspberry"   # Pi default OS password is "raspberry"

# Network parameters
export  MASTER01_HOSTNAME=kubemaster
export  WORKER01_HOSTNAME=kubenode1
export  WORKER02_HOSTNAME=kubenode2
export  WORKER03_HOSTNAME=kubenode3
export  WORKER04_HOSTNAME=kubenode4
export  WORKER05_HOSTNAME=kubenode5
export  MASTER01_IP=10.1.1.105
export  WORKER01_IP=10.1.1.110
export  WORKER02_IP=10.1.1.111
export  WORKER03_IP=10.1.1.112
export  WORKER04_IP=10.1.1.113
export  WORKER05_IP=10.1.1.114
export  DNS=10.1.1.1

# No need to change unless you have less or more workers
export MASTERS_HOSTS="$MASTER01_HOSTNAME"
export MASTERS_IPS="$MASTER01_IP"
export WORKERS_HOSTS="$WORKER01_HOSTNAME $WORKER02_HOSTNAME $WORKER03_HOSTNAME $WORKER04_HOSTNAME $WORKER05_HOSTNAME"
export WORKERS_IPS="$WORKER01_IP $WORKER02_IP $WORKER03_IP $WORKER04_IP $WORKER05_IP"
