/**
 * TypeScript Enums for ContechData Australia Rates Database
 *
 * These enums are derived from SQL migration files and match the database
 * CHECK constraints and reference table values. They provide type-safe access
 * to enumerated values throughout the application.
 *
 * Generated from:
 * - /au/supabase/migrations/001_reference_tables.sql
 * - /au/supabase/migrations/004_rate_tables.sql
 * - /au/supabase/migrations/005_adjustment_tables.sql
 */

/**
 * UnitCategory
 *
 * Classification of measurement units used in construction estimates.
 * Supports SI (metric) and imperial units for legacy compatibility.
 *
 * Database constraint: CHECK (category IN ('length', 'area', 'volume', 'weight', 'time', 'count', 'provisional'))
 * Seed units include: m, m2, m3, t, hr, nr, ls, etc.
 */
export enum UnitCategory {
  /** Length measurements (m, mm, cm, km, ft) */
  Length = 'length',

  /** Area measurements (m2, ha, sqft) */
  Area = 'area',

  /** Volume measurements (m3, l, ml, cbft) */
  Volume = 'volume',

  /** Weight/mass measurements (t, kg, g) */
  Weight = 'weight',

  /** Time measurements (hr, day, wk, mth, yr) */
  Time = 'time',

  /** Count measurements (nr, item, each, pair, set) */
  Count = 'count',

  /** Provisional units for uncertain quantities (ls, prov, cont, pc, allowance) */
  Provisional = 'provisional',
}

/**
 * RegionState
 *
 * Australian states and territories used for regional pricing adjustments.
 * These map to the 'state' column in the regions table.
 *
 * Database constraint: CHECK (state IN ('NSW', 'VIC', 'QLD', 'WA', 'SA', 'TAS', 'ACT', 'NT'))
 * Regions include: Sydney, Melbourne, Brisbane, Perth, Adelaide, Hobart, ACT, NT
 */
export enum RegionState {
  /** New South Wales */
  NSW = 'NSW',

  /** Victoria */
  VIC = 'VIC',

  /** Queensland */
  QLD = 'QLD',

  /** Western Australia */
  WA = 'WA',

  /** South Australia */
  SA = 'SA',

  /** Tasmania */
  TAS = 'TAS',

  /** Australian Capital Territory */
  ACT = 'ACT',

  /** Northern Territory */
  NT = 'NT',
}

/**
 * BuildingCategory
 *
 * Primary classification of building project types.
 * Used to categorize projects and select appropriate estimation methodology.
 *
 * Database constraint: CHECK (category IN ('residential', 'commercial', 'industrial', 'institutional', 'health', 'civic'))
 * Examples: RES_HOUSE, COM_OFFICE_HIGH, IND_WAREHOUSE, EDU_SCHOOL, HEALTH_HOSPITAL
 */
export enum BuildingCategory {
  /** Residential buildings (houses, apartments, townhouses) */
  Residential = 'residential',

  /** Commercial buildings (offices, retail, hotels) */
  Commercial = 'commercial',

  /** Industrial buildings (warehouses, factories, manufacturing) */
  Industrial = 'industrial',

  /** Institutional buildings (schools, universities, TAFEs) */
  Institutional = 'institutional',

  /** Healthcare buildings (clinics, hospitals) */
  Health = 'health',

  /** Civic buildings (community centers, public facilities) */
  Civic = 'civic',
}

/**
 * Complexity
 *
 * Project complexity classification affecting estimation methodology selection
 * and contingency factor application.
 *
 * Database constraint: CHECK (complexity IN ('low', 'standard', 'medium', 'high', 'very_high'))
 * Range: low → standard → medium → high → very_high
 */
export enum Complexity {
  /** Low complexity (e.g., simple warehouses, detached houses) */
  Low = 'low',

  /** Standard complexity (typical residential or commercial buildings) */
  Standard = 'standard',

  /** Medium complexity (mid-rise apartments, offices) */
  Medium = 'medium',

  /** High complexity (high-rise offices, hotels) */
  High = 'high',

  /** Very high complexity (complex commercial, hospitals) */
  VeryHigh = 'very_high',
}

/**
 * SpecLevel
 *
 * Specification levels for finishes and quality standards.
 * Used to differentiate cost profiles and apply cost multipliers.
 *
 * Seed data rank values: basic=1, standard=2, premium=3, luxury=4
 * Cost multipliers: basic=0.85x, standard=1.00x, premium=1.35x, luxury=1.70x
 */
export enum SpecLevel {
  /** Basic: Economy finishes and materials (0.85x cost multiplier) */
  Basic = 'basic',

  /** Standard: Standard finishes and materials (1.00x cost multiplier) */
  Standard = 'standard',

  /** Premium: High-quality finishes (1.35x cost multiplier) */
  Premium = 'premium',

  /** Luxury: Premium finishes and high-end materials (1.70x cost multiplier) */
  Luxury = 'luxury',
}

/**
 * RateType
 *
 * Classification of rate components in the cost build-up.
 * Enables granular tracking and separate manipulation of labour, material, and plant costs.
 *
 * Seed data: labour, material, plant, composite
 * Database constraint: CHECK (code ~ '^[a-z_]{3,20}$')
 */
export enum RateType {
  /** Labour cost (wages, entitlements, supervision) */
  Labour = 'labour',

  /** Material cost (purchase price + waste factors) */
  Material = 'material',

  /** Plant and equipment hire (machinery, tools, equipment) */
  Plant = 'plant',

  /** Composite rate (pre-built rates combining labour + material + plant) */
  Composite = 'composite',
}

/**
 * ConfidenceLevel
 *
 * Data confidence rating for rates and estimates.
 * Used in risk assessment and rate quality scoring.
 *
 * Seed data rank values: low=1, medium=2, high=3
 * Confidence ranges: low=±15-20%, medium=±10%, high=±5%
 */
export enum ConfidenceLevel {
  /** Low confidence: ±15-20%, limited data sources, wide market variation */
  Low = 'low',

  /** Medium confidence: ±10%, multiple data sources, reasonable consistency */
  Medium = 'medium',

  /** High confidence: ±5%, extensive validated data, narrow market variation */
  High = 'high',
}

/**
 * RateStatus
 *
 * Workflow status for rates in approval and archival pipelines.
 * Tracks the lifecycle from draft through approval to archival.
 *
 * Seed data progression: draft → reviewed → approved → archived
 * Database constraint: CHECK (code ~ '^[a-z_]{3,20}$')
 */
export enum RateStatus {
  /** Draft: Rate under development and not yet reviewed */
  Draft = 'draft',

  /** Reviewed: Rate reviewed by senior estimator, pending final approval */
  Reviewed = 'reviewed',

  /** Approved: Rate approved and active in the database */
  Approved = 'approved',

  /** Archived: Rate archived and no longer used in new estimates */
  Archived = 'archived',
}

/**
 * ConditionFactorCategory
 *
 * Categories of condition factors that affect productivity and cost build-up.
 * Used to classify productivity modifiers and adjustment codes.
 *
 * These factors adjust rates based on site and project conditions beyond
 * standard assumptions.
 */
export enum ConditionFactorCategory {
  /** Location-based factors (accessibility, distance from suppliers) */
  Location = 'location',

  /** Height-related factors (scaffolding, elevated work platforms) */
  Height = 'height',

  /** Weather and seasonal factors (exposure, seasonal delays) */
  Weather = 'weather',

  /** Complexity factors (skill requirements, technical difficulty) */
  Complexity = 'complexity',

  /** Quantity-based factors (economy of scale, bulk discounts) */
  Quantity = 'quantity',
}

/**
 * Enum type guards and helpers
 */

/**
 * Type guard for UnitCategory
 */
export function isUnitCategory(value: unknown): value is UnitCategory {
  return Object.values(UnitCategory).includes(value as UnitCategory);
}

/**
 * Type guard for RegionState
 */
export function isRegionState(value: unknown): value is RegionState {
  return Object.values(RegionState).includes(value as RegionState);
}

/**
 * Type guard for BuildingCategory
 */
export function isBuildingCategory(value: unknown): value is BuildingCategory {
  return Object.values(BuildingCategory).includes(value as BuildingCategory);
}

/**
 * Type guard for Complexity
 */
export function isComplexity(value: unknown): value is Complexity {
  return Object.values(Complexity).includes(value as Complexity);
}

/**
 * Type guard for SpecLevel
 */
export function isSpecLevel(value: unknown): value is SpecLevel {
  return Object.values(SpecLevel).includes(value as SpecLevel);
}

/**
 * Type guard for RateType
 */
export function isRateType(value: unknown): value is RateType {
  return Object.values(RateType).includes(value as RateType);
}

/**
 * Type guard for ConfidenceLevel
 */
export function isConfidenceLevel(value: unknown): value is ConfidenceLevel {
  return Object.values(ConfidenceLevel).includes(value as ConfidenceLevel);
}

/**
 * Type guard for RateStatus
 */
export function isRateStatus(value: unknown): value is RateStatus {
  return Object.values(RateStatus).includes(value as RateStatus);
}

/**
 * Type guard for ConditionFactorCategory
 */
export function isConditionFactorCategory(
  value: unknown
): value is ConditionFactorCategory {
  return Object.values(ConditionFactorCategory).includes(
    value as ConditionFactorCategory
  );
}
