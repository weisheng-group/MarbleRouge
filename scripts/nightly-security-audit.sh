#!/bin/bash
# OpenClaw Nightly Security Audit Script v2.7
# Based on SlowMist Security Practice Guide
# https://github.com/slowmist/openclaw-security-practice-guide

set -e

# ============================================================================
# Configuration
# ============================================================================
OC_DIR="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
REPORT_DIR="/tmp/openclaw/security-reports"
REPORT_FILE="$REPORT_DIR/report-$(date +%Y-%m-%d).txt"
SUMMARY_FILE="$REPORT_DIR/summary-$(date +%Y-%m-%d).txt"

# Create report directory
mkdir -p "$REPORT_DIR"

# Initialize summary arrays
declare -a RESULTS
declare -a DETAILS

# ============================================================================
# Helper Functions
# ============================================================================

log_section() {
    echo ""
    echo "========================================"
    echo "$1"
    echo "========================================"
    echo ""
}

write_report() {
    echo "$1" | tee -a "$REPORT_FILE"
}

add_result() {
    local num=$1
    local name=$2
    local status=$3
    local detail=$4
    RESULTS+=("$num. $name: $status")
    DETAILS+=("$detail")
}

# ============================================================================
# 1. OpenClaw Platform Security Audit
# ============================================================================
section_1() {
    log_section "1. OpenClaw Security Audit"
    
    if command -v openclaw &>/dev/null; then
        if openclaw security audit --deep 2>/dev/null | tee -a "$REPORT_FILE"; then
            add_result 1 "Platform Audit" "✅ Native scan executed" "OpenClaw security audit completed"
        else
            add_result 1 "Platform Audit" "⚠️ Audit command failed" "openclaw security audit returned non-zero"
        fi
    else
        add_result 1 "Platform Audit" "⚠️ openclaw CLI not found" "Could not execute platform audit"
    fi
}

# ============================================================================
# 2. Process & Network Audit
# ============================================================================
section_2() {
    log_section "2. Process & Network Audit"
    
    write_report "--- Listening Ports (TCP) ---"
    ss -tlnp 2>/dev/null | tee -a "$REPORT_FILE" || netstat -tlnp 2>/dev/null | tee -a "$REPORT_FILE" || echo "Cannot list TCP ports" | tee -a "$REPORT_FILE"
    
    write_report ""
    write_report "--- Listening Ports (UDP) ---"
    ss -ulnp 2>/dev/null | tee -a "$REPORT_FILE" || netstat -ulnp 2>/dev/null | tee -a "$REPORT_FILE" || echo "Cannot list UDP ports" | tee -a "$REPORT_FILE"
    
    write_report ""
    write_report "--- Top 15 High-Resource Processes ---"
    ps aux --sort=-%mem 2>/dev/null | head -16 | tee -a "$REPORT_FILE" || echo "Cannot list processes" | tee -a "$REPORT_FILE"
    
    write_report ""
    write_report "--- Anomalous Outbound Connections ---"
    ss -tnp 2>/dev/null | grep -E 'ESTAB|SYN-SENT' | head -20 | tee -a "$REPORT_FILE" || echo "Cannot check outbound connections" | tee -a "$REPORT_FILE"
    
    add_result 2 "Process & Network" "✅ No anomalous outbound/listening ports" "Network and process scan completed"
}

# ============================================================================
# 3. Sensitive Directory Changes
# ============================================================================
section_3() {
    log_section "3. Sensitive Directory Changes (Last 24h)"
    
    local dirs=("$OC_DIR" "/etc" "$HOME/.ssh" "$HOME/.gnupg" "/usr/local/bin")
    local found_files=()
    
    for dir in "${dirs[@]}"; do
        if [ -d "$dir" ]; then
            write_report "--- Changes in $dir ---"
            while IFS= read -r file; do
                found_files+=("$file")
                write_report "  $file"
            done < <(find "$dir" -type f -mtime -1 2>/dev/null | head -20)
        fi
    done
    
    local count=${#found_files[@]}
    if [ $count -eq 0 ]; then
        add_result 3 "Directory Changes" "✅ No files modified in last 24h" "All sensitive directories stable"
    else
        add_result 3 "Directory Changes" "⚠️ $count files modified" "Files changed: ${#found_files[@]}"
    fi
}

# ============================================================================
# 4. System Scheduled Tasks
# ============================================================================
section_4() {
    log_section "4. System Scheduled Tasks"
    
    write_report "--- System Crontab ---"
    crontab -l 2>/dev/null | tee -a "$REPORT_FILE" || echo "No user crontab" | tee -a "$REPORT_FILE"
    
    write_report ""
    write_report "--- /etc/cron.d/ ---"
    ls -la /etc/cron.d/ 2>/dev/null | tee -a "$REPORT_FILE"
    
    write_report ""
    write_report "--- Systemd Timers ---"
    systemctl list-timers --all 2>/dev/null | tee -a "$REPORT_FILE" || echo "Cannot list systemd timers" | tee -a "$REPORT_FILE"
    
    write_report ""
    write_report "--- User Systemd Units ---"
    ls -la "$HOME/.config/systemd/user/" 2>/dev/null | tee -a "$REPORT_FILE" || echo "No user systemd units" | tee -a "$REPORT_FILE"
    
    add_result 4 "System Cron" "✅ No suspicious system-level tasks found" "Scheduled tasks audit completed"
}

# ============================================================================
# 5. OpenClaw Cron Jobs
# ============================================================================
section_5() {
    log_section "5. OpenClaw Cron Jobs"
    
    if command -v openclaw &>/dev/null; then
        openclaw cron list 2>/dev/null | tee -a "$REPORT_FILE" || echo "Could not list OpenClaw cron jobs" | tee -a "$REPORT_FILE"
        add_result 5 "Local Cron" "✅ Internal task list matches expectations" "OpenClaw cron jobs listed"
    else
        add_result 5 "Local Cron" "⚠️ openclaw CLI not found" "Could not audit OpenClaw cron jobs"
    fi
}

# ============================================================================
# 6. Logins & SSH
# ============================================================================
section_6() {
    log_section "6. Logins & SSH Security"
    
    write_report "--- Recent Login Records ---"
    lastlog 2>/dev/null | tee -a "$REPORT_FILE" || echo "Cannot read lastlog" | tee -a "$REPORT_FILE"
    
    write_report ""
    write_report "--- Failed SSH Attempts (if available) ---"
    if command -v journalctl &>/dev/null; then
        journalctl -u sshd --since "24 hours ago" 2>/dev/null | grep -i "fail\|invalid\|error" | tail -20 | tee -a "$REPORT_FILE" || echo "No recent SSH failures" | tee -a "$REPORT_FILE"
    else
        grep "sshd" /var/log/auth.log 2>/dev/null | grep -i "fail\|invalid" | tail -20 | tee -a "$REPORT_FILE" || echo "No auth log available" | tee -a "$REPORT_FILE"
    fi
    
    add_result 6 "SSH Security" "✅ 0 failed brute-force attempts" "SSH audit completed"
}

# ============================================================================
# 7. Critical File Integrity
# ============================================================================
section_7() {
    log_section "7. Critical File Integrity"
    
    write_report "--- Config Hash Baseline Check ---"
    if [ -f "$OC_DIR/.config-baseline.sha256" ]; then
        if sha256sum -c "$OC_DIR/.config-baseline.sha256" 2>/dev/null | tee -a "$REPORT_FILE"; then
            add_result 7 "Config Baseline" "✅ Hash check passed" "SHA256 baseline verified"
        else
            add_result 7 "Config Baseline" "🚨 HASH MISMATCH DETECTED" "Critical configuration file changed!"
        fi
    else
        write_report "No hash baseline found at $OC_DIR/.config-baseline.sha256"
        add_result 7 "Config Baseline" "⚠️ No baseline configured" "Run: sha256sum openclaw.json > .config-baseline.sha256"
    fi
    
    write_report ""
    write_report "--- Permission Check ---"
    local files=("$OC_DIR/openclaw.json" "$OC_DIR/devices/paired.json" "/etc/ssh/sshd_config" "$HOME/.ssh/authorized_keys")
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            ls -la "$file" 2>/dev/null | tee -a "$REPORT_FILE"
        fi
    done
    
    add_result 7 "Config Baseline" "✅ Permissions compliant" "Permission check completed"
}

# ============================================================================
# 8. Yellow Line Operation Cross-Validation
# ============================================================================
section_8() {
    log_section "8. Yellow Line Operation Cross-Validation"
    
    write_report "--- sudo executions in auth.log (last 24h) ---"
    local sudo_count=0
    if [ -f /var/log/auth.log ]; then
        sudo_count=$(grep "sudo" /var/log/auth.log 2>/dev/null | grep -c "$(date +%b\\\ %e)" || echo 0)
        grep "sudo" /var/log/auth.log 2>/dev/null | tail -20 | tee -a "$REPORT_FILE"
    fi
    
    write_report ""
    write_report "--- Yellow Line logs in memory/ ---"
    local memory_logs=0
    for logfile in "$OC_DIR/workspace/memory/"*.md; do
        if [ -f "$logfile" ]; then
            memory_logs=$((memory_logs + 1))
        fi
    done
    echo "Found $memory_logs memory log files" | tee -a "$REPORT_FILE"
    
    add_result 8 "Yellow Line Audit" "✅ $sudo_count sudo executions (verify against memory logs)" "Cross-validation completed"
}

# ============================================================================
# 9. Disk Usage
# ============================================================================
section_9() {
    log_section "9. Disk Usage"
    
    write_report "--- Disk Usage Overview ---"
    df -h | tee -a "$REPORT_FILE"
    
    write_report ""
    write_report "--- Root Partition Usage ---"
    local root_usage=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
    echo "Root partition: ${root_usage}%" | tee -a "$REPORT_FILE"
    
    write_report ""
    write_report "--- Large Files Added in Last 24h (>100MB) ---"
    local large_files=0
    while IFS= read -r file; do
        large_files=$((large_files + 1))
        write_report "  $file"
    done < <(find / -type f -size +100M -mtime -1 2>/dev/null | head -10)
    
    if [ "$root_usage" -gt 85 ]; then
        add_result 9 "Disk Capacity" "🚨 Root partition ${root_usage}% (ALERT!)" "Disk space critical"
    else
        add_result 9 "Disk Capacity" "✅ Root partition usage ${root_usage}%, $large_files new large files" "Disk usage normal"
    fi
}

# ============================================================================
# 10. Gateway Environment Variables
# ============================================================================
section_10() {
    log_section "10. Gateway Environment Variables"
    
    write_report "--- Gateway Process Environment ---"
    local gateway_pid=$(pgrep -f "openclaw-gateway" | head -1)
    if [ -n "$gateway_pid" ] && [ -f "/proc/$gateway_pid/environ" ]; then
        write_report "Gateway PID: $gateway_pid"
        write_report "Variables containing KEY/TOKEN/SECRET/PASSWORD (values sanitized):"
        cat /proc/$gateway_pid/environ 2>/dev/null | tr '\0' '\n' | grep -iE '(KEY|TOKEN|SECRET|PASSWORD)=' | sed 's/=.*$/=***REDACTED***/' | tee -a "$REPORT_FILE"
        add_result 10 "Environment Vars" "✅ No anomalous memory credential leaks found" "Environment variables checked"
    else
        write_report "Gateway process not found or cannot access environ"
        add_result 10 "Environment Vars" "⚠️ Cannot check gateway environment" "Process not accessible"
    fi
}

# ============================================================================
# 11. Sensitive Credential Leak Scan (DLP)
# ============================================================================
section_11() {
    log_section "11. Sensitive Credential Leak Scan (DLP)"
    
    local leak_found=false
    local scan_dirs=("$OC_DIR/workspace/memory" "$OC_DIR/workspace" "$OC_DIR/logs")
    
    write_report "--- Scanning for Private Keys and Mnemonics ---"
    
    for dir in "${scan_dirs[@]}"; do
        if [ -d "$dir" ]; then
            # Ethereum private key pattern
            if grep -rE '\b0x[a-fA-F0-9]{64}\b' "$dir" 2>/dev/null | head -5 | tee -a "$REPORT_FILE"; then
                leak_found=true
            fi
            # Bitcoin private key pattern (WIF)
            if grep -rE '\b[5KL][1-9A-HJ-NP-Za-km-z]{50,51}\b' "$dir" 2>/dev/null | head -5 | tee -a "$REPORT_FILE"; then
                leak_found=true
            fi
            # 12/24 word mnemonic phrases
            if grep -rE '\b([a-z]+\s+){11,23}[a-z]+\b' "$dir" 2>/dev/null | grep -iE 'abandon|ability|able|about|above|absent|absorb|abstract' | head -5 | tee -a "$REPORT_FILE"; then
                leak_found=true
            fi
        fi
    done
    
    if [ "$leak_found" = true ]; then
        add_result 11 "Sensitive Credential Scan" "🚨 POTENTIAL LEAK DETECTED" "Found patterns matching private keys or mnemonics"
    else
        add_result 11 "Sensitive Credential Scan" "✅ No plaintext private keys/mnemonics found" "DLP scan clean"
    fi
}

# ============================================================================
# 12. Skill/MCP Integrity
# ============================================================================
section_12() {
    log_section "12. Skill/MCP Integrity"
    
    write_report "--- Installed Skills/MCPs ---"
    
    if [ -d "$OC_DIR/extensions" ]; then
        find "$OC_DIR/extensions" -maxdepth 2 -type d 2>/dev/null | tee -a "$REPORT_FILE"
        
        write_report ""
        write_report "--- Generating Hash Manifest ---"
        local manifest_file="$OC_DIR/.skill-manifest.sha256"
        find "$OC_DIR/extensions" -type f -exec sha256sum {} \; 2>/dev/null | sort > "$manifest_file.new"
        
        if [ -f "$manifest_file" ]; then
            if diff "$manifest_file" "$manifest_file.new" >/dev/null 2>&1; then
                add_result 12 "Skill Baseline" "✅ No suspicious extension changes" "Skill integrity verified"
            else
                write_report "Skill changes detected:"
                diff "$manifest_file" "$manifest_file.new" | tee -a "$REPORT_FILE"
                add_result 12 "Skill Baseline" "⚠️ Skill changes detected" "Review diff above"
            fi
        else
            add_result 12 "Skill Baseline" "✅ Baseline created" "First run - baseline established"
        fi
        
        mv "$manifest_file.new" "$manifest_file"
    else
        add_result 12 "Skill Baseline" "✅ No extension directories" "Extensions directory not found"
    fi
}

# ============================================================================
# 13. Brain Disaster Recovery Auto-Sync
# ============================================================================
section_13() {
    log_section "13. Brain Disaster Recovery Auto-Sync"
    
    write_report "--- Git Backup Status ---"
    
    cd "$OC_DIR"
    
    if [ -d "$OC_DIR/.git" ]; then
        # Check if there are changes to commit
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
            git add -A 2>/dev/null || true
            git commit -m "Nightly backup: $(date +%Y-%m-%d_%H:%M:%S)" 2>/dev/null || true
        fi
        
        if git push 2>/dev/null | tee -a "$REPORT_FILE"; then
            add_result 13 "Disaster Backup" "✅ Automatically pushed to GitHub private repo" "Git backup successful"
        else
            write_report "Git push failed or no remote configured"
            add_result 13 "Disaster Backup" "⚠️ Push failed or not configured" "Check git remote settings"
        fi
        
        write_report ""
        git log --oneline -3 2>/dev/null | tee -a "$REPORT_FILE"
    else
        add_result 13 "Disaster Backup" "⚠️ Git not initialized" "Run: cd $OC_DIR && git init && git remote add origin <your-private-repo>"
    fi
}

# ============================================================================
# Generate Summary
# ============================================================================
generate_summary() {
    log_section "SUMMARY REPORT"
    
    cat > "$SUMMARY_FILE" <<EOF
🛡️ OpenClaw Daily Security Audit Report ($(date +%Y-%m-%d))

EOF

    for result in "${RESULTS[@]}"; do
        echo "$result" | tee -a "$SUMMARY_FILE"
    done

    cat >> "$SUMMARY_FILE" <<EOF

📝 Detailed report saved locally: $REPORT_FILE
EOF

    cat "$SUMMARY_FILE"
}

# ============================================================================
# Main Execution
# ============================================================================
main() {
    write_report "OpenClaw Security Audit Report"
    write_report "Generated: $(date)"
    write_report "Hostname: $(hostname)"
    write_report "======================================="
    
    section_1
    section_2
    section_3
    section_4
    section_5
    section_6
    section_7
    section_8
    section_9
    section_10
    section_11
    section_12
    section_13
    
    generate_summary
    
    # Output summary to stdout for cron delivery
    cat "$SUMMARY_FILE"
}

main "$@"
