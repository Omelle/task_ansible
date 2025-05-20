#!/bin/bash

# Liste des IPs ou noms d'hôte dans l'inventaire Ansible
hosts=(
  192.168.33.101
  192.168.33.102
  192.168.33.103
)

KNOWN_HOSTS="$HOME/.ssh/known_hosts"

echo "🔐 Nettoyage des anciennes clés SSH..."

for host in "${hosts[@]}"; do
  echo "🧹 Suppression de la clé pour $host"
  ssh-keygen -f "$KNOWN_HOSTS" -R "$host" >/dev/null 2>&1
done

echo "✅ Clés supprimées. Tu peux relancer ta commande Ansible."
