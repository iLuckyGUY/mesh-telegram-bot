#!/bin/bash
set -euo pipefail

APP_DIR=/app/app

echo "━━━ Adding env-var branding support ─────────────────"

sed_checked() {
    local file="$1" pattern="$2" replacement="$3" desc="$4"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        sed -i "s|$pattern|$replacement|g" "$file"
        echo "  ✅ ${desc}"
    else
        echo "  ⚠️  ${desc} — pattern not found (upstream may have changed)"
    fi
}

# ── 1. config.py: add env var fields (with upstream defaults) ──
CONFIG_FILE="${APP_DIR}/config.py"
if ! grep -q "BOT_DISPLAY_NAME" "$CONFIG_FILE" 2>/dev/null; then
    sed -i "/SUPPORT_USERNAME: str = '@support'/a\\
\\
    # ── Whitelabel branding (from env) ──────────────────────\\
    BOT_DISPLAY_NAME: str = 'Remnawave Bedolaga Bot'\\
    DEVELOPER_CONTACT_URL: str = 'https://t.me/fringg'\\
    COMMUNITY_URL: str = 'https://t.me/+wTdMtSWq8YdmZmVi'\\
" "$CONFIG_FILE"
    echo "  ✅ config.py — BOT_DISPLAY_NAME, DEVELOPER_CONTACT_URL, COMMUNITY_URL added"
else
    echo "  ✓ config.py — fields already exist"
fi

# ── 2. global_error.py: use settings.* ─────────────────────
sed_checked "${APP_DIR}/middlewares/global_error.py" \
    "^DEVELOPER_CONTACT_URL: Final\[str\] = 'https://t.me/fringg'" \
    "# DEVELOPER_CONTACT_URL — now from settings.DEVELOPER_CONTACT_URL" \
    "global_error.py — remove hardcoded DEVELOPER_CONTACT_URL"

sed_checked "${APP_DIR}/middlewares/global_error.py" \
    "url=DEVELOPER_CONTACT_URL," \
    "url=settings.DEVELOPER_CONTACT_URL," \
    "global_error.py — use settings.DEVELOPER_CONTACT_URL"

sed_checked "${APP_DIR}/middlewares/global_error.py" \
    "<b>Remnawave Bedolaga Bot</b>" \
    "<b>\${settings.BOT_DISPLAY_NAME}</b>" \
    "global_error.py — use settings.BOT_DISPLAY_NAME"

# ── 3. startup_notification_service.py: use settings.* ─────
SNS_FILE="${APP_DIR}/services/startup_notification_service.py"

sed_checked "$SNS_FILE" \
    "^COMMUNITY_URL: Final\[str\] = 'https://t.me/+wTdMtSWq8YdmZmVi'" \
    "# COMMUNITY_URL — now from settings.COMMUNITY_URL" \
    "startup_notification.py — remove hardcoded COMMUNITY_URL"

sed_checked "$SNS_FILE" \
    "^DEVELOPER_CONTACT_URL: Final\[str\] = 'https://t.me/fringg'" \
    "# DEVELOPER_CONTACT_URL — now from settings.DEVELOPER_CONTACT_URL" \
    "startup_notification.py — remove hardcoded DEVELOPER_CONTACT_URL"

sed_checked "$SNS_FILE" \
    "url=COMMUNITY_URL," \
    "url=settings.COMMUNITY_URL," \
    "startup_notification.py — use settings.COMMUNITY_URL"

sed_checked "$SNS_FILE" \
    "url=DEVELOPER_CONTACT_URL," \
    "url=settings.DEVELOPER_CONTACT_URL," \
    "startup_notification.py — use settings.DEVELOPER_CONTACT_URL"

sed_checked "$SNS_FILE" \
    "<b>Remnawave Bedolaga Bot</b>" \
    "<b>\${settings.BOT_DISPLAY_NAME}</b>" \
    "startup_notification.py — use settings.BOT_DISPLAY_NAME (×2)"

echo ""
echo "━━━ Env-var branding support added successfully ━━━"
echo "  Set BOT_DISPLAY_NAME, DEVELOPER_CONTACT_URL,"
echo "  COMMUNITY_URL in runtime env to override defaults."
