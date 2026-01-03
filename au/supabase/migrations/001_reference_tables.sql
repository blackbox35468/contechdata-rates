-- Migration: 001_reference_tables.sql
-- Description: Create reference tables for Australian construction rates database
-- Created: 2026-01-03
-- Author: ContechData Team

-- ============================================================================
-- UNITS TABLE
-- ============================================================================
-- Stores measurement units used in construction estimates
-- Supports both SI (metric) and imperial units for legacy compatibility
CREATE TABLE IF NOT EXISTS units (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  symbol VARCHAR(20) NOT NULL,
  category VARCHAR(50) NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT units_code_valid CHECK (code ~ '^[a-z0-9\-]{1,20}$'),
  CONSTRAINT units_category_valid CHECK (category IN ('length', 'area', 'volume', 'weight', 'time', 'count', 'provisional'))
);

COMMENT ON TABLE units IS 'Measurement units used in construction estimates (SI metric, imperial, and provisional units)';
COMMENT ON COLUMN units.code IS 'Unique code identifier (e.g., m2, m3, hr, ls)';
COMMENT ON COLUMN units.category IS 'Unit classification (length, area, volume, weight, time, count, provisional)';

-- ============================================================================
-- REGIONS TABLE
-- ============================================================================
-- Australian regions with geographical pricing factors
-- Supports 16 regions across all states and territories
CREATE TABLE IF NOT EXISTS regions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  state VARCHAR(3) NOT NULL,
  factor DECIMAL(4, 2) NOT NULL DEFAULT 1.00,
  is_baseline BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT regions_code_valid CHECK (code ~ '^[A-Z_]{3,20}$'),
  CONSTRAINT regions_state_valid CHECK (state IN ('NSW', 'VIC', 'QLD', 'WA', 'SA', 'TAS', 'ACT', 'NT')),
  CONSTRAINT regions_factor_valid CHECK (factor > 0 AND factor <= 2.0),
  CONSTRAINT regions_only_one_baseline CHECK (NOT (is_baseline AND factor != 1.00))
);

COMMENT ON TABLE regions IS 'Australian regions with geographical pricing adjustment factors (Sydney Metro baseline = 1.00)';
COMMENT ON COLUMN regions.code IS 'Region code (e.g., SYD_METRO, MEL_OUTER, NSW_REGIONAL)';
COMMENT ON COLUMN regions.factor IS 'Price adjustment factor relative to baseline (SYD_METRO = 1.00)';
COMMENT ON COLUMN regions.is_baseline IS 'Marks Sydney Metro as baseline region for rate comparisons';

-- ============================================================================
-- BUILDING_TYPES TABLE
-- ============================================================================
-- Construction project types with complexity ratings
-- Supports residential, commercial, industrial, institutional, health, civic
CREATE TABLE IF NOT EXISTS building_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(30) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(30) NOT NULL,
  complexity VARCHAR(20) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT building_types_code_valid CHECK (code ~ '^[A-Z_]{4,30}$'),
  CONSTRAINT building_types_category_valid CHECK (category IN ('residential', 'commercial', 'industrial', 'institutional', 'health', 'civic')),
  CONSTRAINT building_types_complexity_valid CHECK (complexity IN ('low', 'standard', 'medium', 'high', 'very_high'))
);

COMMENT ON TABLE building_types IS 'Building project types with complexity ratings for estimating methodology selection';
COMMENT ON COLUMN building_types.code IS 'Unique project type code (e.g., RES_HOUSE, COM_OFFICE_HIGH, IND_WAREHOUSE)';
COMMENT ON COLUMN building_types.complexity IS 'Project complexity (low→very_high) affecting methodology and contingency factors';

-- ============================================================================
-- SPEC_LEVELS TABLE
-- ============================================================================
-- Specification levels for finishes and quality standards
-- Used to differentiate cost profiles within same building type
CREATE TABLE IF NOT EXISTS spec_levels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  rank INTEGER NOT NULL UNIQUE,
  cost_multiplier DECIMAL(3, 2) NOT NULL DEFAULT 1.00,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT spec_levels_code_valid CHECK (code ~ '^[a-z_]{3,20}$'),
  CONSTRAINT spec_levels_rank_valid CHECK (rank >= 1 AND rank <= 4),
  CONSTRAINT spec_levels_cost_multiplier_valid CHECK (cost_multiplier > 0 AND cost_multiplier <= 2.5)
);

COMMENT ON TABLE spec_levels IS 'Specification levels (basic, standard, premium, luxury) affecting material and finish costs';
COMMENT ON COLUMN spec_levels.rank IS 'Ordering (1=basic, 4=luxury) for comparative analysis';
COMMENT ON COLUMN spec_levels.cost_multiplier IS 'Cost factor relative to standard specification (standard = 1.00)';

-- ============================================================================
-- RATE_TYPES TABLE
-- ============================================================================
-- Classification of rate components in the cost build-up
-- Enables granular tracking of labour, material, plant, composite costs
CREATE TABLE IF NOT EXISTS rate_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  is_composite BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT rate_types_code_valid CHECK (code ~ '^[a-z_]{3,20}$')
);

COMMENT ON TABLE rate_types IS 'Rate component classification (labour, material, plant, composite) for cost tracking';
COMMENT ON COLUMN rate_types.code IS 'Unique rate type code (labour, material, plant, composite)';
COMMENT ON COLUMN rate_types.is_composite IS 'Flag: TRUE for composite rates (combines labour+material+plant)';

-- ============================================================================
-- CONFIDENCE_LEVELS TABLE
-- ============================================================================
-- Data confidence rating for rates and estimates
-- Used in risk assessment and rate quality scoring
CREATE TABLE IF NOT EXISTS confidence_levels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  rank INTEGER NOT NULL UNIQUE,
  percentage_range VARCHAR(20),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT confidence_levels_code_valid CHECK (code ~ '^[a-z_]{3,20}$'),
  CONSTRAINT confidence_levels_rank_valid CHECK (rank >= 1 AND rank <= 3)
);

COMMENT ON TABLE confidence_levels IS 'Data confidence ratings (high, medium, low) for rates and estimate reliability assessment';
COMMENT ON COLUMN confidence_levels.rank IS 'Confidence ordering (1=low, 3=high)';
COMMENT ON COLUMN confidence_levels.percentage_range IS 'Estimated accuracy range (e.g., ±5%, ±10%, ±15%)';

-- ============================================================================
-- RATE_STATUSES TABLE
-- ============================================================================
-- Workflow status for rates in approval and archival pipelines
-- Tracks rate lifecycle from draft through approval to archival
CREATE TABLE IF NOT EXISTS rate_statuses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT rate_statuses_code_valid CHECK (code ~ '^[a-z_]{3,20}$')
);

COMMENT ON TABLE rate_statuses IS 'Rate lifecycle status (draft, reviewed, approved, archived) for approval workflow tracking';
COMMENT ON COLUMN rate_statuses.code IS 'Unique status code (draft, reviewed, approved, archived)';
COMMENT ON COLUMN rate_statuses.is_active IS 'Flag: FALSE for archived rates to enable filtering in queries';

-- ============================================================================
-- INDEXES
-- ============================================================================
CREATE INDEX idx_units_category ON units(category);
CREATE INDEX idx_regions_state ON regions(state);
CREATE INDEX idx_regions_baseline ON regions(is_baseline);
CREATE INDEX idx_building_types_category ON building_types(category);
CREATE INDEX idx_building_types_complexity ON building_types(complexity);
CREATE INDEX idx_spec_levels_rank ON spec_levels(rank);
CREATE INDEX idx_confidence_levels_rank ON confidence_levels(rank);
CREATE INDEX idx_rate_statuses_active ON rate_statuses(is_active);

-- ============================================================================
-- SEED DATA - UNITS
-- ============================================================================
INSERT INTO units (code, name, symbol, category, description) VALUES
-- Length units
('m', 'Linear metre', 'm', 'length', 'Unit of length used for linear measurements'),
('mm', 'Millimetre', 'mm', 'length', 'Sub-unit of length for precise measurements'),
('cm', 'Centimetre', 'cm', 'length', 'Sub-unit of length'),
('km', 'Kilometre', 'km', 'length', 'Unit of length for longer distances'),
('run', 'Running metre', 'rm', 'length', 'Linear metre, typically for materials sold by the metre'),
('lin', 'Linear', 'lin', 'length', 'Linear measurement unit'),
('lft', 'Linear foot', 'ft', 'length', 'Imperial unit of length (sometimes used in Australia for legacy estimates)'),

-- Area units
('m2', 'Square metre', 'm²', 'area', 'Unit of area used for flooring, walls, roofing, and surface coverage'),
('ha', 'Hectare', 'ha', 'area', 'Unit of area for land measurement (10,000 m²)'),
('sqft', 'Square foot', 'ft²', 'area', 'Imperial unit of area (sometimes used in Australia for legacy estimates)'),
('sqm', 'Square metre (alternate)', 'sqm', 'area', 'Square metre expressed as combined notation'),

-- Volume units
('m3', 'Cubic metre', 'm³', 'volume', 'Unit of volume used for concrete, excavation, and material quantities'),
('l', 'Litre', 'L', 'volume', 'Unit of liquid or fluid volume'),
('ml', 'Millilitre', 'mL', 'volume', 'Sub-unit of liquid volume'),
('cbft', 'Cubic foot', 'ft³', 'volume', 'Imperial unit of volume'),
('cum', 'Cubic metre (alternate)', 'cum', 'volume', 'Cubic metre expressed as combined notation'),

-- Weight units
('t', 'Tonne', 't', 'weight', 'Metric ton (1000 kg) for material quantities'),
('kg', 'Kilogram', 'kg', 'weight', 'Unit of mass or weight'),
('g', 'Gram', 'g', 'weight', 'Sub-unit of weight'),
('tonne', 'Tonne (alternate)', 'tonne', 'weight', 'Metric ton expressed as full word'),

-- Time units
('hr', 'Hour', 'hr', 'time', 'Unit of time for labour and equipment rental'),
('day', 'Day', 'day', 'time', 'Unit of time (8 hours or 24 hours depending on context)'),
('wk', 'Week', 'wk', 'time', 'Unit of time (7 days)'),
('mth', 'Month', 'mth', 'time', 'Unit of time (approximately 30 days)'),
('yr', 'Year', 'yr', 'time', 'Unit of time (12 months)'),
('hr-labour', 'Labour hour', 'hr', 'time', 'Hour of labour work'),
('hr-equipment', 'Equipment hour', 'hr', 'time', 'Hour of equipment hire or operation'),

-- Count units
('nr', 'Number', 'nr', 'count', 'Unit count for discrete items or components'),
('item', 'Item', 'item', 'count', 'Single item or unit count'),
('each', 'Each', 'ea', 'count', 'Per each item'),
('pair', 'Pair', 'pr', 'count', 'Two items together'),
('set', 'Set', 'set', 'count', 'Collection of items'),

-- Provisional units
('ls', 'Lump sum', 'LS', 'provisional', 'Fixed price for complete work item or component'),
('prov', 'Provisional sum', 'PS', 'provisional', 'Allowance for work where final quantity is uncertain'),
('cont', 'Contingency', 'CONT', 'provisional', 'Allowance for unforeseen costs or variations'),
('pc', 'Prime cost', 'PC', 'provisional', 'Allowance for materials to be selected later'),
('allowance', 'Allowance', 'ALW', 'provisional', 'General allowance for undefined work'),
('fixed', 'Fixed rate', 'FIX', 'provisional', 'Fixed rate regardless of quantity')
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- SEED DATA - REGIONS
-- ============================================================================
INSERT INTO regions (code, name, state, factor, is_baseline) VALUES
('SYD_METRO', 'Sydney Metro', 'NSW', 1.00, TRUE),
('SYD_OUTER', 'Sydney Outer', 'NSW', 1.05, FALSE),
('NSW_REGIONAL', 'Regional NSW', 'NSW', 1.10, FALSE),
('MEL_METRO', 'Melbourne Metro', 'VIC', 0.95, FALSE),
('MEL_OUTER', 'Melbourne Outer', 'VIC', 1.00, FALSE),
('VIC_REGIONAL', 'Regional Victoria', 'VIC', 1.08, FALSE),
('BNE_METRO', 'Brisbane Metro', 'QLD', 0.92, FALSE),
('QLD_REGIONAL', 'Regional Queensland', 'QLD', 1.12, FALSE),
('PER_METRO', 'Perth Metro', 'WA', 1.15, FALSE),
('WA_REGIONAL', 'Regional WA', 'WA', 1.25, FALSE),
('ADL_METRO', 'Adelaide Metro', 'SA', 0.90, FALSE),
('SA_REGIONAL', 'Regional SA', 'SA', 1.05, FALSE),
('HOB_METRO', 'Hobart Metro', 'TAS', 1.08, FALSE),
('TAS_REGIONAL', 'Regional Tasmania', 'TAS', 1.15, FALSE),
('ACT', 'Australian Capital Territory', 'ACT', 1.02, FALSE),
('NT', 'Northern Territory', 'NT', 1.30, FALSE)
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- SEED DATA - BUILDING_TYPES
-- ============================================================================
INSERT INTO building_types (code, name, category, complexity) VALUES
-- Residential
('RES_HOUSE', 'Detached House', 'residential', 'standard'),
('RES_TOWNHOUSE', 'Townhouse', 'residential', 'standard'),
('RES_APARTMENT_LOW', 'Low-rise Apartment (1-3 storeys)', 'residential', 'medium'),
('RES_APARTMENT_MID', 'Mid-rise Apartment (4-8 storeys)', 'residential', 'high'),
('RES_APARTMENT_HIGH', 'High-rise Apartment (9+ storeys)', 'residential', 'very_high'),

-- Commercial
('COM_OFFICE_LOW', 'Low-rise Office', 'commercial', 'medium'),
('COM_OFFICE_HIGH', 'High-rise Office', 'commercial', 'very_high'),
('COM_RETAIL', 'Retail/Shopping', 'commercial', 'medium'),
('COM_HOTEL', 'Hotel', 'commercial', 'high'),

-- Industrial
('IND_WAREHOUSE', 'Warehouse', 'industrial', 'low'),
('IND_FACTORY', 'Factory/Manufacturing', 'industrial', 'medium'),

-- Institutional
('EDU_SCHOOL', 'School', 'institutional', 'medium'),
('EDU_UNIVERSITY', 'University/TAFE', 'institutional', 'high'),

-- Health
('HEALTH_CLINIC', 'Medical Clinic', 'health', 'medium'),
('HEALTH_HOSPITAL', 'Hospital', 'health', 'very_high'),

-- Civic
('CIVIC_COMMUNITY', 'Community Centre', 'civic', 'medium')
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- SEED DATA - SPEC_LEVELS
-- ============================================================================
INSERT INTO spec_levels (code, name, description, rank, cost_multiplier) VALUES
('basic', 'Basic', 'Economy finishes and materials for cost-sensitive projects', 1, 0.85),
('standard', 'Standard', 'Standard finishes and materials for typical projects', 2, 1.00),
('premium', 'Premium', 'High-quality finishes and materials for upmarket projects', 3, 1.35),
('luxury', 'Luxury', 'Premium finishes and high-end materials for luxury projects', 4, 1.70)
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- SEED DATA - RATE_TYPES
-- ============================================================================
INSERT INTO rate_types (code, name, description, is_composite) VALUES
('labour', 'Labour', 'Direct labour cost (wages, entitlements, supervision)', FALSE),
('material', 'Material', 'Materials and supply cost (purchase price + waste factors)', FALSE),
('plant', 'Plant', 'Plant and equipment hire (machinery, tools, equipment costs)', FALSE),
('composite', 'Composite', 'Pre-built rates combining labour + material + plant', TRUE)
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- SEED DATA - CONFIDENCE_LEVELS
-- ============================================================================
INSERT INTO confidence_levels (code, name, description, rank, percentage_range) VALUES
('low', 'Low', 'Limited data sources, wide variation in market rates, estimates ±15-20%', 1, '±15-20%'),
('medium', 'Medium', 'Multiple data sources, reasonable market consistency, estimates ±10%', 2, '±10%'),
('high', 'High', 'Extensive validated data, narrow market variation, estimates ±5%', 3, '±5%')
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- SEED DATA - RATE_STATUSES
-- ============================================================================
INSERT INTO rate_statuses (code, name, description, is_active) VALUES
('draft', 'Draft', 'Rate under development and not yet reviewed', TRUE),
('reviewed', 'Reviewed', 'Rate reviewed by senior estimator, pending final approval', TRUE),
('approved', 'Approved', 'Rate approved and active in the database', TRUE),
('archived', 'Archived', 'Rate archived and no longer used in new estimates', FALSE)
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- UPDATE TRIGGERS for updated_at timestamps
-- ============================================================================
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER units_update_trigger
  BEFORE UPDATE ON units
  FOR EACH ROW
  EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER regions_update_trigger
  BEFORE UPDATE ON regions
  FOR EACH ROW
  EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER building_types_update_trigger
  BEFORE UPDATE ON building_types
  FOR EACH ROW
  EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER spec_levels_update_trigger
  BEFORE UPDATE ON spec_levels
  FOR EACH ROW
  EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER rate_types_update_trigger
  BEFORE UPDATE ON rate_types
  FOR EACH ROW
  EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER confidence_levels_update_trigger
  BEFORE UPDATE ON confidence_levels
  FOR EACH ROW
  EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER rate_statuses_update_trigger
  BEFORE UPDATE ON rate_statuses
  FOR EACH ROW
  EXECUTE FUNCTION update_timestamp();
