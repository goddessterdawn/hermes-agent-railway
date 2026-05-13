#!/usr/bin/env bash
set -e
# ── Env-to-file bridge ──────────────────────────────────────────────
mkdir -p /root/.hermes
cat > /root/.hermes/config.yaml <<EOF
model: openrouter/deepseek/deepseek-chat
BASE_URL: ${BASE_URL:-https://openrouter.ai/api/v1}
OPENROUTER_API_KEY: ${OPENROUTER_API_KEY}
SLACK_APP_TOKEN: ${SLACK_APP_TOKEN}
DISCORD_BOT_TOKEN: ${DISCORD_BOT_TOKEN}
ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY}
EOF
chmod 600 /root/.hermes/config.yaml
echo "[entrypoint] config.yaml written"
# ────────────────────────────────────────────────────────────────────
AUTO_UPDATE="${AUTO_UPDATE:-true}"

if [ "$AUTO_UPDATE" = "true" ]; then
  echo "Checking for Hermes updates..."
  cd /opt/hermes-agent
  if git pull --recurse-submodules 2>&1 | grep -v 'Already up to date'; then
    echo "Updating dependencies..."
    VIRTUAL_ENV=/opt/hermes-agent/venv uv pip install -e ".[all]" --quiet
    echo "Update complete."
  else
    echo "Already up to date."
  fi
fi

hermes dashboard --host 127.0.0.1 --port 9119 --no-open &

exec python /auth_proxy.py
