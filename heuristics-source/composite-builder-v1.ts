/**
 * Composite Builder System Prompt v1
 * Used by: /create-composite skill and conversational composite generation
 *
 * Version History:
 * - v1 (2026-01-03): Initial creation for multi-market composite generation
 */

/**
 * NRM Section Reference - Maps work items to NRM classification
 */
export const NRM_SECTION_MAP = {
  0: { name: 'Facilitating Works', trades: ['Preliminaries', 'Demolition', 'Scaffolding'], examples: ['Site setup', 'Temporary works', 'Protection'] },
  1: { name: 'Substructure', trades: ['Earthworks', 'Concreter', 'Formworker'], examples: ['Footings', 'Slabs', 'Piling', 'Excavation'] },
  2: { name: 'Superstructure', trades: ['Carpenter', 'Bricklayer', 'Roofer', 'Glazier', 'Steelworker'], examples: ['Framing', 'Walls', 'Roof', 'Windows', 'Doors'] },
  3: { name: 'Internal Finishes', trades: ['Plasterer', 'Painter', 'Tiler', 'Floor Layer', 'Ceiling Fixer'], examples: ['Plasterboard', 'Painting', 'Tiling', 'Flooring', 'Ceilings'] },
  4: { name: 'Fittings, Furnishings & Equipment', trades: ['Joiner', 'Kitchen Installer', 'Cabinetmaker'], examples: ['Joinery', 'Kitchens', 'Wardrobes', 'Benchtops'] },
  5: { name: 'Services', trades: ['Electrician', 'Plumber', 'HVAC', 'Fire Protection'], examples: ['Electrical', 'Plumbing', 'Air conditioning', 'Fire systems', 'Lifts'] },
  6: { name: 'Prefabricated Buildings', trades: ['Prefab'], examples: ['Modular buildings', 'Prefab structures'] },
  7: { name: 'Work to Existing Buildings', trades: ['Renovations', 'Demolition'], examples: ['Alterations', 'Refurbishment', 'Restoration'] },
  8: { name: 'External Works', trades: ['Landscaper', 'Civil', 'Fencer', 'Paver'], examples: ['Drainage', 'Landscaping', 'Fencing', 'Paving', 'Driveways'] },
} as const;

/**
 * Resource ID naming conventions by market
 */
export const RESOURCE_ID_PATTERNS = {
  materials: 'MAT_{MARKET}_{ITEM}',  // e.g., MAT_AU_FLOOR_TILES, MAT_UK_PLASTERBOARD
  labour: 'LAB_{MARKET}_{TRADE}',    // e.g., LAB_AU_TILER, LAB_NZ_ELECTRICIAN
  plant: 'PLT_{MARKET}_{ITEM}',      // e.g., PLT_AU_EXCAVATOR, PLT_CA_CRANE
  examples: {
    AU: { materials: ['MAT_AU_FLOOR_TILES', 'MAT_AU_PLASTERBOARD', 'MAT_AU_TIMBER_FLOOR'], labour: ['LAB_AU_TILER', 'LAB_AU_CARPENTER', 'LAB_AU_ELECTRICIAN'], plant: ['PLT_AU_EXCAVATOR', 'PLT_AU_CRANE'] },
    NZ: { materials: ['MAT_NZ_FLOOR_TILES', 'MAT_NZ_GIB_BOARD', 'MAT_NZ_TIMBER_FLOOR'], labour: ['LAB_NZ_TILER', 'LAB_NZ_CARPENTER', 'LAB_NZ_ELECTRICIAN'], plant: ['PLT_NZ_EXCAVATOR', 'PLT_NZ_CRANE'] },
    UK: { materials: ['MAT_UK_FLOOR_TILES', 'MAT_UK_PLASTERBOARD', 'MAT_UK_TIMBER_FLOOR'], labour: ['LAB_UK_TILER', 'LAB_UK_CARPENTER', 'LAB_UK_ELECTRICIAN'], plant: ['PLT_UK_EXCAVATOR', 'PLT_UK_CRANE'] },
    CA: { materials: ['MAT_CA_FLOOR_TILES', 'MAT_CA_DRYWALL', 'MAT_CA_TIMBER_FLOOR'], labour: ['LAB_CA_TILER', 'LAB_CA_CARPENTER', 'LAB_CA_ELECTRICIAN'], plant: ['PLT_CA_EXCAVATOR', 'PLT_CA_CRANE'] },
    US: { materials: ['MAT_US_FLOOR_TILES', 'MAT_US_DRYWALL', 'MAT_US_TIMBER_FLOOR'], labour: ['LAB_US_TILER', 'LAB_US_CARPENTER', 'LAB_US_ELECTRICIAN'], plant: ['PLT_US_EXCAVATOR', 'PLT_US_CRANE'] },
  },
} as const;

/**
 * Labour productivity heuristics by trade (hours per unit)
 */
export const TRADE_PRODUCTIVITY_HEURISTICS = {
  // Finishes (NRM 3)
  tiling_floor: { range: [0.3, 0.5], unit: 'hr/m2', notes: 'Standard floor tiles, increases for complex patterns' },
  tiling_wall: { range: [0.5, 0.8], unit: 'hr/m2', notes: 'Wall tiles, higher for small format or intricate work' },
  painting_walls: { range: [0.1, 0.15], unit: 'hr/m2', notes: '2 coats, brush/roller, add for cutting in' },
  painting_ceilings: { range: [0.12, 0.18], unit: 'hr/m2', notes: '2 coats, overhead work' },
  plastering: { range: [0.2, 0.35], unit: 'hr/m2', notes: 'Plasterboard fixing and setting' },
  flooring_timber: { range: [0.25, 0.35], unit: 'hr/m2', notes: 'Floating or fixed timber floors' },
  flooring_carpet: { range: [0.15, 0.25], unit: 'hr/m2', notes: 'Carpet and underlay' },
  flooring_vinyl: { range: [0.2, 0.3], unit: 'hr/m2', notes: 'Sheet or plank vinyl' },

  // Superstructure (NRM 2)
  framing_walls: { range: [0.15, 0.25], unit: 'hr/m2', notes: 'Timber stud walls, standard height' },
  framing_roof: { range: [0.2, 0.35], unit: 'hr/m2', notes: 'Roof framing, varies by complexity' },
  brickwork: { range: [0.8, 1.2], unit: 'hr/m2', notes: 'Single skin brickwork' },
  roofing_tiles: { range: [0.15, 0.25], unit: 'hr/m2', notes: 'Concrete or terracotta tiles' },
  roofing_metal: { range: [0.1, 0.18], unit: 'hr/m2', notes: 'Metal roof sheeting' },
  glazing: { range: [0.5, 1.0], unit: 'hr/m2', notes: 'Window installation' },

  // Services (NRM 5)
  electrical_point: { range: [0.3, 0.5], unit: 'hr/point', notes: 'GPO, switch, or light point' },
  plumbing_fixture: { range: [1.0, 2.0], unit: 'hr/fixture', notes: 'Basin, toilet, shower, etc.' },
  plumbing_rough_in: { range: [0.8, 1.5], unit: 'hr/point', notes: 'Pipe rough-in per fixture' },
  hvac_duct: { range: [0.3, 0.5], unit: 'hr/m', notes: 'Ductwork installation' },

  // Substructure (NRM 1)
  concrete_slab: { range: [0.05, 0.1], unit: 'hr/m2', notes: 'Concrete placement, excludes formwork' },
  formwork: { range: [0.3, 0.5], unit: 'hr/m2', notes: 'Formwork to slabs/footings' },
  excavation_machine: { range: [0.02, 0.05], unit: 'hr/m3', notes: 'Machine excavation' },
  excavation_hand: { range: [0.5, 1.0], unit: 'hr/m3', notes: 'Hand excavation' },

  // External Works (NRM 8)
  paving: { range: [0.15, 0.25], unit: 'hr/m2', notes: 'Brick or concrete pavers' },
  fencing_timber: { range: [0.3, 0.5], unit: 'hr/m', notes: 'Timber paling fence' },
  fencing_colorbond: { range: [0.2, 0.35], unit: 'hr/m', notes: 'Metal sheet fencing' },
  landscaping: { range: [0.2, 0.4], unit: 'hr/m2', notes: 'Garden bed preparation and planting' },
} as const;

/**
 * Material waste factor guidelines by material type
 */
export const WASTE_FACTOR_GUIDELINES = {
  tiles: { factor: [1.05, 1.10], notes: '5-10% waste for cuts, breakage, pattern matching' },
  timber: { factor: [1.07, 1.12], notes: '7-12% waste for cuts, defects, offcuts' },
  paint: { factor: [1.05, 1.08], notes: '5-8% for coverage variation, application loss' },
  concrete: { factor: [1.03, 1.05], notes: '3-5% for slump, spillage, over-ordering' },
  plasterboard: { factor: [1.05, 1.10], notes: '5-10% for cuts around openings' },
  insulation: { factor: [1.03, 1.05], notes: '3-5% for cutting and fitting' },
  roofing: { factor: [1.05, 1.08], notes: '5-8% for laps, cuts, ridge/valley pieces' },
  bricks: { factor: [1.03, 1.05], notes: '3-5% for breakage and cutting' },
  adhesives: { factor: [1.10, 1.15], notes: '10-15% for application variation' },
  fixings: { factor: [1.10, 1.15], notes: '10-15% for drops, over-use, lost items' },
} as const;

/**
 * Common gang compositions by work type
 */
export const GANG_COMPOSITIONS = {
  single_trade: { tiler: 1 },
  trade_pair: { tradesperson: 1, apprentice: 1 },
  carpentry_team: { carpenter: 2, labourer: 1 },
  civil_team: { operator: 1, labourer: 2 },
  concrete_team: { concreter: 2, labourer: 2 },
  electrical_team: { electrician: 1, apprentice: 1 },
  plumbing_team: { plumber: 1, apprentice: 1 },
  painting_team: { painter: 2 },
  roofing_team: { roofer: 2, labourer: 1 },
  survey_team: { surveyor: 1, assistant: 1 },
} as const;

/**
 * Golden Composite JSON Schema Template
 */
export const COMPOSITE_SCHEMA_TEMPLATE = `{
  "code": "GC-{MARKET}-{4-digit-number}",
  "name": "Short descriptive name",
  "description": "Detailed description of the work item",
  "market": "AU | NZ | UK | CA | US",
  "classification": "NRM",
  "nrm_level2_code": "X.X (e.g., 3.2 for floor finishes)",
  "unit": "m2 | m | m3 | EA | no | ls | hr",
  "total_rate": 0,
  "scope_includes": ["Item 1", "Item 2", "..."],
  "scope_excludes": ["Item 1", "Item 2", "..."],
  "methodology": {
    "spacing": "As applicable (e.g., 600mm centres)",
    "fixings": ["Fixing type 1", "Fixing type 2"],
    "installation_sequence": ["Step 1", "Step 2", "..."],
    "quality_checks": ["Check 1", "Check 2", "..."],
    "tools_required": ["Tool 1", "Tool 2", "..."],
    "safety_considerations": ["Safety item 1", "Safety item 2", "..."]
  },
  "labour_hours_per_unit": 0.0,
  "gang_composition": { "trade": 1 },
  "material_waste_factor": 1.05,
  "components": {
    "materials": [{ "resource_id": "MAT_{MARKET}_{ITEM}", "qty": 1, "unit": "m2" }],
    "labour": [{ "resource_id": "LAB_{MARKET}_{TRADE}", "qty": 0.3, "unit": "hr" }],
    "plant": []
  },
  "rates": {
    "material_coverage_factor": 1.05,
    "labour_productivity_rate": "0.3 hr/m2",
    "plant_productivity_rate": "0 hr/m2"
  },
  "spec_tier": "standard | economy | premium",
  "metadata": {
    "reviewed_by": "",
    "confidence": 0.6,
    "needs_review": true,
    "source_reference": ""
  }
}`;

/**
 * Main system prompt for composite rate generation
 */
export const COMPOSITE_BUILDER_SYSTEM_PROMPT = `You are an expert Construction Estimator and Quantity Surveyor specializing in creating detailed composite rates for construction work items.

Your role is to generate complete, accurate composite rate JSON files from free-form descriptions of construction work.

=== MARKETS SUPPORTED ===
- AU: Australia (AUD, AS/NZS standards)
- NZ: New Zealand (NZD, AS/NZS standards)
- UK: United Kingdom (GBP, British standards)
- CA: Canada (CAD, CSA standards)
- US: United States (USD, ASTM/ANSI standards)

=== NRM CLASSIFICATION (REQUIRED) ===
Every composite must be classified to an NRM Level 2 code:

Section 0 - Facilitating Works: 0.1-0.9 (Preliminaries, Demolition, Scaffolding)
Section 1 - Substructure: 1.1-1.9 (Foundations, Earthworks, Piling)
Section 2 - Superstructure: 2.1-2.9 (Frame, Roof, External Walls, Windows, Doors)
Section 3 - Internal Finishes: 3.1-3.9 (Wall finishes, Floor finishes, Ceiling finishes)
Section 4 - Fittings: 4.1-4.9 (Joinery, Kitchens, Wardrobes)
Section 5 - Services: 5.1-5.9 (Electrical, Plumbing, HVAC, Fire, Lifts)
Section 6 - Prefabricated Buildings: 6.1-6.9
Section 7 - Work to Existing: 7.1-7.9 (Alterations, Refurbishment)
Section 8 - External Works: 8.1-8.9 (Drainage, Landscaping, Fencing, Paving)

=== RESOURCE ID CONVENTIONS (CRITICAL) ===
All resource IDs must follow these patterns:
- Materials: MAT_{MARKET}_{ITEM} (e.g., MAT_AU_FLOOR_TILES, MAT_UK_PLASTERBOARD)
- Labour: LAB_{MARKET}_{TRADE} (e.g., LAB_AU_TILER, LAB_NZ_ELECTRICIAN)
- Plant: PLT_{MARKET}_{ITEM} (e.g., PLT_AU_EXCAVATOR, PLT_CA_CRANE)

Use UPPERCASE, underscores between words, and be descriptive but concise.

=== LABOUR PRODUCTIVITY RATES (USE AS GUIDE) ===
Tiling (floor): 0.3-0.5 hr/m2 | Tiling (wall): 0.5-0.8 hr/m2
Painting (walls): 0.1-0.15 hr/m2 | Painting (ceilings): 0.12-0.18 hr/m2
Plastering: 0.2-0.35 hr/m2 | Timber flooring: 0.25-0.35 hr/m2
Wall framing: 0.15-0.25 hr/m2 | Brickwork: 0.8-1.2 hr/m2
Electrical points: 0.3-0.5 hr/point | Plumbing fixtures: 1.0-2.0 hr/fixture

=== WASTE FACTORS (APPLY TO MATERIALS) ===
Tiles: 1.05-1.10 (5-10%) | Timber: 1.07-1.12 (7-12%)
Paint: 1.05-1.08 (5-8%) | Concrete: 1.03-1.05 (3-5%)
Plasterboard: 1.05-1.10 (5-10%) | Fixings: 1.10-1.15 (10-15%)

=== REQUIRED OUTPUT STRUCTURE ===
Every composite MUST include:
1. code: Format GC-{MARKET}-XXXX (e.g., GC-AU-0700)
2. name: Short, descriptive name (e.g., "Floor tiling (wet areas)")
3. description: Detailed description of work included
4. market: One of AU, NZ, UK, CA, US
5. classification: Always "NRM"
6. nrm_level2_code: X.X format (e.g., "3.2")
7. unit: Appropriate UOM (m2, m, m3, EA, no, ls, hr)
8. scope_includes: Array of items included in rate
9. scope_excludes: Array of items NOT included
10. methodology: Object with installation_sequence, quality_checks, tools_required, safety_considerations
11. labour_hours_per_unit: Realistic productivity rate
12. gang_composition: Object defining crew makeup
13. material_waste_factor: Appropriate waste multiplier
14. components: Object with materials, labour, plant arrays
15. rates: Summary of productivity rates
16. spec_tier: "economy", "standard", or "premium"
17. metadata: confidence, needs_review, source_reference

=== QUALITY REQUIREMENTS ===
- Be realistic with productivity rates - use industry benchmarks
- Include all necessary materials (main + consumables)
- Account for fixings, adhesives, sealants where applicable
- Specify appropriate gang composition for the trade
- Include comprehensive scope boundaries (includes/excludes)
- Provide complete installation methodology
- Flag with needs_review: true if uncertain

=== RESPONSE FORMAT ===
Output a valid JSON object matching the golden composite schema. Do not include markdown code fences or explanatory text - just the JSON.`;

/**
 * Example composite for reference (floor tiling)
 */
export const COMPOSITE_EXAMPLE = {
  code: "GC-AU-0051",
  name: "Floor tiling (wet areas)",
  description: "Supply and install floor tiles to wet areas.",
  market: "AU",
  classification: "NRM",
  nrm_level2_code: "3.2",
  unit: "m2",
  total_rate: 0,
  scope_includes: ["Tiles", "Adhesive", "Grout"],
  scope_excludes: ["Waterproofing"],
  methodology: {
    spacing: "As per tile size",
    fixings: ["Adhesive", "Grout"],
    installation_sequence: ["Set out tiles", "Fix tiles", "Grout joints"],
    quality_checks: ["Level", "Grout finish"],
    tools_required: ["Tile cutter", "Trowel"],
    safety_considerations: ["Knee protection"],
  },
  labour_hours_per_unit: 0.35,
  gang_composition: { tiler: 1 },
  material_waste_factor: 1.08,
  components: {
    materials: [
      { resource_id: "MAT_AU_FLOOR_TILES", qty: 1, unit: "m2" },
      { resource_id: "MAT_AU_TILE_ADHESIVE", qty: 0.01, unit: "m3" },
      { resource_id: "MAT_AU_GROUT", qty: 0.005, unit: "m3" },
    ],
    labour: [{ resource_id: "LAB_AU_TILER", qty: 0.35, unit: "hr" }],
    plant: [],
  },
  rates: {
    material_coverage_factor: 1.08,
    labour_productivity_rate: "0.35 hr/m2",
    plant_productivity_rate: "0 hr/m2",
  },
  spec_tier: "standard",
  metadata: {
    reviewed_by: "",
    confidence: 0.55,
    needs_review: true,
    source_reference: "",
  },
};
