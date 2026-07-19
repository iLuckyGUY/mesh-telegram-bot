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
if ! grep -q "^    BOT_DISPLAY_NAME:" "$CONFIG_FILE" 2>/dev/null; then
    sed -i "/SUPPORT_USERNAME: str = '@support'/a\\
\\
    # ── Whitelabel branding (from env) ──────────────────────\\
    BOT_DISPLAY_NAME: str = 'Remnawave Bedolaga Bot'\\
    DEVELOPER_CONTACT_URL: str = 'https://t.me/fringg'\\
    COMMUNITY_URL: str = 'https://t.me/+wTdMtSWq8YdmZmVi'\\
    GITHUB_BOT_URL: str = 'https://github.com/iLuckyGUY/mesh-bot'\\
    GITHUB_CABINET_URL: str = 'https://github.com/iLuckyGUY/mesh-app'\\
" "$CONFIG_FILE"
    echo     "  ✅ config.py — BOT_DISPLAY_NAME, DEVELOPER_CONTACT_URL, COMMUNITY_URL, GITHUB_BOT_URL, GITHUB_CABINET_URL added"
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
    "<b>{settings.BOT_DISPLAY_NAME}</b>" \
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
    "^GITHUB_BOT_URL: Final\[str\] = 'https://github.com/BEDOLAGA-DEV/remnawave-bedolaga-telegram-bot'" \
    "# GITHUB_BOT_URL — now from settings.GITHUB_BOT_URL" \
    "startup_notification.py — remove hardcoded GITHUB_BOT_URL"

sed_checked "$SNS_FILE" \
    "^GITHUB_CABINET_URL: Final\[str\] = 'https://github.com/BEDOLAGA-DEV/bedolaga-cabinet'" \
    "# GITHUB_CABINET_URL — now from settings.GITHUB_CABINET_URL" \
    "startup_notification.py — remove hardcoded GITHUB_CABINET_URL"

sed_checked "$SNS_FILE" \
    "url=GITHUB_BOT_URL," \
    "url=settings.GITHUB_BOT_URL," \
    "startup_notification.py — use settings.GITHUB_BOT_URL"

sed_checked "$SNS_FILE" \
    "url=GITHUB_CABINET_URL," \
    "url=settings.GITHUB_CABINET_URL," \
    "startup_notification.py — use settings.GITHUB_CABINET_URL"

sed_checked "$SNS_FILE" \
    "<b>Remnawave Bedolaga Bot</b>" \
    "<b>{settings.BOT_DISPLAY_NAME}</b>" \
    "startup_notification.py — use settings.BOT_DISPLAY_NAME (×2)"


# ── 4. rich_admin.py: use settings.BOT_DISPLAY_NAME in footer ──
RICH_ADMIN_FILE="${APP_DIR}/utils/rich_admin.py"
if grep -q "def rich_footer_now(label: str = '')" "$RICH_ADMIN_FILE" 2>/dev/null; then
    echo "  ✓ rich_admin.py — already patched"
elif grep -q "def rich_footer_now(label: str = 'Remnawave Bedolaga Bot')" "$RICH_ADMIN_FILE" 2>/dev/null; then
    sed -i "s|def rich_footer_now(label: str = 'Remnawave Bedolaga Bot') -> str:|def rich_footer_now(label: str = '') -> str:|" "$RICH_ADMIN_FILE"
    sed -i "s|    return f'<footer>{html.escape(label)} · {stamp}</footer>'|    label = label or settings.BOT_DISPLAY_NAME\n    return f'<footer>{html.escape(label)} · {stamp}</footer>'|" "$RICH_ADMIN_FILE"
    echo "  ✅ rich_admin.py — use settings.BOT_DISPLAY_NAME in footer"
else
    echo "  ⚠️  rich_admin.py — pattern not found (upstream may have changed)"
fi


echo ""
echo "━━━ Env-var branding support added successfully ━━━"
echo "  Set BOT_DISPLAY_NAME, DEVELOPER_CONTACT_URL, COMMUNITY_URL,"
echo "  GITHUB_BOT_URL, GITHUB_CABINET_URL, CABINET_REPO"
echo "  in runtime env to override defaults."
