# NRM Waste Factor Update - Summary Report

**Date**: 2026-01-03
**Agent**: Agent 4 (Heuristics Remediation Workflow)
**Task**: Update waste factors in composite rates to comply with NRM standards

---

## Executive Summary

Updated waste factors across **777 composite rates** in 7 NRM group files to align with Australian NRM standards. This addresses a systematic underestimation of material quantities by 0.8% on average.

### Key Metrics

- **Total composites processed**: 777
- **Composites updated**: 140 (18.0%)
- **Composites unchanged**: 637 (82.0%)
- **Average waste factor increase**: 1.050 → 1.058 (+0.8%)
- **Material quantity correction**: 1.0078x

---

## Material Breakdown

| Material Type | Count | NRM Waste Factor | Previous Factor | Gap Closed |
|---------------|-------|------------------|-----------------|------------|
| Timber        | 70    | 1.10             | 1.05            | +5%        |
| Plasterboard  | 14    | 1.10             | 1.05            | +5%        |
| Tiles         | 35    | 1.10             | 1.05            | +5%        |
| Brickwork     | 21    | 1.07             | 1.05            | +2%        |
| Concrete      | 62    | 1.05             | 1.05            | 0%         |
| Steel         | 71    | 1.05             | 1.05            | 0%         |
| Default       | 504   | 1.05             | 1.05            | 0%         |

---

## NRM Compliance Check

| Material     | NRM Standard | Actual Applied | Status |
|--------------|--------------|----------------|--------|
| Timber       | 1.10         | 1.10           | PASS   |
| Plasterboard | 1.10         | 1.10           | PASS   |
| Tiles        | 1.10         | 1.10           | PASS   |
| Brickwork    | 1.07         | 1.07           | PASS   |
| Concrete     | 1.05         | 1.05           | PASS   |

All identified materials now comply with NRM waste factor standards.

---

## Updates by NRM Group

### Group 0: Facilitating Works
- **Total composites**: 17
- **Updated**: 1
- **Key updates**: Masonry demolition (1.05 → 1.07)

### Group 1: Substructure
- **Total composites**: 34
- **Updated**: 3
- **Key updates**: Strip foundations with blockwork (1.05 → 1.07)

### Group 2: Superstructure
- **Total composites**: 200
- **Updated**: 61 (30.5%)
- **Key updates**:
  - Timber framing: 42 items (1.05 → 1.10)
  - Steel framing: 45 items (1.05 → 1.05, no change)
  - Roof tiles: 7 items (1.05 → 1.10)
  - Plasterboard: 4 items (1.05 → 1.10)

### Group 3: Finishes
- **Total composites**: 81
- **Updated**: 43 (53.1%)
- **Key updates**:
  - Wall/floor tiles: 21 items (1.05 → 1.10)
  - Plasterboard: 10 items (1.05 → 1.10)
  - Timber finishes: 11 items (1.05 → 1.10)

### Group 4: Fittings
- **Total composites**: 65
- **Updated**: 3
- **Key updates**: Minor tile and timber fittings

### Group 5: Services
- **Total composites**: 215
- **Updated**: 5
- **Key updates**: Service penetrations in tiles/masonry

### Group 8: External Works
- **Total composites**: 165
- **Updated**: 24
- **Key updates**:
  - Timber decking/fencing: 15 items (1.05 → 1.10)
  - Brickwork/paving: 7 items (1.05 → 1.07)

---

## Impact Analysis

### Quantity Impact
- **Previous underestimation**: ~0.8%
- **Correction factor**: 1.0078x
- **Affected composites**: 140 (primarily timber, tiles, plasterboard, brickwork)

### Cost Impact
The waste factor increase primarily affects material costs. For a typical composite:
- Labour cost: No change
- Plant cost: No change
- Material cost: Increased by waste factor delta (e.g., 1.10 vs 1.05 = +4.8% on materials)

Example: Timber frame composite
- **Before**: Labour $95 + Materials $25 × 1.05 = $95 + $26.25 = $121.25
- **After**: Labour $95 + Materials $25 × 1.10 = $95 + $27.50 = $122.50
- **Change**: +$1.25 per unit (+1.0%)

### Nett Total Recalculation
All composites with updated waste factors had their `nett_total` and `total_rate` recalculated:
- `nett_total` = labour_total + (materials_total × waste_factor) + plant_total
- `total_rate` = nett_total × (1 + ohp_percent / 100)

---

## Material Type Identification Methodology

Materials were identified using regex pattern matching on:
1. Composite name
2. Composite description
3. Material component descriptions
4. Material resource IDs

### Pattern Examples

**Timber**: timber, wood, lumber, framing, stud, joist, rafter, decking
**Plasterboard**: plasterboard, gypsum, drywall, sheet lining
**Tiles**: tile, ceramic, porcelain, mosaic, tiling
**Brickwork**: brick, masonry, blockwork, block, CBU, CMU
**Concrete**: concrete, RC, reinforced
**Steel**: steel, metal, iron, aluminium

---

## Validation

### File Integrity
- All 7 JSON files successfully updated
- JSON structure validated
- No composites corrupted

### Spot Checks

| Code | Name | Material | Old Waste | New Waste | Status |
|------|------|----------|-----------|-----------|--------|
| GRP2-TIMFRA-014 | Timber frame - wall, 90x45 studs | Timber | 1.05 | 1.10 | PASS |
| GRP3-WALFIN-002 | Wall finish - plasterboard, set, paint | Plasterboard | 1.05 | 1.10 | PASS |
| GRP3-WALFIN-005 | Wall finish - ceramic tiles 300x300 | Tiles | 1.05 | 1.10 | PASS |
| GRP1-STRFOU-002 | Strip foundation - block to DPC | Brickwork | 1.05 | 1.07 | PASS |

---

## Default Factor (504 composites)

504 composites remain at the default 1.05 factor. These include:
- Generic material allowances (no specific material type)
- Multi-material composites (mixed materials)
- Services/MEP items (minimal material waste)
- Plant-heavy items (excavation, compaction)

**Recommendation**: Review these composites manually to determine if they contain specific materials requiring higher waste factors. The conservative 1.05 default is appropriate for:
- Site works
- Preliminaries
- Services (electrical, plumbing)
- Items with minimal material content

---

## Resource Link Exclusions

This update only modified **inline waste factors** in the composite JSON files. Composites that reference materials via `resource_id` (e.g., `MAT_AU_*`) were not updated, as their waste factors are managed in the resource library.

**Note**: A separate update process is required for resource library materials.

---

## Files Modified

1. `group_0_facilitating.json` (1 update)
2. `group_1_substructure.json` (3 updates)
3. `group_2_superstructure.json` (61 updates)
4. `group_3_finishes.json` (43 updates)
5. `group_4_fittings.json` (3 updates)
6. `group_5_services.json` (5 updates)
7. `group_8_external.json` (24 updates)

---

## Next Steps

### For Database Import
1. Review the 504 "default" composites for potential material-specific waste factors
2. Validate waste factors against actual project data
3. Consider regional variations (waste factors may differ by state/city)

### For Resource Library
1. Update material resources (`MAT_AU_*` entries) with NRM-compliant waste factors
2. Ensure consistency between composite inline materials and resource library
3. Add waste factor metadata to resource entries

### For Documentation
1. Document waste factor standards in project wiki
2. Create material waste factor lookup table for estimators
3. Add waste factor validation to composite rate creation workflow

---

## Appendix: Detailed Update Log

See `waste_factor_update_report.json` for complete list of 140 updated composites including:
- Composite code
- Name
- Material type identified
- Old waste factor
- New waste factor
- Evidence text used for identification
