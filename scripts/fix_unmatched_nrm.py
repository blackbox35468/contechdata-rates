#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fix 78 unmatched NRM items in seed rate JSON files.

Group 0 (Facilitating) - 17 items with empty L2 codes
Group 5 (Services) - 61 items with range codes (5.3-5.4, 5.5-5.7)
"""

import json
import csv
import sys
from pathlib import Path
from typing import Dict, List, Tuple

# Force UTF-8 encoding for output
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')

# File paths
BASE_DIR = Path(__file__).parent.parent
CROSSWALK_FILE = BASE_DIR / "NRM" / "NRM1_L4_to_NRM2_Crosswalk.csv"
GROUP_0_FILE = BASE_DIR / "au" / "seed-data" / "composite_rates" / "group_0_facilitating.json"
GROUP_5_FILE = BASE_DIR / "au" / "seed-data" / "composite_rates" / "group_5_services.json"

# Load crosswalk data
def load_crosswalk() -> Dict[str, Dict]:
    """Load NRM crosswalk and index by L2 code and L4 code."""
    crosswalk_by_l4 = {}
    crosswalk_by_l2 = {}

    with open(CROSSWALK_FILE, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            l4_code = row['nrm1_l4_code']
            l2_code = row['nrm1_l2_code']

            crosswalk_by_l4[l4_code] = row

            if l2_code not in crosswalk_by_l2:
                crosswalk_by_l2[l2_code] = []
            crosswalk_by_l2[l2_code].append(row)

    return crosswalk_by_l4, crosswalk_by_l2

# Manual mappings for Group 0 items
GROUP_0_MAPPINGS = {
    "GRP0-ASBREM-001": ("0.1", "0.1.1.1", "Asbestos removal - toxic material"),
    "GRP0-ASBREM-002": ("0.1", "0.1.1.1", "Asbestos removal - toxic material"),
    "GRP0-LEAPAI-003": ("0.1", "0.1.1.1", "Lead paint removal - toxic material"),
    "GRP0-DEM-004": ("0.2", "0.2.1.1", "Demolition of entire buildings"),
    "GRP0-DEM-005": ("0.2", "0.2.1.1", "Demolition of entire buildings"),
    "GRP0-DEM-006": ("0.2", "0.2.1.1", "Demolition of entire buildings"),
    "GRP0-DEM-007": ("0.2", "0.2.1.1", "Demolition of entire buildings"),
    "GRP0-DEM-008": ("0.2", "0.2.1.1", "Demolition of entire buildings"),
    "GRP0-TEMSTO-009": ("0.5", "0.5.1.1", "Temporary diversion of drains"),
    "GRP0-TEMSEW-010": ("0.5", "0.5.1.1", "Temporary diversion of drains"),
    "GRP0-TEMPOW-011": ("0.5", "0.5.1.2", "Temporary diversion of services"),
    "GRP0-ROCBRE-012": ("0.6", "0.6.1.1", "Excavation works - rock breaking"),
    "GRP0-ROCBRE-013": ("0.6", "0.6.1.1", "Excavation works - rock breaking"),
    "GRP0-DEW-014": ("0.4", "0.4.1.1", "Site dewatering"),
    "GRP0-DEW-015": ("0.4", "0.4.1.1", "Site dewatering"),
    "GRP0-GROIMP-016": ("0.4", "0.4.2.1", "Soil stabilisation measures"),
    "GRP0-GROIMP-017": ("0.4", "0.4.2.1", "Soil stabilisation measures"),
}

# Manual mappings for Group 5 items with range codes
def get_group_5_l2_mapping(code: str, name: str) -> Tuple[str, str]:
    """
    Map Group 5 items to correct L2 code based on item name.

    Items with "5.3-5.4" → Use 5.4 (Water installations)
    Items with "5.5-5.7" → Use 5.5 (HVAC), 5.6 (Space heating), or 5.7 (Electrical)
    """
    name_lower = name.lower()

    # Water installations (originally 5.3-5.4)
    if "hot water" in name_lower or "water heater" in name_lower:
        return ("5.4", "Hot water system")
    elif "water" in name_lower or "rainwater" in name_lower or "tempering" in name_lower:
        return ("5.4", "Water installation")

    # HVAC/Heating/Ventilation (originally 5.5-5.7)
    elif "ac" in name_lower or "air conditioning" in name_lower or "split system" in name_lower:
        return ("5.6", "Air conditioning system")
    elif "ducted" in name_lower and ("ac" in name_lower or "ductwork" in name_lower or "grille" in name_lower or "diffuser" in name_lower):
        return ("5.6", "Ducted air conditioning")
    elif "vrf" in name_lower or "chiller" in name_lower or "cooling" in name_lower or "ahu" in name_lower or "fcu" in name_lower:
        return ("5.6", "Central cooling system")
    elif "bms" in name_lower and "control" in name_lower:
        return ("5.6", "BMS controls")
    elif "heating" in name_lower or "heater" in name_lower or "fireplace" in name_lower or "boiler" in name_lower:
        return ("5.6", "Heating system")
    elif "exhaust" in name_lower or "fan" in name_lower or "ventilation" in name_lower or "hrv" in name_lower or "erv" in name_lower or "smoke" in name_lower or "stair press" in name_lower:
        return ("5.7", "Ventilation system")

    # Default fallback
    else:
        return ("5.6", "Mechanical services")

def find_best_l4_match(l2_code: str, item_name: str, crosswalk_by_l2: Dict) -> Tuple[str, Dict]:
    """Find the best L4 code match for a given L2 code and item name."""
    if l2_code not in crosswalk_by_l2:
        return None, None

    candidates = crosswalk_by_l2[l2_code]

    # Simple keyword matching
    name_lower = item_name.lower()
    keywords_map = {
        "toxic": ["toxic", "hazardous"],
        "demolition": ["demolition"],
        "diversion": ["diversion"],
        "excavation": ["excavation"],
        "dewatering": ["dewatering"],
        "stabilisation": ["stabilisation"],
        "hot water": ["hot water"],
        "water": ["water", "cold water"],
        "heater": ["heater"],
        "air conditioning": ["air conditioning", "cooling"],
        "heating": ["heating"],
        "ventilation": ["ventilation", "fan", "exhaust"],
    }

    # Try to find exact match based on keywords
    for candidate in candidates:
        desc_lower = candidate['nrm1_description'].lower()
        for keyword_group in keywords_map.values():
            if any(kw in name_lower for kw in keyword_group):
                if any(kw in desc_lower for kw in keyword_group):
                    return candidate['nrm1_l4_code'], candidate

    # If no keyword match, return first candidate
    return candidates[0]['nrm1_l4_code'], candidates[0]

def fix_group_0(crosswalk_by_l4: Dict, crosswalk_by_l2: Dict):
    """Fix Group 0 facilitating items."""
    print("=" * 80)
    print("FIXING GROUP 0 (FACILITATING) - 17 items")
    print("=" * 80)

    with open(GROUP_0_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    fixed_count = 0

    for rate in data['rates']:
        code = rate['code']

        if code in GROUP_0_MAPPINGS:
            l2_code, l4_code, reasoning = GROUP_0_MAPPINGS[code]

            if l4_code in crosswalk_by_l4:
                crosswalk_entry = crosswalk_by_l4[l4_code]
            else:
                # Find best match
                l4_code, crosswalk_entry = find_best_l4_match(l2_code, rate['name'], crosswalk_by_l2)

            if crosswalk_entry:
                rate['nrm1_l4_code'] = crosswalk_entry['nrm1_l4_code']
                rate['nrm1_l3_code'] = crosswalk_entry['nrm1_l3_code']
                rate['nrm1_l2_code'] = crosswalk_entry['nrm1_l2_code']
                rate['nrm1_description'] = crosswalk_entry['nrm1_description']
                rate['nrm2_primary_ws'] = crosswalk_entry['nrm2_primary_ws']
                rate['nrm2_primary_ws_name'] = crosswalk_entry['nrm2_primary_ws_name']
                rate['nrm2_primary_items'] = crosswalk_entry['nrm2_primary_items']
                rate['nrm2_secondary_ws'] = crosswalk_entry['nrm2_secondary_ws']
                rate['mapping_confidence'] = "Manual"

                fixed_count += 1
                print(f"[OK] {code}: {rate['name']}")
                print(f"  L2: {l2_code} -> L4: {l4_code}")
                print(f"  Reasoning: {reasoning}")
                print()

    # Write back
    with open(GROUP_0_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"Fixed {fixed_count} items in Group 0")
    return fixed_count

def fix_group_5(crosswalk_by_l4: Dict, crosswalk_by_l2: Dict):
    """Fix Group 5 services items."""
    print("\n" + "=" * 80)
    print("FIXING GROUP 5 (SERVICES) - 61 items")
    print("=" * 80)

    with open(GROUP_5_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    fixed_count = 0

    for rate in data['rates']:
        l2_code = rate.get('nrm1_l2_code', '')

        # Only fix items with range codes
        if l2_code in ["5.3-5.4", "5.5-5.7"]:
            # Get correct L2 mapping
            correct_l2, reasoning = get_group_5_l2_mapping(rate['code'], rate['name'])

            # Find best L4 match
            l4_code, crosswalk_entry = find_best_l4_match(correct_l2, rate['name'], crosswalk_by_l2)

            if crosswalk_entry:
                rate['nrm1_l4_code'] = crosswalk_entry['nrm1_l4_code']
                rate['nrm1_l3_code'] = crosswalk_entry['nrm1_l3_code']
                rate['nrm1_l2_code'] = crosswalk_entry['nrm1_l2_code']
                rate['nrm1_description'] = crosswalk_entry['nrm1_description']
                rate['nrm2_primary_ws'] = crosswalk_entry['nrm2_primary_ws']
                rate['nrm2_primary_ws_name'] = crosswalk_entry['nrm2_primary_ws_name']
                rate['nrm2_primary_items'] = crosswalk_entry['nrm2_primary_items']
                rate['nrm2_secondary_ws'] = crosswalk_entry['nrm2_secondary_ws']
                rate['mapping_confidence'] = "Manual"

                fixed_count += 1
                print(f"[OK] {rate['code']}: {rate['name']}")
                print(f"  {l2_code} -> L2: {correct_l2} -> L4: {l4_code}")
                print(f"  Reasoning: {reasoning}")
                print()

    # Write back
    with open(GROUP_5_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"Fixed {fixed_count} items in Group 5")
    return fixed_count

def main():
    """Main function."""
    print("Loading NRM crosswalk...")
    crosswalk_by_l4, crosswalk_by_l2 = load_crosswalk()
    print(f"Loaded {len(crosswalk_by_l4)} L4 codes, {len(crosswalk_by_l2)} L2 codes")
    print()

    # Fix both groups
    count_0 = fix_group_0(crosswalk_by_l4, crosswalk_by_l2)
    count_5 = fix_group_5(crosswalk_by_l4, crosswalk_by_l2)

    print("\n" + "=" * 80)
    print(f"TOTAL FIXED: {count_0 + count_5} items")
    print("=" * 80)

if __name__ == "__main__":
    main()
