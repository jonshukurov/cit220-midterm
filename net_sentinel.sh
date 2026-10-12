cat << 'EOF' > net_sentinel.sh
#!/usr/bin/env bash
# ==============================================================================
# Script Name: net_sentinel.sh
# Author: Jon Shukurov
# Course: CIT 220 Z01 Linux Sys Admin - Midterm Project
# Description: Custom network diagnostic orchestrator with strict error traps,
#              secure temp directories, interface inspection, and Python parsing.
# ==============================================================================

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ACTIVITY_LOG="$ROOT_DIR/sentinel_activity.log"
METRIC_DATA="$ROOT_DIR/network_raw_metrics.txt"

record_log() {
local severity="$1"
shift
printf '[%s] [%s] %s\n' "$(date --iso-8601=seconds)" "$severity" "$*" | tee -a "$ACTIVITY_LOG"
}

safe_exit_trap() {
local code=$?
if [ $code -ne 0 ]; then
    record_log "ERROR" "Sentinel workflow terminated with failure exit code $code."
else
    record_log "INFO" "Sentinel workflow executed and completed successfully."
fi
}
trap safe_exit_trap EXIT

record_log "INFO" "Initializing Network Latency & Port Sentinel Orchestrator..."

if [[ ! -r /etc/os-release ]]; then
record_log "ERROR" "Unable to read operating system release metadata."
exit 1
fi

source /etc/os-release
record_log "INFO" "Executing Environment: ${NAME:-Linux} (${VERSION_ID:-Unknown})"

SCRATCH_DIR="$(mktemp -d /tmp/net-sentinel-extended.XXXXXX)"
trap 'rm -rf -- "$SCRATCH_DIR"' EXIT
record_log "INFO" "Temporary scratch workspace provisioned at: $SCRATCH_DIR"

record_log "INFO" "Collecting local network interface configurations..."
ip addr show > "$METRIC_DATA" || ifconfig -a >> "$METRIC_DATA" || true

record_log "INFO" "Gathering active socket and listening port details..."
ss -tulpn >> "$METRIC_DATA" || netstat -tulpn >> "$METRIC_DATA" || true

record_log "INFO" "Checking local routing table status..."
ip route show >> "$METRIC_DATA" || route -n >> "$METRIC_DATA" || true

record_log "INFO" "Performing gateway connectivity ping test..."
ping -c 3 8.8.8.8 >> "$METRIC_DATA" 2>&1 || record_log "WARNING" "Gateway ping test returned non-zero status."

record_log "INFO" "Executing verification checks on required command utilities..."
for utility in python3 ip ss ping; do
if command -v "$utility" &> /dev/null; then
    record_log "INFO" "Utility verification passed: '$utility' is available."
else
    record_log "WARNING" "Utility verification warning: '$utility' was not found."
fi
done

record_log "INFO" "Handing raw network metrics over to Python analyzer..."
if python3 "$ROOT_DIR/latency_evaluator.py" "$METRIC_DATA" 2>&1 | tee -a "$ACTIVITY_LOG"; then
record_log "INFO" "Python analyzer completed evaluation successfully."
else
record_log "ERROR" "Python analyzer execution failed."
exit 1
fi

record_log "INFO" "All network sentinel auditing tasks have finished processing."
EOF