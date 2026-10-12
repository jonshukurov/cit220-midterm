cat << 'EOF' > README.md
# Network Latency & Port Sentinel

## Project Information
- **Course:** CIT 220 Z01 Linux Sys Admin
- **Instructor:** Professor Jay Powser
- **Student:** Jon Shukurov
- **Environment:** Omarchy Linux

## Project Summary
This custom system utility suite monitors local networking parameters, records interface status, pings configured gateway endpoints, and evaluates open local listening ports without interacting with external package managers or security update feeds.

## Architecture
- **`net_sentinel.sh`**: The primary Bash orchestrator script. It handles environment validation, temporary scratch directories, network status extraction, and routes data into the Python analysis pipeline.
- **`latency_evaluator.py`**: A companion Python utility that reads raw network diagnostic metrics, parses latency averages, and reports connectivity warnings.

## Execution Instructions
Grant execution rights and run the orchestrator script in your terminal: