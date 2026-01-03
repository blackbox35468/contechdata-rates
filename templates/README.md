# Construction Type Templates and Matrix

Comprehensive Australian construction template matrix for fast template-based estimates. Covers all building sectors with realistic GFA values, construction methods, and finishing levels.

## Overview

This folder contains the master template definition for the ContechData estimating system. Templates enable the `EB-select-template` → `EB-instantiate-template` pipeline to generate deterministic estimates without AI matching.

**Total Templates**: 76 across 6 sectors
- **Residential**: 20 templates (houses, townhouses, duplexes, apartments)
- **Commercial**: 10 templates (offices, retail, cafes, bars)
- **Healthcare**: 8 templates (medical clinics, dental surgeries, aged care, pharmacies)
- **Industrial**: 6 templates (warehouses, workshops, light industrial)
- **Education**: 3 templates (childcare, classrooms, STEM labs)
- **Civil**: 29 templates (roads, water/sewer, earthworks, drainage, retaining walls)

## Files

### Master Template Matrix
- **`template-matrix.json`** - Complete matrix with all 76 templates and swap extensions
  - Schema version 1.0.0
  - Metadata with sector and swap configuration
  - All templates organized by sector
  - 3 new swap options (cavity_brick_block, cavity_brick_metal_stud, metal_deck)

### Sector-Specific Files (for editing)
- **`construction-types/residential.json`** - 20 residential templates
- **`construction-types/commercial.json`** - 10 commercial templates
- **`construction-types/healthcare.json`** - 8 healthcare templates
- **`construction-types/industrial.json`** - 6 industrial templates
- **`construction-types/education.json`** - 3 education templates
- **`construction-types/civil-drainage.json`** - 5 civil drainage templates
- **`construction-types/civil-earthworks.json`** - 5 civil earthworks templates
- **`construction-types/civil-roads.json`** - 8 civil road templates
- **`construction-types/civil-retainingwalls.json`** - 5 civil retaining wall templates
- **`construction-types/civil-watersewer.json`** - 6 civil water/sewer templates

## Template Structure

Each template follows this schema:

```json
{
  "template_id": "au-res-3bed-bv-150",           // Unique identifier
  "name": "3-Bedroom Brick Veneer House",        // Display name
  "description": "...",                          // Detailed description
  "building_type": "residential_house",          // Type code
  "sector": "residential",                       // Sector classification
  "specifications": {
    "gfa_m2": 150,                               // Gross floor area
    "storeys": 1,                                // Number of storeys
    "bedrooms": 3,                               // Residential only
    "bathrooms": 2,                              // Residential only
    "living_areas": 2,                           // Residential only
    "garage_spaces": 2,                          // Residential only
    "default_construction": "brick_veneer",      // Wall system
    "construction_notes": "...",                 // Technical details
    "default_roofing": "metal",                  // Roof type
    "roof_type": "Steel (Colorbond)",            // Roof description
    "foundation_type": "Strip Footings",         // Foundation system
    "ceiling_height_m": 2.7,                     // Typical height
    "finish_level": "standard",                  // standard or premium
    "project_type": "new_build",                 // Project classification
    "location_context": "Australian suburban"    // Geographic context
  },
  "is_active": true,                             // Availability
  "applicable_swaps": [                          // Swappable categories
    "cladding", "roofing", "flooring", "windows", "kitchen", "bathroom"
  ],
  "tags": [                                      // For search and filtering
    "residential", "brick_veneer", "single_storey", "new_build", "3bed"
  ]
}
```

## Building Types by Sector

### Residential (20)
- **Detached Houses**: 2-bed (100m²), 3-bed (150m²), 4-bed (200m²), 5-bed (280m²)
- **Townhouses**: 2-bed (90m²), 3-bed (130m²), 4-bed (170m²)
- **Duplexes**: 2-bed (85m²/side), 3-bed (125m²/side), 4-bed (165m²/side)
- **Apartments**: 1-bed (55m²), 2-bed (75m²), 3-bed (105m²)
- **Premium Houses**: 4-bed (220m²), 5-bed (320m²)
- **Two-Storey Houses**: 3-bed (170m²), 4-bed (230m²), 5-bed (300m²)
- **Rural/Acreage**: 4-bed rural (250m²), 5-bed acreage (350m²)

### Commercial (10)
- **Offices**: Small (150m²), Medium (400m²), Large (1200m²)
- **Retail**: Small (80m²), Medium (150m²), Large (300m²)
- **Cafes/Restaurants**: Small (100m²), Medium (200m²)
- **Food Court**: 500m²
- **Bar/Pub**: 250m²

### Healthcare (8)
- **Medical Clinics**: Small (150m²), Medium (250m²), Large (500m²)
- **Dental Surgeries**: Small (120m²), Medium (200m²)
- **Aged Care**: Small (600m²), Medium (1200m²)
- **Pharmacy**: 120m²

### Industrial (6)
- **Warehouses**: Small (400m²), Medium (800m²), Large (2000m²)
- **Workshops**: Small (200m²), Medium (500m²)
- **Light Industrial**: 300m²

### Education (3)
- **Childcare Centre**: 400m²
- **Classroom Block**: 600m²
- **STEM Lab**: 350m²

## Civil Infrastructure Templates

Civil infrastructure templates use a **hybrid sizing model** that varies by asset type. Unlike building templates which use Gross Floor Area (GFA), civil templates are sized by:
- **Length** (meters) for linear assets (roads, pipes, channels)
- **Area** (square meters) for surface treatments (pavement, drainage basins)
- **Volume** (cubic meters) for bulk earthworks
- **Length × Height** for retaining walls

### Roads (8 templates)
- **2-Lane Sealed Roads**: Asphalt (7m width) and Concrete (7m width)
- **4-Lane Divided Highway**: 14m width with median
- **Unsealed Road**: 6m width gravel surface
- **Road Resurfacing**: Overlay on existing pavement
- **Road Widening**: Extension of existing road
- **Industrial Heavy-Duty Road**: Reinforced pavement for heavy vehicles
- **Local Access Road**: 5.5m width residential street

### Water/Sewer (6 templates)
- **Sewer Mains**: 150mm PVC and 225mm PVC
- **Water Mains**: 100mm DICL (Ductile Iron Cement Lined) and 200mm DICL
- **Stormwater Drainage**: 375mm RCP (Reinforced Concrete Pipe) and 600mm RCP

### Earthworks (5 templates)
- **Bulk Cut - Clay**: Excavation in clay soil
- **Bulk Fill - Select**: Imported select fill material
- **Site Preparation - Small**: <5,000m² sites
- **Site Preparation - Large**: >5,000m² sites
- **Rock Excavation**: Hard rock cutting

### Drainage (5 templates)
- **Open Channel - Lined**: Concrete lined drainage channel
- **Open Channel - Grass**: Natural grass swale
- **Detention Basin - Small**: <500m³ capacity
- **Detention Basin - Large**: >500m³ capacity
- **Kerb & Gutter**: Standard concrete kerb and gutter

### Retaining Walls (5 templates)
- **Concrete Retaining Wall - Low**: <1.5m height
- **Concrete Retaining Wall - Medium**: 1.5m-3m height
- **Concrete Retaining Wall - High**: >3m height
- **Masonry Retaining Wall**: Block construction
- **Gabion Wall**: Rock-filled basket system

## Wall Systems

### Brick Veneer (Default - Most Common)
- **Construction**: 110mm face brick + 40mm cavity + 90mm timber frame + 10mm plasterboard
- **Use**: Residential, most common Australian construction
- **Advantages**: Cost-effective, traditional, good thermal performance
- **Applied to**: Houses, townhouses, duplexes, residential apartments, childcare, classrooms

### Cavity Brick + Block (NEW)
- **Construction**: 110mm face brick + 90mm cavity + 200mm concrete block
- **Use**: Commercial, institutional, high thermal/acoustic performance
- **Advantages**: Higher durability, better fire rating, good insulation
- **Applied to**: Commercial offices, aged care facilities, healthcare

### Cavity Brick + Metal Stud (NEW)
- **Construction**: 110mm face brick + 90mm cavity + 90mm metal stud + 13mm plasterboard
- **Use**: Commercial, premium residential, fire-rated construction
- **Advantages**: Fire-rated, lightweight, consistent quality
- **Applied to**: Commercial apartments, offices, some premium residential

### Rendered Masonry
- **Construction**: 200mm concrete block + render both sides
- **Use**: Healthcare, commercial, low maintenance
- **Advantages**: Durable, low maintenance, weather-resistant
- **Applied to**: Medical clinics, retail shops, cafes, workshops

### Metal Cladding
- **Construction**: Insulated metal cladding on steel portal frame
- **Use**: Industrial, warehouses, workshops
- **Advantages**: Fast erection, economical, suitable for large spans
- **Applied to**: Warehouses, workshops, industrial units

## Roof Types

### Metal (Colorbond) - Default
- **Type**: Steel (Colorbond) or Metal Deck with membrane
- **Use**: Residential, commercial, industrial
- **GFA Multiplier**: 1.15 (includes pitch and eaves)
- **Applied to**: Most templates except education and some residential

### Tile - Traditional
- **Type**: Concrete Tiles or Terracotta Tiles
- **Use**: Residential, education (more traditional aesthetic)
- **GFA Multiplier**: 1.15 (includes pitch)
- **Applied to**: Childcare centres, classroom blocks, STEM labs, optional on residential

### Metal Deck - Commercial
- **Type**: Metal Deck with membrane waterproofing
- **Use**: Flat commercial and industrial roofs
- **GFA Multiplier**: 1.05 (flat roof)
- **Applied to**: Apartments, offices, some commercial buildings

## Swap Options

Templates support customization through predefined swap options:

### Cladding Swaps
- `brick_veneer` (default) - 110mm face brick + cavity + timber frame
- `timber_weatherboard` - Timber board finish
- `fibre_cement` - James Hardie or equivalent
- `rendered_masonry` - Cement render finish
- `metal_cladding` - Colorbond or similar
- **NEW**: `cavity_brick_block` - 110mm brick + cavity + block
- **NEW**: `cavity_brick_metal_stud` - 110mm brick + cavity + metal stud

### Roofing Swaps
- `colorbond_metal` (default) - Steel (Colorbond)
- `concrete_tiles` - Concrete tile finish
- `terracotta_tiles` - Clay tile finish
- **NEW**: `metal_deck` - Metal deck with membrane (commercial)

### Flooring Swaps
- `carpet` (default) - Carpet finish
- `timber_flooring` - Hardwood or timber
- `tiles` - Ceramic or porcelain
- `polished_concrete` - Polished concrete finish

### Window Swaps
- `aluminium` (default) - Standard aluminium frames
- `timber_frames` - Timber window frames
- `upvc` - uPVC frames

### Kitchen/Bathroom Swaps
- `standard` (default) - Standard fit-out
- `premium` - Premium finishes and fixtures

## Civil Swap Options

Civil templates support material and method swaps specific to infrastructure projects:

### Pavement Surface Swaps
- `asphalt` (default) - Hot mix asphalt wearing course
- `concrete` - Concrete pavement slab
- `spray_seal` - Bitumen spray seal (lower cost option)
- `unsealed` - Gravel surface (rural/temporary roads)

### Pipe Material Swaps
- `pvc_pipe` (default for sewer) - PVC sewer pipe
- `dicl_pipe` (default for water) - Ductile Iron Cement Lined
- `concrete_pipe` - Reinforced concrete pipe (stormwater)
- `hdpe_pipe` - High-density polyethylene (modern alternative)

### Base Material Swaps
- `crushed_rock` (default) - Standard crushed rock base
- `recycled_aggregate` - Recycled concrete/asphalt (sustainable option)
- `stabilized_base` - Cement or lime stabilized subgrade

### Kerb Type Swaps
- `concrete_kerb` (default) - Standard concrete kerb and gutter
- `asphalt_kerb` - Roll-over asphalt kerb
- `no_kerb` - Rural/unsealed roads without kerb

### Soil Condition Modifiers (Not Swaps)
Civil templates include soil condition factors that modify productivity:
- **Clay**: 1.0 (baseline)
- **Sand**: 0.8 (faster excavation)
- **Rock**: 2.5 (requires breaking/blasting)
- **Mixed**: 1.3 (conservative default)

These are applied as productivity modifiers, not material swaps.

## Australian GFA Standards

### Residential
- 1-bed apartment: 55m²
- 2-bed house/townhouse: 85-100m²
- 3-bed house: 140-170m²
- 4-bed house: 180-230m²
- 5-bed house: 250-350m²

### Commercial
- Small retail: 80-150m²
- Medium office: 300-600m²
- Large office: 1000-2000m²

### Healthcare
- Small medical clinic: 120-180m²
- Medium medical clinic: 200-350m²
- Dental surgery: 100-200m²

### Industrial
- Small warehouse: 300-600m²
- Medium warehouse: 700-1500m²
- Large warehouse: 1500-5000m²

### Education
- Childcare centre: 350-600m²
- Classroom block: 500-900m²
- STEM lab: 300-450m²

## Civil Sizing Metrics

Civil templates use different measurement units depending on asset type:

### Roads
- **Primary Metric**: Length (m) × Width (m) = Area (m²)
- **Example**: 100m × 7m = 700m² of 2-lane sealed road
- **Note**: Width is fixed per template (e.g., 7m for 2-lane, 14m for 4-lane)

### Pipes (Water/Sewer/Stormwater)
- **Primary Metric**: Length (m) with Diameter (mm)
- **Example**: 200m of 150mm sewer main
- **Note**: Diameter determines pipe material costs and trenching requirements

### Earthworks
- **Primary Metric**: Volume (m³) with soil/cut-fill type
- **Example**: 5,000m³ bulk cut in clay
- **Note**: Soil type affects productivity (clay, sand, rock, mixed)

### Drainage Systems
- **Channels**: Length (m) with cross-section type
- **Basins**: Area (m²) or Volume (m³) depending on design
- **Kerb & Gutter**: Length (m)

### Retaining Walls
- **Primary Metric**: Length (m) × Height (m) = Area (m²)
- **Example**: 50m × 2.5m = 125m² of medium-height concrete wall
- **Note**: Height category affects structural requirements and methodology

## Finish Levels

### Standard
- Basic but quality finishes
- Appropriate for most residential and commercial projects
- Cost-effective, market-standard materials
- Example: Brick veneer house with standard kitchen/bathroom

### Premium
- Higher quality finishes and materials
- Enhanced specifications for upmarket projects
- Premium kitchen/bathroom fixtures
- Example: 4-bed brick veneer house with premium finishes

## Template Selection Logic

Templates are matched via `EB-select-template` edge function using pattern matching:

### Residential Pattern Matching
- `%3-Bedroom%House%` → Matches all 3-bed detached houses
- `%Townhouse%` → Matches any townhouse
- `%Duplex%` → Matches duplexes
- `%Apartment%` → Matches apartments

### Commercial Pattern Matching
- `%Office%` → Matches office templates
- `%Retail%` → Matches retail shops
- `%Cafe%` → Matches cafe/restaurant
- `%Food Court%` → Matches food court

### Healthcare Pattern Matching
- `%Medical Clinic%` → Matches medical clinic templates
- `%Dental%` → Matches dental surgeries
- `%Aged Care%` → Matches aged care facilities
- `%Pharmacy%` → Matches pharmacy

### Industrial Pattern Matching
- `%Warehouse%` → Matches warehouse templates
- `%Workshop%` → Matches workshop templates
- `%Industrial%` → Matches light industrial

### Education Pattern Matching
- `%Childcare%` → Matches childcare centre
- `%Classroom%` → Matches classroom block
- `%STEM%` → Matches STEM lab

### Civil Template Selection Patterns
- `%Road%` → All road templates (8 matches)
- `%2-Lane%` → 2-lane specific roads (asphalt or concrete)
- `%4-Lane%` → 4-lane divided highway
- `%Sewer%` → Sewer main templates (150mm or 225mm)
- `%Water%` → Water main templates (100mm or 200mm)
- `%Stormwater%` → Stormwater drainage templates (375mm or 600mm)
- `%Earthwork%` or `%Bulk%` → Bulk earthwork templates
- `%Site Prep%` → Site preparation templates
- `%Drainage%` or `%Channel%` → Drainage systems
- `%Detention%` → Detention basin templates
- `%Kerb%` → Kerb and gutter
- `%Retaining%` or `%Wall%` → Retaining wall templates
- `%Concrete Wall%` → Concrete retaining walls (low/medium/high)
- `%Gabion%` → Gabion wall system

## Integration with EB Pipeline

### Step 1: Select Template (`EB-select-template`)
```
User Input: "3 bedroom brick veneer house 150m²"
    ↓
Haiku extracts: building_type=residential_house, bedrooms=3, gfa_m2=150
    ↓
Pattern matches: "%3-Bedroom%House%"
    ↓
Returns: template_id = "au-res-3bed-house-150"
```

### Step 2: Instantiate Template (`EB-instantiate-template`)
```
Template ID: au-res-3bed-house-150
User GFA: 150m² (= base GFA, so scale factor = 1.0)
    ↓
Load template_items from database
    ↓
Scale quantities: qty = base_qty × (user_gfa / base_gfa)
    ↓
Apply swaps: User selects "concrete tiles" for roofing
    ↓
Output: Fully instantiated scope with NRM L4 codes and quantities
```

## NRM Level 4 Integration

Each template item references NRM Level 4 cost codes:
- **Template Items** link to `nrm_l4_code` (e.g., "2.3.1", "2.5.1")
- **Composite Defaults** map NRM L4 to composites by building type
- **Swap Options** reference NRM L4 codes for alternative materials

### Building Templates
Building templates primarily reference:
- **NRM Section 2**: Substructure (foundations, basements)
- **NRM Section 3**: Superstructure (frame, walls, floors, roofs)
- **NRM Section 4**: Finishes (floor/wall/ceiling finishes)
- **NRM Section 5**: Services (MEP systems)

### Civil Templates
Civil templates reference:
- **NRM Level 1**: Preliminaries (site establishment, traffic management)
- **NRM Level 8**: External Works (roads, drainage, earthworks, retaining walls)

### Civil Asset Type Mapping to NRM Sections

| Civil Asset Type | NRM Level 1 Items | NRM Level 8 Items |
|------------------|-------------------|-------------------|
| Roads | Site access, traffic control | Road pavement, base course, kerbs |
| Water/Sewer Mains | Trench protection, traffic management | Pipe laying, bedding, trenching |
| Earthworks | Site establishment, plant mobilization | Bulk excavation, fill, compaction |
| Drainage | Erosion control, permits | Open channels, basins, pipe drainage |
| Retaining Walls | Engineering design, surveying | Concrete/masonry walls, drainage |

### Example: Roofing Swap (Building)
- Base: Colorbond metal (NRM L4: 2.3.1 Metal roof sheeting)
- Swap to Concrete Tiles: Different NRM L4 code (2.3.2 Tile roof covering)
- Same roofing item, different composite rate

### Example: Pavement Swap (Civil)
- Base: Asphalt (NRM L4: 8.1.1 Asphalt pavement)
- Swap to Concrete: Different NRM L4 code (8.1.2 Concrete pavement)
- Different structural requirements and composite rates

## Database Population

### Future Work
These templates are ready for database loading:

```sql
-- Insert into template_sets table
INSERT INTO template_sets (template_id, name, building_type, sector, specifications, is_active, applicable_swaps, tags)
SELECT * FROM json_to_recordset(template_matrix.json) AS t(template_id, name, building_type, ...);

-- Update swap_options for new wall systems
INSERT INTO template_swap_options (swap_category, option_name, ...)
SELECT * FROM json_to_recordset(swap_extensions.json);
```

## Notes

- **Source of Truth**: `template-matrix.json` is the canonical source
- **Sector Files**: `construction-types/*.json` are for easier editing; keep in sync with master
- **Total Templates**: 76 across 6 sectors (47 building + 29 civil)
- **Swap System**: Existing swap infrastructure used; building and civil-specific swap options added
- **Pattern Matching**: Template names must match patterns in `EB-select-template`
- **Scaling Models**:
  - **Building templates**: GFA-based scaling (quantities scale linearly with user GFA vs base GFA)
  - **Civil templates**: Metric-based scaling (length, area, volume, or length × height)
- **Australian Context**: All values calibrated for Australian construction standards
- **NRM Compliance**: All templates reference NRM Level 1, 2, 4, and 8 cost codes depending on sector
