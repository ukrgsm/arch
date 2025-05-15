#!/bin/bash

set -e

# Змінні
DISK="/dev/sdb"
MOUNT_POINT="/mnt/veeam_repo"
USERNAME="veeamrepo"

echo "[1/6] Перевірка наявності диска $DISK..."
if [ ! -b "$DISK" ]; then
  echo "❌ Диск $DISK не знайдено!"
  exit 1
fi

echo "[2/6] Форматування диска як XFS з reflink=1..."
sudo mkfs.xfs -m reflink=1 "$DISK"

echo "[3/6] Створення точки монтування та запис у fstab..."
sudo mkdir -p "$MOUNT_POINT"
UUID=$(sudo blkid -s UUID -o value "$DISK")
if [ -z "$UUID" ]; then
  echo "❌ UUID не знайдено. Зачекай кілька секунд або перевір вручну командою blkid."
  exit 1
fi
echo "UUID=$UUID $MOUNT_POINT xfs defaults 0 0" | sudo tee -a /etc/fstab
sudo mount "$MOUNT_POINT"

echo "[4/6] Створення користувача $USERNAME..."
if ! id "$USERNAME" &>/dev/null; then
  sudo adduser --disabled-password --gecos "" "$USERNAME"
  sudo usermod -aG sudo "$USERNAME"
fi

echo "[5/6] Встановлення прав доступу до репозиторію..."
sudo chown -R "$USERNAME":"$USERNAME" "$MOUNT_POINT"
sudo chmod 700 "$MOUNT_POINT"

echo "[6/6] Додавання $USERNAME до sudoers без пароля..."
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USERNAME
sudo chmod 440 /etc/sudoers.d/$USERNAME

echo "✅ Готово! Диск змонтовано, користувач створений і має sudo без пароля."
