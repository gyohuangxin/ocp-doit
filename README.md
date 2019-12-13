OpenShift Installer OpenStack Dev Scripts
=========================================

# Pre-requisites

- CentOS 7
- ideally on a bare metal host
- user with passwordless sudo access

# Instructions

## 0) Pre installation

Enable the appropriate openstack repo. 
From the output of 

 `sudo yum search release-openstack`

install the desired repositories for the release you want to use. For example: 

 `sudo yum install centos-release-openstack-rocky`

Install openstack client

`sudo yum install python2-openstackclient`

Install git

`sudo yum install git`

Configure stack user to use ansible <2.9 (2.9 does not support he "failed" filter).
We have to do it at the root level because some of the playbooks apperantly are run 
under root, so just changing it at the user level will not work. 

`sudo pip uninstall ansible`

`sudo pip install "ansible==2.8.7"`

Then verify that you ansible version is 2.8.7

`ansible --version`

Clone this repository:

`cd <to_wherever_you_want_this_source_code_to_live`

`git clone <this repos address>`


CD to repo

`cd ocp-doit`

Get the lastest artifacts hash for the tripleo  if you want to use it, and set it in common.sh
you can get it from:

` https://trunk.rdoproject.org/centos7/current-tripleo/commit.yaml`

by joining the `commit_hash` with the first 8 characters of the `distro_hash` with a `_`. 
For example:
 
    commit_hash: 38c4e3104abdeb4699cfbe7a78fa2f37d7a863b4
    distgit_dir: /home/centos-master-uc/data/puppet-manila_distro/
    distro_hash: 93bde36c78d20a482068674c1391725cdf89b6d9

then the hash becomes:

`38c4e3104abdeb4699cfbe7a78fa2f37d7a863b4_93bde36c`

Install and configure a dns server on the host machine (The machine with the LOCAL_IP address).  The LOCAL_IP
address is used as the dns server for the host as well as the forwarder for the Neutron dnsmasq and other dns services. 

example /etc/dnsmasq.conf

    domain-needed
    bogus-priv
    server=192.168.122.1
    conf-dir=/etc/dnsmasq.d,.rpmnew,.rpmsave,.rpmo
    
## 1) Create local config

Create a config file based on the example and set values appropriate for your
local environment.

`$ cp config.sh.example config.sh`

## 2) Run the scripts in order

- `./01_install_requirements.sh`
- `./02_run_all_in_one.sh`
- `./03_configure_undercloud.sh`
- `./04_ocp_repo_sync.sh`
- `./05_build_ocp_installer.sh`

and finally, run the OpenShift installer to do a deployment on your local
single node OpenStack deployment:

- `./06_run_ocp.sh`

Once the installer is running and the VMs have been created, the following
script will add an `/etc/hosts` entry for the floating IP of the service VM
hosting the API load balancer.  This is required for the installer to be able
to look up the API hostname and talk to the API.

- `./expose-ocp-api.sh`

### Customizing Deployment

You may need to provide further customization to your deployment, such as
limiting the number of master and worker nodes created to fit in your
development environment.  You can do this by generating and editing the
`install-config.yaml` file before launching the deployment.

- `./06_run_ocp.sh create install-config`
- `${EDITOR} ocp/install-config.yaml
- `./06_run_ocp.sh`

## 3) Installer Dev Workflow

Once you have a complete working environment, you do not need to re-run all
sripts.  If you're making changes to the installer, your workflow would look
like:

- `ocp-cleanup.sh`
- `build_ocp_installer.sh`
- `06_run_ocp.sh`
