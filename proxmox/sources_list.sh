#!/bin/bash

echo "🔧 Закоментовуємо Enterprise репозиторії..."

# Коментуємо enterprise PVE репозиторій
if [ -f /etc/apt/sources.list.d/pve-enterprise.list ]; then
  sed -i 's|^deb https://enterprise.proxmox.com|# deb https://enterprise.proxmox.com|' /etc/apt/sources.list.d/pve-enterprise.list
fi

# Коментуємо enterprise Ceph репозиторій, якщо існує
if [ -f /etc/apt/sources.list.d/ceph.list ]; then
  sed -i 's|^deb https://enterprise.proxmox.com|# deb https://enterprise.proxmox.com|' /etc/apt/sources.list.d/ceph.list
fi

# Додаємо pve-no-subscription
echo "🟢 Додаємо безкоштовний PVE репозиторій..."
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list

# Додаємо ceph-no-subscription
echo "🟢 Додаємо безкоштовний Ceph Quincy репозиторій..."
echo "deb http://download.proxmox.com/debian/ceph-quincy bookworm main" > /etc/apt/sources.list.d/ceph-no-subscription.list

# Оновлюємо
echo "🔄 Оновлення списку пакетів..."
apt update

echo "✅ Готово! Тепер використовуються лише безкоштовні репозиторії Proxmox."
