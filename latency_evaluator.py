#!/usr/bin/env python3
"""
CIT 220 Z01 - Latency & Port Sentinel Evaluator
Author: Jon Shukurov
Description: Parses raw network inspection data, evaluates connection states, 
             tracks socket interfaces, and extracts diagnostic summaries.
"""

import sys
import os
import re
from datetime import datetime

def display_banner():
    print("================================================================")
    print("          NETWORK LATENCY & PORT EVALUATOR PARSER               ")
    print(f"          Parsed At: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} ")
    print("================================================================")

def validate_environment():
    if len(sys.argv) < 2:
        print("[Error] Missing required metric data file argument.")
        print("Usage: python3 latency_evaluator.py <metrics_file>")
        sys.exit(1)

    target_file = sys.argv[1]
    if not os.path.exists(target_file):
        print(f"[Critical Error] Target file '{target_file}' could not be located.")
        sys.exit(1)
        
    return target_file

def parse_network_data():
    target_file = validate_environment()
    display_banner()

    total_lines = 0
    active_interfaces = 0
    listening_ports = 0
    anomaly_flags = 0
    gateway_status = "Unknown"

    try:
        with open(target_file, 'r', encoding='utf-8') as f:
            for idx, line in enumerate(f, 1):
                total_lines += 1
                stripped = line.strip()

                if "UP" in stripped or "RUNNING" in stripped:
                    active_interfaces += 1

                if "LISTEN" in stripped or "tcp" in stripped:
                    listening_ports += 1

                if any(err in stripped.upper() for err in ["TIMEOUT", "UNREACHABLE", "ERROR", "DOWN", "100% PACKET LOSS"]):
                    anomaly_flags += 1
                    print(f"[Network Anomaly - Line {idx}] {stripped}")

                if "bytes from" in stripped:
                    gateway_status = "Connected (Healthy)"

        print("----------------------------------------------------------------")
        print("                  NETWORK EVALUATION SUMMARY                    ")
        print("----------------------------------------------------------------")
        print(f" Total Log Records Scanned   : {total_lines}")
        print(f" Active Interface States     : {active_interfaces}")
        print(f" Socket/Port Indicators      : {listening_ports}")
        print(f" Gateway Connectivity Status : {gateway_status}")
        print(f" Connectivity Anomalies Found: {anomaly_flags}")
        print(" Evaluation parse completed successfully.")
        print("================================================================")

    except Exception as err:
        print(f"[Exception] Encountered error during metric parsing: {err}")
        sys.exit(1)

if __name__ == "__main__":
    parse_network_data()
