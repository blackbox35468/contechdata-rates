-- Migration: 005_adjustment_tables.sql
-- Purpose: Create adjustment tables for regional factors, escalation indices, and GST rates
-- Created: 2026-01-03
-- Requires: 004_regions_table.sql (regions table must exist first)

-- Table 1: regional_factors
-- Regional pricing adjustments indexed by region_code with validity date ranges
-- Used to apply regional cost multipliers to base rates
COMMENT ON TABLE regional_factors IS 'Regional pricing adjustment factors with effective date ranges. Used to apply regional cost multipliers to base rates during estimate calculations.';

CREATE TABLE IF NOT EXISTS regional_factors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    region_code VARCHAR(50) NOT NULL REFERENCES regions(code) ON DELETE RESTRICT,
    factor NUMERIC(6,4) NOT NULL CHECK (factor > 0),
    effective_from DATE NOT NULL,
    effective_to DATE,
    source VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Date range validity constraint: effective_to must be after effective_from (if set)
    CONSTRAINT valid_date_range CHECK (
        effective_to IS NULL OR effective_to > effective_from
    )
);

COMMENT ON COLUMN regional_factors.id IS 'Unique identifier for this regional factor record';
COMMENT ON COLUMN regional_factors.region_code IS 'Foreign key reference to regions table';
COMMENT ON COLUMN regional_factors.factor IS 'Pricing multiplier (e.g., 1.05 = +5% cost adjustment)';
COMMENT ON COLUMN regional_factors.effective_from IS 'Date from which this factor applies';
COMMENT ON COLUMN regional_factors.effective_to IS 'Date until which this factor applies (NULL = current/indefinite)';
COMMENT ON COLUMN regional_factors.source IS 'Source of the factor (e.g., "ABS Q4 2025", "Market Analysis")';
COMMENT ON COLUMN regional_factors.notes IS 'Additional notes about this factor';

-- Indexes for efficient range queries on effective dates
CREATE INDEX IF NOT EXISTS idx_regional_factors_region_code ON regional_factors(region_code);
CREATE INDEX IF NOT EXISTS idx_regional_factors_effective_dates ON regional_factors(effective_from, effective_to);
CREATE INDEX IF NOT EXISTS idx_regional_factors_active ON regional_factors(region_code, effective_from, effective_to)
    WHERE effective_to IS NULL OR effective_to >= CURRENT_DATE;

-- Table 2: escalation_indices
-- Construction cost escalation tracking with quarterly updates
-- Used for adjusting historical cost data to current pricing
COMMENT ON TABLE escalation_indices IS 'Construction cost escalation indices by quarter and year. Used to adjust costs from historical base year to current pricing.';

CREATE TABLE IF NOT EXISTS escalation_indices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    year INTEGER NOT NULL CHECK (year >= 2000 AND year <= 2100),
    quarter INTEGER NOT NULL CHECK (quarter >= 1 AND quarter <= 4),
    index_value NUMERIC(8,4) NOT NULL CHECK (index_value > 0),
    base_year INTEGER NOT NULL CHECK (base_year >= 2000 AND base_year <= 2100),
    source VARCHAR(255) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Unique constraint: only one entry per year/quarter combination
    CONSTRAINT unique_year_quarter UNIQUE (year, quarter)
);

COMMENT ON COLUMN escalation_indices.id IS 'Unique identifier for this escalation index record';
COMMENT ON COLUMN escalation_indices.year IS 'Calendar year of the index';
COMMENT ON COLUMN escalation_indices.quarter IS 'Quarter (1-4) of the index';
COMMENT ON COLUMN escalation_indices.index_value IS 'Index value relative to base year (e.g., 105.2 = +5.2% relative to base)';
COMMENT ON COLUMN escalation_indices.base_year IS 'Year used as index base (e.g., 2020 = 100)';
COMMENT ON COLUMN escalation_indices.source IS 'Source of the index (e.g., "ABS Construction Price Index", "BLS")';
COMMENT ON COLUMN escalation_indices.notes IS 'Additional notes about this index value';

-- Indexes for efficient temporal queries
CREATE INDEX IF NOT EXISTS idx_escalation_indices_year_quarter ON escalation_indices(year, quarter);
CREATE INDEX IF NOT EXISTS idx_escalation_indices_year ON escalation_indices(year);
CREATE INDEX IF NOT EXISTS idx_escalation_indices_base_year ON escalation_indices(base_year);

-- Table 3: gst_rates
-- GST rates by region with validity date ranges
-- Australia currently applies a uniform 10% GST, but stored as configurable per region for future flexibility
COMMENT ON TABLE gst_rates IS 'GST (Goods and Services Tax) rates by region with effective date ranges. Typically uniform at 10% nationwide but stored per region for flexibility.';

CREATE TABLE IF NOT EXISTS gst_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    region_code VARCHAR(50) NOT NULL REFERENCES regions(code) ON DELETE RESTRICT,
    rate NUMERIC(5,4) NOT NULL CHECK (rate >= 0 AND rate <= 1),
    effective_from DATE NOT NULL,
    effective_to DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Date range validity constraint: effective_to must be after effective_from (if set)
    CONSTRAINT valid_gst_date_range CHECK (
        effective_to IS NULL OR effective_to > effective_from
    )
);

COMMENT ON COLUMN gst_rates.id IS 'Unique identifier for this GST rate record';
COMMENT ON COLUMN gst_rates.region_code IS 'Foreign key reference to regions table';
COMMENT ON COLUMN gst_rates.rate IS 'GST rate as decimal (e.g., 0.10 = 10%)';
COMMENT ON COLUMN gst_rates.effective_from IS 'Date from which this rate applies';
COMMENT ON COLUMN gst_rates.effective_to IS 'Date until which this rate applies (NULL = current/indefinite)';
COMMENT ON COLUMN gst_rates.notes IS 'Additional notes about this rate';

-- Indexes for efficient range queries on effective dates
CREATE INDEX IF NOT EXISTS idx_gst_rates_region_code ON gst_rates(region_code);
CREATE INDEX IF NOT EXISTS idx_gst_rates_effective_dates ON gst_rates(effective_from, effective_to);
CREATE INDEX IF NOT EXISTS idx_gst_rates_active ON gst_rates(region_code, effective_from, effective_to)
    WHERE effective_to IS NULL OR effective_to >= CURRENT_DATE;

-- SAMPLE DATA INSERTION
-- Insert regional factors based on regions.json pricing factors
INSERT INTO regional_factors (region_code, factor, effective_from, effective_to, source, notes)
VALUES
    ('SYD_METRO', 1.00, '2025-01-01', NULL, 'ABS Construction Price Index Q4 2025', 'Baseline region'),
    ('SYD_OUTER', 1.05, '2025-01-01', NULL, 'ABS Construction Price Index Q4 2025', 'Sydney Outer premium'),
    ('NSW_REGIONAL', 1.10, '2025-01-01', NULL, 'ABS Construction Price Index Q4 2025', 'Regional NSW premium'),
    ('MEL_METRO', 0.95, '2025-01-01', NULL, 'ABS Construction Price Index Q4 2025', 'Melbourne discount'),
    ('MEL_OUTER', 1.00, '2025-01-01', NULL, 'ABS Construction Price Index Q4 2025', 'Melbourne Outer'),
    ('VIC_REGIONAL', 1.08, '2025-01-01', NULL, 'ABS Construction Price Index Q4 2025', 'Regional Victoria premium'),
    ('BNE_METRO', 0.92, '2025-01-01', NULL, 'ABS Construction Price Index Q4 2025', 'Brisbane discount'),
    ('QLD_REGIONAL', 1.12, '2025-01-01', NULL, 'ABS Construction Price Index Q4 2025', 'Regional Queensland premium'),
    ('PER_METRO', 1.15, '2025-01-01', NULL, 'ABS Construction Price Index Q4 2025', 'Perth premium'),
    ('WA_REGIONAL', 1.25, '2025-01-01', NULL, 'ABS Construction Price Index Q4 2025', 'Remote WA premium'),
    ('ADL_METRO', 0.90, '2025-01-01', NULL, 'ABS Construction Price Index Q4 2025', 'Adelaide discount'),
    ('SA_REGIONAL', 1.05, '2025-01-01', NULL, 'ABS Construction Price Index Q4 2025', 'Regional SA premium'),
    ('HOB_METRO', 1.08, '2025-01-01', NULL, 'ABS Construction Price Index Q4 2025', 'Hobart premium'),
    ('TAS_REGIONAL', 1.15, '2025-01-01', NULL, 'ABS Construction Price Index Q4 2025', 'Remote Tasmania premium'),
    ('ACT', 1.02, '2025-01-01', NULL, 'ABS Construction Price Index Q4 2025', 'ACT minor premium'),
    ('NT', 1.30, '2025-01-01', NULL, 'ABS Construction Price Index Q4 2025', 'Remote NT premium');

-- Insert GST rates (Australia applies 10% nationwide)
INSERT INTO gst_rates (region_code, rate, effective_from, effective_to, notes)
VALUES
    ('SYD_METRO', 0.10, '2000-07-01', NULL, 'Australian GST standard rate (effective from GST introduction 2000-07-01)'),
    ('SYD_OUTER', 0.10, '2000-07-01', NULL, 'Australian GST standard rate'),
    ('NSW_REGIONAL', 0.10, '2000-07-01', NULL, 'Australian GST standard rate'),
    ('MEL_METRO', 0.10, '2000-07-01', NULL, 'Australian GST standard rate'),
    ('MEL_OUTER', 0.10, '2000-07-01', NULL, 'Australian GST standard rate'),
    ('VIC_REGIONAL', 0.10, '2000-07-01', NULL, 'Australian GST standard rate'),
    ('BNE_METRO', 0.10, '2000-07-01', NULL, 'Australian GST standard rate'),
    ('QLD_REGIONAL', 0.10, '2000-07-01', NULL, 'Australian GST standard rate'),
    ('PER_METRO', 0.10, '2000-07-01', NULL, 'Australian GST standard rate'),
    ('WA_REGIONAL', 0.10, '2000-07-01', NULL, 'Australian GST standard rate'),
    ('ADL_METRO', 0.10, '2000-07-01', NULL, 'Australian GST standard rate'),
    ('SA_REGIONAL', 0.10, '2000-07-01', NULL, 'Australian GST standard rate'),
    ('HOB_METRO', 0.10, '2000-07-01', NULL, 'Australian GST standard rate'),
    ('TAS_REGIONAL', 0.10, '2000-07-01', NULL, 'Australian GST standard rate'),
    ('ACT', 0.10, '2000-07-01', NULL, 'Australian GST standard rate'),
    ('NT', 0.10, '2000-07-01', NULL, 'Australian GST standard rate');

-- Insert placeholder escalation index (2025 Q4 baseline)
INSERT INTO escalation_indices (year, quarter, index_value, base_year, source, notes)
VALUES
    (2025, 4, 100.0000, 2025, 'ABS Construction Price Index Q4 2025', 'Baseline index value for 2025 Q4');

-- Create function to get current regional factor for a region
CREATE OR REPLACE FUNCTION get_current_regional_factor(p_region_code VARCHAR)
RETURNS NUMERIC AS $$
    SELECT factor
    FROM regional_factors
    WHERE region_code = p_region_code
      AND effective_from <= CURRENT_DATE
      AND (effective_to IS NULL OR effective_to >= CURRENT_DATE)
    ORDER BY effective_from DESC
    LIMIT 1;
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION get_current_regional_factor(VARCHAR) IS 'Returns the currently applicable regional factor for a given region code';

-- Create function to get current GST rate for a region
CREATE OR REPLACE FUNCTION get_current_gst_rate(p_region_code VARCHAR)
RETURNS NUMERIC AS $$
    SELECT rate
    FROM gst_rates
    WHERE region_code = p_region_code
      AND effective_from <= CURRENT_DATE
      AND (effective_to IS NULL OR effective_to >= CURRENT_DATE)
    ORDER BY effective_from DESC
    LIMIT 1;
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION get_current_gst_rate(VARCHAR) IS 'Returns the currently applicable GST rate for a given region code';

-- Create function to get escalation index for a specific year/quarter
CREATE OR REPLACE FUNCTION get_escalation_index(p_year INTEGER, p_quarter INTEGER)
RETURNS NUMERIC AS $$
    SELECT index_value
    FROM escalation_indices
    WHERE year = p_year AND quarter = p_quarter;
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION get_escalation_index(INTEGER, INTEGER) IS 'Returns the escalation index value for a specific year and quarter';
