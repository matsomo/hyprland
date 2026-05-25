#!/usr/bin/bash
# Restart hyprpanel after events that put it into its broken default-layout state:
#   1. Hyprland emits monitoradded (monitor input switch / hotplug)
#   2. logind PrepareForSleep=false (system resumed from suspend) — suspend/resume
#      does not always emit monitoradded, but the bar still breaks, so we trigger
#      off the resume directly.
#
# Safeguards:
#   - FALLBACK monitor events (Hyprland's transient headless state during
#     suspend/resume) are ignored — restarting against that state pins hyprpanel
#     to the wrong monitor list.
#   - Before restarting, wait for the target monitor (DP-2) to actually be
#     present in `hyprctl monitors`. If it never appears, skip.
#   - Lock is held inside a subshell, and the child hyprpanel is spawned with
#     FD 9 explicitly closed (9>&-) so it cannot inherit and pin the lock.

set -u

SIG="${HYPRLAND_INSTANCE_SIGNATURE:-}"
[[ -n "$SIG" ]] || { echo "HYPRLAND_INSTANCE_SIGNATURE not set" >&2; exit 1; }

SOCK="${XDG_RUNTIME_DIR:-/tmp}/hypr/${SIG}/.socket2.sock"
LOG="${HYPRPANEL_RESTART_LOG:-/tmp/hyprpanel-restart.log}"
LOCK="${HYPRPANEL_RESTART_LOCK:-/tmp/hyprpanel-restart.lock}"
TARGET_MONITOR="${HYPRPANEL_TARGET_MONITOR:-DP-2}"
MONITOR_DELAY="${HYPRPANEL_RESTART_DELAY:-2.0}"
RESUME_DELAY="${HYPRPANEL_RESUME_DELAY:-3.0}"
MONITOR_WAIT="${HYPRPANEL_MONITOR_WAIT:-15}"   # seconds to wait for target monitor

log() { printf '%(%F %T)T %s\n' -1 "$*" >> "$LOG"; }

target_present() {
    hyprctl monitors -j 2>/dev/null \
        | grep -q "\"name\": \"${TARGET_MONITOR}\""
}

wait_for_target() {
    local i=0 max=$((MONITOR_WAIT * 2))   # 0.5s steps
    while (( i < max )); do
        target_present && return 0
        sleep 0.5
        i=$((i + 1))
    done
    return 1
}

restart_hyprpanel() {
    local reason="$1" delay="$2"
    # Subshell scope: FD 9 is opened, lock acquired, and released on subshell exit.
    # The hyprpanel child is spawned with 9>&- so it doesn't inherit the lock.
    (
        flock -n 9 || { log "skip restart ($reason): another in flight"; exit 0; }
        log "restart scheduled ($reason, sleep ${delay}s)"
        sleep "$delay"
        if ! wait_for_target; then
            log "skip restart ($reason): ${TARGET_MONITOR} not present after ${MONITOR_WAIT}s"
            exit 0
        fi
        hyprpanel -q 2>/dev/null || true
        sleep 0.5
        setsid nohup hyprpanel >/dev/null 2>&1 </dev/null 9>&- &
        disown
        log "restart issued ($reason)"
    ) 9>"$LOCK"
}

listen_hyprland() {
    [[ -S "$SOCK" ]] || { log "ERROR: hyprland socket missing: $SOCK"; return 1; }
    log "hyprland listener started ($SOCK)"
    while IFS= read -r line; do
        case "$line" in
            "monitoradded>>FALLBACK"*|"monitoraddedv2>>-1,FALLBACK"*)
                log "ignoring FALLBACK monitor event"
                ;;
            monitoradded*)
                log "hyprland event: $line"
                restart_hyprpanel "monitor-added" "$MONITOR_DELAY" &
                ;;
        esac
    done < <(socat -U - UNIX-CONNECT:"$SOCK")
    log "hyprland listener exited"
}

listen_logind() {
    log "logind listener started"
    while IFS= read -r line; do
        # PrepareForSleep emits twice: true=going to sleep, false=resumed.
        case "$line" in
            *"boolean false"*)
                log "logind event: resume"
                restart_hyprpanel "resume" "$RESUME_DELAY" &
                ;;
        esac
    done < <(dbus-monitor --system "type='signal',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'" 2>/dev/null)
    log "logind listener exited"
}

cleanup() {
    log "watcher stopping (pid $$)"
    jobs -p | xargs -r kill 2>/dev/null
}
trap cleanup EXIT

log "watcher started (pid $$, monitor_delay=${MONITOR_DELAY}s, resume_delay=${RESUME_DELAY}s, target=${TARGET_MONITOR})"
listen_hyprland &
listen_logind &
wait
