# contechdata-rates

Single entry point for the rate library data and schema assets.

Structure:
- NRM/ contains the canonical source handoff files (Excel and docs).
- workspace/au/ is the AU ingestion and transformation workspace.
- au/ is the curated AU seed library output.
- templates/ holds construction type templates and the master template matrix (sector splits under construction-types/).
- heuristics-source/ holds Supabase export CSVs and QA notes for productivity/coverage/quantity heuristics.

For new regions, add:
- workspace/<region>/ for staging and transforms
- <region>/ for curated seed data
