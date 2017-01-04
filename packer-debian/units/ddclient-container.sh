cat > /etc/systemd/system/ddclient-container.service <<EOF
[Unit]
Description=ddclient-container
After=docker.service
BindsTo=docker.service

[Service]
TimeoutStartSec=0
Restart=on-failure
RestartSec=20
ExecStartPre=-/usr/bin/docker volume rm chef-secret-volume
ExecStartPre=/usr/bin/docker volume create --driver local --opt type=9p --opt o=ro,relatime,sync,dirsync,trans=virtio,version=9p2000.L --opt device=chef-secret --name chef-secret-volume
ExecStartPre=-/usr/bin/docker volume rm rndc-key-volume
ExecStartPre=-/usr/bin/docker stop ddclient
ExecStartPre=-/usr/bin/docker kill ddclient
ExecStartPre=-/usr/bin/docker rm ddclient
ExecStartPre=-/usr/bin/docker pull randomcoww/chef-client:entrypoint
ExecStart=/usr/bin/docker run --rm --name ddclient -v chef-secret-volume:/etc/chef randomcoww/chef-client:entrypoint -o 'role[ddclient_freedns]'
ExecStartPost=-/bin/sh -c '/usr/bin/docker rmi \$(/usr/bin/docker images -qf dangling=true)'
ExecStop=/usr/bin/docker stop ddclient

[Install]
WantedBy=multi-user.target
EOF
systemctl enable ddclient-container.service
