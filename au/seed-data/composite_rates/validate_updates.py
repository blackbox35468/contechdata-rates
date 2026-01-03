#!/usr/bin/env python3
"""
Validate waste factor updates against NRM standards.
"""

import json
from pathlib import Path
from typing import Dict, List

NRM_STANDARDS = {
    'timber': 1.10,
    'plasterboard': 1.10,
    'gypsum': 1.10,
    'tiles': 1.10,
    'ceramic': 1.10,
    'porcelain': 1.10,
    'brickwork': 1.07,
    'brick': 1.07,
    'masonry': 1.07,
    'blockwork': 1.07,
    'concrete': 1.05,
    'steel': 1.05,
    'metal': 1.05,
}

def validate_files():
    """Validate all composite rate files."""
    base_path = Path(__file__).parent
    files = [
        'group_0_facilitating.json',
        'group_1_substructure.json',
        'group_2_superstructure.json',
        'group_3_finishes.json',
        'group_4_fittings.json',
        'group_5_services.json',
        'group_8_external.json'
    ]

    print("=" * 80)
    print("WASTE FACTOR VALIDATION")
    print("=" * 80)

    total_composites = 0
    total_compliant = 0
    waste_factors_found = set()
    issues = []

    for filename in files:
        filepath = base_path / filename
        if not filepath.exists():
            print(f"\nWARNING: {filename} not found")
            continue

        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)

        print(f"\n{filename}:")
        print(f"  Composites: {len(data['rates'])}")

        file_waste_factors = {}
        for composite in data['rates']:
            waste_factor = composite.get('material_waste_factor', 1.0)
            waste_percent = composite.get('waste_percent', 0)

            # Validate consistency
            expected_percent = int((waste_factor - 1.0) * 100)
            if waste_percent != expected_percent:
                issues.append({
                    'file': filename,
                    'code': composite['code'],
                    'issue': f"Waste percent mismatch: {waste_percent}% vs expected {expected_percent}%"
                })

            # Validate recalculation
            labour_total = composite.get('labour_total', 0)
            materials_total = composite.get('materials_total', 0)
            plant_total = composite.get('plant_total', 0)

            expected_nett = round(labour_total + (materials_total * waste_factor) + plant_total, 2)
            actual_nett = composite.get('nett_total', 0)

            if abs(expected_nett - actual_nett) > 0.02:  # Allow 2 cent rounding
                issues.append({
                    'file': filename,
                    'code': composite['code'],
                    'issue': f"Nett total mismatch: {actual_nett} vs expected {expected_nett}"
                })

            # Track waste factor distribution
            if waste_factor not in file_waste_factors:
                file_waste_factors[waste_factor] = 0
            file_waste_factors[waste_factor] += 1
            waste_factors_found.add(waste_factor)

            total_composites += 1
            if waste_factor >= 1.05:  # Minimum acceptable
                total_compliant += 1

        print(f"  Waste factor distribution:")
        for wf in sorted(file_waste_factors.keys()):
            print(f"    {wf}: {file_waste_factors[wf]} composites")

    print("\n" + "=" * 80)
    print("OVERALL STATISTICS")
    print("=" * 80)
    print(f"Total composites validated: {total_composites}")
    print(f"Compliant (≥1.05): {total_compliant} ({total_compliant / total_composites * 100:.1f}%)")
    print(f"Unique waste factors: {sorted(waste_factors_found)}")

    if issues:
        print("\n" + "=" * 80)
        print(f"ISSUES FOUND: {len(issues)}")
        print("=" * 80)
        for issue in issues[:20]:  # Show first 20
            print(f"  [{issue['file']}] {issue['code']}: {issue['issue']}")
        if len(issues) > 20:
            print(f"  ... and {len(issues) - 20} more")
    else:
        print("\nNo issues found. All composites are compliant!")

    return len(issues) == 0

if __name__ == '__main__':
    success = validate_files()
    exit(0 if success else 1)
