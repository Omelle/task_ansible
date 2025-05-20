#!/bin/bash

set -e

KEY_PATH="/root/.ssh/id_ansible"
INVENTORY="inventories/inventory.ini"

read -s -p "🔑 Entrez le mot de passe root des VMs : " VM_PASS
echo ""

# Générer une nouvelle clé SSH sans passphrase si elle n'existe pas
if [ ! -f "$KEY_PATH" ]; then
    echo "🔐 Génération d'une nouvelle clé SSH sans passphrase..."
    ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N ""
    echo "✅ Clé SSH générée : $KEY_PATH"
else
    echo "ℹ️  Clé SSH déjà présente : $KEY_PATH"
fi

# Lecture des IPs dans l'inventaire
echo "📦 Lecture des IPs dans l'inventaire : $INVENTORY"
HOSTS=$(grep -E '^[0-9]' "$INVENTORY" | awk '{print $1}')

# Copier la clé publique sur chaque hôte
for ip in $HOSTS; do
    echo "🚀 Déploiement de la clé publique sur $ip..."
    ssh-keygen -f "/root/.ssh/known_hosts" -R "$ip" >/dev/null 2>&1 || true
    sshpass -p "$VM_PASS" ssh-copy-id -i "$KEY_PATH.pub" -o StrictHostKeyChecking=no root@"$ip"
done

# Mettre à jour l'inventaire avec le chemin de la nouvelle clé
echo "📝 Mise à jour de l'inventaire Ansible..."
if ! grep -q "ansible_ssh_private_key_file" "$INVENTORY"; then
    echo -e "\n[all:vars]\nansible_ssh_private_key_file=$KEY_PATH" >> "$INVENTORY"
else
    sed -i "s|ansible_ssh_private_key_file=.*|ansible_ssh_private_key_file=$KEY_PATH|" "$INVENTORY"
fi

# Test Ansible
echo "📡 Test de connexion SSH avec Ansible..."
ansible all -i "$INVENTORY" -m ping

echo "✅ Environnement prêt pour Ansible !"
