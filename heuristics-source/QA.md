# Heuristics QA Status (2026-01-03)

Location: `heuristics-source/supabase-exports/` (clean CSV exports from Supabase)

## Missing-field summary
- `labour_productivity_constants-20260103-v2.csv` (1167 rows): 87 missing `hours_per_unit`.
- `plant_productivity_constants-20260103-v2.csv` (459 rows): all missing `hours_per_unit`, `plant_category`, `activity_type` (output_unit/market present).
- `material_coverage_reference-20260103-v2.csv` (317 rows): all missing `coverage`, `market` (coverage_unit present).
- `quantity_heuristics-20260103-v3.csv` (116 rows): all missing `driver`, `quantity_formula`, `market` (unit present).
- `productivity_metrics-20260103.csv` (19 rows): 10 missing `location`; all missing `output_unit`.

## QA plan (draft)
1) Normalize required fields per table and fill gaps (values must align with NRM measurement standards and composite units).
   - Labour: backfill `hours_per_unit` for 87 rows.
   - Plant: add `plant_category` + `activity_type` taxonomy; derive `hours_per_unit` from output_rate or trusted refs.
   - Material: add `coverage` values (per `coverage_unit`) and `market` tags.
   - Quantity: add `driver`, `quantity_formula`, `market`; tie to NRM level/unit.
   - Productivity metrics: add `location` and `output_unit`.
2) Define mapping keys to templates: `sector`, `building_type`, `nrm_section/level`, `unit/output_unit`, `market`.
3) Produce a crosswalk CSV (templates ↔ heuristics) to spot gaps before edits.
4) Log QA checks and row counts to `workspace/au/metadata/validations/` once fields are filled.

## Notes
- CSVs are UTF-8, comma-delimited, with headers; no escaped JSON remains.
- Do not edit canonical sources under `NRM/`; heuristics updates should stay in `heuristics-source/` until approved.
