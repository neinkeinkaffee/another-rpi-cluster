# another-rpi-cluster

## Enable cgroups

```
./run ansible all -b -m shell -a "sed -i '$ s/$/ cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory/' /boot/cmdline.txt"
./run ansible all -b -m shell -a "reboot"
```

## Install k3s

```
export SERVER_IP=192.168.1.217
./run ansible control -b -m shell -a "curl -sfL https://get.k3s.io | sh -"
./run ansible workers -b -m shell -a "K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=$(ssh pi@pi0 sudo cat /var/lib/rancher/k3s/server/node-token) curl -sfL https://get.k3s.io | sh -"
```

## Reformat and mount USB flash drives

```
./run ansible all -b -m shell -a "umount /dev/{{ var_disk }}; wipefs -a /dev/{{ var_disk }}"
./run ansible all -b -m filesystem -a "fstype=ext4 dev=/dev/{{ var_disk }}" 
./run ansible all -b -m shell -a "blkid -s UUID -o value /dev/{{ var_disk }}"
./run ansible all -m ansible.posix.mount -a "path=/usb src=UUID={{ var_uuid }} fstype=ext4 state=mounted" -b
```
