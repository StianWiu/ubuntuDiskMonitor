# Step 1: Create the systemd service file
```shell
sudo nano /etc/systemd/system/disk_monitor.service
```

# Paste the following content inside the disk_monitor.service file:
```ini
[Unit]
Description=Disk Monitor Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/disk_monitor.sh # Change me
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

# Step 2: Reload systemd to pick up the new service
```shell
sudo systemctl daemon-reload
```

# Step 3: Enable the service so it starts on boot
```shell
sudo systemctl enable disk_monitor.service
```

# Step 4: Start the service now
```shell
sudo systemctl start disk_monitor.service
```

# Step 5: Check status of the service
```shell
sudo systemctl status disk_monitor.service
```
