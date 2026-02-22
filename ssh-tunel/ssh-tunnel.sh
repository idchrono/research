#!/usr/bin/env bash
# Strict mode

# Log everything to file and stdout (append)
exec > >(tee -a ./ssh-tunnel.log 2>&1) 2>&1

# Load environment variables (exported automatically)
[[ -f .env ]] && set -a && . .env && set +a

# Required vars
: ${REMOTE_USER:?"REMOTE_USER is not set in .env"}
: ${REMOTE_HOST:?"REMOTE_HOST is not set in .env"}

# Defaults
NETWORK=${NETWORK:-0/0}
EXCLUDE=${EXCLUDE:-"192.168.0.0/16"}

# Build sshuttle exclude flags
EXCLUDE_ARGS=()
for e in $EXCLUDE; do
  EXCLUDE_ARGS+=(-x "$e")
done

# Run sshuttle
sshuttle --dns -r "$REMOTE_USER@$REMOTE_HOST" "$NETWORK" "${EXCLUDE_ARGS[@]}"
