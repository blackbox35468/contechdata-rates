-- NRM Tables Migration
-- Created: 2026-01-03
-- Purpose: Create NRM1 and NRM2 reference tables with seed data

-- ============================================================================
-- NRM1 TABLES
-- ============================================================================

-- NRM1 Groups (top-level classification)
-- Example: 0 = "Facilitating works", 1 = "Substructure", 2 = "Superstructure"
CREATE TABLE IF NOT EXISTS nrm1_groups (
  code TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE nrm1_groups IS 'NRM1 top-level groups providing the highest-level classification of construction work (e.g., Facilitating Works, Substructure, Superstructure)';
COMMENT ON COLUMN nrm1_groups.code IS 'Natural key: single digit or two-digit code (0-13)';
COMMENT ON COLUMN nrm1_groups.name IS 'Group name (e.g., "Facilitating works", "Substructure")';

-- NRM1 Elements (second level classification)
-- Example: 0.1 = "Toxic/hazardous/contaminated material treatment" (under group 0)
CREATE TABLE IF NOT EXISTS nrm1_elements (
  code TEXT PRIMARY KEY,
  group_code TEXT NOT NULL,
  name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  CONSTRAINT fk_nrm1_elements_group
    FOREIGN KEY (group_code) REFERENCES nrm1_groups(code) ON DELETE CASCADE
);

CREATE INDEX idx_nrm1_elements_group_code ON nrm1_elements(group_code);

COMMENT ON TABLE nrm1_elements IS 'NRM1 elements providing the second level of classification under a group (e.g., Element 0.1 under group 0)';
COMMENT ON COLUMN nrm1_elements.code IS 'Natural key: Group code + decimal + digit (e.g., "0.1", "2.3")';
COMMENT ON COLUMN nrm1_elements.group_code IS 'Foreign key to nrm1_groups(code)';

-- NRM1 Subelements (third level classification)
-- Example: 0.1.1 = "Toxic or hazardous material removal" (under element 0.1)
CREATE TABLE IF NOT EXISTS nrm1_subelements (
  code TEXT PRIMARY KEY,
  element_code TEXT NOT NULL,
  name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  CONSTRAINT fk_nrm1_subelements_element
    FOREIGN KEY (element_code) REFERENCES nrm1_elements(code) ON DELETE CASCADE
);

CREATE INDEX idx_nrm1_subelements_element_code ON nrm1_subelements(element_code);

COMMENT ON TABLE nrm1_subelements IS 'NRM1 subelements providing the third level of classification under an element (e.g., Subelement 0.1.1 under element 0.1)';
COMMENT ON COLUMN nrm1_subelements.code IS 'Natural key: Element code + decimal + digit (e.g., "0.1.1", "2.3.4")';
COMMENT ON COLUMN nrm1_subelements.element_code IS 'Foreign key to nrm1_elements(code)';

-- ============================================================================
-- NRM2 TABLES
-- ============================================================================

-- NRM2 Work Sections (first level classification)
-- Example: 2 = "Off-site manufactured materials, components or buildings"
CREATE TABLE IF NOT EXISTS nrm2_work_sections (
  number INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE nrm2_work_sections IS 'NRM2 work sections providing the first level of classification (e.g., Section 2 = Off-site manufactured materials)';
COMMENT ON COLUMN nrm2_work_sections.number IS 'Natural key: Work section number (2-41)';
COMMENT ON COLUMN nrm2_work_sections.name IS 'Work section name';

-- NRM2 Items (second level classification)
-- Example: WS2.1 = "Component" under section 2, unit = "nr"
CREATE TABLE IF NOT EXISTS nrm2_items (
  code TEXT PRIMARY KEY,
  work_section INTEGER NOT NULL,
  description TEXT NOT NULL,
  unit TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  CONSTRAINT fk_nrm2_items_work_section
    FOREIGN KEY (work_section) REFERENCES nrm2_work_sections(number) ON DELETE CASCADE
);

CREATE INDEX idx_nrm2_items_work_section ON nrm2_items(work_section);

COMMENT ON TABLE nrm2_items IS 'NRM2 items providing the second level of classification under a work section (e.g., Item WS2.1 under section 2)';
COMMENT ON COLUMN nrm2_items.code IS 'Natural key: Work section code + dot + item number (e.g., "WS2.1", "WS11.2")';
COMMENT ON COLUMN nrm2_items.work_section IS 'Foreign key to nrm2_work_sections(number)';
COMMENT ON COLUMN nrm2_items.unit IS 'Unit of measurement (e.g., "nr", "m2", "m", "item", "m3", "t", "hr")';

-- ============================================================================
-- NRM1 TO NRM2 MAPPING
-- ============================================================================

-- Mapping table to link NRM1 elements/subelements to NRM2 items
-- Supports many-to-many relationship: one NRM1 item may map to multiple NRM2 items
CREATE TABLE IF NOT EXISTS nrm1_nrm2_mapping (
  nrm1_code TEXT NOT NULL,
  nrm2_code TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  PRIMARY KEY (nrm1_code, nrm2_code),

  CONSTRAINT fk_nrm1_mapping
    FOREIGN KEY (nrm1_code) REFERENCES nrm1_elements(code) ON DELETE CASCADE,
  CONSTRAINT fk_nrm2_mapping
    FOREIGN KEY (nrm2_code) REFERENCES nrm2_items(code) ON DELETE CASCADE
);

CREATE INDEX idx_nrm1_nrm2_mapping_nrm1 ON nrm1_nrm2_mapping(nrm1_code);
CREATE INDEX idx_nrm1_nrm2_mapping_nrm2 ON nrm1_nrm2_mapping(nrm2_code);

COMMENT ON TABLE nrm1_nrm2_mapping IS 'Many-to-many mapping between NRM1 elements and NRM2 items, enabling cross-reference and traceability between classification systems';
COMMENT ON COLUMN nrm1_nrm2_mapping.description IS 'Description of the mapping relationship and its context';

-- ============================================================================
-- SEED DATA: NRM1 GROUPS
-- ============================================================================

INSERT INTO nrm1_groups (code, name) VALUES
  ('0', 'Facilitating works'),
  ('1', 'Substructure'),
  ('10', 'Main contractor design'),
  ('11', 'Main contractor other costs'),
  ('12', 'Works by others'),
  ('13', 'Risks'),
  ('2', 'Superstructure'),
  ('3', 'Finishes'),
  ('4', 'Fittings, furnishings and equipment'),
  ('5', 'Services'),
  ('6', 'Prefabricated buildings and building units'),
  ('7', 'Works to existing buildings'),
  ('8', 'External works'),
  ('9', 'Main contractor preliminaries')
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- SEED DATA: NRM1 ELEMENTS (Sample - First 10 for brevity)
-- ============================================================================

INSERT INTO nrm1_elements (code, group_code, name) VALUES
  ('0.1', '0', 'Toxic/hazardous/contaminated material treatment'),
  ('0.2', '0', 'Major demolition works'),
  ('0.3', '0', 'Temporary support for adjacent structures'),
  ('0.4', '0', 'Specialist groundworks'),
  ('0.5', '0', 'Temporary diversion works'),
  ('0.6', '0', 'Extraordinary site investigation works'),
  ('1.1', '1', 'Standard foundations'),
  ('13.2', '13', 'Construction risks'),
  ('13.4', '13', 'Employer other risks'),
  ('2.1', '2', 'Steel frames'),
  ('2.2', '2', 'Floors'),
  ('2.3', '2', 'Roof structure'),
  ('2.4', '2', 'Stair/ramp structures'),
  ('2.5', '2', 'External enclosing walls above ground level'),
  ('2.6', '2', 'External windows'),
  ('2.7', '2', 'Walls and partitions'),
  ('2.8', '2', 'Internal doors'),
  ('3.1', '3', 'Wall fnishes'),
  ('3.2', '3', 'Finishes'),
  ('3.3', '3', 'Finishes to ceilings'),
  ('4.1', '4', 'General fttings, furnishings and equipment'),
  ('5.1', '5', 'Sanitary installations'),
  ('5.10', '5', 'Lift and conveyor installations'),
  ('5.11', '5', 'Fire and lightning protection'),
  ('5.12', '5', 'Communication, security and control systems'),
  ('5.13', '5', 'Specialist installations'),
  ('5.14', '5', 'Builder''s work in connection with services'),
  ('5.2', '5', 'Services equipment'),
  ('5.3', '5', 'Disposal installations'),
  ('5.4', '5', 'Water installations'),
  ('5.5', '5', 'Heat source'),
  ('5.6', '5', 'Space heating and air conditioning systems'),
  ('5.7', '5', 'Ventilation systems'),
  ('5.8', '5', 'Electrical installations'),
  ('5.9', '5', 'Fuel installations'),
  ('6.1', '6', 'Complete buildings'),
  ('7.1', '7', 'Minor demolition and alteration works'),
  ('7.2', '7', 'Repairs to existing services'),
  ('7.3', '7', 'Damp-proof courses'),
  ('7.4', '7', 'Facade retention'),
  ('7.5', '7', 'Cleaning'),
  ('7.6', '7', 'Masonry repairs'),
  ('8.1', '8', 'Site clearance'),
  ('8.2', '8', 'Roads, paths and pavings'),
  ('8.3', '8', 'Seeding'),
  ('8.4', '8', 'Fencing and railings'),
  ('8.5', '8', 'Site/street furniture and equipment'),
  ('8.6', '8', 'Surface water and foul water drainage'),
  ('8.7', '8', 'Water mains supply'),
  ('8.8', '8', 'Minor building works')
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- SEED DATA: NRM1 SUBELEMENTS (Sample - First 20 for brevity)
-- ============================================================================

INSERT INTO nrm1_subelements (code, element_code, name) VALUES
  ('0.1.1', '0.1', 'Toxic or hazardous material removal'),
  ('0.1.2', '0.1', 'Contaminated land'),
  ('0.1.3', '0.1', 'Eradication of plant growth'),
  ('0.2.1', '0.2', 'Demolition works'),
  ('0.2.2', '0.2', 'Soft strip works'),
  ('0.3.1', '0.3', 'Temporary support for adjacent structures'),
  ('0.4.1', '0.4', 'Site dewatering and pumping'),
  ('0.4.2', '0.4', 'Soil stabilisation measures'),
  ('0.4.3', '0.4', 'Ground gas venting measures'),
  ('0.5.1', '0.5', 'Temporary diversion works'),
  ('0.6.1', '0.6', 'Archaeological investigation'),
  ('0.6.2', '0.6', 'Reptile/wildlife harm mitigation measures'),
  ('0.6.3', '0.6', 'Other extraordinary site investigation works'),
  ('1.1.1', '1.1', 'Standard foundations'),
  ('1.1.2', '1.1', 'Specialist foundations'),
  ('1.1.3', '1.1', 'Lowest foor'),
  ('1.1.4', '1.1', 'Basement excavation'),
  ('1.1.5', '1.1', 'Basement retaining walls'),
  ('2.1.1', '2.1', 'Steel frames'),
  ('2.1.2', '2.1', 'Space frames/ decks')
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- SEED DATA: NRM2 WORK SECTIONS
-- ============================================================================

INSERT INTO nrm2_work_sections (number, name) VALUES
  (2, 'Off-site manufactured materials, components or buildings'),
  (3, 'Demolitions'),
  (4, 'Alterations, repairs and conservation'),
  (5, 'Excavating and filling'),
  (6, 'Ground remediation'),
  (7, 'Piling'),
  (8, 'Underpinning'),
  (9, 'Diaphragm walls and embedded retaining walls'),
  (10, 'Crib walls, gabions and reinforced earth'),
  (11, 'In-situ concrete works'),
  (12, 'Precast/composite'),
  (13, 'Precast concrete'),
  (14, 'Masonry'),
  (15, 'Structural metalwork'),
  (16, 'Carpentry'),
  (17, 'Sheet roof coverings'),
  (18, 'Tile and slate roof and wall coverings'),
  (19, 'Waterproofing'),
  (20, 'Proprietary walls,'),
  (21, 'Cladding and covering'),
  (22, 'General joinery'),
  (23, 'Windows, screens and lights'),
  (24, 'Doors, shutters and hatches'),
  (25, 'Stairs, walkways'),
  (26, 'Metalwork'),
  (27, 'Glazing'),
  (28, 'Floor, wall, ceiling and roof finishings'),
  (29, 'Decoration'),
  (30, 'Suspended ceilings'),
  (31, 'Insulation, fire stopping and fire protection'),
  (32, 'Furniture, fittings and equipment'),
  (33, 'Drainage above'),
  (34, 'Drainage below'),
  (35, 'Site works'),
  (36, 'Fencing'),
  (37, 'Soft landscaping'),
  (38, 'Mechanical services'),
  (39, 'Electrical services'),
  (40, 'Transportation systems'),
  (41, 'Builder''s work in connection with mechanical, electrical and transportation installations')
ON CONFLICT (number) DO NOTHING;

-- ============================================================================
-- SEED DATA: NRM2 ITEMS (Sample - First 50 for brevity)
-- ============================================================================

INSERT INTO nrm2_items (code, work_section, description, unit) VALUES
  ('WS2.1', 2, 'Component.', 'nr'),
  ('WS2.2', 2, 'Prefabricated structures.', 'nr'),
  ('WS2.3', 2, 'Prefabricated building units.', 'nr'),
  ('WS2.4', 2, 'Prefabricated buildings.', 'nr'),
  ('WS3.1', 3, 'Demolitions.', 'item'),
  ('WS3.2', 3, 'Temporary support of structures, roads, etc.', 'item'),
  ('WS3.3', 3, 'Temporary works.', 'm2'),
  ('WS3.4', 3, 'Decontamination.', 'item'),
  ('WS3.5', 3, 'Recycling.', 'item'),
  ('WS4.1', 4, 'Works of', 'item'),
  ('WS4.2', 4, 'Removing.', 'item/ m2/m/ nr'),
  ('WS4.3', 4, 'Cutting or forming openings.', 'item/ m2/m/ nr'),
  ('WS4.8', 4, 'Removing existing and replacing.', 'item/ m2/m/ nr'),
  ('WS4.9', 4, 'Preparing existing structures for connection or attachment of', 'nr'),
  ('WS4.10', 4, 'Repairing.', 'item/ m2/m/ nr'),
  ('WS4.11', 4, 'Repointing joints.', 'm'),
  ('WS4.12', 4, 'Repointing.', 'm2/m/ nr'),
  ('WS4.13', 4, 'Resin or cement impregnation/ injection.', 'item/ m2/m/ nr'),
  ('WS4.14', 4, 'Inserting new walls ties.', 'm2/nr'),
  ('WS4.15', 4, 'Re-dressing existing flashings, etc.', 'm/nr'),
  ('WS5.1', 5, 'Preliminary sitework.', 'item/ nr'),
  ('WS5.2', 5, 'Removing trees.', 'nr'),
  ('WS5.4', 5, 'Site clearance.', 'm2'),
  ('WS5.5', 5, 'Site preparation.', 'm2'),
  ('WS5.6', 5, 'Excavation,', 'm3'),
  ('WS6.1', 6, 'Site dewatering.', 'item'),
  ('WS6.2', 6, 'Sterilisation.', 'm3'),
  ('WS6.3', 6, 'Chemical neutralising.', 'm3'),
  ('WS6.4', 6, 'Freezing.', 'm3'),
  ('WS6.5', 6, 'Ground gas venting.', 'm2'),
  ('WS7.1', 7, 'Interlocking sheet piles.', 'm2'),
  ('WS7.2', 7, 'Bored piles.', 'm'),
  ('WS11.1', 11, 'Mass concrete.', 'm3'),
  ('WS11.2', 11, 'Horizontal work.', 'm3'),
  ('WS11.3', 11, 'Sloping work < 150.', 'm3'),
  ('WS11.5', 11, 'Vertical work.', 'm3'),
  ('WS15.1', 15, 'Framed members, framing and fabrication.', 't'),
  ('WS15.3', 15, 'Isolated structural members, fabrication.', 't'),
  ('WS15.4', 15, 'Isolated structural members, permanent erection on site.', 'nr'),
  ('WS23.1', 23, 'Windows and window frames.', 'nr'),
  ('WS24.1', 24, 'Door sets.', 'nr'),
  ('WS24.2', 24, 'Doors.', 'nr'),
  ('WS28.1', 28, 'Screeds, beds and toppings, thickness and number of coats stated.', 'm/m2'),
  ('WS28.2', 28, 'Finish to floors, type of finish and overall thickness stated.', 'm/m2'),
  ('WS29.1', 29, 'Painting general surfaces.', 'm/m2/ nr'),
  ('WS33.1', 33, 'Pipework.', 'm'),
  ('WS34.1', 34, 'Drain runs.', 'm'),
  ('WS35.1', 35, 'Kerbs.', 'm'),
  ('WS36.1', 36, 'Fencing, type stated.', 'm'),
  ('WS38.1', 38, 'Primary equipment.', 'nr')
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- SEED DATA: NRM1 TO NRM2 MAPPING (Sample - First 10 mappings)
-- ============================================================================

INSERT INTO nrm1_nrm2_mapping (nrm1_code, nrm2_code, description) VALUES
  ('0.1', 'WS6.1', 'Site dewatering (Contaminated material treatment, Specialist ground works)'),
  ('0.1', 'WS6.10', 'Ground stabilisation (Contaminated material treatment)'),
  ('0.1', 'WS6.2', 'Sterilisation (Contaminated material treatment)'),
  ('0.1', 'WS6.3', 'Chemical neutralising (Contaminated material treatment)'),
  ('0.1', 'WS6.4', 'Freezing (Contaminated material treatment)'),
  ('0.2', 'WS3.1', 'Demolitions (Major demolition works)'),
  ('0.2', 'WS3.2', 'Temporary support (Major demolition works)'),
  ('0.2', 'WS3.3', 'Temporary works (Major demolition works)'),
  ('0.2', 'WS3.4', 'Decontamination (Major demolition works)'),
  ('0.2', 'WS3.5', 'Recycling (Major demolition works)')
ON CONFLICT (nrm1_code, nrm2_code) DO NOTHING;

-- ============================================================================
-- VERIFICATION CHECKS (optional - for data quality)
-- ============================================================================

-- Verify NRM1 hierarchy integrity
SELECT
  'nrm1_elements' as table_name,
  COUNT(*) as total_records,
  COUNT(DISTINCT group_code) as unique_groups,
  COUNT(CASE WHEN name IS NULL OR name = '' THEN 1 END) as null_names
FROM nrm1_elements
UNION ALL
SELECT
  'nrm1_subelements' as table_name,
  COUNT(*) as total_records,
  COUNT(DISTINCT element_code) as unique_groups,
  COUNT(CASE WHEN name IS NULL OR name = '' THEN 1 END) as null_names
FROM nrm1_subelements
UNION ALL
SELECT
  'nrm2_items' as table_name,
  COUNT(*) as total_records,
  COUNT(DISTINCT work_section) as unique_groups,
  COUNT(CASE WHEN description IS NULL OR description = '' THEN 1 END) as null_names
FROM nrm2_items;
