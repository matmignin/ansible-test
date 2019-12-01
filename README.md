#Overview 
Automate 3 load-balanced web servers that host a static website.

* Provider is AWS
  * 3 EC2 Ubuntu instances
  * Elastic Load-Balance
  * Security Group for elb.
* Deployment with Terraform 
  * Updates apt-get and installs python 2
  * Outputs 3 ip address and load balancer address
* Provision with Ansible
  * Uses dynamic inventory to manage ip addresses
  * Installs NGINX 
  * Appends instances ip addresses to `./hosts` under `[ants_servers]`
  * Replaces `nginx.conf` with `default` in `etc/nginx/sites-available/`
  * Hard links `defualt` into `sites-enabled`
  * Uploads `index.html` and `assets` into `/usr/share/nginx/html/`
  * Restarts NGINX
  * Default web page of NGINX replaced with madebymignin website

---
# Setup
1. Make a virtual env
2. Install requirements.txt

```
mkvirtualenv ansible_env
pip install -r requirements.txt

```
3. Set credentials for AWS as environment variables. 
```
export AWS_ACCESS_KEY_ID=<AWS access key>
export AWS_SECRET_ACCESS_KEY=<AWS Secret Access Key>
export EC2_INI_PATH=Ansible/inventory/ec2.ini
export ANSIBLE_INVENTORY=Ansible/inventory/ec2.py
```  
4. Set up ssh-agent to point tokeypair.pem 
```
  ssh-add /<path-to-keypair.pem>
}
```
5. Run Terraform
```
$ terraform init
$ terraform plan
$ terraform apply
```

6. Run Ansible
```
ansible-playbook nginx.yml
- should now be able to visit website 
- it may not work the first time. 

