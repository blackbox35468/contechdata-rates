/**
 * Supabase Auto-Generated Database Types
 * Generated: 2026-01-03
 * Project: ContechData - Australia
 *
 * Database schema types for construction rates database
 * Includes all tables from migrations 001-005
 */

// ============================================================================
// TYPE DEFINITIONS
// ============================================================================

/** Condition factor category type */
export type ConditionFactorCategory = 'location' | 'height' | 'weather' | 'complexity' | 'quantity';

// ============================================================================
// TABLE: UNITS
// ============================================================================
/**
 * Measurement units used in construction estimates
 * Supports both SI (metric) and imperial units for legacy compatibility
 */
export interface Units {
  Row: {
    /** Unique UUID identifier */
    id: string;
    /** Unique code identifier (e.g., m2, m3, hr, ls) */
    code: string;
    /** Human-readable unit name (e.g., "Square metre") */
    name: string;
    /** Unit symbol (e.g., "m²", "m³") */
    symbol: string;
    /** Unit classification (length, area, volume, weight, time, count, provisional) */
    category: string;
    /** Detailed description of the unit */
    description: string | null;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    id?: string;
    code: string;
    name: string;
    symbol: string;
    category: string;
    description?: string | null;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    id?: string;
    code?: string;
    name?: string;
    symbol?: string;
    category?: string;
    description?: string | null;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: REGIONS
// ============================================================================
/**
 * Australian regions with geographical pricing factors
 * Supports 16 regions across all states and territories
 * Sydney Metro (SYD_METRO) is the baseline region with factor 1.00
 */
export interface Regions {
  Row: {
    /** Unique UUID identifier */
    id: string;
    /** Region code (e.g., SYD_METRO, MEL_OUTER, NSW_REGIONAL) */
    code: string;
    /** Human-readable region name */
    name: string;
    /** State code (NSW, VIC, QLD, WA, SA, TAS, ACT, NT) */
    state: string;
    /** Price adjustment factor relative to baseline (SYD_METRO = 1.00) */
    factor: number;
    /** Marks Sydney Metro as baseline region for rate comparisons */
    is_baseline: boolean;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    id?: string;
    code: string;
    name: string;
    state: string;
    factor?: number;
    is_baseline?: boolean;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    id?: string;
    code?: string;
    name?: string;
    state?: string;
    factor?: number;
    is_baseline?: boolean;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: BUILDING_TYPES
// ============================================================================
/**
 * Construction project types with complexity ratings
 * Supports residential, commercial, industrial, institutional, health, civic
 */
export interface BuildingTypes {
  Row: {
    /** Unique UUID identifier */
    id: string;
    /** Unique project type code (e.g., RES_HOUSE, COM_OFFICE_HIGH, IND_WAREHOUSE) */
    code: string;
    /** Human-readable building type name */
    name: string;
    /** Building category (residential, commercial, industrial, institutional, health, civic) */
    category: string;
    /** Project complexity (low, standard, medium, high, very_high) affecting methodology and contingency factors */
    complexity: string;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    id?: string;
    code: string;
    name: string;
    category: string;
    complexity: string;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    id?: string;
    code?: string;
    name?: string;
    category?: string;
    complexity?: string;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: SPEC_LEVELS
// ============================================================================
/**
 * Specification levels for finishes and quality standards
 * Used to differentiate cost profiles within same building type
 */
export interface SpecLevels {
  Row: {
    /** Unique UUID identifier */
    id: string;
    /** Unique specification level code (e.g., basic, standard, premium, luxury) */
    code: string;
    /** Human-readable specification level name */
    name: string;
    /** Detailed description of the specification level */
    description: string | null;
    /** Ordering (1=basic, 4=luxury) for comparative analysis */
    rank: number;
    /** Cost factor relative to standard specification (standard = 1.00) */
    cost_multiplier: number;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    id?: string;
    code: string;
    name: string;
    description?: string | null;
    rank: number;
    cost_multiplier?: number;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    id?: string;
    code?: string;
    name?: string;
    description?: string | null;
    rank?: number;
    cost_multiplier?: number;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: RATE_TYPES
// ============================================================================
/**
 * Classification of rate components in the cost build-up
 * Enables granular tracking of labour, material, plant, composite costs
 */
export interface RateTypes {
  Row: {
    /** Unique UUID identifier */
    id: string;
    /** Unique rate type code (labour, material, plant, composite) */
    code: string;
    /** Human-readable rate type name */
    name: string;
    /** Detailed description of the rate type */
    description: string | null;
    /** Flag: TRUE for composite rates (combines labour+material+plant) */
    is_composite: boolean;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    id?: string;
    code: string;
    name: string;
    description?: string | null;
    is_composite?: boolean;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    id?: string;
    code?: string;
    name?: string;
    description?: string | null;
    is_composite?: boolean;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: CONFIDENCE_LEVELS
// ============================================================================
/**
 * Data confidence rating for rates and estimates
 * Used in risk assessment and rate quality scoring
 */
export interface ConfidenceLevels {
  Row: {
    /** Unique UUID identifier */
    id: string;
    /** Unique confidence level code (low, medium, high) */
    code: string;
    /** Human-readable confidence level name */
    name: string;
    /** Detailed description of the confidence level */
    description: string | null;
    /** Confidence ordering (1=low, 3=high) */
    rank: number;
    /** Estimated accuracy range (e.g., ±5%, ±10%, ±15%) */
    percentage_range: string | null;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    id?: string;
    code: string;
    name: string;
    description?: string | null;
    rank: number;
    percentage_range?: string | null;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    id?: string;
    code?: string;
    name?: string;
    description?: string | null;
    rank?: number;
    percentage_range?: string | null;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: RATE_STATUSES
// ============================================================================
/**
 * Workflow status for rates in approval and archival pipelines
 * Tracks rate lifecycle from draft through approval to archival
 */
export interface RateStatuses {
  Row: {
    /** Unique UUID identifier */
    id: string;
    /** Unique status code (draft, reviewed, approved, archived) */
    code: string;
    /** Human-readable status name */
    name: string;
    /** Detailed description of the rate status */
    description: string | null;
    /** Flag: FALSE for archived rates to enable filtering in queries */
    is_active: boolean;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    id?: string;
    code: string;
    name: string;
    description?: string | null;
    is_active?: boolean;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    id?: string;
    code?: string;
    name?: string;
    description?: string | null;
    is_active?: boolean;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: NRM1_GROUPS
// ============================================================================
/**
 * NRM1 top-level groups providing the highest-level classification of construction work
 * Examples: Facilitating Works, Substructure, Superstructure
 */
export interface Nrm1Groups {
  Row: {
    /** Natural key: single digit or two-digit code (0-13) */
    code: string;
    /** Group name (e.g., "Facilitating works", "Substructure") */
    name: string;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    code: string;
    name: string;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    code?: string;
    name?: string;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: NRM1_ELEMENTS
// ============================================================================
/**
 * NRM1 elements providing the second level of classification under a group
 * Examples: Element 0.1 under group 0
 */
export interface Nrm1Elements {
  Row: {
    /** Natural key: Group code + decimal + digit (e.g., "0.1", "2.3") */
    code: string;
    /** Foreign key to nrm1_groups(code) */
    group_code: string;
    /** Element name describing the work classification */
    name: string;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    code: string;
    group_code: string;
    name: string;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    code?: string;
    group_code?: string;
    name?: string;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: NRM1_SUBELEMENTS
// ============================================================================
/**
 * NRM1 subelements providing the third level of classification under an element
 * Examples: Subelement 0.1.1 under element 0.1
 */
export interface Nrm1Subelements {
  Row: {
    /** Natural key: Element code + decimal + digit (e.g., "0.1.1", "2.3.4") */
    code: string;
    /** Foreign key to nrm1_elements(code) */
    element_code: string;
    /** Subelement name describing the specific work item */
    name: string;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    code: string;
    element_code: string;
    name: string;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    code?: string;
    element_code?: string;
    name?: string;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: NRM2_WORK_SECTIONS
// ============================================================================
/**
 * NRM2 work sections providing the first level of classification
 * Examples: Section 2 = Off-site manufactured materials
 */
export interface Nrm2WorkSections {
  Row: {
    /** Natural key: Work section number (2-41) */
    number: number;
    /** Work section name describing the category of work */
    name: string;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    number: number;
    name: string;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    number?: number;
    name?: string;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: NRM2_ITEMS
// ============================================================================
/**
 * NRM2 items providing the second level of classification under a work section
 * Examples: Item WS2.1 under section 2
 */
export interface Nrm2Items {
  Row: {
    /** Natural key: Work section code + dot + item number (e.g., "WS2.1", "WS11.2") */
    code: string;
    /** Foreign key to nrm2_work_sections(number) */
    work_section: number;
    /** Description of the work item */
    description: string;
    /** Unit of measurement (e.g., "nr", "m2", "m", "item", "m3", "t", "hr") */
    unit: string;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    code: string;
    work_section: number;
    description: string;
    unit: string;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    code?: string;
    work_section?: number;
    description?: string;
    unit?: string;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: NRM1_NRM2_MAPPING
// ============================================================================
/**
 * Many-to-many mapping between NRM1 elements and NRM2 items
 * Enables cross-reference and traceability between classification systems
 */
export interface Nrm1Nrm2Mapping {
  Row: {
    /** Foreign key to nrm1_elements(code) */
    nrm1_code: string;
    /** Foreign key to nrm2_items(code) */
    nrm2_code: string;
    /** Description of the mapping relationship and its context */
    description: string | null;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    nrm1_code: string;
    nrm2_code: string;
    description?: string | null;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    nrm1_code?: string;
    nrm2_code?: string;
    description?: string | null;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: LABOUR_RESOURCES
// ============================================================================
/**
 * Trade labour rates in AUD per hour
 * Base rate + oncosts (superannuation, workers comp, etc.)
 */
export interface LabourResources {
  Row: {
    /** Natural key: LAB_AU_[TRADE_CODE] (e.g., LAB_AU_BRICK) */
    code: string;
    /** Trade name (e.g., Bricklayer) */
    trade: string;
    /** Hourly rate before oncosts, in AUD */
    base_rate: number;
    /** Percentage of base rate for oncosts (super, workers comp, etc.) */
    oncost_percent: number;
    /** Final rate = base_rate + (base_rate × oncost_percent / 100) */
    total_rate: number;
    /** Unit of measurement (hr, day, etc.) */
    unit: string;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    code: string;
    trade: string;
    base_rate: number;
    oncost_percent: number;
    total_rate: number;
    unit?: string;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    code?: string;
    trade?: string;
    base_rate?: number;
    oncost_percent?: number;
    total_rate?: number;
    unit?: string;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: GANGS
// ============================================================================
/**
 * Gang templates combining multiple labour resources with pre-calculated combined rates
 * Each gang has a specific tradesperson-to-labourer ratio
 */
export interface Gangs {
  Row: {
    /** Natural key: GANG_AU_[COMPOSITION] (e.g., GANG_AU_GENERAL_1_0) */
    code: string;
    /** Human-readable gang description (e.g., "1 Tradesman + 1 Labourer") */
    name: string;
    /** Combined hourly rate for entire gang, in AUD */
    combined_rate: number;
    /** Unit of measurement (hr, day, etc.) */
    unit: string;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    code: string;
    name: string;
    combined_rate: number;
    unit?: string;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    code?: string;
    name?: string;
    combined_rate?: number;
    unit?: string;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: GANG_COMPOSITIONS
// ============================================================================
/**
 * Member composition of gangs
 * Defines the specific roles and counts within each gang template
 */
export interface GangCompositions {
  Row: {
    /** Auto-generated serial ID */
    id: number;
    /** Foreign key to gangs(code) */
    gang_code: string;
    /** Role in gang: "tradesperson" or "labourer" */
    role: string;
    /** Number of workers in this role (supports fractional staff) */
    count: number;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    id?: number;
    gang_code: string;
    role: string;
    count: number;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    id?: number;
    gang_code?: string;
    role?: string;
    count?: number;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: CONDITION_FACTORS
// ============================================================================
/**
 * Productivity adjustment factors for labour and plant
 * Examples: height, access difficulty, weather exposure
 */
export interface ConditionFactors {
  Row: {
    /** Natural key: CF_[CATEGORY]_[NAME] (e.g., CF_LOCATION_RESTRICTED_ACCESS) */
    code: string;
    /** Factor category: location | height | weather | complexity | quantity */
    category: ConditionFactorCategory;
    /** Factor name (e.g., "Difficult access") */
    name: string;
    /** Multiplier to apply to rates (e.g., 1.2 = 20% productivity reduction) */
    factor: number;
    /** Comma-separated list of resource types (e.g., "Labour, Plant" or "All") */
    applies_to: string;
    /** Human-readable description of the factor */
    description: string | null;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    code: string;
    category: ConditionFactorCategory;
    name: string;
    factor: number;
    applies_to: string;
    description?: string | null;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    code?: string;
    category?: ConditionFactorCategory;
    name?: string;
    factor?: number;
    applies_to?: string;
    description?: string | null;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: MATERIALS
// ============================================================================
/**
 * Material items and unit rates
 * Placeholder for future feature with unit rates and waste factors
 */
export interface Materials {
  Row: {
    /** Material code (e.g., MAT_AU_BRICK_CLAY_100) */
    code: string;
    /** Description of the material item */
    description: string;
    /** Unit of measurement (e.g., "nr", "kg", "m", "m2") */
    unit: string;
    /** Cost per unit in AUD */
    unit_rate: number | null;
    /** Material waste multiplier (e.g., 1.07 for 7% waste) */
    waste_factor: number;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    code: string;
    description: string;
    unit: string;
    unit_rate?: number | null;
    waste_factor?: number;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    code?: string;
    description?: string;
    unit?: string;
    unit_rate?: number | null;
    waste_factor?: number;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: PLANT
// ============================================================================
/**
 * Plant and equipment items for hire rates
 * Placeholder for future feature with hire rates and productivity factors
 */
export interface Plant {
  Row: {
    /** Equipment code (e.g., PLANT_AU_SCAFFOLDING_FRAME) */
    code: string;
    /** Description of the plant/equipment item */
    description: string;
    /** Unit of measurement (e.g., "hr", "day", "week") */
    unit: string;
    /** Hire cost per unit in AUD */
    rate: number | null;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    code: string;
    description: string;
    unit: string;
    rate?: number | null;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    code?: string;
    description?: string;
    unit?: string;
    rate?: number | null;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: COMPOSITE_RATES
// ============================================================================
/**
 * Main composite rate records with aggregate costs and modifiers
 * Code is the natural key. Total_rate includes labour + materials + plant + waste allowance + OH&P percentage
 */
export interface CompositeRates {
  Row: {
    /** Natural key: unique rate identifier */
    code: string;
    /** Human-readable rate name */
    name: string;
    /** Detailed description of the rate */
    description: string | null;
    /** Unit of measurement (e.g., "m²", "m", "nr") */
    unit: string;
    /** NRM1 classification code */
    nrm1_code: string | null;
    /** Comma-separated NRM2 codes */
    nrm2_codes: string | null;
    /** Specification level applied */
    spec_level: string | null;
    /** Base date for the rate (e.g., "Jan-2025") */
    base_date: string | null;
    /** Region where rate applies */
    region: string | null;
    /** Total labour cost component */
    labour_total: number;
    /** Total materials cost component */
    materials_total: number;
    /** Total plant/equipment cost component */
    plant_total: number;
    /** Waste percentage allowance */
    waste_percent: number;
    /** Overhead & Profit percentage */
    ohp_percent: number;
    /** Final total rate = labour + materials + plant + waste + OH&P */
    total_rate: number;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    code: string;
    name: string;
    description?: string | null;
    unit: string;
    nrm1_code?: string | null;
    nrm2_codes?: string | null;
    spec_level?: string | null;
    base_date?: string | null;
    region?: string | null;
    labour_total?: number;
    materials_total?: number;
    plant_total?: number;
    waste_percent?: number;
    ohp_percent?: number;
    total_rate?: number;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    code?: string;
    name?: string;
    description?: string | null;
    unit?: string;
    nrm1_code?: string | null;
    nrm2_codes?: string | null;
    spec_level?: string | null;
    base_date?: string | null;
    region?: string | null;
    labour_total?: number;
    materials_total?: number;
    plant_total?: number;
    waste_percent?: number;
    ohp_percent?: number;
    total_rate?: number;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: COMPOSITE_RATE_LABOUR
// ============================================================================
/**
 * Labour line items breakdown for each composite rate
 * Each labour item includes task description, gang composition, output rates, and derived cost per unit
 * Sorted by NRM2 code
 */
export interface CompositeRateLabour {
  Row: {
    /** Auto-generated UUID identifier */
    id: string;
    /** Foreign key to composite_rates(code) */
    composite_code: string;
    /** NRM2 code reference */
    nrm2_code: string | null;
    /** Description of the labour task */
    task_description: string;
    /** Gang composition code reference */
    gang: string | null;
    /** Output quantity per unit time */
    output: number | null;
    /** Unit for output measurement */
    output_unit: string | null;
    /** Hours of labour required per unit of work */
    hrs_per_unit: number | null;
    /** Hourly rate for the labour */
    rate_per_hour: number | null;
    /** Calculated cost per unit of work */
    cost_per_unit: number;
    /** Source of the labour rate (e.g., "Internal", "External") */
    source: string | null;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    id?: string;
    composite_code: string;
    nrm2_code?: string | null;
    task_description: string;
    gang?: string | null;
    output?: number | null;
    output_unit?: string | null;
    hrs_per_unit?: number | null;
    rate_per_hour?: number | null;
    cost_per_unit: number;
    source?: string | null;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    id?: string;
    composite_code?: string;
    nrm2_code?: string | null;
    task_description?: string;
    gang?: string | null;
    output?: number | null;
    output_unit?: string | null;
    hrs_per_unit?: number | null;
    rate_per_hour?: number | null;
    cost_per_unit?: number;
    source?: string | null;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: COMPOSITE_RATE_MATERIALS
// ============================================================================
/**
 * Material line items breakdown for each composite rate
 * Each material item includes unit type, quantity, unit rate, and total cost
 */
export interface CompositeRateMaterials {
  Row: {
    /** Auto-generated UUID identifier */
    id: string;
    /** Foreign key to composite_rates(code) */
    composite_code: string;
    /** NRM2 code reference */
    nrm2_code: string | null;
    /** Description of the material item */
    description: string;
    /** Unit of measurement for the material */
    unit: string | null;
    /** Quantity of material required per unit of work */
    quantity: number | null;
    /** Unit rate for the material in AUD */
    unit_rate: number | null;
    /** Total cost for this material item */
    cost: number;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    id?: string;
    composite_code: string;
    nrm2_code?: string | null;
    description: string;
    unit?: string | null;
    quantity?: number | null;
    unit_rate?: number | null;
    cost: number;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    id?: string;
    composite_code?: string;
    nrm2_code?: string | null;
    description?: string;
    unit?: string | null;
    quantity?: number | null;
    unit_rate?: number | null;
    cost?: number;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: COMPOSITE_RATE_PLANT
// ============================================================================
/**
 * Plant and equipment line items breakdown for each composite rate
 * Each item includes unit type, quantity, hire rate, and total cost
 */
export interface CompositeRatePlant {
  Row: {
    /** Auto-generated UUID identifier */
    id: string;
    /** Foreign key to composite_rates(code) */
    composite_code: string;
    /** NRM2 code reference */
    nrm2_code: string | null;
    /** Description of the plant/equipment item */
    description: string;
    /** Unit of measurement for hire/usage */
    unit: string | null;
    /** Quantity of plant/equipment required */
    quantity: number | null;
    /** Hire rate per unit in AUD */
    rate: number | null;
    /** Total cost for this plant/equipment item */
    cost: number;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    id?: string;
    composite_code: string;
    nrm2_code?: string | null;
    description: string;
    unit?: string | null;
    quantity?: number | null;
    rate?: number | null;
    cost: number;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    id?: string;
    composite_code?: string;
    nrm2_code?: string | null;
    description?: string;
    unit?: string | null;
    quantity?: number | null;
    rate?: number | null;
    cost?: number;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: COMPOSITE_RATE_FACTORS
// ============================================================================
/**
 * Applied condition factors for each composite rate
 * Links composite rates to productivity modifiers and adjustment codes
 */
export interface CompositeRateFactors {
  Row: {
    /** Auto-generated UUID identifier */
    id: string;
    /** Foreign key to composite_rates(code) */
    composite_code: string;
    /** Code of the condition factor being applied */
    factor_code: string;
    /** Applied value of the factor */
    applied_value: number | null;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    id?: string;
    composite_code: string;
    factor_code: string;
    applied_value?: number | null;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    id?: string;
    composite_code?: string;
    factor_code?: string;
    applied_value?: number | null;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: REGIONAL_FACTORS
// ============================================================================
/**
 * Regional pricing adjustment factors with effective date ranges
 * Used to apply regional cost multipliers to base rates during estimate calculations
 */
export interface RegionalFactors {
  Row: {
    /** Unique UUID identifier for this record */
    id: string;
    /** Foreign key reference to regions(code) */
    region_code: string;
    /** Pricing multiplier (e.g., 1.05 = +5% cost adjustment) */
    factor: number;
    /** Date from which this factor applies */
    effective_from: string;
    /** Date until which this factor applies (NULL = current/indefinite) */
    effective_to: string | null;
    /** Source of the factor (e.g., "ABS Q4 2025", "Market Analysis") */
    source: string | null;
    /** Additional notes about this factor */
    notes: string | null;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    id?: string;
    region_code: string;
    factor: number;
    effective_from: string;
    effective_to?: string | null;
    source?: string | null;
    notes?: string | null;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    id?: string;
    region_code?: string;
    factor?: number;
    effective_from?: string;
    effective_to?: string | null;
    source?: string | null;
    notes?: string | null;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: ESCALATION_INDICES
// ============================================================================
/**
 * Construction cost escalation indices by quarter and year
 * Used to adjust costs from historical base year to current pricing
 */
export interface EscalationIndices {
  Row: {
    /** Unique UUID identifier for this record */
    id: string;
    /** Calendar year of the index */
    year: number;
    /** Quarter (1-4) of the index */
    quarter: number;
    /** Index value relative to base year (e.g., 105.2 = +5.2% relative to base) */
    index_value: number;
    /** Year used as index base (e.g., 2020 = 100) */
    base_year: number;
    /** Source of the index (e.g., "ABS Construction Price Index", "BLS") */
    source: string;
    /** Additional notes about this index value */
    notes: string | null;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    id?: string;
    year: number;
    quarter: number;
    index_value: number;
    base_year: number;
    source: string;
    notes?: string | null;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    id?: string;
    year?: number;
    quarter?: number;
    index_value?: number;
    base_year?: number;
    source?: string;
    notes?: string | null;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// TABLE: GST_RATES
// ============================================================================
/**
 * GST (Goods and Services Tax) rates by region with effective date ranges
 * Typically uniform at 10% nationwide but stored per region for flexibility
 */
export interface GstRates {
  Row: {
    /** Unique UUID identifier for this record */
    id: string;
    /** Foreign key reference to regions(code) */
    region_code: string;
    /** GST rate as decimal (e.g., 0.10 = 10%) */
    rate: number;
    /** Date from which this rate applies */
    effective_from: string;
    /** Date until which this rate applies (NULL = current/indefinite) */
    effective_to: string | null;
    /** Additional notes about this rate */
    notes: string | null;
    /** Timestamp when record was created */
    created_at: string;
    /** Timestamp when record was last updated */
    updated_at: string;
  };
  Insert: {
    id?: string;
    region_code: string;
    rate: number;
    effective_from: string;
    effective_to?: string | null;
    notes?: string | null;
    created_at?: string;
    updated_at?: string;
  };
  Update: {
    id?: string;
    region_code?: string;
    rate?: number;
    effective_from?: string;
    effective_to?: string | null;
    notes?: string | null;
    created_at?: string;
    updated_at?: string;
  };
}

// ============================================================================
// DATABASE INTERFACE
// ============================================================================

/**
 * Main Database interface combining all tables and views
 * Follows Supabase naming convention with public schema
 */
export interface Database {
  public: {
    Tables: {
      units: Units;
      regions: Regions;
      building_types: BuildingTypes;
      spec_levels: SpecLevels;
      rate_types: RateTypes;
      confidence_levels: ConfidenceLevels;
      rate_statuses: RateStatuses;
      nrm1_groups: Nrm1Groups;
      nrm1_elements: Nrm1Elements;
      nrm1_subelements: Nrm1Subelements;
      nrm2_work_sections: Nrm2WorkSections;
      nrm2_items: Nrm2Items;
      nrm1_nrm2_mapping: Nrm1Nrm2Mapping;
      labour_resources: LabourResources;
      gangs: Gangs;
      gang_compositions: GangCompositions;
      condition_factors: ConditionFactors;
      materials: Materials;
      plant: Plant;
      composite_rates: CompositeRates;
      composite_rate_labour: CompositeRateLabour;
      composite_rate_materials: CompositeRateMaterials;
      composite_rate_plant: CompositeRatePlant;
      composite_rate_factors: CompositeRateFactors;
      regional_factors: RegionalFactors;
      escalation_indices: EscalationIndices;
      gst_rates: GstRates;
    };
    Views: {};
    Functions: {
      update_timestamp: {
        Args: Record<string, never>;
        Returns: unknown;
      };
      get_current_regional_factor: {
        Args: {
          p_region_code: string;
        };
        Returns: number;
      };
      get_current_gst_rate: {
        Args: {
          p_region_code: string;
        };
        Returns: number;
      };
      get_escalation_index: {
        Args: {
          p_year: number;
          p_quarter: number;
        };
        Returns: number;
      };
    };
    Enums: {
      condition_factor_category: ConditionFactorCategory;
    };
  };
}
