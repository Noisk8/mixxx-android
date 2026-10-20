#!/bin/sh
set -eu

skin_name="XDJ_RX3_Mixxx"
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
mixxx_data="$HOME/Library/Containers/org.mixxx.mixxx/Data/Library/Application Support/Mixxx"
target_root="$mixxx_data/skins"
target_dir="$target_root/$skin_name"

mkdir -p "$target_root"
if [ -d "$target_dir" ]; then
  backup_dir="$target_dir.backup-$(date +%Y%m%d-%H%M%S)"
  mv "$target_dir" "$backup_dir"
  printf 'Respaldo anterior: %s\n' "$backup_dir"
fi

mkdir -p "$target_dir"
rsync -a --exclude '.DS_Store' "$script_dir/" "$target_dir/"
printf 'Skin instalada en: %s\n' "$target_dir"
printf 'Reinicia Mixxx y selecciona "NauticMixxx" en Preferencias > Interfaz.\n'
