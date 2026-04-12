import sys

def parse_vcd(file_path):
    print(f"[*] Scanning {file_path} for suspicious low-activity signals...")
    signals = {}
    activity = {}
    current_scope = []
    
    try:
        with open(file_path, 'r') as f:
            for line in f:
                line = line.strip()
                if not line: continue
                
                # 1. Parse Hierarchy (Scope)
                if line.startswith("$scope"):
                    parts = line.split()
                    if len(parts) >= 3:
                        current_scope.append(parts[2])
                elif line.startswith("$upscope"):
                    if current_scope:
                        current_scope.pop()
                
                # 2. Parse Signal Definitions
                elif line.startswith("$var"):
                    parts = line.split()
                    if len(parts) >= 5:
                        sig_id = parts[3]
                        sig_name = "/".join(current_scope) + "/" + parts[4]
                        signals[sig_id] = sig_name
                        activity[sig_id] = 0
                
                elif line.startswith("$enddefinitions"):
                    print(f"[*] Header parsed. Tracking {len(signals)} signals. Analyzing activity...")
                
                # 3. Parse Value Changes (THE FIX IS HERE)
                elif not line.startswith("$") and not line.startswith("#"):
                    # Check if it is a multi-bit vector (starts with 'b' or 'B')
                    if line.startswith("b") or line.startswith("B"):
                        parts = line.split()
                        if len(parts) == 2:
                            sig_id = parts[1] # The ID is after the space
                            if sig_id in activity:
                                activity[sig_id] += 1
                    else:
                        # It is a 1-bit scalar (e.g., '1n')
                        sig_id = line[1:]
                        if sig_id in activity:
                            activity[sig_id] += 1

        print("[*] Analysis Complete.\n")
        return signals, activity

    except FileNotFoundError:
        print("Error: File not found.")
        return None, None

def report_trojans(signals, activity):
    sorted_signals = sorted(activity.items(), key=lambda item: item[1])
    
    print("--- SUSPICIOUS SIGNAL REPORT (Top 20 Lowest Activity) ---")
    print(f"{'SWITCHES':<10} | {'SIGNAL NAME'}")
    print("-" * 60)
    
    found_trigger = False
    count_printed = 0
    
    for sig_id, count in sorted_signals:
        if count_printed >= 20: break
        name = signals.get(sig_id, "Unknown")
        
        # Filter out expected quiet signals like Clock or Reset
        if "clk" in name.lower() or "rst" in name.lower() or "rcon" in name.lower(): continue 
        
        marker = ""
        if "trojan" in name.lower() or "trigger" in name.lower():
            marker = " <--- TROJAN DETECTED!"
            found_trigger = True
            
        print(f"{count:<10} | {name}{marker}")
        count_printed += 1
        
    print("-" * 60)
    if found_trigger:
        print("\n[SUCCESS] The automated script successfully flagged the Trojan trigger!")
    else:
        print("\n[NOTE] Trojan not explicitly named in top 20, or signal name aliased.")

if __name__ == "__main__":
    vcd_file = "../activity_logs/infected.vcd"
    sigs, acts = parse_vcd(vcd_file)
    if sigs:
        report_trojans(sigs, acts)
