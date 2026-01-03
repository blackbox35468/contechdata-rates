-- Migration: Create resource tables for labour, gangs, and condition factors
-- Created: 2026-01-03
-- Purpose: Core resource rate tables for estimate composition and pricing

-- ============================================================================
-- 1. LABOUR_RESOURCES TABLE
-- ============================================================================
-- Stores trade labour rates with base and fully-loaded costs
-- Uses natural key (code) as primary key for consistency with gangs/factors

CREATE TABLE IF NOT EXISTS labour_resources (
  code TEXT PRIMARY KEY,
  trade TEXT NOT NULL,
  base_rate DECIMAL(10, 2) NOT NULL,
  oncost_percent DECIMAL(5, 2) NOT NULL,
  total_rate DECIMAL(10, 2) NOT NULL,
  unit TEXT NOT NULL DEFAULT 'hr',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE labour_resources IS 'Trade labour rates in AUD per hour. Base rate + oncosts (superannuation, workers comp, etc.)';
COMMENT ON COLUMN labour_resources.code IS 'Natural key: LAB_AU_[TRADE_CODE] (e.g., LAB_AU_BRICK)';
COMMENT ON COLUMN labour_resources.trade IS 'Trade name (e.g., Bricklayer)';
COMMENT ON COLUMN labour_resources.base_rate IS 'Hourly rate before oncosts, in AUD';
COMMENT ON COLUMN labour_resources.oncost_percent IS 'Percentage of base rate for oncosts (super, workers comp, etc.)';
COMMENT ON COLUMN labour_resources.total_rate IS 'Final rate = base_rate + (base_rate × oncost_percent / 100)';
COMMENT ON COLUMN labour_resources.unit IS 'Unit of measurement (hr, day, etc.)';

-- ============================================================================
-- 2. GANGS TABLE
-- ============================================================================
-- Stores gang templates with combined rates
-- Each gang has a specific tradesperson-to-labourer ratio

CREATE TABLE IF NOT EXISTS gangs (
  code TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  combined_rate DECIMAL(10, 2) NOT NULL,
  unit TEXT NOT NULL DEFAULT 'hr',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE gangs IS 'Gang templates combining multiple labour resources with pre-calculated combined rates';
COMMENT ON COLUMN gangs.code IS 'Natural key: GANG_AU_[COMPOSITION] (e.g., GANG_AU_GENERAL_1_0)';
COMMENT ON COLUMN gangs.name IS 'Human-readable gang description (e.g., "1 Tradesman + 1 Labourer")';
COMMENT ON COLUMN gangs.combined_rate IS 'Combined hourly rate for entire gang, in AUD';
COMMENT ON COLUMN gangs.unit IS 'Unit of measurement (hr, day, etc.)';

-- ============================================================================
-- 3. GANG_COMPOSITIONS TABLE
-- ============================================================================
-- Defines the member composition of each gang
-- Foreign key to labour_resources for role references

CREATE TABLE IF NOT EXISTS gang_compositions (
  id SERIAL PRIMARY KEY,
  gang_code TEXT NOT NULL REFERENCES gangs(code) ON DELETE CASCADE,
  role TEXT NOT NULL,
  count DECIMAL(5, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE gang_compositions IS 'Member composition of gangs (e.g., gang GANG_AU_GENERAL_1_1 has 1x tradesperson + 1x labourer)';
COMMENT ON COLUMN gang_compositions.gang_code IS 'Foreign key to gangs table';
COMMENT ON COLUMN gang_compositions.role IS 'Role in gang: "tradesperson" or "labourer"';
COMMENT ON COLUMN gang_compositions.count IS 'Number of workers in this role (supports fractional staff)';

CREATE UNIQUE INDEX idx_gang_compositions_unique
  ON gang_compositions(gang_code, role);

-- ============================================================================
-- 4. CONDITION_FACTORS TABLE
-- ============================================================================
-- Stores productivity condition factors for labour/plant adjustments
-- Categories: location, height, weather, complexity, quantity

CREATE TYPE condition_factor_category AS ENUM ('location', 'height', 'weather', 'complexity', 'quantity');

CREATE TABLE IF NOT EXISTS condition_factors (
  code TEXT PRIMARY KEY,
  category condition_factor_category NOT NULL,
  name TEXT NOT NULL,
  factor DECIMAL(5, 3) NOT NULL,
  applies_to TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT check_factor_positive CHECK (factor > 0)
);

COMMENT ON TABLE condition_factors IS 'Productivity adjustment factors for labour and plant (e.g., height, access difficulty, weather exposure)';
COMMENT ON COLUMN condition_factors.code IS 'Natural key: CF_[CATEGORY]_[NAME] (e.g., CF_LOCATION_RESTRICTED_ACCESS)';
COMMENT ON COLUMN condition_factors.category IS 'Factor category: location | height | weather | complexity | quantity';
COMMENT ON COLUMN condition_factors.name IS 'Factor name (e.g., "Difficult access")';
COMMENT ON COLUMN condition_factors.factor IS 'Multiplier to apply to rates (e.g., 1.2 = 20% productivity reduction)';
COMMENT ON COLUMN condition_factors.applies_to IS 'Comma-separated list of resource types (e.g., "Labour, Plant" or "All")';
COMMENT ON COLUMN condition_factors.description IS 'Human-readable description of the factor';

CREATE INDEX idx_condition_factors_category ON condition_factors(category);

-- ============================================================================
-- 5. MATERIALS TABLE
-- ============================================================================
-- Placeholder for future material items
-- Will store unit rates and waste factors

CREATE TABLE IF NOT EXISTS materials (
  code TEXT PRIMARY KEY,
  description TEXT NOT NULL,
  unit TEXT NOT NULL,
  unit_rate DECIMAL(10, 2),
  waste_factor DECIMAL(5, 3) DEFAULT 1.0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE materials IS 'Material items and unit rates (placeholder for future feature)';
COMMENT ON COLUMN materials.code IS 'Material code (e.g., MAT_AU_BRICK_CLAY_100)';
COMMENT ON COLUMN materials.unit_rate IS 'Cost per unit in AUD';
COMMENT ON COLUMN materials.waste_factor IS 'Material waste multiplier (e.g., 1.07 for 7% waste)';

-- ============================================================================
-- 6. PLANT TABLE
-- ============================================================================
-- Placeholder for future plant/equipment items
-- Will store hire rates and productivity factors

CREATE TABLE IF NOT EXISTS plant (
  code TEXT PRIMARY KEY,
  description TEXT NOT NULL,
  unit TEXT NOT NULL,
  rate DECIMAL(10, 2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE plant IS 'Plant and equipment items for hire rates (placeholder for future feature)';
COMMENT ON COLUMN plant.code IS 'Equipment code (e.g., PLANT_AU_SCAFFOLDING_FRAME)';
COMMENT ON COLUMN plant.rate IS 'Hire cost per unit in AUD';

-- ============================================================================
-- SEED DATA: Labour Resources
-- ============================================================================

INSERT INTO labour_resources (code, trade, base_rate, oncost_percent, total_rate, unit) VALUES
('LAB_AU_BRICK', 'Bricklayer', 65.00, 20, 78.00, 'hr'),
('LAB_AU_CARP', 'Carpenter', 62.00, 20, 74.40, 'hr'),
('LAB_AU_PLAST', 'Plasterer', 60.00, 20, 72.00, 'hr'),
('LAB_AU_TILER', 'Tiler', 58.00, 20, 69.60, 'hr'),
('LAB_AU_PLUMB', 'Plumber/Drainlayer', 68.00, 20, 81.60, 'hr'),
('LAB_AU_ELECT', 'Electrician', 70.00, 20, 84.00, 'hr'),
('LAB_AU_PAINT', 'Painter', 55.00, 20, 66.00, 'hr'),
('LAB_AU_ROOF', 'Roofer', 60.00, 20, 72.00, 'hr'),
('LAB_AU_LAB', 'Labourer', 45.00, 20, 54.00, 'hr'),
('LAB_AU_SEMI', 'Semi-skilled', 50.00, 20, 60.00, 'hr')
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- SEED DATA: Gangs
-- ============================================================================

INSERT INTO gangs (code, name, combined_rate, unit) VALUES
('GANG_AU_GENERAL_1_0', '1 Tradesman only', 65.00, 'hr'),
('GANG_AU_GENERAL_1_0.5', '1 Tradesman + half labourer', 82.50, 'hr'),
('GANG_AU_GENERAL_1_1', '1 Tradesman + 1 labourer', 95.00, 'hr'),
('GANG_AU_GENERAL_2_1', '2 Tradesmen + 1 labourer', 165.00, 'hr'),
('GANG_AU_GENERAL_0_1', '1 Labourer only', 55.00, 'hr'),
('GANG_AU_GENERAL_0_2', '2 Labourers', 110.00, 'hr')
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- SEED DATA: Gang Compositions
-- ============================================================================

INSERT INTO gang_compositions (gang_code, role, count) VALUES
('GANG_AU_GENERAL_1_0', 'tradesperson', 1),
('GANG_AU_GENERAL_1_0', 'labourer', 0),
('GANG_AU_GENERAL_1_0.5', 'tradesperson', 1),
('GANG_AU_GENERAL_1_0.5', 'labourer', 0.5),
('GANG_AU_GENERAL_1_1', 'tradesperson', 1),
('GANG_AU_GENERAL_1_1', 'labourer', 1),
('GANG_AU_GENERAL_2_1', 'tradesperson', 2),
('GANG_AU_GENERAL_2_1', 'labourer', 1),
('GANG_AU_GENERAL_0_1', 'tradesperson', 0),
('GANG_AU_GENERAL_0_1', 'labourer', 1),
('GANG_AU_GENERAL_0_2', 'tradesperson', 0),
('GANG_AU_GENERAL_0_2', 'labourer', 2)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- SEED DATA: Condition Factors
-- ============================================================================

-- Location factors (3 levels)
INSERT INTO condition_factors (code, category, name, factor, applies_to, description) VALUES
('CF_LOCATION_NORMAL_ACCESS', 'location', 'Normal access', 1.00, 'All', 'Normal access - Factor: 1.0'),
('CF_LOCATION_RESTRICTED_ACCESS', 'location', 'Restricted access', 1.10, 'All', 'Restricted access - Factor: 1.1'),
('CF_LOCATION_DIFFICULT_ACCESS', 'location', 'Difficult access', 1.20, 'All', 'Difficult access - Factor: 1.2'),

-- Height factors (4 levels)
('CF_HEIGHT_LEQ_35M_GROUND_LEVEL', 'height', '≤3.5m (ground level)', 1.00, 'Labour, Plant', '≤3.5m (ground level) - Factor: 1.0'),
('CF_HEIGHT_35M_70M', 'height', '3.5m - 7.0m', 1.10, 'Labour, Plant', '3.5m - 7.0m - Factor: 1.1'),
('CF_HEIGHT_70M_105M', 'height', '7.0m - 10.5m', 1.20, 'Labour, Plant', '7.0m - 10.5m - Factor: 1.2'),
('CF_HEIGHT_GT_105M', 'height', '>10.5m', 1.35, 'Labour, Plant', '>10.5m - Factor: 1.35'),

-- Weather factors (3 levels)
('CF_WEATHER_INTERNAL_WORK', 'weather', 'Internal work', 1.00, 'Labour', 'Internal work - Factor: 1.0'),
('CF_WEATHER_EXTERNAL_SHELTERED', 'weather', 'External - sheltered', 1.03, 'Labour', 'External - sheltered - Factor: 1.03'),
('CF_WEATHER_EXTERNAL_EXPOSED', 'weather', 'External - exposed', 1.08, 'Labour', 'External - exposed - Factor: 1.08'),

-- Complexity factors (3 levels)
('CF_COMPLEXITY_STRAIGHTFORWARD', 'complexity', 'Straightforward', 1.00, 'Labour', 'Straightforward - Factor: 1.0'),
('CF_COMPLEXITY_MODERATE_DETAIL', 'complexity', 'Moderate detail', 1.10, 'Labour', 'Moderate detail - Factor: 1.1'),
('CF_COMPLEXITY_COMPLEX_INTRICATE', 'complexity', 'Complex/intricate', 1.25, 'Labour', 'Complex/intricate - Factor: 1.25'),

-- Quantity factors (3 levels)
('CF_QUANTITY_SMALL_QTY_LT_25PCT', 'quantity', 'Small qty (<25% of norm)', 1.15, 'Labour', 'Small qty (<25% of norm) - Factor: 1.15'),
('CF_QUANTITY_NORMAL_QUANTITY', 'quantity', 'Normal quantity', 1.00, 'Labour', 'Normal quantity - Factor: 1.0'),
('CF_QUANTITY_LARGE_QTY_GT_200PCT', 'quantity', 'Large qty (>200% of norm)', 0.95, 'Labour', 'Large qty (>200% of norm) - Factor: 0.95')
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- Enable Row Level Security (optional, for future)
-- ============================================================================
-- Uncomment when RLS policies are defined
-- ALTER TABLE labour_resources ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE gangs ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE gang_compositions ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE condition_factors ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE materials ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE plant ENABLE ROW LEVEL SECURITY;
