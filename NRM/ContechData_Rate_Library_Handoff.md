# TASK: Create ContechData Rate Library Infrastructure

## CONTEXT

I'm building ContechData - an AI-powered construction estimating platform. The AI generates detailed estimates from simple prompts (e.g. "3 bed house") using composite rates that:
- Roll UP to NRM1 cost plan summaries
- Drill DOWN to NRM2 measurement detail

---

## COMPLETED WORK

All files located in `/mnt/user-data/outputs/`:

| File | Description |
|------|-------------|
| `NRM1_Schedule_Fixed.xlsx` | Clean NRM1 cost elements |
| `NRM2_Schedule_Fixed.xlsx` | Clean NRM2 measurement rules |
| `NRM1_NRM2_Full_Linkage.xlsx` | Item-level mapping (465 NRM2 items → NRM1 codes) |
| `NRM1_to_NRM2_Mapping.xlsx` | Element-level mapping |
| `Composite_Rate_Template.xlsx` | 5 example rates with full build-ups |

### Composite Rate Template Contains:
- **Rate Summary** - All rates with NRM1/NRM2 codes, totals
- **Labour Build-up** - Gang, output rate (e.g. 1.2 m²/hr), hrs/unit, cost/unit
- **Materials Build-up** - Qty per unit, unit rates, wastage %
- **Plant Build-up** - Equipment allowances
- **Ref - Labour Resources** - Trade rates with oncosts
- **Ref - Gangs** - 1+1, 1+0.5, etc. with combined rates
- **Ref - Condition Factors** - Height, access, weather multipliers

---

## ITEMS NOT YET IMPLEMENTED (MUST BE INCLUDED IN SCHEMA)

### 1. Pricing Adjustments

| Item | Description | Implementation |
|------|-------------|----------------|
| **Indexation/Escalation** | Adjust rates from base date to current/future date | Link to `escalation_indices` table (e.g. Cordell, ABS CPI, BCI) |
| **Regional Factors** | Sydney ≠ Regional NSW ≠ Melbourne | `regional_factors` table with multipliers by postcode/region |
| **Spec Tiers** | Same element at Budget/Standard/Premium | `spec_level` field on composite rates, or separate rates |
| **Minimum Charges** | Small qty often has minimums (e.g. min 1 day plant) | `minimum_charge` and `minimum_qty` fields |
| **GST Handling** | Rates stored ex-GST, applied at summary | `gst_applicable` boolean, calculate at output |

### 2. Rate Types & Sources

| Item | Description | Implementation |
|------|-------------|----------------|
| **Subcontractor Rates** | All-in subbies rate vs labour+materials build-up | `rate_type` enum: 'buildup', 'subcontractor', 'supply_only', 'supply_fix' |
| **Data Sources** | Track origin: Rawlinsons, Cordell, subbie quote, internal | `source` and `source_reference` fields |
| **Quote Management** | Link rates to actual supplier/subbie quotes | `quotes` table with expiry dates |
| **Confidence Level** | How reliable is this rate? | `confidence` enum: 'verified', 'estimated', 'budget_allowance' |

### 3. Preliminaries & Project Costs

| Item | Description | Implementation |
|------|-------------|----------------|
| **Preliminaries** | Site establishment, supervision, insurances, etc. | Separate `preliminaries` table - can be % or itemised |
| **Contractor OH&P** | Typically 10-20% | `ohp_percentage` field, may vary by project size |
| **Design Contingency** | Allowance for incomplete design | Applied at cost plan level |
| **Construction Contingency** | Risk allowance | Applied at cost plan level |
| **Professional Fees** | Architect, engineer, QS | Outside rates, but needs placeholder |

### 4. Versioning & Audit

| Item | Description | Implementation |
|------|-------------|----------------|
| **Rate Versioning** | Track changes over time | `rate_versions` table or temporal tables |
| **Audit Trail** | Who changed what, when | `created_by`, `updated_by`, `created_at`, `updated_at` |
| **Soft Delete** | Don't lose historical data | `deleted_at` timestamp |
| **Approval Workflow** | Draft → Pending → Approved rates | `status` enum |
| **Effective Dates** | Rate valid from/to | `effective_from`, `effective_to` |

### 5. Rate Metadata

| Item | Description | Implementation |
|------|-------------|----------------|
| **Exclusions** | What's NOT included in this rate | `exclusions` text array |
| **Assumptions** | What we've assumed | `assumptions` text array |
| **Specification Notes** | Detailed spec for this rate | `specification` text |
| **Alternative Specs** | Link to alternative rates (e.g. different insulation) | `alternative_rates` junction table |
| **Dependencies** | This rate requires another (e.g. wall needs foundation) | `rate_dependencies` table |

### 6. Units & Quantities

| Item | Description | Implementation |
|------|-------------|----------------|
| **Unit Conversions** | m² to m, nr to m², etc. | `unit_conversions` table |
| **Quantity Heuristics** | e.g. 0.4m² ext wall per m² GFA | Stored in building templates, not rates |
| **Rounding Rules** | How to round quantities | `rounding_rule` on unit types |

### 7. Project Context

| Item | Description | Implementation |
|------|-------------|----------------|
| **Building Typologies** | Residential, Commercial, Industrial | `building_types` reference table |
| **Project Association** | Rates used on which projects | `project_rates` junction for historical tracking |
| **Client Rate Libraries** | Custom rates per client/builder | `organisation_id` on rates for multi-tenancy |

### 8. Reporting & Output

| Item | Description | Implementation |
|------|-------------|----------------|
| **Cost Plan Format** | NRM1 elemental summary | Query structure for grouping |
| **BOQ Format** | NRM2 detailed breakdown | Query structure for line items |
| **Benchmarking** | Compare to historical projects | `project_costs` table for actuals |

### 9. AI/Search Considerations

| Item | Description | Implementation |
|------|-------------|----------------|
| **Embeddings** | Voyage AI embeddings for semantic search | `embedding` vector column on rates |
| **Tags/Categories** | For filtering and AI context | `rate_tags` junction table |
| **Search Descriptions** | Optimised text for AI matching | `search_text` computed column |

### 10. Future Considerations (Schema Placeholder Only)

| Item | Description |
|------|-------------|
| **Carbon/Sustainability** | Embodied carbon per unit |
| **Lead Times** | Procurement/delivery times |
| **BIM Integration** | Link to Revit/IFC elements |
| **Daywork Rates** | Separate from measured work |

---

## REQUIRED DELIVERABLES

### 1. Folder Structure

```
/contechdata-rates/
├── README.md
├── /docs/
│   ├── data-model.md           # ERD + table descriptions
│   ├── rate-structure.md       # How composite rates work
│   ├── nrm-mapping.md          # NRM1↔NRM2 relationship explained
│   ├── pricing-adjustments.md  # Escalation, regional, GST
│   └── ai-integration.md       # How AI queries rates
├── /reference-data/
│   ├── nrm1_elements.json
│   ├── nrm2_items.json
│   ├── nrm1_nrm2_mapping.json
│   ├── work_sections.json
│   ├── units.json
│   ├── regions.json
│   └── building_types.json
├── /seed-data/
│   ├── labour_resources.json
│   ├── gangs.json
│   ├── gang_compositions.json
│   ├── condition_factors.json
│   ├── materials.json
│   ├── plant.json
│   ├── composite_rates.json
│   ├── composite_rate_labour.json
│   ├── composite_rate_materials.json
│   ├── composite_rate_plant.json
│   ├── regional_factors.json
│   └── escalation_indices.json
├── /supabase/
│   ├── migrations/
│   │   ├── 001_reference_tables.sql
│   │   ├── 002_nrm_tables.sql
│   │   ├── 003_resource_tables.sql
│   │   ├── 004_rate_tables.sql
│   │   ├── 005_adjustment_tables.sql
│   │   └── 006_audit_functions.sql
│   ├── seed.sql
│   ├── rls_policies.sql
│   └── functions/
│       ├── calculate_rate.sql      # Apply adjustments
│       ├── escalate_rate.sql       # Date adjustment
│       └── search_rates.sql        # AI-friendly search
└── /types/
    ├── database.types.ts           # Generated Supabase types
    └── enums.ts                    # TypeScript enums matching DB
```

### 2. Database Schema (Supabase/PostgreSQL)

#### Reference Tables
- `units` - m², m, nr, item, t, etc.
- `regions` - Sydney Metro, Regional NSW, Melbourne, etc.
- `building_types` - Residential, Commercial, Industrial
- `spec_levels` - Budget, Standard, Premium
- `rate_types` - Buildup, Subcontractor, Supply Only, Supply & Fix
- `confidence_levels` - Verified, Estimated, Budget Allowance
- `rate_statuses` - Draft, Pending, Approved, Archived

#### NRM Tables
- `nrm1_groups` - Group elements (0-12)
- `nrm1_elements` - Elements (e.g. 2.5)
- `nrm1_subelements` - Sub-elements (e.g. 2.5.1)
- `nrm2_work_sections` - Work sections (1-41)
- `nrm2_items` - Measurement items
- `nrm1_nrm2_mapping` - Linkage table (many-to-many)

#### Resource Tables
- `labour_resources` - Trade rates by region/date
- `gangs` - Gang definitions (1+1, 1+0.5, etc.)
- `gang_compositions` - Junction: which resources in which gang
- `materials` - Material rates by supplier/region/date
- `plant` - Plant/equipment rates
- `condition_factors` - Height, access, weather multipliers

#### Rate Tables
- `composite_rates` - Header with NRM1 code, unit, totals, metadata
- `composite_rate_labour` - Labour lines with productivity
- `composite_rate_materials` - Material lines with quantities
- `composite_rate_plant` - Plant lines
- `composite_rate_factors` - Which condition factors applied
- `rate_versions` - Version history
- `rate_tags` - Junction for categorisation
- `rate_alternatives` - Links to alternative specs
- `rate_dependencies` - Prerequisites

#### Adjustment Tables
- `regional_factors` - Multipliers by region
- `escalation_indices` - BCI, Cordell, etc. by date
- `gst_rates` - GST % by date (for future changes)

#### Key Requirements
- All monetary fields: `DECIMAL(12,2)`
- All rates have: `base_date`, `region_id`, `effective_from`, `effective_to`
- Audit fields: `created_at`, `updated_at`, `created_by`, `updated_by`, `deleted_at`
- Enable RLS for multi-tenancy: `organisation_id` on relevant tables
- Indexes on: NRM codes, region, date ranges, status
- Computed columns for search optimisation

### 3. JSON Files

Convert all Excel data to properly structured JSON:
- Use UUID for all IDs (for Supabase compatibility)
- Include foreign key references
- Maintain data integrity
- Ready for `supabase db seed`

### 4. Documentation

Each doc should include:
- **data-model.md**: Mermaid ERD, table descriptions, relationships
- **rate-structure.md**: How build-ups work, calculation examples
- **nrm-mapping.md**: NRM1↔NRM2 explained with examples
- **pricing-adjustments.md**: Escalation formula, regional factors, worked examples
- **ai-integration.md**: How AI should query, example prompts → SQL

---

## TECHNICAL NOTES

- **Platform**: Supabase (PostgreSQL)
- **AI**: Claude API + Voyage AI embeddings
- **Currency**: AUD (store as cents or DECIMAL)
- **Baseline**: Sydney Metro, Jan-2025
- **Multi-tenant**: Design for multiple organisations from start

---

## SOURCE FILES LOCATION

Excel files in `/mnt/user-data/outputs/`:
- `NRM1_Schedule_Fixed.xlsx`
- `NRM2_Schedule_Fixed.xlsx`
- `NRM1_NRM2_Full_Linkage.xlsx`
- `NRM1_to_NRM2_Mapping.xlsx`
- `Composite_Rate_Template.xlsx`

---

## SUCCESS CRITERIA

1. All JSON files validate and import cleanly to Supabase
2. Schema supports all rate calculations without application logic
3. Documentation clear enough for another developer to understand
4. 5 example rates fully populated with all relationships
5. SQL functions for rate calculation, escalation, search

---

## EXAMPLE COMPOSITE RATE STRUCTURE

```
┌─────────────────────────────────────────────────────────────────────┐
│ COMPOSITE RATE                                                       │
├─────────────────────────────────────────────────────────────────────┤
│ Rate ID:        EXT-WALL-001                                        │
│ Description:    Cavity wall - facing brick/block, insulated, plaster│
│ Unit:           m²                                                  │
│ Total Rate:     $388.27                                             │
│                                                                     │
│ NRM1 CODE:      2.5.1  (External enclosing walls above ground)      │
│                 ↑ ROLLS UP TO COST PLAN SUMMARY                     │
├─────────────────────────────────────────────────────────────────────┤
│ NRM2 BREAKDOWN                               ↓ DRILLS DOWN TO DETAIL│
├──────────┬─────────────────────────────┬──────┬─────────────────────┤
│ NRM2 Code│ Component                   │ Unit │ Build-up            │
├──────────┼─────────────────────────────┼──────┼─────────────────────┤
│ WS14.1   │ Facing brickwork 102.5mm    │ m²   │ 1+1 gang @ 1.2m²/hr │
│ WS14.1   │ Blockwork 100mm             │ m²   │ 1+0.5 gang @ 2.5m²/hr│
│ WS31.1   │ Cavity insulation 100mm     │ m²   │ 1+0 gang @ 8.0m²/hr │
│ WS28.1   │ Plasterboard + skim         │ m²   │ 1+0.5 gang @ 4.0m²/hr│
│ WS29.1   │ Decoration (mist + 2 coats) │ m²   │ 1+0 gang @ 12m²/hr  │
└──────────┴─────────────────────────────┴──────┴─────────────────────┘
```

---

## AI WORKFLOW

```
User Prompt: "3 bed house, difficult site access"
                    ↓
AI selects building template → quantities generated
                    ↓
Condition factor applied: Access = Difficult (×1.20)
                    ↓
Composite rates selected and adjusted
                    ↓
OUTPUT:
├── NRM1 Cost Plan Summary (rolled up)
└── NRM2 Detailed Breakdown (drill down available)
```
