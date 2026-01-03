"""Generate composite rates with labour, materials, and plant build-ups."""
import json
import os
from typing import Dict, List, Any

# Paths
base_dir = r'C:\dev\contech\temp-contechdata\contechdata-rates'
staging_file = os.path.join(base_dir, 'workspace', 'au', 'ingest', 'staging', 'rate_descriptions.json')
output_dir = os.path.join(base_dir, 'au', 'seed-data', 'composite_rates')

os.makedirs(output_dir, exist_ok=True)

# Load extracted rates
with open(staging_file, 'r', encoding='utf-8') as f:
    data = json.load(f)

rates = data['rates']
print(f'Loaded {len(rates)} rates')

# Gang rates (from gangs.json)
GANGS = {
    '1+0': 65.0,
    '1+0.5': 82.5,
    '1+1': 95.0,
    '2+1': 165.0,
    '0+1': 55.0,
    '0+2': 110.0
}

# Trade mapping based on keywords
def get_trade_and_gang(description: str, nrm_group: int) -> tuple:
    desc_lower = description.lower()

    # Electrical work
    if any(kw in desc_lower for kw in ['electric', 'power', 'light', 'cable', 'socket', 'switch', 'wiring', 'circuit']):
        return 'Electrician', '1+0', 84.0

    # Plumbing work
    if any(kw in desc_lower for kw in ['plumb', 'pipe', 'drain', 'water', 'sanitary', 'tap', 'valve', 'toilet', 'basin']):
        return 'Plumber', '1+0.5', 92.0

    # HVAC work
    if any(kw in desc_lower for kw in ['hvac', 'ventil', 'air con', 'duct', 'heating', 'cooling', 'extract']):
        return 'HVAC', '1+1', 95.0

    # Brickwork/masonry
    if any(kw in desc_lower for kw in ['brick', 'block', 'masonry', 'render', 'mortar']):
        return 'Bricklayer', '1+1', 95.0

    # Carpentry
    if any(kw in desc_lower for kw in ['timber', 'wood', 'frame', 'joinery', 'door', 'window', 'stair', 'rail']):
        return 'Carpenter', '1+0.5', 82.5

    # Roofing
    if any(kw in desc_lower for kw in ['roof', 'tile', 'gutter', 'flashing']):
        return 'Roofer', '1+1', 95.0

    # Plastering
    if any(kw in desc_lower for kw in ['plaster', 'render', 'skim', 'ceiling']):
        return 'Plasterer', '1+0.5', 82.5

    # Tiling
    if any(kw in desc_lower for kw in ['tile', 'ceramic', 'porcelain', 'mosaic']):
        return 'Tiler', '1+0.5', 82.5

    # Painting
    if any(kw in desc_lower for kw in ['paint', 'decor', 'coating', 'finish']):
        return 'Painter', '1+0', 66.0

    # Concrete/groundworks
    if any(kw in desc_lower for kw in ['concrete', 'excavat', 'foundation', 'footing', 'slab']):
        return 'Labourer', '0+2', 110.0

    # Demolition/hazmat
    if any(kw in desc_lower for kw in ['demol', 'asbestos', 'hazard', 'remov']):
        return 'Specialist', '1+1', 95.0

    # Default by group
    if nrm_group == 0:  # Facilitating
        return 'Specialist', '1+1', 95.0
    elif nrm_group == 1:  # Substructure
        return 'Labourer', '0+2', 110.0
    elif nrm_group == 5:  # Services
        return 'Tradesperson', '1+0', 75.0
    else:
        return 'General', '1+0.5', 82.5


def get_labour_hours(unit: str, description: str) -> float:
    """Labour hours heuristics based on unit."""
    unit_lower = unit.lower() if unit else 'm2'
    desc_lower = description.lower()

    # Complex work
    if any(kw in desc_lower for kw in ['complex', 'ornate', 'special', 'bespoke']):
        multiplier = 1.5
    else:
        multiplier = 1.0

    if 'm2' in unit_lower or 'm²' in unit_lower:
        # Area-based work
        if any(kw in desc_lower for kw in ['wall', 'brick', 'block', 'masonry']):
            return 0.6 * multiplier
        elif any(kw in desc_lower for kw in ['tile', 'floor', 'ceil']):
            return 0.35 * multiplier
        elif any(kw in desc_lower for kw in ['paint', 'coat']):
            return 0.12 * multiplier
        elif any(kw in desc_lower for kw in ['roof', 'clad']):
            return 0.25 * multiplier
        else:
            return 0.3 * multiplier
    elif 'm3' in unit_lower or 'm³' in unit_lower:
        # Volume-based work (concrete, excavation)
        return 1.5 * multiplier
    elif unit_lower in ['m', 'lm']:
        # Linear work
        if any(kw in desc_lower for kw in ['pipe', 'cable', 'duct']):
            return 0.15 * multiplier
        else:
            return 0.25 * multiplier
    elif unit_lower in ['nr', 'ea', 'item', 'unit', 'leaf']:
        # Each/number based
        if any(kw in desc_lower for kw in ['simple', 'small']):
            return 0.5 * multiplier
        elif any(kw in desc_lower for kw in ['large', 'complex']):
            return 3.0 * multiplier
        else:
            return 1.0 * multiplier
    else:
        return 0.5 * multiplier


def get_material_cost(unit: str, description: str) -> float:
    """Material cost heuristics."""
    unit_lower = unit.lower() if unit else 'm2'
    desc_lower = description.lower()

    # High value materials
    if any(kw in desc_lower for kw in ['marble', 'granite', 'stone', 'premium']):
        base = 150.0
    elif any(kw in desc_lower for kw in ['timber', 'hardwood']):
        base = 80.0
    elif any(kw in desc_lower for kw in ['steel', 'metal']):
        base = 60.0
    elif any(kw in desc_lower for kw in ['tile', 'porcelain']):
        base = 55.0
    elif any(kw in desc_lower for kw in ['brick', 'block']):
        base = 40.0
    elif any(kw in desc_lower for kw in ['concrete']):
        base = 35.0
    elif any(kw in desc_lower for kw in ['plaster', 'paint']):
        base = 15.0
    elif any(kw in desc_lower for kw in ['insulation']):
        base = 20.0
    elif any(kw in desc_lower for kw in ['electric', 'cable']):
        base = 25.0
    elif any(kw in desc_lower for kw in ['pipe', 'plumb']):
        base = 30.0
    else:
        base = 25.0

    # Adjust for unit type
    if 'm3' in unit_lower or 'm³' in unit_lower:
        return base * 5
    elif unit_lower in ['nr', 'ea', 'item', 'unit']:
        return base * 0.8
    else:
        return base


def get_plant_cost(unit: str, description: str, nrm_group: int) -> float:
    """Plant cost heuristics."""
    desc_lower = description.lower()

    # Groups with significant plant
    if nrm_group in [0, 1, 8]:  # Facilitating, Substructure, External
        base = 15.0
    elif any(kw in desc_lower for kw in ['excavat', 'demol', 'concrete']):
        base = 20.0
    elif any(kw in desc_lower for kw in ['scaffold', 'height', 'lift']):
        base = 10.0
    elif any(kw in desc_lower for kw in ['crane', 'hoist']):
        base = 25.0
    else:
        base = 3.0

    return base


def build_rate(rate: Dict) -> Dict:
    """Build rate with all components."""
    trade, gang, gang_rate = get_trade_and_gang(rate['description'], rate['nrm_group'])
    hrs = get_labour_hours(rate['unit'], rate['description'])
    mat_cost = get_material_cost(rate['unit'], rate['description'])
    plant_cost = get_plant_cost(rate['unit'], rate['description'], rate['nrm_group'])

    labour_cost = hrs * gang_rate

    # Build output
    return {
        'code': rate['code'],
        'name': rate['description'],
        'description': rate['notes'] or rate['description'],
        'unit': rate['unit'],
        'nrm1_code': rate['nrm1_code'],
        'nrm2_codes': ', '.join(rate['nrm2_codes']) if rate['nrm2_codes'] else '',
        'spec_level': 'Standard',
        'base_date': 'Jan-2025',
        'region': 'Sydney Metro',
        'labour': [{
            'nrm2_code': rate['nrm2_codes'][0] if rate['nrm2_codes'] else 'WS1',
            'task_description': rate['description'][:50],
            'gang': gang,
            'output': round(1/hrs, 2) if hrs > 0 else 1.0,
            'output_unit': rate['unit'] + '/hr',
            'hrs_per_unit': round(hrs, 4),
            'rate_per_hour': gang_rate,
            'cost_per_unit': round(labour_cost, 2),
            'source': 'Heuristic'
        }],
        'materials': [{
            'nrm2_code': rate['nrm2_codes'][0] if rate['nrm2_codes'] else 'WS1',
            'description': 'Materials allowance',
            'unit': rate['unit'],
            'quantity': 1.0,
            'unit_rate': round(mat_cost, 2),
            'cost': round(mat_cost, 2),
            'supplier': 'TBC'
        }],
        'plant': [{
            'nrm2_code': rate['nrm2_codes'][0] if rate['nrm2_codes'] else 'WS1',
            'description': 'Plant allowance',
            'unit': rate['unit'],
            'quantity': 1.0,
            'unit_rate': round(plant_cost, 2),
            'cost': round(plant_cost, 2),
            'notes': None
        }],
        'labour_total': round(labour_cost, 2),
        'materials_total': round(mat_cost, 2),
        'plant_total': round(plant_cost, 2),
        'waste_percent': 5,
        'nett_total': round((labour_cost + mat_cost + plant_cost) * 1.05, 2),
        'ohp_percent': 15,
        'total_rate': round((labour_cost + mat_cost + plant_cost) * 1.05 * 1.15, 2)
    }


# Group names
GROUP_NAMES = {
    0: 'facilitating',
    1: 'substructure',
    2: 'superstructure',
    3: 'finishes',
    4: 'fittings',
    5: 'services',
    8: 'external'
}

# Process and write files
group_data = {}
for rate in rates:
    g = rate['nrm_group']
    if g not in group_data:
        group_data[g] = []
    group_data[g].append(build_rate(rate))

# Write group files
index = {'groups': {}, 'total': 0}
for g, group_rates in group_data.items():
    filename = f'group_{g}_{GROUP_NAMES.get(g, "unknown")}.json'
    filepath = os.path.join(output_dir, filename)

    output = {
        'meta': {
            'nrm_group': g,
            'group_name': GROUP_NAMES.get(g, 'unknown'),
            'count': len(group_rates),
            'generated': '2026-01-03',
            'source': 'Composite_Rate_Descriptions.xlsx'
        },
        'rates': group_rates
    }

    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(output, f, indent=2, ensure_ascii=False)

    index['groups'][str(g)] = {
        'name': GROUP_NAMES.get(g, 'unknown'),
        'file': filename,
        'count': len(group_rates),
        'codes': [r['code'] for r in group_rates]
    }
    index['total'] += len(group_rates)
    print(f'Wrote {filename}: {len(group_rates)} rates')

# Write index file
index_path = os.path.join(base_dir, 'au', 'seed-data', 'composite_rates_index.json')
with open(index_path, 'w', encoding='utf-8') as f:
    json.dump(index, f, indent=2, ensure_ascii=False)

print(f'\nWrote composite_rates_index.json: {index["total"]} total rates')
print('\nDone! Generated rates by group:')
for g in sorted(group_data.keys()):
    print(f'  Group {g} ({GROUP_NAMES.get(g)}): {len(group_data[g])} rates')
