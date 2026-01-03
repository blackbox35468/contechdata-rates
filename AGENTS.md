# Contechdata Rates Agents Guide

> **Last Updated**: 2026-01-03
> **Version**: 2.0

This file is the shared prompt for Codex and Claude Code. Keep it current as the structure or pipeline changes.

## Scope
- Single entry point: contechdata-rates/
- Contains NRM structure definitions and rate templates, not production rates.
- All changes are local-only unless the user explicitly requests a GitHub sync.

## Knowledge Base (authoritative sources)
- contechdata-rates/README.md (entry point and structure)
- contechdata-rates/AGENTS.md (this file; keep current)
- contechdata-rates/NRM/README.md + NRM Excel sources (canonical inputs)
- contechdata-rates/workspace/au/docs (mapping notes, extraction decisions)
- contechdata-rates/au/docs (published AU documentation)
- contechdata-rates/templates/README.md (template matrix + sector splits)
- contechdata-rates/heuristics-source/QA.md (heuristics QA status and gaps)

Update this knowledge base list and related docs whenever sources, structure, or decisions change.

## Governance (strict)
- No assumptions. If anything is unclear, stop and ask the user.
- No GitHub syncs unless the user explicitly asks.
- No modifications to canonical sources under NRM/.
- Update AGENTS.md when structure, pipeline, or tasks change.
- Update NRM/README.md whenever source files change.
- Keep contechdata-rates/ excluded from Vercel builds.

## Required Logs and Artifacts
- workspace/au/docs/decision-log.md: decisions, dates, rationale, owner.
- workspace/au/docs/question-log.md: open questions and answers.
- workspace/au/metadata/validations/: QA outputs (counts, checks, notes).
- au/docs/: published documentation aligned to actual outputs.

If a task creates or changes data outputs, it must update the relevant log and docs.

## Log Templates (use these formats)
Decision Log (workspace/au/docs/decision-log.md):
- YYYY-MM-DD | decision | context | rationale | owner | impacted files

Question Log (workspace/au/docs/question-log.md):
- YYYY-MM-DD | question | context | status (open/answered) | owner | answer

QA Log (workspace/au/metadata/validations/qa-log.md):
- YYYY-MM-DD | dataset | check | expected | actual | result | notes

## Naming and Data Conventions
- JSON filenames: snake_case, lower-case.
- Keys: snake_case, stable across outputs.
- IDs: UUIDs for primary identifiers unless a source code is the natural key.
- Monetary values: decimal strings or numbers, consistent per file.
- Units: explicit unit fields for quantities and rates.
- Dates: ISO-8601 (YYYY-MM-DD).

## File Format Standards
- Markdown files: ASCII, simple headings, no embedded binaries.
- JSON files: UTF-8, 2-space indent, newline at EOF, no comments.
- SQL files: one statement per section, include headings for each table.

## Change Control
- Any structural change must update:
  - contechdata-rates/README.md
  - contechdata-rates/AGENTS.md
  - contechdata-rates/NRM/README.md (if source list changed)
- Any new output file must be listed in the relevant section of this file.
- Record changes in workspace/au/docs/decision-log.md.
- When AGENTS.md changes, update the version and last-updated fields.

## QA Gates (must pass before publish)
1. Source integrity: canonical NRM/ files unchanged.
2. Row counts: document expected vs actual counts.
3. Schema validation: required fields present, types consistent.
4. Referential integrity: foreign keys resolve.
5. Output parity: staging -> curated -> final outputs match expectations.
6. Documentation sync: au/docs matches outputs.

## Task Intake Protocol (mandatory)
1. Confirm scope, inputs, outputs, and acceptance criteria with the user.
2. Identify source files and destination paths; list them in question-log if unclear.
3. Claim the task in Task Status (set to in-progress + agent id).
4. Perform work only after all ambiguities are resolved.

## Question Protocol (no assumptions)
- If any field mapping, schema choice, or destination is unclear, stop and ask.
- Record all open questions in workspace/au/docs/question-log.md.
- Do not proceed on a task with unresolved questions.

## Completion Protocol (definition of done)
- Outputs created in correct folder(s).
- QA gates satisfied and noted in workspace/au/metadata/validations/.
- Task Status updated to complete with agent id and notes.
- Decision log updated if any non-trivial mapping or schema choice was made.

## File Placement Rules
- NRM/ is canonical and never edited.
- workspace/au/ingest/raw/nrm/ is the editable mirror used by scripts.
- workspace/au/ingest/staging/ is normalized intermediate output.
- workspace/au/ingest/curated/ is cleaned data ready to publish.
- au/reference-data/ and au/seed-data/ are the published outputs.

## Structure (verified)
- contechdata-rates/
  - README.md
  - AGENTS.md
  - NRM/ (canonical source files)
  - workspace/ (ETL staging)
    - au/
      - ingest/raw/ (working copies)
      - ingest/staging/ (normalized)
      - ingest/curated/ (clean outputs)
      - scripts/ (ETL scripts)
      - sql/ (migrations/transforms)
  - au/ (Australia output)
    - reference-data/ (NRM JSON exports)
    - seed-data/ (rate templates)
    - docs/ (documentation)
    - supabase/migrations/ (schema)
    - types/ (TypeScript)
  - templates/ (construction type templates and matrices)
    - construction-types/

## Consolidated Paths
- contechdata-rates/NRM/ (canonical source)
- contechdata-rates/workspace/au/ (ETL staging; extract/transform scripts)
- contechdata-rates/au/ (curated output)
- contechdata-rates/templates/ (construction type templates; staging for matrices)

## Glossary
- canonical: original authenticated source files in NRM/ (never edited)
- workspace: ETL staging area for edits and scripts
- staging: normalized intermediate outputs before curation
- curated: final outputs published to au/reference-data and au/seed-data
- reference-data: structural NRM data, read-only after publish
- seed-data: example rate templates, not production rates

## Benefits of Consolidation
1. Single entry point: everything under contechdata-rates/
2. Clear purpose: rate library infrastructure only
3. Region-aware: au/ for Australia; add nz/, uk/ later
4. Source alongside output: NRM files travel with the library

## Recommendations
- After restructure completes:
  - Verify NRM/ folder is at top level with source Excel files.
  - Verify workspace/au/ has ETL scaffold.
  - Verify au/ has output structure (reference-data, seed-data, supabase, types).

- ETL scripts (workspace/au/scripts/extract/):
  | Script                        | Input                            | Output                                   |
  |-------------------------------|----------------------------------|------------------------------------------|
  | extract-nrm1.ts               | NRM/NRM1_Schedule_Fixed.xlsx     | au/reference-data/nrm1_elements.json     |
  | extract-nrm2.ts               | NRM/NRM2_Schedule_Fixed.xlsx     | au/reference-data/nrm2_items.json        |
  | extract-nrm-mapping.ts        | NRM/NRM1_NRM2_Full_Linkage.xlsx  | au/reference-data/nrm1_nrm2_mapping.json |
  | extract-composite-template.ts | NRM/Composite_Rate_Template.xlsx | au/seed-data/                            |

- What goes where:
  - au/reference-data/ (NRM structure - read-only):
    - nrm1_elements.json (NRM1 cost element hierarchy)
    - nrm2_items.json (NRM2 measurement items)
    - nrm1_nrm2_mapping.json (linkage between them)
    - units.json, regions.json, building_types.json
  - au/seed-data/ (rate templates - examples only):
    - composite_rate_template.json (5 example rates from Excel)
    - labour_resources.json (trade rate templates)
    - gangs.json (gang composition templates)
    - condition_factors.json (height/access multipliers)

- Documentation (au/docs/):
  - data-model.md (ERD showing table relationships)
  - rate-structure.md (how composite rates work)
  - nrm-mapping.md (NRM1/NRM2 relationship)

- Files to process:
  | Source (NRM/)                          | Content                | Destination (au/)                     |
  |----------------------------------------|------------------------|---------------------------------------|
  | NRM1_Schedule_Fixed.xlsx               | NRM1 element hierarchy | reference-data/nrm1_elements.json     |
  | NRM2_Schedule_Fixed.xlsx               | NRM2 measurement rules | reference-data/nrm2_items.json        |
  | NRM1_NRM2_Full_Linkage.xlsx            | 465 item mappings      | reference-data/nrm1_nrm2_mapping.json |
  | Composite_Rate_Template.xlsx           | 5 rate templates       | seed-data/ (multiple files)           |
  | Composite_Rate_Descriptions.xlsx       | rate descriptions      | seed-data/ (link to templates)        |

- Structure clarification (intentional design):
  - NRM/ = canonical sources (original authenticated files; never modified).
  - workspace/au/ingest/raw/nrm/ = working copies (may be annotated during ETL).

  Pipeline flow:
  NRM/                             (canonical sources)
       (copy)
  workspace/au/ingest/raw/nrm/     (working copies for ETL)
       [extract scripts]
  workspace/au/ingest/staging/     (intermediate normalized data)
       [transform scripts]
  au/reference-data/               (final JSON output)
  au/seed-data/                    (final JSON output)

- Summary (current expected state):
  | Path                                           | Purpose                         | Status  |
  |------------------------------------------------|---------------------------------|---------|
  | contechdata-rates/                             | Single entry point              | Ready   |
  | contechdata-rates/NRM/                         | Canonical authenticated sources | 9 files |
  | contechdata-rates/workspace/au/ingest/raw/nrm/ | Working copies for ETL          | Mirror  |
  | contechdata-rates/workspace/au/                | ETL staging workspace           | Ready   |
  | contechdata-rates/au/                          | Curated AU output               | Ready   |

- Detailed task list:
  - Phase 1: Extract NRM hierarchies
    - Task 1.1: Extract NRM1 elements
      - Input: workspace/au/ingest/raw/nrm/NRM1_Schedule_Fixed.xlsx
      - Script: workspace/au/scripts/extract/extract-nrm1.ts
      - Output: au/reference-data/nrm1_elements.json
      - Schema:
        {
          "groups": [{ "code": "0", "name": "Facilitating Works" }],
          "elements": [{ "code": "0.1", "group_code": "0", "name": "..." }],
          "subelements": [{ "code": "0.1.1", "element_code": "0.1", "name": "..." }]
        }
    - Task 1.2: Extract NRM2 items
      - Input: workspace/au/ingest/raw/nrm/NRM2_Schedule_Fixed.xlsx
      - Script: workspace/au/scripts/extract/extract-nrm2.ts
      - Output: au/reference-data/nrm2_items.json
      - Schema:
        {
          "work_sections": [{ "number": 1, "name": "..." }],
          "items": [{ "code": "WS1.1", "work_section": 1, "description": "..." }]
        }
    - Task 1.3: Extract NRM1/NRM2 mapping
      - Input: workspace/au/ingest/raw/nrm/NRM1_NRM2_Full_Linkage.xlsx
      - Script: workspace/au/scripts/extract/extract-nrm-mapping.ts
      - Output: au/reference-data/nrm1_nrm2_mapping.json
      - Expected: 465 item-level mappings

  - Phase 2: Extract rate templates
    - Task 2.1: Extract composite rate template
      - Input: workspace/au/ingest/raw/nrm/Composite_Rate_Template.xlsx
      - Script: workspace/au/scripts/extract/extract-composite-template.ts
      - Outputs:
        - au/seed-data/composite_rates.json (5 example rates)
        - au/seed-data/composite_rate_labour.json (labour build-up lines)
        - au/seed-data/composite_rate_materials.json (material lines)
        - au/seed-data/composite_rate_plant.json (plant lines)
    - Task 2.2: Extract labour resources
      - Input: Composite_Rate_Template.xlsx ("Ref - Labour Resources" sheet)
      - Output: au/seed-data/labour_resources.json
      - Contains: trade rates with oncosts
    - Task 2.3: Extract gangs
      - Input: Composite_Rate_Template.xlsx ("Ref - Gangs" sheet)
      - Output: au/seed-data/gangs.json
      - Contains: gang compositions with combined rates
    - Task 2.4: Extract condition factors
      - Input: Composite_Rate_Template.xlsx ("Ref - Condition Factors" sheet)
      - Output: au/seed-data/condition_factors.json
      - Contains: height, access, weather multipliers

  - Phase 3: Generate reference data
    - Task 3.1: Create units reference
      - Output: au/reference-data/units.json
      - Contains: m2, m, nr, item, t, hr, day, etc.
    - Task 3.2: Create regions reference
      - Output: au/reference-data/regions.json
      - Contains: Sydney Metro, Regional NSW, Melbourne, Brisbane, etc.
    - Task 3.3: Create building types reference
      - Output: au/reference-data/building_types.json
      - Contains: Residential, Commercial, Industrial, etc.

  - Phase 4: SQL schema migrations
    - Task 4.1: Reference tables migration
      - Output: au/supabase/migrations/001_reference_tables.sql
      - Creates: units, regions, building_types, spec_levels, rate_types, confidence_levels, rate_statuses
    - Task 4.2: NRM tables migration
      - Output: au/supabase/migrations/002_nrm_tables.sql
      - Creates: nrm1_groups, nrm1_elements, nrm1_subelements, nrm2_work_sections, nrm2_items, nrm1_nrm2_mapping
    - Task 4.3: Resource tables migration
      - Output: au/supabase/migrations/003_resource_tables.sql
      - Creates: labour_resources, gangs, gang_compositions, materials, plant, condition_factors
    - Task 4.4: Rate tables migration
      - Output: au/supabase/migrations/004_rate_tables.sql
      - Creates: composite_rates, composite_rate_labour, composite_rate_materials, composite_rate_plant, composite_rate_factors
    - Task 4.5: Adjustment tables migration
      - Output: au/supabase/migrations/005_adjustment_tables.sql
      - Creates: regional_factors, escalation_indices, gst_rates

  - Phase 5: Documentation
    - Task 5.1: Data model ERD
      - Output: au/docs/data-model.md
      - Contains: Mermaid ERD, table descriptions, relationships
    - Task 5.2: Rate structure guide
      - Output: au/docs/rate-structure.md
      - Contains: how composite rates work, calculation examples
    - Task 5.3: NRM mapping guide
      - Output: au/docs/nrm-mapping.md
      - Contains: NRM1/NRM2 relationship explained with examples

  - Phase 6: TypeScript types
    - Task 6.1: Generate database types
      - Output: au/types/database.types.ts
      - Method: generate from Supabase schema after migrations applied
    - Task 6.2: Create enums
      - Output: au/types/enums.ts
      - Contains: TypeScript enums matching DB enums

## Pipeline Flow
- NRM/ is canonical source.
- Copy sources to workspace/au/ingest/raw/nrm for staging.
- Normalize to workspace/au/ingest/staging, then curate into workspace/au/ingest/curated.
- Publish curated outputs to au/reference-data and au/seed-data.
- Keep docs and supabase migrations aligned with the curated outputs.

## QA & Validation
- Verify canonical vs working copies: NRM/ stays untouched; workspace/au/ingest/raw/nrm is the editable mirror.
- Track expected counts (example: 465 mappings from NRM1_NRM2_Full_Linkage.xlsx).
- Validate JSON schemas: required fields, ID uniqueness, and foreign keys.
- Check referential integrity across nrm1/nrm2/mapping and composite rate lines.
- Record QA outputs in workspace/au/metadata/validations with dates and notes.

## MCP & Tools
- Filesystem: use local shell for file ops and checks.
- GitHub MCP: sync only when the user explicitly asks.
- Supabase MCP: use for schema/migration work when requested.
- Vercel MCP: only if deployment/build config is requested.

## Operating Rules
- Do not assume; ask questions when requirements or mappings are unclear.
- Do not push to GitHub unless the user explicitly asks.
- Keep contechdata-rates/ excluded from Vercel builds.
- Use PowerShell for commands; prefer rg for search.
- Keep files ASCII unless the file already uses non-ASCII and it is required.
- Do not modify canonical NRM sources; work from copies in workspace.
- Update NRM/README.md when source files change.
- For new regions: add workspace/<region>/ and <region>/, then update README.md and this file.

## Current Plan (Codex + Claude)
1. Inventory AU sources: list sheets/columns + join keys under workspace/au/docs.
2. Define canonical JSON targets for au/reference-data and au/seed-data (fields, IDs, FKs).
3. Draft a transformation spec mapping each Excel sheet to JSON outputs.
4. Produce staging and curated outputs in workspace/au/ingest/staging and ingest/curated.
5. Build composite rate seed data from Composite_Rate_Template.xlsx and Composite_Rate_Descriptions.xlsx.
6. Write AU docs in au/docs aligned to the data and mappings.

## Task Status

**Tracking Location**: `contechdata-rates/AGENTS.md` (this file, Task Status section)

| Wave | Task | Type | Status | Agent | Output |
|------|------|------|--------|-------|--------|
| 1 | 1.1 Extract NRM1 elements | extraction | complete | haiku-1 | `au/reference-data/nrm1_elements.json` (14 groups, 50 elements, 163 subelements) |
| 1 | 1.2 Extract NRM2 items | extraction | complete | haiku-2 | `au/reference-data/nrm2_items.json` (40 work sections, 352 items) |
| 1 | 1.3 Extract NRM mapping | extraction | complete | haiku-3 | `au/reference-data/nrm1_nrm2_mapping.json` (80 NRM1 codes) |
| 1 | 3.1 Create units reference | reference | complete | haiku-4 | `au/reference-data/units.json` (38 units) |
| 1 | 3.2 Create regions reference | reference | complete | haiku-5 | `au/reference-data/regions.json` (16 regions) |
| 1 | 3.3 Create building types | reference | complete | haiku-6 | `au/reference-data/building_types.json` (16 types) |
| 1 | **QA-1 Validate Wave 1** | **qa** | complete | opus-qa | `workspace/au/metadata/validations/wave1-qa.md` (PASSED) |
| 2 | 2.1 Extract composite template | composite | complete | haiku-7 | `au/seed-data/composite_rates.json` (5 rates) |
| 2 | 2.2 Extract labour resources | composite | complete | haiku-8 | `au/seed-data/labour_resources.json` (10 trades) |
| 2 | 2.3 Extract gangs | composite | complete | haiku-9 | `au/seed-data/gangs.json` (6 gangs) |
| 2 | 2.4 Extract condition factors | composite | complete | haiku-10 | `au/seed-data/condition_factors.json` (16 factors) |
| 2 | **QA-2 Validate Wave 2** | **qa** | complete | opus-qa | `workspace/au/metadata/validations/wave2-qa.md` (PASSED) |
| 3 | 4.1 Reference tables migration | migration | complete | haiku-11 | `au/supabase/migrations/001_reference_tables.sql` (7 tables, 81 rows) |
| 3 | 4.2 NRM tables migration | migration | complete | haiku-12 | `au/supabase/migrations/002_nrm_tables.sql` (6 tables, 184 rows) |
| 3 | 4.3 Resource tables migration | migration | complete | haiku-13 | `au/supabase/migrations/003_resource_tables.sql` (6 tables, 44 rows) |
| 3 | 4.4 Rate tables migration | migration | complete | haiku-14 | `au/supabase/migrations/004_rate_tables.sql` (5 tables, 80 rows) |
| 3 | 4.5 Adjustment tables migration | migration | complete | haiku-15 | `au/supabase/migrations/005_adjustment_tables.sql` (3 tables, 33 rows) |
| 3 | **QA-3 Validate Wave 3** | **qa** | complete | opus-qa | `workspace/au/metadata/validations/wave3-qa.md` (PASSED) |
| 4 | 5.1 Data model ERD | docs | complete | haiku-16 | `au/docs/data-model.md` (1002 lines, full ERD + table descriptions) |
| 4 | 5.2 Rate structure guide | docs | complete | haiku-17 | `au/docs/rate-structure.md` (500 lines, worked examples) |
| 4 | 5.3 NRM mapping guide | docs | complete | haiku-18 | `au/docs/nrm-mapping.md` (382 lines, NRM1/NRM2 mapping) |
| 4 | 6.1 Database types | types | complete | haiku-19 | `au/types/database.types.ts` (1341 lines, 27 table interfaces) |
| 4 | 6.2 Enums | types | complete | haiku-20 | `au/types/enums.ts` (321 lines, 9 enums + type guards) |
| 4 | **QA-4 Final validation** | **qa** | complete | opus-qa | `workspace/au/metadata/validations/final-qa.md` (PASSED) |
| 5 | 7.0 Fix Excel encoding | seed-rates | complete | opus-main | Fixed HTML entities (m² units) in `NRM/Composite_Rate_Descriptions.xlsx` |
| 5 | 7.1 Extract rate descriptions | seed-rates | complete | opus-main | `workspace/au/ingest/staging/rate_descriptions.json` (777 rates) |
| 5 | 7.2 Generate composite rates | seed-rates | complete | opus-main | `au/seed-data/composite_rates/` (7 group files, 777 rates) |
| 5 | 7.3 Generate index | seed-rates | complete | opus-main | `au/seed-data/composite_rates_index.json` (777 rate codes) |
| 5 | **QA-5 Validate Seed Rates** | **qa** | complete | opus-main | `workspace/au/metadata/validations/seed-rates-qa.md` (PASSED) |

**Status values**: `pending` | `in-progress` | `complete` | `blocked`

**Agent types**: `extraction` | `composite` | `reference` | `migration` | `docs` | `types` | `qa`

## Agent Coordination

### Claiming Tasks
1. Set status to `in-progress`
2. Add your agent identifier (e.g., `claude-1`, `codex-1`)
3. Complete the task
4. Set status to `complete` and add notes if needed

### Wave Execution (Parallel)

**Wave 1** (all parallel):
- Tasks 1.1, 1.2, 1.3 (extraction) - different source files
- Tasks 3.1, 3.2, 3.3 (reference) - independent data
- Then QA-1 validates all outputs

**Wave 2** (after Wave 1 + QA-1 complete):
- Tasks 2.1-2.4 (composite) - use `/create-composite` skill
- Cross-reference with 520+ golden composites in `international/au/golden-composites/`
- Then QA-2 validates rate integrity

**Wave 3** (after Wave 2 + QA-2 complete):
- Tasks 4.1-4.5 (migration) - can run in parallel
- Then QA-3 validates schema

**Wave 4** (after Wave 3 + QA-3 complete):
- Tasks 5.1-5.3 (docs) + 6.1-6.2 (types) - parallel
- Then QA-4 final sign-off

### Composite Rate Agent
For tasks 2.1-2.4, use the `/create-composite` skill:
```
/create-composite cavity wall facing brick --market AU --nrm 2.5
```
Reference: `.claude/docs/composite-rates.md`
Existing composites: `international/au/golden-composites/` (520+)

### QA Agent Responsibilities
After each wave, QA agent must:
1. Verify row counts match expectations
2. Validate JSON schemas
3. Check referential integrity
4. Log results to `workspace/au/metadata/validations/`
5. Block next wave if critical issues found

### Conflict Resolution
- If two agents claim the same task, first update wins
- Check status before starting work
- If blocked, add note and move to next task
