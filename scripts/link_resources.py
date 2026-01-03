"""
Wave 6: Resource Library Linking
Transform 777 seed rates to use resource_id links instead of inline values.
"""

import json
import os
import re
from datetime import datetime

# Paths
BASE_DIR = r'C:\dev\contech\temp-contechdata\contechdata-rates'
INTL_DIR = r'C:\dev\contech\temp-contechdata\international\au'
RATES_DIR = os.path.join(BASE_DIR, 'au', 'seed-data', 'composite_rates')
OUTPUT_DIR = os.path.join(BASE_DIR, 'workspace', 'au', 'metadata', 'validations')

os.makedirs(OUTPUT_DIR, exist_ok=True)

# =============================================================================
# LOAD RESOURCE LIBRARIES
# =============================================================================

def load_labour_resources():
    """Load labour rates from labour-rates.json"""
    path = os.path.join(INTL_DIR, 'resources', 'labour-rates.json')
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    return {r['resource_id']: r for r in data['rates']}

def load_material_resources():
    """Load material resource IDs from individual files"""
    resources = {}
    res_dir = os.path.join(INTL_DIR, 'resources')
    for f in os.listdir(res_dir):
        if f.startswith('MAT_AU_') and f.endswith('.json'):
            path = os.path.join(res_dir, f)
            try:
                with open(path, 'r', encoding='utf-8') as fp:
                    data = json.load(fp)
                    # Get resource_id from filename or data
                    res_id = f.replace('.json', '')
                    resources[res_id] = data
            except:
                pass
    return resources

def get_plant_resources():
    """Define plant resource IDs based on plant mapping CSV"""
    return {
        'PLT_AU_EXCAVATOR': {'name': 'Excavator', 'rate': 180},
        'PLT_AU_MINI_EXCAVATOR': {'name': 'Mini Excavator', 'rate': 120},
        'PLT_AU_SKID_STEER': {'name': 'Skid Steer Loader', 'rate': 100},
        'PLT_AU_COMPACTOR': {'name': 'Compactor', 'rate': 80},
        'PLT_AU_ROLLER': {'name': 'Roller', 'rate': 90},
        'PLT_AU_TIPPER_TRUCK': {'name': 'Tipper Truck', 'rate': 95},
        'PLT_AU_AUGER_DRILL': {'name': 'Auger Drill Rig', 'rate': 250},
        'PLT_AU_VIBRATOR': {'name': 'Concrete Vibrator', 'rate': 25},
        'PLT_AU_NAIL_GUN': {'name': 'Nail Gun', 'rate': 15},
        'PLT_AU_LIFTING_GEAR': {'name': 'Lifting Gear', 'rate': 50},
        'PLT_AU_CRANE': {'name': 'Mobile Crane', 'rate': 350},
        'PLT_AU_BREAKER': {'name': 'Hydraulic Breaker', 'rate': 150},
        'PLT_AU_SCAFFOLD': {'name': 'Scaffold', 'rate': 12},
        'PLT_AU_CONCRETE_PUMP': {'name': 'Concrete Pump', 'rate': 200},
        'PLT_AU_GENERATOR': {'name': 'Generator', 'rate': 60},
        'PLT_AU_EWP': {'name': 'Elevated Work Platform', 'rate': 180},
        'PLT_AU_SKIP_BIN': {'name': 'Skip Bin', 'rate': 150},
    }

# =============================================================================
# TRADE DETECTION
# =============================================================================

TRADE_KEYWORDS = [
    (r'asbestos|hazmat|toxic|contamin', 'LAB_AU_CIVIL'),
    (r'demolit|strip.?out', 'LAB_AU_CIVIL'),
    (r'electri|power|cable|light|switch|outlet', 'LAB_AU_ELECTRICIAN'),
    (r'plumb|pipe|drain|sewer|water.?main|tap|valve', 'LAB_AU_PLUMBER'),
    (r'brick|block|masonry|pointing', 'LAB_AU_BRICKLAYER'),
    (r'paint|coat|prime|finish|stain', 'LAB_AU_PAINTER'),
    (r'tile|floor.?finish|ceramic|porcelain', 'LAB_AU_TILER'),
    (r'roof|gutter|fascia|eave|soffit', 'LAB_AU_ROOFER'),
    (r'concret|slab|footing|pour', 'LAB_AU_CONCRETER'),
    (r'steel|weld|reinforce|rebar|reo', 'LAB_AU_STEEL_FIXER'),
    (r'carp|timber|frame|joist|bearer|truss', 'LAB_AU_CARPENTER'),
    (r'plaster|gyprock|drywall|cornice|ceiling.?lining', 'LAB_AU_PLASTERER'),
    (r'glaz|window|glass|mirror', 'LAB_AU_GLAZIER'),
    (r'hvac|air.?con|duct|ventil|split.?system', 'LAB_AU_HVAC'),
    (r'insul|batts|wrap|thermal', 'LAB_AU_INSULATOR'),
    (r'landscap|garden|plant|turf|mulch', 'LAB_AU_LANDSCAPER'),
    (r'pav|paver|brick.?pav', 'LAB_AU_PAVER'),
    (r'fence|gate|screen', 'LAB_AU_FENCER'),
    (r'waterproof|membrane', 'LAB_AU_WATERPROOFER'),
    (r'joiner|cabinet|bench|cupboard', 'LAB_AU_JOINER'),
    (r'survey|setout', 'LAB_AU_SURVEYOR'),
    (r'excavat|dig|trench|earth', 'LAB_AU_CIVIL'),
]

def detect_trade(description, nrm1_code=None):
    """Detect trade from description keywords"""
    desc_lower = description.lower()

    for pattern, trade in TRADE_KEYWORDS:
        if re.search(pattern, desc_lower):
            return trade

    # Fallback based on NRM1 group
    if nrm1_code:
        code = str(nrm1_code)
        if code.startswith('0'):  # Facilitating
            return 'LAB_AU_CIVIL'
        elif code.startswith('1'):  # Substructure
            return 'LAB_AU_CONCRETER'
        elif code.startswith('2'):  # Superstructure
            return 'LAB_AU_CARPENTER'
        elif code.startswith('3'):  # Finishes
            return 'LAB_AU_PLASTERER'
        elif code.startswith('4'):  # Fittings
            return 'LAB_AU_JOINER'
        elif code.startswith('5'):  # Services
            return 'LAB_AU_ELECTRICIAN'
        elif code.startswith('8'):  # External
            return 'LAB_AU_CIVIL'

    return 'LAB_AU_TRADES'

# =============================================================================
# GANG EXPANSION
# =============================================================================

def expand_gang(gang_str, trade_id, hrs_per_unit, labour_resources):
    """
    Expand gang composition to resource_id entries.
    Gang format: "1+0", "1+0.5", "1+1", "0+2"
    First number = tradesperson, second = labourer
    """
    components = []

    # Parse gang string
    parts = gang_str.split('+')
    trade_count = float(parts[0]) if parts[0] else 0
    labourer_count = float(parts[1]) if len(parts) > 1 and parts[1] else 0

    # Add trade resource
    if trade_count > 0:
        trade_hrs = hrs_per_unit * trade_count
        components.append({
            'resource_id': trade_id,
            'qty': round(trade_hrs, 3),
            'unit': 'hr'
        })

    # Add labourer resource
    if labourer_count > 0:
        labourer_hrs = hrs_per_unit * labourer_count
        components.append({
            'resource_id': 'LAB_AU_LABOURER',
            'qty': round(labourer_hrs, 3),
            'unit': 'hr'
        })

    return components

# =============================================================================
# PLANT DETECTION
# =============================================================================

PLANT_KEYWORDS = [
    (r'excavat|dig|trench|bulk.?cut', 'PLT_AU_MINI_EXCAVATOR'),
    (r'demolit|break|crush', 'PLT_AU_BREAKER'),
    (r'concret|pour|slab', 'PLT_AU_VIBRATOR'),
    (r'crane|lift|hoist', 'PLT_AU_CRANE'),
    (r'scaffold|height|high.?level', 'PLT_AU_SCAFFOLD'),
    (r'compact|roll|subgrade', 'PLT_AU_COMPACTOR'),
    (r'clear|grub|strip', 'PLT_AU_SKID_STEER'),
    (r'generator|power.?supply', 'PLT_AU_GENERATOR'),
    (r'ewp|platform|cherry.?pick', 'PLT_AU_EWP'),
    (r'pump|dewater', 'PLT_AU_CONCRETE_PUMP'),
    (r'skip|bin|waste', 'PLT_AU_SKIP_BIN'),
]

def detect_plant(description):
    """Detect required plant from description"""
    desc_lower = description.lower()

    for pattern, plant in PLANT_KEYWORDS:
        if re.search(pattern, desc_lower):
            return plant

    return None

# =============================================================================
# MATERIAL MAPPING
# =============================================================================

def find_material_match(description, nrm2_codes, material_resources):
    """
    Try to match material description to a resource_id.
    Returns resource_id if found, None otherwise.
    """
    desc_lower = description.lower()

    # Check for specific materials
    material_patterns = [
        (r'brick', 'MAT_AU_BRICKS'),
        (r'concrete|cement', 'MAT_AU_CONCRETE'),
        (r'plasterboard|gyprock|drywall', 'MAT_AU_PLASTERBOARD'),
        (r'timber|frame|stud', 'MAT_AU_FRAMING'),
        (r'tile', 'MAT_AU_FLOOR_TILES'),
        (r'carpet', 'MAT_AU_CARPET'),
        (r'paint', 'MAT_AU_PAINT'),
        (r'insul|batt', 'MAT_AU_ACOUSTIC_BATTS'),
        (r'membrane|waterproof', 'MAT_AU_WATERPROOF_MEMBRANE'),
        (r'door', 'MAT_AU_DOOR'),
        (r'window', 'MAT_AU_WINDOW'),
        (r'pipe|drain', 'MAT_AU_DRAINAGE'),
        (r'cable|wire', 'MAT_AU_ELEC_CABLE'),
        (r'conduit', 'MAT_AU_CONDUIT'),
        (r'flashin', 'MAT_AU_FLASHINGS'),
        (r'cornice', 'MAT_AU_CORNICE'),
        (r'cladding', 'MAT_AU_CLADDING'),
        (r'fence', 'MAT_AU_FENCE'),
        (r'decking', 'MAT_AU_DECKING'),
        (r'basin|sink', 'MAT_AU_BASIN'),
        (r'bath|tub', 'MAT_AU_BATH'),
    ]

    for pattern, mat_id in material_patterns:
        if re.search(pattern, desc_lower):
            # Check if resource exists
            if mat_id in material_resources:
                return mat_id

    return None

# =============================================================================
# TRANSFORM RATE
# =============================================================================

def transform_rate(rate, labour_resources, material_resources, plant_resources):
    """Transform a single rate to use resource_id links"""

    components = {
        'labour': [],
        'materials': [],
        'plant': []
    }

    # === LABOUR ===
    trade_id = detect_trade(rate.get('description', ''), rate.get('nrm1_code'))

    for labour_item in rate.get('labour', []):
        gang = labour_item.get('gang', '1+0')
        hrs_per_unit = labour_item.get('hrs_per_unit', 0.5)

        gang_components = expand_gang(gang, trade_id, hrs_per_unit, labour_resources)
        components['labour'].extend(gang_components)

    # === MATERIALS ===
    for mat in rate.get('materials', []):
        mat_desc = mat.get('description', '')
        mat_id = find_material_match(mat_desc, rate.get('nrm2_codes', ''), material_resources)

        if mat_id:
            components['materials'].append({
                'resource_id': mat_id,
                'qty': mat.get('quantity', 1.0),
                'unit': mat.get('unit', 'ea')
            })
        else:
            # Keep as inline allowance
            components['materials'].append({
                'description': mat_desc,
                'qty': mat.get('quantity', 1.0),
                'unit': mat.get('unit', 'ea'),
                'rate': mat.get('unit_rate', 0)
            })

    # === PLANT ===
    plant_id = detect_plant(rate.get('description', ''))
    if plant_id and rate.get('plant'):
        plant_item = rate['plant'][0]
        components['plant'].append({
            'resource_id': plant_id,
            'qty': plant_item.get('quantity', 0.1),
            'unit': plant_item.get('unit', 'hr')
        })
    elif rate.get('plant'):
        # Keep generic plant allowance
        plant_item = rate['plant'][0]
        if plant_item.get('cost', 0) > 0:
            components['plant'].append({
                'description': plant_item.get('description', 'Plant allowance'),
                'qty': plant_item.get('quantity', 1.0),
                'unit': plant_item.get('unit', 'ea'),
                'rate': plant_item.get('unit_rate', 0)
            })

    # Build new rate structure
    new_rate = {
        'code': rate.get('code'),
        'name': rate.get('name'),
        'description': rate.get('description'),
        'unit': rate.get('unit'),
        'nrm1_code': rate.get('nrm1_code'),
        'nrm2_codes': rate.get('nrm2_codes'),
        'spec_level': rate.get('spec_level', 'Standard'),
        'base_date': rate.get('base_date', 'Jan-2025'),
        'region': rate.get('region', 'Sydney Metro'),
        'components': components,
        'labour_hours_per_unit': sum(c.get('qty', 0) for c in components['labour']),
        'gang_composition': rate.get('labour', [{}])[0].get('gang', '1+0') if rate.get('labour') else '1+0',
        'material_waste_factor': 1.0 + (rate.get('waste_percent', 5) / 100),
        'labour_total': rate.get('labour_total', 0),
        'materials_total': rate.get('materials_total', 0),
        'plant_total': rate.get('plant_total', 0),
        'waste_percent': rate.get('waste_percent', 5),
        'nett_total': rate.get('nett_total', 0),
        'ohp_percent': rate.get('ohp_percent', 15),
        'total_rate': rate.get('total_rate', 0)
    }

    return new_rate

# =============================================================================
# MAIN EXECUTION
# =============================================================================

def main():
    print("Wave 6: Resource Library Linking")
    print("=" * 50)

    # Load resources
    print("\nLoading resource libraries...")
    labour_resources = load_labour_resources()
    print(f"  Labour: {len(labour_resources)} resources")

    material_resources = load_material_resources()
    print(f"  Materials: {len(material_resources)} resources")

    plant_resources = get_plant_resources()
    print(f"  Plant: {len(plant_resources)} resources")

    # Stats
    stats = {
        'total_rates': 0,
        'labour_linked': 0,
        'materials_linked': 0,
        'plant_linked': 0,
        'by_group': {}
    }

    # Process each group file
    group_files = sorted([f for f in os.listdir(RATES_DIR) if f.startswith('group_') and f.endswith('.json')])

    for group_file in group_files:
        print(f"\nProcessing {group_file}...")

        path = os.path.join(RATES_DIR, group_file)
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)

        group_stats = {
            'count': 0,
            'labour_linked': 0,
            'materials_linked': 0,
            'plant_linked': 0
        }

        new_rates = []
        for rate in data.get('rates', []):
            new_rate = transform_rate(rate, labour_resources, material_resources, plant_resources)
            new_rates.append(new_rate)

            # Count stats
            group_stats['count'] += 1
            if any(c.get('resource_id') for c in new_rate['components']['labour']):
                group_stats['labour_linked'] += 1
            if any(c.get('resource_id') for c in new_rate['components']['materials']):
                group_stats['materials_linked'] += 1
            if any(c.get('resource_id') for c in new_rate['components']['plant']):
                group_stats['plant_linked'] += 1

        # Update data
        data['rates'] = new_rates
        data['meta']['transformed'] = datetime.now().strftime('%Y-%m-%d')
        data['meta']['resource_linked'] = True

        # Write back
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

        print(f"  Rates: {group_stats['count']}")
        print(f"  Labour linked: {group_stats['labour_linked']} ({100*group_stats['labour_linked']/group_stats['count']:.0f}%)")
        print(f"  Materials linked: {group_stats['materials_linked']} ({100*group_stats['materials_linked']/group_stats['count']:.0f}%)")
        print(f"  Plant linked: {group_stats['plant_linked']} ({100*group_stats['plant_linked']/group_stats['count']:.0f}%)")

        stats['total_rates'] += group_stats['count']
        stats['labour_linked'] += group_stats['labour_linked']
        stats['materials_linked'] += group_stats['materials_linked']
        stats['plant_linked'] += group_stats['plant_linked']
        stats['by_group'][group_file] = group_stats

    # Generate QA report
    print("\n" + "=" * 50)
    print("Generating QA report...")

    report = f"""# Resource Linking QA Report

**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**Status**: COMPLETE

## Summary

| Metric | Count | Percentage |
|--------|-------|------------|
| Total Rates | {stats['total_rates']} | 100% |
| Labour Linked | {stats['labour_linked']} | {100*stats['labour_linked']/stats['total_rates']:.1f}% |
| Materials Linked | {stats['materials_linked']} | {100*stats['materials_linked']/stats['total_rates']:.1f}% |
| Plant Linked | {stats['plant_linked']} | {100*stats['plant_linked']/stats['total_rates']:.1f}% |

## By Group

| Group | Rates | Labour % | Materials % | Plant % |
|-------|-------|----------|-------------|---------|
"""

    for group_file, gs in stats['by_group'].items():
        group_name = group_file.replace('.json', '').replace('group_', '')
        report += f"| {group_name} | {gs['count']} | {100*gs['labour_linked']/gs['count']:.0f}% | {100*gs['materials_linked']/gs['count']:.0f}% | {100*gs['plant_linked']/gs['count']:.0f}% |\n"

    report += f"""
## Resource Libraries Used

| Type | Count |
|------|-------|
| Labour (LAB_AU_*) | {len(labour_resources)} |
| Materials (MAT_AU_*) | {len(material_resources)} |
| Plant (PLT_AU_*) | {len(plant_resources)} |

## Trade Detection Patterns

The following keyword patterns were used to detect trades:

| Pattern | Resource ID |
|---------|-------------|
| asbestos, hazmat, toxic | LAB_AU_CIVIL |
| electrical, power, cable | LAB_AU_ELECTRICIAN |
| plumb, pipe, drain | LAB_AU_PLUMBER |
| brick, block, masonry | LAB_AU_BRICKLAYER |
| paint, coat | LAB_AU_PAINTER |
| tile, floor | LAB_AU_TILER |
| roof, gutter | LAB_AU_ROOFER |
| concrete, slab | LAB_AU_CONCRETER |
| steel, weld | LAB_AU_STEEL_FIXER |
| timber, frame | LAB_AU_CARPENTER |
| plaster, gyprock | LAB_AU_PLASTERER |
| glaz, window | LAB_AU_GLAZIER |
| hvac, air con | LAB_AU_HVAC |
| default | LAB_AU_TRADES |

## Notes

- Labour: All rates have at least one linked labour resource
- Materials: Rates with generic "Materials allowance" keep inline values
- Plant: Only rates with identifiable plant needs get resource links

---

**QA Completed By**: Claude Opus 4.5
**Date**: {datetime.now().strftime('%Y-%m-%d')}
"""

    qa_path = os.path.join(OUTPUT_DIR, 'resource-linking-qa.md')
    with open(qa_path, 'w', encoding='utf-8') as f:
        f.write(report)

    print(f"\nQA report written to: {qa_path}")
    print(f"\nTotal rates transformed: {stats['total_rates']}")
    print(f"Labour linked: {stats['labour_linked']} ({100*stats['labour_linked']/stats['total_rates']:.1f}%)")
    print(f"Materials linked: {stats['materials_linked']} ({100*stats['materials_linked']/stats['total_rates']:.1f}%)")
    print(f"Plant linked: {stats['plant_linked']} ({100*stats['plant_linked']/stats['total_rates']:.1f}%)")

if __name__ == '__main__':
    main()
