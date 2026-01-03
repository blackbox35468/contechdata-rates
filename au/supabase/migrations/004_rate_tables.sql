-- Migration: 004_rate_tables.sql
-- Description: Create rate tables for composite rates with labour, materials, plant, and factors
-- Date: 2025-01-03

-- Table: composite_rates
-- Purpose: Main composite rate records with aggregate costs and modifiers
CREATE TABLE composite_rates (
  code VARCHAR(50) PRIMARY KEY NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  unit VARCHAR(20) NOT NULL,
  nrm1_code VARCHAR(20),
  nrm2_codes VARCHAR(255),
  spec_level VARCHAR(50),
  base_date VARCHAR(20),
  region VARCHAR(100),
  labour_total NUMERIC(12, 2) NOT NULL DEFAULT 0,
  materials_total NUMERIC(12, 2) NOT NULL DEFAULT 0,
  plant_total NUMERIC(12, 2) NOT NULL DEFAULT 0,
  waste_percent NUMERIC(5, 2) NOT NULL DEFAULT 0 CHECK (waste_percent >= 0 AND waste_percent <= 100),
  ohp_percent NUMERIC(5, 2) NOT NULL DEFAULT 0 CHECK (ohp_percent >= 0 AND ohp_percent <= 100),
  total_rate NUMERIC(12, 2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE composite_rates IS 'Main composite rate records. Code is the natural key. Total_rate includes labour + materials + plant + waste allowance + OH&P percentage.';

-- Table: composite_rate_labour
-- Purpose: Labour line items breakdown for each composite rate
CREATE TABLE composite_rate_labour (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  composite_code VARCHAR(50) NOT NULL REFERENCES composite_rates(code) ON DELETE CASCADE,
  nrm2_code VARCHAR(20),
  task_description VARCHAR(255) NOT NULL,
  gang VARCHAR(10),
  output NUMERIC(10, 4),
  output_unit VARCHAR(20),
  hrs_per_unit NUMERIC(10, 6),
  rate_per_hour NUMERIC(10, 2),
  cost_per_unit NUMERIC(12, 2) NOT NULL,
  source VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE composite_rate_labour IS 'Labour line items breakdown. Each labour item includes task description, gang composition, output rates, and derived cost per unit. Sorted by NRM2 code.';

-- Table: composite_rate_materials
-- Purpose: Material line items breakdown for each composite rate
CREATE TABLE composite_rate_materials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  composite_code VARCHAR(50) NOT NULL REFERENCES composite_rates(code) ON DELETE CASCADE,
  nrm2_code VARCHAR(20),
  description VARCHAR(255) NOT NULL,
  unit VARCHAR(20),
  quantity NUMERIC(12, 4),
  unit_rate NUMERIC(12, 4),
  cost NUMERIC(12, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE composite_rate_materials IS 'Material line items breakdown. Each material item includes unit type, quantity, unit rate, and total cost. Supplier field can be added to materials if needed.';

-- Table: composite_rate_plant
-- Purpose: Plant/equipment line items breakdown for each composite rate
CREATE TABLE composite_rate_plant (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  composite_code VARCHAR(50) NOT NULL REFERENCES composite_rates(code) ON DELETE CASCADE,
  nrm2_code VARCHAR(20),
  description VARCHAR(255) NOT NULL,
  unit VARCHAR(20),
  quantity NUMERIC(12, 4),
  rate NUMERIC(12, 4),
  cost NUMERIC(12, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE composite_rate_plant IS 'Plant and equipment line items breakdown. Each item includes unit type, quantity, hire rate, and total cost.';

-- Table: composite_rate_factors
-- Purpose: Applied condition factors for each composite rate
CREATE TABLE composite_rate_factors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  composite_code VARCHAR(50) NOT NULL REFERENCES composite_rates(code) ON DELETE CASCADE,
  factor_code VARCHAR(50) NOT NULL,
  applied_value NUMERIC(5, 4),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE composite_rate_factors IS 'Applied condition factors. Links composite rates to productivity modifiers, access factors, or other adjustment codes with their applied values.';

-- Create indexes for common queries
CREATE INDEX idx_composite_rates_nrm1_code ON composite_rates(nrm1_code);
CREATE INDEX idx_composite_rates_region ON composite_rates(region);
CREATE INDEX idx_composite_rates_spec_level ON composite_rates(spec_level);
CREATE INDEX idx_composite_labour_composite_code ON composite_rate_labour(composite_code);
CREATE INDEX idx_composite_labour_nrm2_code ON composite_rate_labour(nrm2_code);
CREATE INDEX idx_composite_materials_composite_code ON composite_rate_materials(composite_code);
CREATE INDEX idx_composite_materials_nrm2_code ON composite_rate_materials(nrm2_code);
CREATE INDEX idx_composite_plant_composite_code ON composite_rate_plant(composite_code);
CREATE INDEX idx_composite_plant_nrm2_code ON composite_rate_plant(nrm2_code);
CREATE INDEX idx_composite_factors_composite_code ON composite_rate_factors(composite_code);
CREATE INDEX idx_composite_factors_factor_code ON composite_rate_factors(factor_code);

-- Seed data: Insert 5 example rates from the composite_rates.json

-- Rate 1: EXT-WALL-001 - Cavity wall - facing brick/block, 100mm insulation, plasterboard & skim
INSERT INTO composite_rates (code, name, description, unit, nrm1_code, nrm2_codes, spec_level, base_date, region, labour_total, materials_total, plant_total, waste_percent, ohp_percent, total_rate)
VALUES ('EXT-WALL-001', 'Cavity wall - facing brick/block, 100mm insulation, plasterboard & skim', 'External enclosing walls above ground', 'm²', '2.5.1', 'WS14.1, WS31.1, WS28.1, WS29.1', 'Standard', 'Jan-2025', 'Sydney Metro', 173.35, 145.91, 9.7, 5, 15, 386.69);

INSERT INTO composite_rate_labour (composite_code, nrm2_code, task_description, gang, output, output_unit, hrs_per_unit, rate_per_hour, cost_per_unit, source)
VALUES
('EXT-WALL-001', 'WS14.1', 'Face brickwork 102.5mm', '1+1', 1.2, 'm²/hr', 0.8333333333333334, 95, 79.16666666666667, 'Internal'),
('EXT-WALL-001', 'WS14.1', 'Blockwork 100mm', '1+0.5', 2.5, 'm²/hr', 0.4, 82.5, 33, 'Internal'),
('EXT-WALL-001', 'WS31.1', 'Cavity insulation 100mm', '1+0', 8, 'm²/hr', 0.125, 65, 8.125, 'Internal'),
('EXT-WALL-001', 'WS14.11', 'Cavity closers', '1+0', 12, 'm/hr', 0.08333333333333333, 65, 5.416666666666666, 'Internal'),
('EXT-WALL-001', 'WS14.9', 'DPC bedding', '1+0', 15, 'm/hr', 0.06666666666666667, 65, 4.333333333333333, 'Internal'),
('EXT-WALL-001', 'WS14.12', 'Lintels - set in position', '1+1', 4, 'nr/hr', 0.25, 95, 23.75, 'Internal'),
('EXT-WALL-001', 'WS28.1', 'Plasterboard fix + skim', '1+0.5', 4, 'm²/hr', 0.25, 82.5, 20.625, 'Internal'),
('EXT-WALL-001', 'WS29.1', 'Decoration mist + 2 coats', '1+0', 12, 'm²/hr', 0.08333333333333333, 65, 5.416666666666666, 'Internal');

INSERT INTO composite_rate_materials (composite_code, nrm2_code, description, unit, quantity, unit_rate, cost)
VALUES
('EXT-WALL-001', 'WS14.1', 'Facing bricks', 'nr', 60, 0.85, 51),
('EXT-WALL-001', 'WS14.1', 'Concrete blocks 100mm', 'nr', 10, 3.2, 32),
('EXT-WALL-001', 'WS14.1', 'Mortar (facework)', 'm³', 0.03, 185, 5.55),
('EXT-WALL-001', 'WS14.1', 'Mortar (blockwork)', 'm³', 0.01, 165, 1.65),
('EXT-WALL-001', 'WS14.7', 'Wall ties SS', 'nr', 4, 0.45, 1.8),
('EXT-WALL-001', 'WS31.1', 'Cavity insulation 100mm', 'm²', 1.05, 18, 18.9),
('EXT-WALL-001', 'WS14.11', 'Cavity closers', 'm', 0.15, 8.5, 1.275),
('EXT-WALL-001', 'WS14.9', 'DPC 112.5mm', 'm', 0.1, 4.5, 0.45),
('EXT-WALL-001', 'WS14.12', 'Steel lintel (allow)', 'm', 0.12, 95, 11.4),
('EXT-WALL-001', 'WS28.1', 'Plasterboard 12.5mm', 'm²', 1.05, 8.5, 8.925),
('EXT-WALL-001', 'WS28.1', 'Skim coat plaster', 'm²', 1, 3.2, 3.2),
('EXT-WALL-001', 'WS29.1', 'Paint (mist + 2 coats)', 'm²', 1, 2.8, 2.8);

INSERT INTO composite_rate_plant (composite_code, nrm2_code, description, unit, quantity, rate, cost)
VALUES
('EXT-WALL-001', 'WS14.1', 'Scaffold (allow)', 'm²', 1, 8.5, 8.5),
('EXT-WALL-001', 'WS14.1', 'Mixer/small plant', 'hr', 0.1, 12, 1.2);

-- Rate 2: ROOF-TILE-001 - Pitched roof - concrete interlocking tiles on battens, sarking, insulation
INSERT INTO composite_rates (code, name, description, unit, nrm1_code, nrm2_codes, spec_level, base_date, region, labour_total, materials_total, plant_total, waste_percent, ohp_percent, total_rate)
VALUES ('ROOF-TILE-001', 'Pitched roof - concrete interlocking tiles on battens, sarking, insulation', 'Roof coverings', 'm²', '2.3.2', 'WS18.1, WS16.4, WS31.1', 'Standard', 'Jan-2025', 'Sydney Metro', 85.5, 78.4, 12.5, 5, 15, 207.37);

INSERT INTO composite_rate_labour (composite_code, nrm2_code, task_description, gang, output, output_unit, hrs_per_unit, rate_per_hour, cost_per_unit, source)
VALUES
('ROOF-TILE-001', 'WS16.4', 'Sarking/underlay', '1+0.5', 15, 'm²/hr', 0.06666666666666667, 82.5, 5.5, 'Internal'),
('ROOF-TILE-001', 'WS16.3', 'Tile battens', '1+0.5', 12, 'm²/hr', 0.08333333333333333, 82.5, 6.875, 'Internal'),
('ROOF-TILE-001', 'WS18.1', 'Concrete interlocking tiles', '1+1', 4.5, 'm²/hr', 0.2222222222222222, 95, 21.11111111111111, 'Internal'),
('ROOF-TILE-001', 'WS18.1', 'Ridge/hip tiles', '1+0.5', 8, 'm/hr', 0.125, 82.5, 10.3125, 'Internal'),
('ROOF-TILE-001', 'WS31.1', 'Insulation between joists', '1+0', 10, 'm²/hr', 0.1, 65, 6.5, 'Internal');

INSERT INTO composite_rate_materials (composite_code, nrm2_code, description, unit, quantity, unit_rate, cost)
VALUES
('ROOF-TILE-001', 'WS16.4', 'Sarking/underlay', 'm²', 1.1, 4.5, 4.95),
('ROOF-TILE-001', 'WS16.3', 'Tile battens 50x25', 'm', 3.3, 1.8, 5.94),
('ROOF-TILE-001', 'WS18.1', 'Concrete interlocking tiles', 'nr', 10, 2.85, 28.5),
('ROOF-TILE-001', 'WS18.1', 'Ridge tiles', 'm', 0.08, 28, 2.24),
('ROOF-TILE-001', 'WS18.1', 'Tile clips/fixings', 'nr', 10, 0.15, 1.5),
('ROOF-TILE-001', 'WS31.1', 'Insulation batts 200mm', 'm²', 1.05, 12.5, 13.125),
('ROOF-TILE-001', 'WS18.1', 'Bedding mortar', 'm³', 0.002, 165, 0.33);

INSERT INTO composite_rate_plant (composite_code, nrm2_code, description, unit, quantity, rate, cost)
VALUES
('ROOF-TILE-001', 'WS18.1', 'Scaffold (roof)', 'm²', 1, 10.5, 10.5),
('ROOF-TILE-001', 'WS18.1', 'Tile cutter', 'hr', 0.15, 8, 1.2),
('ROOF-TILE-001', 'WS18.1', 'Hoisting/lifting', 'm²', 1, 0.8, 0.8);

-- Rate 3: FOUND-STRIP-001 - Strip foundation - excavate, concrete 450x250, blockwork to DPC
INSERT INTO composite_rates (code, name, description, unit, nrm1_code, nrm2_codes, spec_level, base_date, region, labour_total, materials_total, plant_total, waste_percent, ohp_percent, total_rate)
VALUES ('FOUND-STRIP-001', 'Strip foundation - excavate, concrete 450x250, blockwork to DPC', 'Standard foundations', 'm', '1.1.1', 'WS5.6, WS11.1, WS14.1', 'Standard', 'Jan-2025', 'Sydney Metro', 125.8, 98.5, 35, 7.5, 15, 306.69);

INSERT INTO composite_rate_labour (composite_code, nrm2_code, task_description, gang, output, output_unit, hrs_per_unit, rate_per_hour, cost_per_unit, source)
VALUES
('FOUND-STRIP-001', 'WS5.6', 'Excavate trench (machine)', '0+1', 8, 'm/hr', 0.125, 55, 6.875, 'Internal'),
('FOUND-STRIP-001', 'WS5.6', 'Trim & level by hand', '0+1', 4, 'm/hr', 0.25, 55, 13.75, 'Internal'),
('FOUND-STRIP-001', 'WS11.1', 'Place concrete (pump)', '0+2', 12, 'm/hr', 0.08333333333333333, 110, 9.166666666666666, 'Internal'),
('FOUND-STRIP-001', 'WS14.1', 'Blockwork to DPC', '1+0.5', 3.5, 'm/hr', 0.2857142857142857, 82.5, 23.57142857142857, 'Internal'),
('FOUND-STRIP-001', 'WS5.6', 'Backfill & compact', '0+1', 6, 'm/hr', 0.1666666666666667, 55, 9.166666666666666, 'Internal');

INSERT INTO composite_rate_materials (composite_code, nrm2_code, description, unit, quantity, unit_rate, cost)
VALUES
('FOUND-STRIP-001', 'WS11.1', 'Concrete C25 (0.1125m³/m)', 'm³', 0.1125, 185, 20.8125),
('FOUND-STRIP-001', 'WS14.1', 'Concrete blocks 100mm', 'nr', 8, 3.2, 25.6),
('FOUND-STRIP-001', 'WS14.1', 'Mortar', 'm³', 0.008, 165, 1.32),
('FOUND-STRIP-001', 'WS14.9', 'DPC 300mm', 'm', 1, 5.8, 5.8),
('FOUND-STRIP-001', 'WS5.6', 'Disposal of excavated (0.35m³/m)', 'm³', 0.35, 45, 15.75);

INSERT INTO composite_rate_plant (composite_code, nrm2_code, description, unit, quantity, rate, cost)
VALUES
('FOUND-STRIP-001', 'WS5.6', 'Mini excavator 1.5t', 'hr', 0.25, 85, 21.25),
('FOUND-STRIP-001', 'WS11.1', 'Concrete pump (share)', 'm', 1, 8.5, 8.5),
('FOUND-STRIP-001', 'WS5.6', 'Compactor plate', 'hr', 0.1, 35, 3.5);

-- Rate 4: FLOOR-TILE-001 - Floor tiling - porcelain 600x600 on screed bed, grout
INSERT INTO composite_rates (code, name, description, unit, nrm1_code, nrm2_codes, spec_level, base_date, region, labour_total, materials_total, plant_total, waste_percent, ohp_percent, total_rate)
VALUES ('FLOOR-TILE-001', 'Floor tiling - porcelain 600x600 on screed bed, grout', 'Finishes to floors', 'm²', '3.2.1', 'WS28.8, WS28.9', 'Standard', 'Jan-2025', 'Sydney Metro', 65, 85.5, 2.5, 10, 15, 185.78);

INSERT INTO composite_rate_labour (composite_code, nrm2_code, task_description, gang, output, output_unit, hrs_per_unit, rate_per_hour, cost_per_unit, source)
VALUES
('FLOOR-TILE-001', 'WS28.8', 'Prepare substrate', '1+0', 20, 'm²/hr', 0.05, 70, 3.5, 'Internal'),
('FLOOR-TILE-001', 'WS28.8', 'Lay porcelain 600x600', '1+0.5', 3.5, 'm²/hr', 0.2857142857142857, 92.5, 26.42857142857143, 'Internal'),
('FLOOR-TILE-001', 'WS28.9', 'Grouting', '1+0', 12, 'm²/hr', 0.08333333333333333, 70, 5.833333333333333, 'Internal'),
('FLOOR-TILE-001', 'WS28.8', 'Cutting (allow 10%)', '1+0', 6, 'm²/hr', 0.1666666666666667, 70, 11.66666666666667, 'Internal');

INSERT INTO composite_rate_materials (composite_code, nrm2_code, description, unit, quantity, unit_rate, cost)
VALUES
('FLOOR-TILE-001', 'WS28.8', 'Porcelain tiles 600x600', 'm²', 1.1, 55, 60.50000000000001),
('FLOOR-TILE-001', 'WS28.8', 'Tile adhesive', 'kg', 5, 1.85, 9.25),
('FLOOR-TILE-001', 'WS28.9', 'Grout', 'kg', 1.5, 3.5, 5.25),
('FLOOR-TILE-001', 'WS28.8', 'Tile spacers', 'nr', 20, 0.02, 0.4),
('FLOOR-TILE-001', 'WS28.8', 'Primer/sealer', 'm²', 1, 2.5, 2.5);

INSERT INTO composite_rate_plant (composite_code, nrm2_code, description, unit, quantity, rate, cost)
VALUES
('FLOOR-TILE-001', 'WS28.8', 'Tile cutter (wet)', 'hr', 0.2, 12.5, 2.5);

-- Rate 5: DRAIN-BG-001 - Drainage below ground - 100mm uPVC, bedding, backfill, average 750mm deep
INSERT INTO composite_rates (code, name, description, unit, nrm1_code, nrm2_codes, spec_level, base_date, region, labour_total, materials_total, plant_total, waste_percent, ohp_percent, total_rate)
VALUES ('DRAIN-BG-001', 'Drainage below ground - 100mm uPVC, bedding, backfill, average 750mm deep', 'Surface water and foul water drainage', 'm', '8.6.1', 'WS34.1, WS34.2, WS5.6', 'Standard', 'Jan-2025', 'Sydney Metro', 45.6, 38.5, 28, 5, 15, 131.13);

INSERT INTO composite_rate_labour (composite_code, nrm2_code, task_description, gang, output, output_unit, hrs_per_unit, rate_per_hour, cost_per_unit, source)
VALUES
('DRAIN-BG-001', 'WS5.6', 'Excavate trench 750 avg', '0+1', 4, 'm/hr', 0.25, 55, 13.75, 'Internal'),
('DRAIN-BG-001', 'WS34.1', 'Lay 100mm uPVC', '1+1', 8, 'm/hr', 0.125, 95, 11.875, 'Internal'),
('DRAIN-BG-001', 'WS34.2', 'Granular bed & surround', '0+1', 6, 'm/hr', 0.1666666666666667, 55, 9.166666666666666, 'Internal'),
('DRAIN-BG-001', 'WS5.6', 'Backfill & compact', '0+1', 5, 'm/hr', 0.2, 55, 11, 'Internal');

INSERT INTO composite_rate_materials (composite_code, nrm2_code, description, unit, quantity, unit_rate, cost)
VALUES
('DRAIN-BG-001', 'WS34.1', '100mm uPVC pipe', 'm', 1.05, 12.5, 13.125),
('DRAIN-BG-001', 'WS34.1', 'Couplers/fittings (allow)', 'nr', 0.3, 8.5, 2.55),
('DRAIN-BG-001', 'WS34.2', 'Granular bed/surround', 'm³', 0.15, 65, 9.75),
('DRAIN-BG-001', 'WS5.6', 'Disposal of excavated', 'm³', 0.45, 45, 20.25);

INSERT INTO composite_rate_plant (composite_code, nrm2_code, description, unit, quantity, rate, cost)
VALUES
('DRAIN-BG-001', 'WS5.6', 'Mini excavator 1.5t', 'hr', 0.25, 85, 21.25),
('DRAIN-BG-001', 'WS34.1', 'Laser level', 'day', 0.05, 65, 3.25),
('DRAIN-BG-001', 'WS5.6', 'Compactor plate', 'hr', 0.1, 35, 3.5);
