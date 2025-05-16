#!/bin/bash
# curl -o ubuntu-init.sh https://raw.githubusercontent.com/ukrgsm/arch/main/ubuntu-init.sh
set -e
ENABLE_SUDO_NOPASSWD=true
ENABLE_UPDATE=true
ENABLE_SSH_HARDEN=true
ENABLE_NEW_USER=false
ENABLE_BASE_TOOLS=true
ENABLE_FIREWALL=false
ENABLE_FAIL2BAN=true
ENABLE_TIME_SYNC=true
ENABLE_HOSTNAME=false
ENABLE_CLOUDINIT_DISABLE=true

### === Функції === ###

grant_sudo_nopasswd() {
    local user
    user=$(whoami)

    echo "👤 Додаємо користувача '$user' до групи sudo та дозволяємо запуск sudo без пароля..."

    sudo usermod -aG sudo "$user"

    # Створюємо sudoers-файл для користувача (без пароля)
    echo "$user ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/$user" > /dev/null
    sudo chmod 440 "/etc/sudoers.d/$user"

    echo "✅ Користувач '$user' може виконувати команди sudo без пароля."
}

update_system() {
    echo "🔄 Оновлення системи..."
    sudo apt update && sudo apt upgrade -y
    sudo apt autoremove -y
}

harden_ssh() {
    echo "🔒 Посилення налаштувань SSH..."
    sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    sudo systemctl restart ssh
}

create_new_user() {
    local username="adminuser"
    echo "👤 Створення нового sudo-користувача '$username'..."
    sudo adduser "$username"
    sudo usermod -aG sudo "$username"
}

install_tools() {
    echo "🛠️ Встановлення базових утиліт..."
    sudo apt install -y vim mc curl git net-tools htop unzip lsb-release ca-certificates gnupg software-properties-common bash-completion 
    #wget nmap tcpdump whois iperf3 mtr dnsutils rclone logwatch jq yq
}

configure_firewall() {
    echo "🔥 Налаштування брандмауера UFW..."
    sudo apt install -y ufw
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw --force enable
    sudo ufw status verbose
}

install_fail2ban() {
    echo "🛡️ Встановлення та запуск Fail2Ban..."
    sudo apt install -y fail2ban
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
}

enable_time_sync() {
    echo "🕒 Увімкнення синхронізації часу..."
    sudo timedatectl set-ntp true
    sudo timedatectl set-timezone Europe/Zurich
    timedatectl status
}

set_hostname() {
    local new_hostname="teleport"
    echo "🏷️ Встановлення hostname: $new_hostname"
    sudo hostnamectl set-hostname "$new_hostname"
    echo "127.0.1.1   $new_hostname" | sudo tee -a /etc/hosts
}

disable_cloudinit() {
    echo "☁️ Вимкнення cloud-init..."
    sudo systemctl disable cloud-init
    sudo systemctl mask cloud-init
}

$ENABLE_SUDO_NOPASSWD && grant_sudo_nopasswd
$ENABLE_UPDATE && update_system
$ENABLE_SSH_HARDEN && harden_ssh
$ENABLE_NEW_USER && create_new_user
$ENABLE_BASE_TOOLS && install_tools
$ENABLE_FIREWALL && configure_firewall
$ENABLE_FAIL2BAN && install_fail2ban
$ENABLE_TIME_SYNC && enable_time_sync
$ENABLE_HOSTNAME && set_hostname
$ENABLE_CLOUDINIT_DISABLE && disable_cloudinit

echo "✅ Підготовка завершена!"
