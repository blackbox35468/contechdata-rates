#!/usr/bin/env python3
"""
Update material waste factors in composite rates to comply with NRM standards.

NRM Waste Factor Standards:
- Timber Framing: 1.10 (was 1.03-1.05, gap -5-7%)
- Plasterboard: 1.10 (was 1.05, gap -5%)
- Tiles: 1.10 (was 1.08, gap -2%)
- Brickwork: 1.07 (was 1.05, gap -2%)
- Concrete: 1.05 (was 1.02-1.03, gap -2-3%)
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Tuple

# NRM waste factor standards
WASTE_FACTORS = {
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
    'default': 1.05  # Conservative default for unidentified materials
}

# Material type patterns for identification
MATERIAL_PATTERNS = {
    'timber': [
        r'\btimber\b', r'\bwood\b', r'\blumber\b', r'\bframing\b',
        r'\bstud\b', r'\bjoist\b', r'\brafter\b', r'\bdecking\b',
        r'\bpine\b', r'\bhardwood\b', r'\bsoftwood\b', r'\bplywood\b'
    ],
    'plasterboard': [
        r'\bplasterboard\b', r'\bgypsum\b', r'\bdrywall\b', r'\bgyproc\b',
        r'\bplaster\b', r'\bsheet\s*lining\b'
    ],
    'tiles': [
        r'\btile[sd]?\b', r'\bceramic\b', r'\bporcelain\b', r'\bmosaic\b',
        r'\btiling\b'
    ],
    'brickwork': [
        r'\bbrick\b', r'\bmasonry\b', r'\bblockwork\b', r'\bblock\b',
        r'\bCBU\b', r'\bCMU\b'
    ],
    'concrete': [
        r'\bconcrete\b', r'\bRC\b', r'\breinforced\b'
    ],
    'steel': [
        r'\bsteel\b', r'\bmetal\b', r'\biron\b', r'\baluminium\b'
    ]
}

def identify_material_type(description: str, name: str = '') -> str:
    """Identify material type from description and name."""
    text = f"{description} {name}".lower()

    for material_type, patterns in MATERIAL_PATTERNS.items():
        for pattern in patterns:
            if re.search(pattern, text, re.IGNORECASE):
                return material_type

    return 'default'

def get_waste_factor_for_material(material_type: str) -> float:
    """Get NRM-compliant waste factor for material type."""
    return WASTE_FACTORS.get(material_type, WASTE_FACTORS['default'])

def analyze_composite(composite: Dict) -> Tuple[str, float, str]:
    """
    Analyze composite to determine appropriate waste factor.

    Returns:
        (material_type, waste_factor, evidence)
    """
    # Check if composite has material components
    components = composite.get('components', {})
    materials = components.get('materials', [])

    if not materials:
        return ('none', composite.get('material_waste_factor', 1.05), 'No material components')

    # Analyze composite name and description for material hints
    name = composite.get('name', '')
    description = composite.get('description', '')

    # Check material component descriptions
    material_texts = []
    for material in materials:
        if 'description' in material:
            material_texts.append(material['description'])
        if 'resource_id' in material:
            material_texts.append(material['resource_id'])

    # Combine all text for analysis
    combined_text = f"{name} {description} {' '.join(material_texts)}"

    # Identify material type
    material_type = identify_material_type(combined_text, name)
    waste_factor = get_waste_factor_for_material(material_type)

    evidence = f"Identified from: {name[:50]}..."

    return (material_type, waste_factor, evidence)

def process_file(filepath: Path) -> Dict:
    """Process a single composite rates file."""
    print(f"\nProcessing: {filepath.name}")

    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)

    stats = {
        'total': len(data['rates']),
        'updated': 0,
        'unchanged': 0,
        'by_material': {},
        'details': []
    }

    for composite in data['rates']:
        current_waste = composite.get('material_waste_factor', 1.05)
        material_type, new_waste, evidence = analyze_composite(composite)

        # Track statistics
        if material_type not in stats['by_material']:
            stats['by_material'][material_type] = {
                'count': 0,
                'waste_factor': new_waste
            }
        stats['by_material'][material_type]['count'] += 1

        # Update if different
        if new_waste != current_waste:
            composite['material_waste_factor'] = new_waste

            # Also update waste_percent for consistency
            composite['waste_percent'] = int((new_waste - 1.0) * 100)

            # Recalculate nett_total (only waste_percent changed, not component costs)
            labour_total = composite.get('labour_total', 0)
            materials_total = composite.get('materials_total', 0)
            plant_total = composite.get('plant_total', 0)

            # Apply waste factor to materials only
            materials_with_waste = materials_total * new_waste
            composite['nett_total'] = round(labour_total + materials_with_waste + plant_total, 2)

            # Update total_rate with OHP
            ohp_percent = composite.get('ohp_percent', 15)
            composite['total_rate'] = round(composite['nett_total'] * (1 + ohp_percent / 100), 2)

            stats['updated'] += 1
            stats['details'].append({
                'code': composite['code'],
                'name': composite['name'],
                'material_type': material_type,
                'old_waste': current_waste,
                'new_waste': new_waste,
                'evidence': evidence
            })
        else:
            stats['unchanged'] += 1

    # Write updated data back
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    return stats

def main():
    """Main execution function."""
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
    print("NRM Waste Factor Update - Composite Rates")
    print("=" * 80)

    all_stats = {
        'total_composites': 0,
        'total_updated': 0,
        'by_material': {},
        'all_details': []
    }

    for filename in files:
        filepath = base_path / filename
        if not filepath.exists():
            print(f"WARNING: {filename} not found, skipping")
            continue

        stats = process_file(filepath)

        print(f"  Total composites: {stats['total']}")
        print(f"  Updated: {stats['updated']}")
        print(f"  Unchanged: {stats['unchanged']}")
        print(f"  Material breakdown:")
        for material, info in sorted(stats['by_material'].items()):
            print(f"    {material}: {info['count']} composites @ {info['waste_factor']}")

        all_stats['total_composites'] += stats['total']
        all_stats['total_updated'] += stats['updated']
        all_stats['all_details'].extend(stats['details'])

        # Merge material stats
        for material, info in stats['by_material'].items():
            if material not in all_stats['by_material']:
                all_stats['by_material'][material] = {'count': 0, 'waste_factor': info['waste_factor']}
            all_stats['by_material'][material]['count'] += info['count']

    print("\n" + "=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print(f"Total composites processed: {all_stats['total_composites']}")
    print(f"Total updated: {all_stats['total_updated']}")
    print(f"Update rate: {all_stats['total_updated'] / all_stats['total_composites'] * 100:.1f}%")
    print(f"\nMaterial breakdown (across all files):")
    for material, info in sorted(all_stats['by_material'].items(), key=lambda x: x[1]['count'], reverse=True):
        print(f"  {material}: {info['count']} composites @ {info['waste_factor']}")

    # Write detailed report
    report_path = base_path / 'waste_factor_update_report.json'
    with open(report_path, 'w', encoding='utf-8') as f:
        json.dump(all_stats, f, indent=2, ensure_ascii=False)

    print(f"\nDetailed report written to: {report_path}")

    # Calculate before/after average waste factors
    old_avg = 1.05  # All were 1.05 before
    if all_stats['total_composites'] > 0:
        new_avg = sum(
            info['count'] * info['waste_factor']
            for info in all_stats['by_material'].values()
        ) / all_stats['total_composites']

        print(f"\nAverage waste factor:")
        print(f"  Before: {old_avg:.3f}")
        print(f"  After: {new_avg:.3f}")
        print(f"  Change: +{(new_avg - old_avg):.3f} ({(new_avg / old_avg - 1) * 100:.1f}%)")

        # Estimate quantity impact
        print(f"\nEstimated material quantity impact:")
        print(f"  Previous underestimation: ~{(1 - old_avg / new_avg) * 100:.1f}%")
        print(f"  Correction factor: {new_avg / old_avg:.4f}x")

if __name__ == '__main__':
    main()
