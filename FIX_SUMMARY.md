# NRM Mapping Fix Summary

**Date**: 2026-01-03
**Script**: `scripts/fix_unmatched_nrm.py`

## Overview

Fixed 78 unmatched items in seed rate JSON files that had no NRM Level 4 mapping.

## Issue

The items fell into two categories:

1. **Group 0 (Facilitating) - 17 items**: Had empty L2 codes in the source data
2. **Group 5 (Services) - 61 items**: Had invalid range codes (`5.3-5.4` or `5.5-5.7`) that don't exist in NRM

## Solution

Created a Python script that:

1. Manually assigned L2 codes to Group 0 items based on content analysis
2. Resolved Group 5 range codes to proper single L2 codes based on item names
3. Matched items to appropriate L4 codes from the NRM crosswalk
4. Updated all NRM fields and set `mapping_confidence` to "Manual"

## Results

### Group 0 (Facilitating) - 17 Items Fixed

| Category | L2 Code | L4 Code | Count | Examples |
|----------|---------|---------|-------|----------|
| Asbestos/lead removal | 0.1 | 0.1.1.1 | 3 | Asbestos removal, Lead paint removal |
| Demolition | 0.2 | 0.2.1.1 | 5 | Single/two storey residential, commercial shed |
| Temporary diversions | 0.5 | 0.5.1.1, 0.5.1.2 | 3 | Stormwater, sewer, power supply |
| Rock breaking | 0.6 | 0.6.1.1 | 2 | Surface, below surface |
| Dewatering | 0.4 | 0.4.1.1 | 2 | Sump pumping, wellpoints |
| Ground improvement | 0.4 | 0.4.2.1 | 2 | Vibro compaction, grouting |

### Group 5 (Services) - 61 Items Fixed

#### 5.3-5.4 Range → 5.4 (Water installations) - 20 items
- Hot water systems (8)
- Water pipes (4)
- Rainwater tanks (3)
- Water meters, valves, pumps (5)

#### 5.5-5.7 Range → 5.6 (Space heating/cooling) - 32 items
- Split system AC (5)
- Ducted AC (4)
- Ductwork and grilles (5)
- VRF, chillers, cooling towers (3)
- AHU, FCU (4)
- BMS controls (2)
- Heating systems (7)
- Fireplaces (3)

#### 5.5-5.7 Range → 5.7 (Ventilation) - 9 items
- Exhaust fans (5)
- HRV/ERV systems (1)
- Car park ventilation (1)
- Smoke exhaust (1)
- Stair pressurisation (1)

## Verification

All 78 items now have:
- Complete NRM L2, L3, L4 codes
- NRM2 primary work section mappings
- `mapping_confidence`: "Manual"

## Files Modified

1. `au/seed-data/composite_rates/group_0_facilitating.json` - 17 items updated
2. `au/seed-data/composite_rates/group_5_services.json` - 61 items updated
3. `workspace/au/metadata/validations/nrm-mapping-qa.md` - Fix summary appended

## Final Statistics

- **Total Rates Processed**: 777
- **Successfully Mapped**: 777 (100%)
- **Manual Mappings**: 78 (10.0%)
- **No Match**: 0 (0.0%)
