#!/usr/bin/env bash

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL AND RUN ANSIBLE
# ----------------------------------------------------------------------------------------------------------------------
apt-get install -y ansible
wget -q https://raw.githubusercontent.com/aleks-ander/zero-client-update-to-fluxbox-20.04/test/ansible/zero.yml -O /root/zero.yml
wget -q https://raw.githubusercontent.com/aleks-ander/zero-client-update-to-fluxbox-20.04/test/ansible/run-once.yml -O /root/run-once.yml
ANSIBLE_LOG_PATH=/root/ansible.log ansible-playbook /root/zero.yml -v
ANSIBLE_LOG_PATH=/root/ansible_once.log ansible-playbook /root/run-once.yml -v

# ----------------------------------------------------------------------------------------------------------------------
# DIABLE VIRTUAL TTY
# ----------------------------------------------------------------------------------------------------------------------
cat <<EOT >>/etc/X11/xorg.conf
Section "ServerFlags"
    Option "DontVTSwitch" "true"
EndSection
EOT

# ----------------------------------------------------------------------------------------------------------------------
# AUTOLOIN AND START X
# ----------------------------------------------------------------------------------------------------------------------
mkdir -p /etc/systemd/system/getty@tty1.service.d/
tee -a /etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --skip-login --noissue --autologin zero --noclear %I $TERM
Type=idle
EOF

echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx >/dev/null 2>&1' >/home/zero/.bash_profile
chown zero:zero /home/zero/.bash_profile

touch /home/zero/.hushlogin
chown zero:zero /home/zero/.hushlogin

sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="quiet"/' /etc/default/grub
echo 'GRUB_RECORDFAIL_TIMEOUT=0' >>/etc/default/grub
update-grub

# ----------------------------------------------------------------------------------------------------------------------
# ALLOW REBOOT + SHUTDOWN
# ----------------------------------------------------------------------------------------------------------------------
echo 'zero ALL=NOPASSWD:/sbin/reboot' >/etc/sudoers.d/zero
echo 'zero ALL=NOPASSWD:/sbin/poweroff' >>/etc/sudoers.d/zero

# ----------------------------------------------------------------------------------------------------------------------
# GNU Privacy Guard is cryptographic software suite. Install for adding keys and repos.
# ----------------------------------------------------------------------------------------------------------------------
apt-get install gnupg -y

# ----------------------------------------------------------------------------------------------------------------------
# CRON
# ----------------------------------------------------------------------------------------------------------------------
wget https://raw.githubusercontent.com/aleks-ander/zero-client-update-to-fluxbox-20.04/test/ansible/ansible-cron.sh -O /etc/cron.hourly/ansible
chmod +x /etc/cron.hourly/ansible
