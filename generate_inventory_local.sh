#!/bin/bash

# echo "#### Cleaning up the space to start again... ####"
vagrant destroy -f || true
rm -rf .vagrant/ || true

vagrant up

# Run the virsh command and store the output in a variable
leases=$(sudo virsh net-dhcp-leases --network vagrant-libvirt)

# Remove the header line from the output
leases=$(echo "$leases" | tail -n +3)

# Initialize variables for each group
manager=""
worker=""

# Loop through each line of the output
while IFS= read -r line; do
  # Extract the hostname and IP address from each line
  hostname=$(echo "$line" | awk '{print $6}')
  ip=$(echo "$line" | awk '{print $5}')

  # Determine the group based on the hostname
  if [[ "$hostname" == *"manager"* ]]; then
    manager+="${hostname} ansible_ssh_host=$(echo "$ip" | sed 's/\/24//')"$'\n'

  else
    worker+="${hostname} ansible_ssh_host=$(echo "$ip" | sed 's/\/24//')"$'\n'
  fi
done <<< "$leases"

# Generate the inventory content
inventory_content="[manager]"$'\n'"${manager}"$'\n'"[worker]"$'\n'"${worker}"

cat << EOF > hosts.ini
[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_connection=ssh
ansible_ssh_user=vagrant
ansible_ssh_extra_args='-o StrictHostKeyChecking=no'
ansible_become_user=root
ansible_port=22

$inventory_content

[nodes:children]
manager
worker

EOF

sleep 6

ansible-playbook -i hosts.ini site.yml