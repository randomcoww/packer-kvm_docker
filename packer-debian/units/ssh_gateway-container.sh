cat > /etc/systemd/system/ssh_gateway-container.service <<EOF
[Unit]
Description=ssh_gateway-container
After=docker.service
BindsTo=docker.service

[Service]
TimeoutStartSec=0
Restart=on-failure
RestartSec=20
ExecStartPre=-/usr/bin/docker volume rm chef-secret-volume
ExecStartPre=/usr/bin/docker volume create --driver local --opt type=9p --opt o=ro,relatime,sync,dirsync,trans=virtio,version=9p2000.L --opt device=chef-secret --name chef-secret-volume
ExecStartPre=-/usr/bin/docker volume rm rndc-key-volume
ExecStartPre=-/usr/bin/docker stop ssh_gateway
ExecStartPre=-/usr/bin/docker kill ssh_gateway
ExecStartPre=-/usr/bin/docker rm ssh_gateway
ExecStartPre=-/usr/bin/docker pull randomcoww/ssh_gateway
ExecStart=/usr/bin/docker run --rm --name ssh_gateway -v chef-secret-volume:/etc/chef --net=brlan --ip 192.168.63.252 -v /etc/resolv.conf:/etc/resolv.conf:ro randomcoww/chef-client:entrypoint -o 'role[ssh_gateway]'
ExecStartPost=-/bin/sh -c '/usr/bin/docker rmi \$(/usr/bin/docker images -qf dangling=true)'
ExecStop=/usr/bin/docker stop ssh_gateway

[Install]
WantedBy=multi-user.target
EOF
systemctl enable ssh_gateway-container.service
