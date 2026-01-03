# ContechData - Data Model Documentation

## Overview

This document provides a comprehensive Entity-Relationship Diagram (ERD) and schema documentation for the ContechData Australian construction rates database. The database comprises 27 tables organized across 5 categories: Reference, NRM, Resource, Rate, and Adjustment tables.

**Project Details:**
- Region: Australia (Sydney Metro baseline)
- Base Date: January 2025
- Currency: AUD (prices stored in cents as integers)
- Scope: 14 Australian states/territories + 16 regions, 989+ composite rates

---

## Database ERD

```mermaid
erDiagram
    %% ============================================================================
    %% REFERENCE TABLES (9 tables)
    %% ============================================================================

    UNITS ||--o{ LABOUR_RESOURCES : uses
    UNITS ||--o{ MATERIALS : uses
    UNITS ||--o{ PLANT : uses
    UNITS ||--o{ COMPOSITE_RATES : measured_in
    UNITS ||--o{ NRM2_ITEMS : measured_in

    REGIONS ||--o{ REGIONAL_FACTORS : applies_to
    REGIONS ||--o{ GST_RATES : applies_to
    REGIONS ||--o{ COMPOSITE_RATES : priced_for

    BUILDING_TYPES ||--o{ COMPOSITE_RATES : classifies

    SPEC_LEVELS ||--o{ COMPOSITE_RATES : grades

    RATE_TYPES ||--o{ COMPOSITE_RATES : categorizes

    CONFIDENCE_LEVELS ||--o{ COMPOSITE_RATES : rates

    RATE_STATUSES ||--o{ COMPOSITE_RATES : has

    %% ============================================================================
    %% NRM TABLES (7 tables)
    %% ============================================================================

    NRM1_GROUPS ||--o{ NRM1_ELEMENTS : contains
    NRM1_ELEMENTS ||--o{ NRM1_SUBELEMENTS : contains
    NRM1_ELEMENTS ||--o{ NRM1_NRM2_MAPPING : references
    NRM1_SUBELEMENTS ||--o{ NRM1_NRM2_MAPPING : references

    NRM2_WORK_SECTIONS ||--o{ NRM2_ITEMS : contains
    NRM2_ITEMS ||--o{ NRM1_NRM2_MAPPING : references

    %% ============================================================================
    %% RESOURCE TABLES (6 tables)
    %% ============================================================================

    LABOUR_RESOURCES ||--o{ GANG_COMPOSITIONS : uses
    GANGS ||--o{ GANG_COMPOSITIONS : defines
    GANGS ||--o{ COMPOSITE_RATE_LABOUR : templates

    CONDITION_FACTORS ||--o{ COMPOSITE_RATE_FACTORS : applies_to

    MATERIALS ||--o{ COMPOSITE_RATE_MATERIALS : itemizes

    PLANT ||--o{ COMPOSITE_RATE_PLANT : itemizes

    %% ============================================================================
    %% RATE TABLES (5 tables)
    %% ============================================================================

    COMPOSITE_RATES ||--o{ COMPOSITE_RATE_LABOUR : breaks_down
    COMPOSITE_RATES ||--o{ COMPOSITE_RATE_MATERIALS : breaks_down
    COMPOSITE_RATES ||--o{ COMPOSITE_RATE_PLANT : breaks_down
    COMPOSITE_RATES ||--o{ COMPOSITE_RATE_FACTORS : applies

    %% ============================================================================
    %% ADJUSTMENT TABLES (3 tables)
    %% ============================================================================

    ESCALATION_INDICES : contains escalation tracking

    %% ============================================================================
    %% TABLE DEFINITIONS
    %% ============================================================================

    UNITS {
        uuid id PK
        varchar code UK
        varchar name
        varchar symbol
        varchar category
        text description
        timestamp created_at
        timestamp updated_at
    }

    REGIONS {
        uuid id PK
        varchar code UK
        varchar name
        varchar state
        decimal factor
        boolean is_baseline
        timestamp created_at
        timestamp updated_at
    }

    BUILDING_TYPES {
        uuid id PK
        varchar code UK
        varchar name
        varchar category
        varchar complexity
        timestamp created_at
        timestamp updated_at
    }

    SPEC_LEVELS {
        uuid id PK
        varchar code UK
        varchar name
        text description
        integer rank UK
        decimal cost_multiplier
        timestamp created_at
        timestamp updated_at
    }

    RATE_TYPES {
        uuid id PK
        varchar code UK
        varchar name
        text description
        boolean is_composite
        timestamp created_at
        timestamp updated_at
    }

    CONFIDENCE_LEVELS {
        uuid id PK
        varchar code UK
        varchar name
        text description
        integer rank UK
        varchar percentage_range
        timestamp created_at
        timestamp updated_at
    }

    RATE_STATUSES {
        uuid id PK
        varchar code UK
        varchar name
        text description
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    NRM1_GROUPS {
        text code PK
        text name
        timestamp created_at
        timestamp updated_at
    }

    NRM1_ELEMENTS {
        text code PK
        text group_code FK
        text name
        timestamp created_at
        timestamp updated_at
    }

    NRM1_SUBELEMENTS {
        text code PK
        text element_code FK
        text name
        timestamp created_at
        timestamp updated_at
    }

    NRM2_WORK_SECTIONS {
        integer number PK
        text name
        timestamp created_at
        timestamp updated_at
    }

    NRM2_ITEMS {
        text code PK
        integer work_section FK
        text description
        text unit
        timestamp created_at
        timestamp updated_at
    }

    NRM1_NRM2_MAPPING {
        text nrm1_code PK_FK
        text nrm2_code PK_FK
        text description
        timestamp created_at
        timestamp updated_at
    }

    LABOUR_RESOURCES {
        text code PK
        text trade
        decimal base_rate
        decimal oncost_percent
        decimal total_rate
        text unit
        timestamp created_at
        timestamp updated_at
    }

    GANGS {
        text code PK
        text name
        decimal combined_rate
        text unit
        timestamp created_at
        timestamp updated_at
    }

    GANG_COMPOSITIONS {
        serial id PK
        text gang_code FK
        text role
        decimal count
        timestamp created_at
        timestamp updated_at
    }

    CONDITION_FACTORS {
        text code PK
        enum category
        text name
        decimal factor
        text applies_to
        text description
        timestamp created_at
        timestamp updated_at
    }

    MATERIALS {
        text code PK
        text description
        text unit
        decimal unit_rate
        decimal waste_factor
        timestamp created_at
        timestamp updated_at
    }

    PLANT {
        text code PK
        text description
        text unit
        decimal rate
        timestamp created_at
        timestamp updated_at
    }

    COMPOSITE_RATES {
        varchar code PK
        varchar name
        text description
        varchar unit
        varchar nrm1_code
        varchar nrm2_codes
        varchar spec_level
        varchar base_date
        varchar region
        numeric labour_total
        numeric materials_total
        numeric plant_total
        numeric waste_percent
        numeric ohp_percent
        numeric total_rate
        timestamp created_at
        timestamp updated_at
    }

    COMPOSITE_RATE_LABOUR {
        uuid id PK
        varchar composite_code FK
        varchar nrm2_code
        varchar task_description
        varchar gang
        numeric output
        varchar output_unit
        numeric hrs_per_unit
        numeric rate_per_hour
        numeric cost_per_unit
        varchar source
        timestamp created_at
        timestamp updated_at
    }

    COMPOSITE_RATE_MATERIALS {
        uuid id PK
        varchar composite_code FK
        varchar nrm2_code
        varchar description
        varchar unit
        numeric quantity
        numeric unit_rate
        numeric cost
        timestamp created_at
        timestamp updated_at
    }

    COMPOSITE_RATE_PLANT {
        uuid id PK
        varchar composite_code FK
        varchar nrm2_code
        varchar description
        varchar unit
        numeric quantity
        numeric rate
        numeric cost
        timestamp created_at
        timestamp updated_at
    }

    COMPOSITE_RATE_FACTORS {
        uuid id PK
        varchar composite_code FK
        varchar factor_code FK
        numeric applied_value
        timestamp created_at
        timestamp updated_at
    }

    REGIONAL_FACTORS {
        uuid id PK
        varchar region_code FK
        numeric factor
        date effective_from
        date effective_to
        varchar source
        text notes
        timestamp created_at
        timestamp updated_at
    }

    ESCALATION_INDICES {
        uuid id PK
        integer year
        integer quarter
        numeric index_value
        integer base_year
        varchar source
        text notes
        timestamp created_at
        timestamp updated_at
    }

    GST_RATES {
        uuid id PK
        varchar region_code FK
        numeric rate
        date effective_from
        date effective_to
        text notes
        timestamp created_at
        timestamp updated_at
    }
```

---

## Table Categories

### 1. REFERENCE TABLES (9 tables)

Reference tables define the fundamental classification systems and lookup values used throughout the database.

#### UNITS
- **Purpose**: Measurement units used in construction estimates (SI metric, imperial, and provisional)
- **Primary Key**: `id` (UUID)
- **Natural Key**: `code` (varchar, unique)
- **Key Columns**:
  - `code`: Unique identifier (m, m2, m3, hr, ls, nr, etc.)
  - `category`: Classification (length, area, volume, weight, time, count, provisional)
  - `symbol`: Display symbol (m², m³, hr, LS, etc.)
- **Cardinality**: 1:Many with Labour Resources, Materials, Plant, Composite Rates, NRM2 Items
- **Sample Data**: 33 units covering all construction measurement types

#### REGIONS
- **Purpose**: Australian regions with geographical pricing factors (16 regions across 8 states/territories)
- **Primary Key**: `id` (UUID)
- **Natural Key**: `code` (varchar, unique)
- **Key Columns**:
  - `code`: Region code (SYD_METRO, MEL_METRO, BNE_METRO, PER_METRO, ADL_METRO, HOB_METRO, etc.)
  - `state`: State code (NSW, VIC, QLD, WA, SA, TAS, ACT, NT)
  - `factor`: Price adjustment multiplier (1.00 = baseline, 0.90-1.30 range)
  - `is_baseline`: Boolean flag (Sydney Metro = 1.00, baseline)
- **Cardinality**: 1:Many with Regional Factors, GST Rates, Composite Rates
- **Regional Baseline**: Sydney Metro (SYD_METRO) = 1.00 factor baseline

#### BUILDING_TYPES
- **Purpose**: Construction project types with complexity ratings
- **Primary Key**: `id` (UUID)
- **Natural Key**: `code` (varchar, unique)
- **Key Columns**:
  - `code`: Type code (RES_HOUSE, COM_OFFICE_HIGH, IND_WAREHOUSE, HEALTH_HOSPITAL, etc.)
  - `category`: Classification (residential, commercial, industrial, institutional, health, civic)
  - `complexity`: Rating (low, standard, medium, high, very_high)
- **Cardinality**: 1:Many with Composite Rates
- **Sample Data**: 16 building types

#### SPEC_LEVELS
- **Purpose**: Specification levels for finishes and quality standards (basic → luxury)
- **Primary Key**: `id` (UUID)
- **Natural Key**: `code` (varchar, unique)
- **Key Columns**:
  - `code`: Level code (basic, standard, premium, luxury)
  - `rank`: Ordering (1=basic, 4=luxury, unique)
  - `cost_multiplier`: Cost factor relative to standard (0.85-1.70)
- **Cardinality**: 1:Many with Composite Rates
- **Sample Data**: 4 specification levels

#### RATE_TYPES
- **Purpose**: Classification of rate components (labour, material, plant, composite)
- **Primary Key**: `id` (UUID)
- **Natural Key**: `code` (varchar, unique)
- **Key Columns**:
  - `code`: Type code (labour, material, plant, composite)
  - `is_composite`: Boolean flag for composite rate flag
- **Cardinality**: 1:Many with Composite Rates
- **Sample Data**: 4 rate types

#### CONFIDENCE_LEVELS
- **Purpose**: Data confidence ratings for rates and estimate reliability
- **Primary Key**: `id` (UUID)
- **Natural Key**: `code` (varchar, unique)
- **Key Columns**:
  - `code`: Level code (low, medium, high)
  - `rank`: Ordering (1=low, 3=high)
  - `percentage_range`: Accuracy range (±5%, ±10%, ±15-20%)
- **Cardinality**: 1:Many with Composite Rates
- **Sample Data**: 3 confidence levels

#### RATE_STATUSES
- **Purpose**: Workflow status for rates (draft → approved → archived)
- **Primary Key**: `id` (UUID)
- **Natural Key**: `code` (varchar, unique)
- **Key Columns**:
  - `code`: Status code (draft, reviewed, approved, archived)
  - `is_active`: Boolean flag (false for archived rates)
- **Cardinality**: 1:Many with Composite Rates
- **Sample Data**: 4 statuses

---

### 2. NRM TABLES (7 tables)

NRM (New Rules of Measurement) tables implement the Australian construction classification standard across two versions.

#### NRM1_GROUPS
- **Purpose**: Top-level NRM1 classification (Facilitating works, Substructure, Superstructure, etc.)
- **Primary Key**: `code` (text, natural key)
- **Key Columns**:
  - `code`: Single/double-digit code (0, 1, 2, ..., 13)
  - `name`: Group name
- **Cardinality**: 1:Many with NRM1 Elements
- **Sample Data**: 14 NRM1 groups

#### NRM1_ELEMENTS
- **Purpose**: Second-level NRM1 classification (0.1, 0.2, 2.5, etc.)
- **Primary Key**: `code` (text, natural key)
- **Natural Key**: group_code + decimal + digit (e.g., "0.1", "2.3")
- **Key Columns**:
  - `code`: Hierarchical code (0.1, 0.2, 1.1, 2.1, etc.)
  - `group_code`: Foreign key to NRM1_GROUPS
  - `name`: Element description
- **Cardinality**: 1:Many with NRM1 Subelements; M:N mapping to NRM2 Items
- **Sample Data**: 48 NRM1 elements

#### NRM1_SUBELEMENTS
- **Purpose**: Third-level NRM1 classification (0.1.1, 0.2.3, etc.)
- **Primary Key**: `code` (text, natural key)
- **Natural Key**: element_code + decimal + digit (e.g., "0.1.1", "2.1.2")
- **Key Columns**:
  - `code`: Hierarchical code (0.1.1, 0.1.2, 1.1.1, etc.)
  - `element_code`: Foreign key to NRM1_ELEMENTS
  - `name`: Subelement description
- **Cardinality**: Many:1 with NRM1 Elements
- **Sample Data**: 20+ NRM1 subelements

#### NRM2_WORK_SECTIONS
- **Purpose**: First-level NRM2 classification (Off-site materials, Demolitions, Piling, etc.)
- **Primary Key**: `number` (integer, natural key)
- **Key Columns**:
  - `number`: Work section number (2-41, gaps indicate unused sections)
  - `name`: Section description
- **Cardinality**: 1:Many with NRM2 Items
- **Sample Data**: 40 NRM2 work sections

#### NRM2_ITEMS
- **Purpose**: Second-level NRM2 classification (WS2.1, WS3.2, WS28.1, etc.)
- **Primary Key**: `code` (text, natural key)
- **Natural Key**: work_section + dot + item number (e.g., "WS2.1", "WS28.8")
- **Key Columns**:
  - `code`: Item code (WS2.1, WS3.2, WS28.8, etc.)
  - `work_section`: Foreign key to NRM2_WORK_SECTIONS
  - `description`: Item description
  - `unit`: Measurement unit (m2, m, nr, item, m3, t, hr)
- **Cardinality**: Many:1 with NRM2 Work Sections; M:N mapping to NRM1 Elements
- **Sample Data**: 50+ NRM2 items

#### NRM1_NRM2_MAPPING
- **Purpose**: Many-to-many mapping between NRM1 elements and NRM2 items
- **Primary Key**: Composite (nrm1_code, nrm2_code)
- **Key Columns**:
  - `nrm1_code`: Foreign key to NRM1_ELEMENTS
  - `nrm2_code`: Foreign key to NRM2_ITEMS
  - `description`: Mapping relationship description
- **Cardinality**: Many:Many (links classification systems)
- **Sample Data**: 10+ sample mappings showing cross-reference

---

### 3. RESOURCE TABLES (6 tables)

Resource tables define the labor, materials, plant, and productivity factors used to build composite rates.

#### LABOUR_RESOURCES
- **Purpose**: Trade labour rates with base and fully-loaded costs (AUD/hr)
- **Primary Key**: `code` (text, natural key)
- **Natural Key**: code (e.g., LAB_AU_BRICK, LAB_AU_ELECT)
- **Key Columns**:
  - `code`: Labour code (LAB_AU_[TRADE_CODE])
  - `trade`: Trade name (Bricklayer, Electrician, Plumber, etc.)
  - `base_rate`: Hourly rate before oncosts (AUD)
  - `oncost_percent`: Percentage for oncosts (superannuation, workers comp, etc.)
  - `total_rate`: Final rate = base_rate + (base_rate × oncost_percent / 100)
  - `unit`: Measurement unit (hr, day)
- **Cardinality**: 1:Many with Gang Compositions
- **Sample Data**: 10 trades (Brick, Carpenter, Plasterer, Tiler, Plumber, Electrician, Painter, Roofer, Labourer, Semi-skilled)

#### GANGS
- **Purpose**: Gang templates combining multiple labour resources with pre-calculated combined rates
- **Primary Key**: `code` (text, natural key)
- **Natural Key**: code (e.g., GANG_AU_GENERAL_1_1)
- **Key Columns**:
  - `code`: Gang code (GANG_AU_[COMPOSITION])
  - `name`: Description (1 Tradesman + 1 Labourer)
  - `combined_rate`: Combined hourly rate (AUD)
  - `unit`: Measurement unit (hr, day)
- **Cardinality**: 1:Many with Gang Compositions; 1:Many with Composite Rate Labour
- **Sample Data**: 6 gang templates (1 tradesman only, 1+0.5, 1+1, 2+1, 0+1, 0+2)

#### GANG_COMPOSITIONS
- **Purpose**: Member composition of each gang (defines who is in each gang)
- **Primary Key**: `id` (serial)
- **Foreign Keys**:
  - `gang_code`: References GANGS(code)
- **Key Columns**:
  - `gang_code`: Gang identifier
  - `role`: Role type (tradesperson or labourer)
  - `count`: Number of workers (supports fractional staff, e.g., 0.5)
- **Cardinality**: Many:1 with GANGS
- **Unique Constraint**: (gang_code, role) - one entry per role per gang
- **Sample Data**: 12 entries defining 6 gang compositions

#### CONDITION_FACTORS
- **Purpose**: Productivity condition factors for labour/plant adjustments
- **Primary Key**: `code` (text, natural key)
- **Key Columns**:
  - `code`: Factor code (CF_[CATEGORY]_[NAME], e.g., CF_LOCATION_RESTRICTED_ACCESS)
  - `category`: Classification (location, height, weather, complexity, quantity)
  - `name`: Factor name (Difficult access, >10.5m, Exposed, Complex/intricate, etc.)
  - `factor`: Multiplier value (1.0-1.35 range)
  - `applies_to`: Resource types affected (All, Labour, Plant, Labour+Plant)
  - `description`: Human-readable explanation
- **Cardinality**: 1:Many with Composite Rate Factors
- **Sample Data**: 15 factors across 5 categories (3 location, 4 height, 3 weather, 3 complexity, 3 quantity)

#### MATERIALS
- **Purpose**: Material items and unit rates (placeholder for future expansion)
- **Primary Key**: `code` (text, natural key)
- **Key Columns**:
  - `code`: Material code (MAT_AU_[TYPE])
  - `description`: Material description
  - `unit`: Measurement unit
  - `unit_rate`: Cost per unit (AUD)
  - `waste_factor`: Material waste multiplier (e.g., 1.07 for 7% waste)
- **Cardinality**: 1:Many with Composite Rate Materials
- **Status**: Placeholder for future feature

#### PLANT
- **Purpose**: Plant and equipment items for hire rates (placeholder for future expansion)
- **Primary Key**: `code` (text, natural key)
- **Key Columns**:
  - `code`: Equipment code (PLANT_AU_[TYPE])
  - `description`: Equipment description
  - `unit`: Measurement unit (hr, day)
  - `rate`: Hire cost per unit (AUD)
- **Cardinality**: 1:Many with Composite Rate Plant
- **Status**: Placeholder for future feature

---

### 4. RATE TABLES (5 tables)

Rate tables store the composite rates and their line-item breakdowns for labour, materials, and plant.

#### COMPOSITE_RATES
- **Purpose**: Main composite rate records with aggregate costs and modifiers
- **Primary Key**: `code` (varchar, natural key)
- **Natural Key**: code (e.g., EXT-WALL-001, ROOF-TILE-001)
- **Key Columns**:
  - `code`: Rate code (unique identifier)
  - `name`: Rate name/description
  - `description`: Detailed description
  - `unit`: Measurement unit (m2, m, nr, m3, item, etc.)
  - `nrm1_code`: NRM1 element reference
  - `nrm2_codes`: Comma-separated NRM2 item codes
  - `spec_level`: Specification level (basic, standard, premium, luxury)
  - `base_date`: Date of rate (Jan-2025)
  - `region`: Region code (SYD_METRO, MEL_METRO, etc.)
  - `labour_total`: Total labour cost component
  - `materials_total`: Total materials cost component
  - `plant_total`: Total plant cost component
  - `waste_percent`: Material waste allowance (%)
  - `ohp_percent`: Overhead & profit percentage (%)
  - `total_rate`: Final rate = labour + materials + plant + waste + OH&P
- **Cardinality**: 1:Many with Composite Rate Labour, Materials, Plant, Factors
- **Sample Data**: 5 example rates (exterior walls, roof tiling, foundations, floor tiling, drainage)

#### COMPOSITE_RATE_LABOUR
- **Purpose**: Labour line items breakdown for each composite rate
- **Primary Key**: `id` (UUID)
- **Foreign Key**: `composite_code` references COMPOSITE_RATES(code)
- **Key Columns**:
  - `composite_code`: Rate identifier
  - `nrm2_code`: Associated NRM2 item code
  - `task_description`: What work is being done
  - `gang`: Gang composition (1+1, 1+0.5, 0+1, etc.)
  - `output`: Work output/productivity rate
  - `output_unit`: Output unit (m2/hr, m/hr, nr/hr)
  - `hrs_per_unit`: Hours required per output unit
  - `rate_per_hour`: Hourly rate (AUD)
  - `cost_per_unit`: Derived cost per output unit
  - `source`: Data source (Internal, External, etc.)
- **Cardinality**: Many:1 with COMPOSITE_RATES
- **Indexes**: composite_code, nrm2_code
- **Sample Data**: 8-30 labour items per rate

#### COMPOSITE_RATE_MATERIALS
- **Purpose**: Material line items breakdown for each composite rate
- **Primary Key**: `id` (UUID)
- **Foreign Key**: `composite_code` references COMPOSITE_RATES(code)
- **Key Columns**:
  - `composite_code`: Rate identifier
  - `nrm2_code`: Associated NRM2 item code
  - `description`: Material description
  - `unit`: Measurement unit (nr, m3, kg, m2, m, etc.)
  - `quantity`: Material quantity per unit
  - `unit_rate`: Cost per unit (AUD)
  - `cost`: Total cost (quantity × unit_rate)
- **Cardinality**: Many:1 with COMPOSITE_RATES
- **Indexes**: composite_code, nrm2_code
- **Sample Data**: 5-12 material items per rate

#### COMPOSITE_RATE_PLANT
- **Purpose**: Plant/equipment line items breakdown for each composite rate
- **Primary Key**: `id` (UUID)
- **Foreign Key**: `composite_code` references COMPOSITE_RATES(code)
- **Key Columns**:
  - `composite_code`: Rate identifier
  - `nrm2_code`: Associated NRM2 item code
  - `description`: Equipment description
  - `unit`: Measurement unit (hr, day, m2, etc.)
  - `quantity`: Quantity of equipment usage
  - `rate`: Hire rate per unit (AUD)
  - `cost`: Total cost (quantity × rate)
- **Cardinality**: Many:1 with COMPOSITE_RATES
- **Indexes**: composite_code, nrm2_code
- **Sample Data**: 2-3 plant items per rate

#### COMPOSITE_RATE_FACTORS
- **Purpose**: Applied condition factors for each composite rate
- **Primary Key**: `id` (UUID)
- **Foreign Keys**:
  - `composite_code`: References COMPOSITE_RATES(code)
  - `factor_code`: References CONDITION_FACTORS(code) (implied)
- **Key Columns**:
  - `composite_code`: Rate identifier
  - `factor_code`: Condition factor code
  - `applied_value`: Factor value applied to this rate
- **Cardinality**: Many:1 with COMPOSITE_RATES
- **Indexes**: composite_code, factor_code
- **Purpose**: Links rates to applicable productivity modifiers

---

### 5. ADJUSTMENT TABLES (3 tables)

Adjustment tables manage regional factors, cost escalation, and tax rates.

#### REGIONAL_FACTORS
- **Purpose**: Regional pricing adjustment factors with effective date ranges
- **Primary Key**: `id` (UUID)
- **Foreign Key**: `region_code` references REGIONS(code)
- **Key Columns**:
  - `region_code`: Region identifier
  - `factor`: Pricing multiplier (>0, typically 0.90-1.30)
  - `effective_from`: Date from which factor applies
  - `effective_to`: Date until which factor applies (NULL = indefinite)
  - `source`: Source of factor (ABS Construction Price Index, etc.)
  - `notes`: Additional notes
- **Cardinality**: Many:1 with REGIONS (one-to-many across time)
- **Indexes**: region_code, effective_dates, active factors
- **Sample Data**: 16 regional factors (one per region, effective from 2025-01-01)

#### ESCALATION_INDICES
- **Purpose**: Construction cost escalation tracking with quarterly updates
- **Primary Key**: `id` (UUID)
- **Key Columns**:
  - `year`: Calendar year (2000-2100)
  - `quarter`: Quarter (1-4)
  - `index_value`: Index value relative to base year
  - `base_year`: Year used as index base
  - `source`: Source (ABS Construction Price Index, etc.)
  - `notes`: Additional notes
- **Cardinality**: Standalone lookup table
- **Unique Constraint**: (year, quarter)
- **Indexes**: year_quarter, year, base_year
- **Sample Data**: Baseline index 2025 Q4 = 100.00

#### GST_RATES
- **Purpose**: GST (Goods and Services Tax) rates by region with effective date ranges
- **Primary Key**: `id` (UUID)
- **Foreign Key**: `region_code` references REGIONS(code)
- **Key Columns**:
  - `region_code`: Region identifier
  - `rate`: GST rate as decimal (0.10 for 10%)
  - `effective_from`: Date from which rate applies
  - `effective_to`: Date until which rate applies (NULL = indefinite)
  - `notes`: Additional notes
- **Cardinality**: Many:1 with REGIONS
- **Indexes**: region_code, effective_dates, active rates
- **Sample Data**: 16 GST rates all at 0.10 (10%, uniform across Australia)
- **Note**: Uniform 10% nationwide since GST introduction (2000-07-01)

---

## Relationships & Cardinality

### Primary Relationships

| From Table | To Table | Relationship | Cardinality |
|-----------|----------|--------------|-------------|
| UNITS | LABOUR_RESOURCES | Unit of measurement | 1:Many |
| UNITS | COMPOSITE_RATES | Rate unit | 1:Many |
| REGIONS | REGIONAL_FACTORS | Regional adjustments | 1:Many |
| REGIONS | GST_RATES | Tax rates | 1:Many |
| REGIONS | COMPOSITE_RATES | Rate pricing | 1:Many |
| BUILDING_TYPES | COMPOSITE_RATES | Project classification | 1:Many |
| SPEC_LEVELS | COMPOSITE_RATES | Quality grading | 1:Many |
| RATE_TYPES | COMPOSITE_RATES | Cost classification | 1:Many |
| CONFIDENCE_LEVELS | COMPOSITE_RATES | Quality rating | 1:Many |
| RATE_STATUSES | COMPOSITE_RATES | Status tracking | 1:Many |
| NRM1_GROUPS | NRM1_ELEMENTS | Classification hierarchy | 1:Many |
| NRM1_ELEMENTS | NRM1_SUBELEMENTS | Classification hierarchy | 1:Many |
| NRM1_ELEMENTS | NRM1_NRM2_MAPPING | Cross-reference | 1:Many |
| NRM2_WORK_SECTIONS | NRM2_ITEMS | Classification hierarchy | 1:Many |
| NRM2_ITEMS | NRM1_NRM2_MAPPING | Cross-reference | 1:Many |
| LABOUR_RESOURCES | GANG_COMPOSITIONS | Gang membership | 1:Many |
| GANGS | GANG_COMPOSITIONS | Gang definition | 1:Many |
| GANGS | COMPOSITE_RATE_LABOUR | Gang templates | 1:Many |
| CONDITION_FACTORS | COMPOSITE_RATE_FACTORS | Factor application | 1:Many |
| MATERIALS | COMPOSITE_RATE_MATERIALS | Rate items | 1:Many |
| PLANT | COMPOSITE_RATE_PLANT | Rate items | 1:Many |
| COMPOSITE_RATES | COMPOSITE_RATE_LABOUR | Rate breakdown | 1:Many |
| COMPOSITE_RATES | COMPOSITE_RATE_MATERIALS | Rate breakdown | 1:Many |
| COMPOSITE_RATES | COMPOSITE_RATE_PLANT | Rate breakdown | 1:Many |
| COMPOSITE_RATES | COMPOSITE_RATE_FACTORS | Factor application | 1:Many |

### Many-to-Many Relationships

| Table 1 | Join Table | Table 2 | Purpose |
|---------|-----------|---------|---------|
| NRM1_ELEMENTS | NRM1_NRM2_MAPPING | NRM2_ITEMS | Cross-reference between NRM1 and NRM2 classification systems |
| GANGS | GANG_COMPOSITIONS | (implicit) | Define gang members by role |

---

## Key Design Patterns

### 1. Natural Keys
- Reference tables use natural keys (VARCHAR codes) for human-readability
- UUID surrogate keys for transaction tables (labour, materials, plant line items)
- Composite natural key for mapping tables (nrm1_code + nrm2_code)

### 2. Pricing Storage
- All prices stored as NUMERIC with 2 decimal places (AUD cents)
- Rates include labour, materials, plant components plus waste and OH&P
- Regional factors applied via REGIONAL_FACTORS table (time-based)

### 3. Temporal Tracking
- All tables include `created_at` and `updated_at` timestamps
- Effective date ranges on REGIONAL_FACTORS and GST_RATES for historical tracking
- Base date on COMPOSITE_RATES for escalation reference

### 4. Classification System
- NRM hierarchical structure: Groups → Elements → Subelements (NRM1)
- NRM2: Work Sections → Items (two-level)
- Cross-reference via NRM1_NRM2_MAPPING (many-to-many)

### 5. Rate Composition
- Composite rates decomposed into:
  - Labour items (task description, gang, output, hours, rate)
  - Material items (description, unit, quantity, unit rate)
  - Plant items (description, unit, quantity, hire rate)
  - Condition factors (productivity adjustments)
- Total = Labour Total + Materials Total + Plant Total + Waste % + OH&P %

---

## Constraints & Validation

### Key Constraints

| Table | Constraint | Validation |
|-------|-----------|-----------|
| UNITS | code pattern | `^[a-z0-9\-]{1,20}$` |
| UNITS | category | IN (length, area, volume, weight, time, count, provisional) |
| REGIONS | factor range | > 0 AND <= 2.0 |
| REGIONS | only one baseline | NOT (is_baseline AND factor != 1.00) |
| SPEC_LEVELS | rank unique | 1-4 (unique) |
| SPEC_LEVELS | cost_multiplier | > 0 AND <= 2.5 |
| CONFIDENCE_LEVELS | rank unique | 1-3 (unique) |
| RATE_STATUSES | code pattern | `^[a-z_]{3,20}$` |
| COMPOSITE_RATES | waste_percent | >= 0 AND <= 100 |
| COMPOSITE_RATES | ohp_percent | >= 0 AND <= 100 |
| CONDITION_FACTORS | factor positive | > 0 |
| REGIONAL_FACTORS | date range | effective_to > effective_from (if set) |
| REGIONAL_FACTORS | factor positive | > 0 |
| ESCALATION_INDICES | year range | >= 2000 AND <= 2100 |
| ESCALATION_INDICES | quarter range | >= 1 AND <= 4 |
| ESCALATION_INDICES | index positive | > 0 |
| ESCALATION_INDICES | unique year/quarter | UNIQUE (year, quarter) |
| GST_RATES | rate range | >= 0 AND <= 1 |
| GST_RATES | date range | effective_to > effective_from (if set) |

---

## Sample Data Summary

### Reference Tables
- **Units**: 33 units (metric, imperial, provisional)
- **Regions**: 16 Australian regions across 8 states/territories
- **Building Types**: 16 project types (residential, commercial, industrial, institutional, health, civic)
- **Spec Levels**: 4 levels (basic=0.85, standard=1.00, premium=1.35, luxury=1.70)
- **Rate Types**: 4 types (labour, material, plant, composite)
- **Confidence Levels**: 3 levels (low, medium, high)
- **Rate Statuses**: 4 statuses (draft, reviewed, approved, archived)

### NRM Tables
- **NRM1 Groups**: 14 groups (0-13)
- **NRM1 Elements**: 48 elements
- **NRM1 Subelements**: 20+ subelements
- **NRM2 Work Sections**: 40 sections (2-41)
- **NRM2 Items**: 50+ items
- **NRM1↔NRM2 Mapping**: 10+ sample mappings

### Resource Tables
- **Labour Resources**: 10 trades (Bricklayer: $78/hr, Electrician: $84/hr, etc.)
- **Gangs**: 6 gang templates (1 tradesman to 2 labourers)
- **Gang Compositions**: 12 entries defining 6 gangs
- **Condition Factors**: 15 factors (location, height, weather, complexity, quantity)
- **Materials**: Placeholder for future
- **Plant**: Placeholder for future

### Rate Tables
- **Composite Rates**: 5 example rates covering exterior walls, roofs, foundations, flooring, drainage
- **Rate Breakdowns**: Labour, materials, plant line items for each rate
- **Rate Factors**: Applied condition factors per rate

### Adjustment Tables
- **Regional Factors**: 16 factors (SYD_METRO=1.00 baseline to NT=1.30)
- **Escalation Indices**: 2025 Q4 baseline (100.00)
- **GST Rates**: 16 entries all at 0.10 (10% uniform)

---

## Access Patterns

### Query Examples

**Get current regional factor:**
```sql
SELECT factor FROM regional_factors
WHERE region_code = 'SYD_METRO'
  AND effective_from <= CURRENT_DATE
  AND (effective_to IS NULL OR effective_to >= CURRENT_DATE)
ORDER BY effective_from DESC LIMIT 1;
```

**Get composite rate with breakdown:**
```sql
SELECT cr.*, crl.*, crm.*, crp.*
FROM composite_rates cr
LEFT JOIN composite_rate_labour crl ON cr.code = crl.composite_code
LEFT JOIN composite_rate_materials crm ON cr.code = crm.composite_code
LEFT JOIN composite_rate_plant crp ON cr.code = crp.composite_code
WHERE cr.code = 'EXT-WALL-001';
```

**Match NRM1 to NRM2:**
```sql
SELECT nm.nrm2_code, ni.description
FROM nrm1_nrm2_mapping nm
JOIN nrm2_items ni ON nm.nrm2_code = ni.code
WHERE nm.nrm1_code = '2.5';
```

---

## Future Enhancements

1. **Material Master**: Expand MATERIALS table with supplier pricing and lead times
2. **Plant Equipment**: Expand PLANT table with hire rates and availability
3. **Vector Embeddings**: Add embedding columns for semantic search on rate descriptions
4. **Audit Logging**: Implement audit trail for rate changes and approvals
5. **Version Control**: Track composite rate versions with effective dates
6. **Supplier Integration**: Link materials and plant to external supplier APIs
7. **Historical Tracking**: Archive old rates with effective date ranges

---

## Migration History

| Migration | Created | Tables | Purpose |
|-----------|---------|--------|---------|
| 001_reference_tables.sql | 2026-01-03 | 9 | Reference classifications |
| 002_nrm_tables.sql | 2026-01-03 | 7 | NRM1 and NRM2 hierarchies |
| 003_resource_tables.sql | 2026-01-03 | 6 | Labour, plant, condition factors |
| 004_rate_tables.sql | 2026-01-03 | 5 | Composite rates and breakdowns |
| 005_adjustment_tables.sql | 2026-01-03 | 3 | Regional, escalation, GST adjustments |

**Total Tables**: 27
**Total Seed Data Records**: 300+ (before composite rate expansion)

---

## Index Strategy

### Performance Indexes

| Table | Index | Columns | Purpose |
|-------|-------|---------|---------|
| UNITS | idx_units_category | category | Filter by unit type |
| REGIONS | idx_regions_state | state | Query by state |
| REGIONS | idx_regions_baseline | is_baseline | Find baseline region |
| BUILDING_TYPES | idx_building_types_complexity | complexity | Filter by project complexity |
| SPEC_LEVELS | idx_spec_levels_rank | rank | Order specifications |
| CONFIDENCE_LEVELS | idx_confidence_levels_rank | rank | Order confidence levels |
| RATE_STATUSES | idx_rate_statuses_active | is_active | Filter active rates |
| NRM1_ELEMENTS | idx_nrm1_elements_group_code | group_code | Hierarchy traversal |
| NRM1_SUBELEMENTS | idx_nrm1_subelements_element_code | element_code | Hierarchy traversal |
| NRM2_ITEMS | idx_nrm2_items_work_section | work_section | Hierarchy traversal |
| NRM1_NRM2_MAPPING | idx_nrm1_nrm2_mapping_nrm1 | nrm1_code | Reverse lookup |
| NRM1_NRM2_MAPPING | idx_nrm1_nrm2_mapping_nrm2 | nrm2_code | Forward lookup |
| GANG_COMPOSITIONS | idx_gang_compositions_unique | (gang_code, role) | Uniqueness constraint |
| CONDITION_FACTORS | idx_condition_factors_category | category | Filter by category |
| COMPOSITE_RATE_LABOUR | idx_composite_labour_composite_code | composite_code | Rate breakdown |
| COMPOSITE_RATE_LABOUR | idx_composite_labour_nrm2_code | nrm2_code | NRM cross-reference |
| COMPOSITE_RATE_MATERIALS | idx_composite_materials_composite_code | composite_code | Rate breakdown |
| COMPOSITE_RATE_MATERIALS | idx_composite_materials_nrm2_code | nrm2_code | NRM cross-reference |
| COMPOSITE_RATE_PLANT | idx_composite_plant_composite_code | composite_code | Rate breakdown |
| COMPOSITE_RATE_PLANT | idx_composite_plant_nrm2_code | nrm2_code | NRM cross-reference |
| COMPOSITE_RATE_FACTORS | idx_composite_factors_composite_code | composite_code | Factor lookup |
| COMPOSITE_RATE_FACTORS | idx_composite_factors_factor_code | factor_code | Factor filter |
| REGIONAL_FACTORS | idx_regional_factors_region_code | region_code | Regional lookup |
| REGIONAL_FACTORS | idx_regional_factors_effective_dates | (effective_from, effective_to) | Date range queries |
| REGIONAL_FACTORS | idx_regional_factors_active | (region_code, effective_from, effective_to) | Current factor lookup |
| ESCALATION_INDICES | idx_escalation_indices_year_quarter | (year, quarter) | Timeline queries |
| ESCALATION_INDICES | idx_escalation_indices_year | year | Year filtering |
| ESCALATION_INDICES | idx_escalation_indices_base_year | base_year | Base reference |
| GST_RATES | idx_gst_rates_region_code | region_code | Regional lookup |
| GST_RATES | idx_gst_rates_effective_dates | (effective_from, effective_to) | Date range queries |
| GST_RATES | idx_gst_rates_active | (region_code, effective_from, effective_to) | Current rate lookup |

---

## Document Version

- **Version**: 1.0
- **Created**: 2026-01-03
- **Last Updated**: 2026-01-03
- **Database Version**: ContechData v1.0
- **Schema Version**: 005_adjustment_tables.sql
