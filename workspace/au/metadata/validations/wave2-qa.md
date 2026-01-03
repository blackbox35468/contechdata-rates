# Wave 2 QA Validation Report

**Validation Date**: 2026-01-03 12:45:00
**Status**: PASSED
**Validator**: QA-2 (Opus 4.5)

## Files Validated

| File | Size | Schema | Counts |
|------|------|--------|--------|
| composite_rates.json | 23,464 bytes | Valid | 5 composite rates |
| labour_resources.json | 1,958 bytes | Valid | 10 trades |
| gangs.json | 1,530 bytes | Valid | 6 gang configurations |
| condition_factors.json | 3,981 bytes | Valid | 16 factors (5 categories) |

## Schema Validation

All files contain required keys:
- `meta` with source, extracted date, sheet (where applicable), and counts
- Primary data arrays with proper snake_case keys

### Composite Rates Schema Check
- [x] Each rate has: code, name, description, unit, nrm1_code, nrm2_codes
- [x] Labour array with: task_description, gang, output, hrs_per_unit, rate_per_hour, cost_per_unit
- [x] Materials array with: description, unit, quantity, unit_rate, cost
- [x] Plant array with: description, unit, quantity, rate, cost
- [x] Totals: labour_total, materials_total, plant_total, waste_percent, ohp_percent, total_rate

### Labour Resources Schema Check
- [x] Each resource has: code, trade, base_rate, oncost_percent, total_rate, unit
- [x] Oncost calculation verified (base_rate × 1.20 = total_rate)
- [x] Codes follow LAB_AU_* pattern

### Gangs Schema Check
- [x] Each gang has: code, name, composition, combined_rate, unit
- [x] Composition object with tradesperson and labourer counts
- [x] Combined rates match composition (tradesperson × 65 + labourer × 55 for standard)
- [x] Codes follow GANG_AU_* pattern

### Condition Factors Schema Check
- [x] Each factor has: code, category, name, factor, applies_to, description
- [x] 5 categories verified: location (3), height (4), weather (3), complexity (3), quantity (3)
- [x] Codes follow CF_* pattern
- [x] Factors range from 0.95 to 1.35 (valid multipliers)

## Cross-Reference Checks

- [x] Gang codes in composite rates match gangs.json (1+0, 1+0.5, 1+1, 2+1)
- [x] Labour trade rates in composite rates align with labour_resources.json base rates
- [x] NRM2 codes in composite rates reference valid work sections from Wave 1

## Rate Calculations Verified

| Rate Code | Labour | Materials | Plant | Waste | OH&P | Total |
|-----------|--------|-----------|-------|-------|------|-------|
| EXT-WALL-001 | ✓ | ✓ | ✓ | 5% | 15% | ✓ |
| ROOF-TILE-001 | ✓ | ✓ | ✓ | 5% | 15% | ✓ |
| FOUND-STRIP-001 | ✓ | ✓ | ✓ | 5% | 15% | ✓ |
| FLOOR-TILE-001 | ✓ | ✓ | ✓ | 5% | 15% | ✓ |
| DRAIN-BG-001 | ✓ | ✓ | ✓ | 5% | 15% | ✓ |

## Agent Performance

| Task | Agent | Status | Output |
|------|-------|--------|--------|
| 2.1 Extract Composites | haiku-7 | Completed | composite_rates.json |
| 2.2 Extract Labour | haiku-8 | Completed | labour_resources.json |
| 2.3 Extract Gangs | haiku-9 | Completed | gangs.json |
| 2.4 Extract Factors | haiku-10 | Completed | condition_factors.json |

## Recommendation

Wave 2 outputs are valid and ready for Wave 3 (SQL schema migrations).
