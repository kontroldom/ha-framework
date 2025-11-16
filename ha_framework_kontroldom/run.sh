#!/usr/bin/with-contenv bashio
set -e

CONFIG_DIR="/config"
SHARE_DIR="/share"
FRAMEWORK_DIR="/opt/framework"

bashio::log.info "HA Framework KontrolDom startuje..."

DRY_RUN=$(bashio::config 'dry_run')
OVERWRITE=$(bashio::config 'overwrite_existing')

copy_item() {
  local src="$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    bashio::log.warning "Źródło nie istnieje: $src"
    return
  fi

  if [ -e "$dest" ] && [ "$OVERWRITE" != "true" ]; then
    bashio::log.info "Pomijam istniejący plik/katalog: $dest"
    return
  fi

  bashio::log.info "Kopiuję: $src -> $dest"
  if [ "$DRY_RUN" != "true" ]; then
    mkdir -p "$(dirname "$dest")"
    cp -r "$src" "$dest"
  fi
}

# 1. Kopiujemy cały framework/config -> /config
bashio::log.info "Kopiuję Framework KontrolDom do /config..."

if [ -d "${FRAMEWORK_DIR}/config" ]; then
  # pliki/katalogi poza .storage
  for f in "${FRAMEWORK_DIR}/config"/*; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"
    if [ "$base" != ".storage" ]; then
      copy_item "$f" "${CONFIG_DIR}/${base}"
    fi
  done
fi

# 2. .storage (HACS, core.config_entries, itp.)
if [ -d "${FRAMEWORK_DIR}/config/.storage" ]; then
  bashio::log.info "Kopiuję .storage (HACS, integracje)..."
  for f in "${FRAMEWORK_DIR}/config/.storage"/*; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"
    copy_item "$f" "${CONFIG_DIR}/.storage/${base}"
  done
fi

# 3. SHARE (opcjonalne)
if [ -d "${FRAMEWORK_DIR}/share" ]; then
  bashio::log.info "Kopiuję zawartość share frameworku..."
  copy_item "${FRAMEWORK_DIR}/share" "${SHARE_DIR}/kontroldom"
fi

# 4. Automatyczna instalacja ADD-ONÓW
SUPERVISOR="http://supervisor"

install_addon() {
  local slug="$1"

  bashio::log.info "Instaluję add-on: ${slug}"
  if [ "$DRY_RUN" = "true" ]; then
    bashio::log.info "(dry_run) pomijam instalację ${slug}"
    return
  fi

  curl -sS -X POST \
    -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
    -H "Content-Type: application/json" \
    "${SUPERVISOR}/addons/${slug}/install" || true

  bashio::log.info "Uruchamiam add-on: ${slug}"
  curl -sS -X POST \
    -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
    -H "Content-Type: application/json" \
    "${SUPERVISOR}/addons/${slug}/start" || true
}

# >>> TU SĄ TWOJE ADD-ONY <<<
ADDONS=(
  "cloudflared"        # Cloudflare Tunnel
  "go2rtc"             # go2rtc
  "a0d7b954_vscode"    # Studio Code Server (Community Add-ons)
  # HACS instalujemy z frameworku (custom_components + .storage), więc BEZ get_hacs
)

for a in "${ADDONS[@]}"; do
  install_addon "$a"
done

# 5. Restart HA, żeby wszystko się wczytało
bashio::log.info "Restartuję Home Assistant, aby zastosować framework..."
if [ "$DRY_RUN" != "true" ]; then
  curl -sS -X POST \
    -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
    -H "Content-Type: application/json" \
    "${SUPERVISOR}/homeassistant/restart" || true
fi

bashio::log.info "Framework KontrolDom – instalacja zakończona."
tail -f /dev/null