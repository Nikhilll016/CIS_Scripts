#!/usr/bin/env bash

# Linux Baseline Security Audit
# Read-only checks. Does not modify system configuration.
# This is a small baseline checker, not a complete CIS benchmark.

set -u

PASS=0
WARN=0
SKIP=0

pass() {
    printf '[PASS] %s\n' "$1"
    PASS=$((PASS + 1))
}

warn() {
    printf '[WARN] %s\n' "$1"
    WARN=$((WARN + 1))
}

skip() {
    printf '[SKIP] %s\n' "$1"
    SKIP=$((SKIP + 1))
}

check_file() {
    local file="$1"
    local max_mode="$2"
    local description="$3"
    local mode owner

    if [[ ! -e "$file" ]]; then
        skip "$description: $file not found"
        return
    fi

    mode=$(stat -c '%a' "$file" 2>/dev/null) || {
        skip "$description: unable to read permissions"
        return
    }

    owner=$(stat -c '%U' "$file" 2>/dev/null) || {
        skip "$description: unable to read owner"
        return
    }

    if [[ "$owner" != "root" ]]; then
        warn "$description: owner is $owner, expected root"
    elif (( (8#$mode & 8#$max_mode) != 0 )); then
        warn "$description: permissions $mode are too permissive"
    else
        pass "$description: owner and permissions look acceptable"
    fi
}

echo "======================================"
echo " Linux Baseline Security Audit"
echo "======================================"

if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    echo "Operating System: ${PRETTY_NAME:-Unknown}"
else
    echo "Operating System: Unknown"
fi

echo
echo "[1] Critical account file checks"

check_file "/etc/passwd" "022" "/etc/passwd"
check_file "/etc/group" "022" "/etc/group"
check_file "/etc/shadow" "044" "/etc/shadow"
check_file "/etc/gshadow" "044" "/etc/gshadow"

echo
echo "[2] SSH configuration checks"

if command -v sshd >/dev/null 2>&1; then
    ssh_config=$(sshd -T 2>/dev/null || true)

    if [[ -z "$ssh_config" ]]; then
        skip "Could not retrieve effective SSH configuration"
    else
        root_login=$(awk '$1=="permitrootlogin" {print $2; exit}' <<< "$ssh_config")
        password_auth=$(awk '$1=="passwordauthentication" {print $2; exit}' <<< "$ssh_config")

        if [[ "$root_login" == "no" ]]; then
            pass "SSH root login is disabled"
        else
            warn "SSH root login setting: ${root_login:-unknown}"
        fi

        if [[ "$password_auth" == "no" ]]; then
            pass "SSH password authentication is disabled"
        else
            warn "SSH password authentication setting: ${password_auth:-unknown}"
        fi
    fi
else
    skip "OpenSSH server tools are not installed"
fi

echo
echo "======================================"
echo " Audit Summary"
echo "======================================"
printf 'Passed: %d\n' "$PASS"
printf 'Warnings: %d\n' "$WARN"
printf 'Skipped: %d\n' "$SKIP"

echo
echo "Note: These are limited baseline checks."
echo "Review results manually before making changes."
echo "This tool does not certify CIS compliance."
