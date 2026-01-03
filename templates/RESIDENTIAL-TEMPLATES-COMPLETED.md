# Residential Templates - Completion Report

**Date**: 2026-01-03
**File**: `residential-with-assumptions.json`
**Size**: 133.6 KB
**Status**: ✅ **COMPLETE**

---

## Summary

- **Total Templates**: 20
- **Sector**: Residential
- **Quality**: Comprehensive metadata matching commercial-with-assumptions.json

---

## Template Breakdown

### Houses (Single Storey) - 8 templates
1. 2-Bedroom House (100m²) - 2bed 1bath
2. 3-Bedroom House (150m²) - 3bed 2bath
3. 4-Bedroom House (200m²) - 4bed 2bath
4. 5-Bedroom House (280m²) - 5bed 3bath
5. 4-Bedroom House Premium (220m²) - 4bed 3bath
6. 5-Bedroom House Premium (320m²) - 5bed 3bath
7. 4-Bedroom Rural House (250m²) - 4bed 2bath
8. 5-Bedroom Acreage House (350m²) - 5bed 3bath

### Houses (Two Storey) - 3 templates
9. 3-Bedroom House Two-Storey (170m²) - 3bed 2bath
10. 4-Bedroom House Two-Storey (230m²) - 4bed 2bath
11. 5-Bedroom House Two-Storey (300m²) - 5bed 3bath

### Townhouses - 3 templates
12. 2-Bedroom Townhouse (90m²) - 2bed 1bath
13. 3-Bedroom Townhouse (130m²) - 3bed 2bath
14. 4-Bedroom Townhouse (170m²) - 4bed 2bath

### Duplexes - 3 templates
15. 2-Bedroom Duplex per side (85m²) - 2bed 1bath
16. 3-Bedroom Duplex per side (125m²) - 3bed 2bath
17. 4-Bedroom Duplex per side (165m²) - 4bed 2bath

### Apartments - 3 templates
18. 1-Bedroom Apartment (55m²) - 1bed 1bath
19. 2-Bedroom Apartment (75m²) - 2bed 1bath
20. 3-Bedroom Apartment (105m²) - 3bed 2bath

---

## Metadata Coverage

Each template includes ALL required metadata sections:

### 1. measurement_assumptions
- ✅ **gfa_definition**: NCC Volume 2 measurement rules
- ✅ **typical_layout**: Room-by-room breakdown with dimensions
- ✅ **derivation_notes**: Explanation of design choices
- ✅ **scaling_rules**: Nonlinear items that don't scale with GFA

### 2. derivation_formulas
- ✅ **perimeter_calculation**: Formula + calculation + NRM reference
- ✅ **external_wall_area**: With waste factor applied (1.07 for brick)
- ✅ **roof_area**: With waste factor applied (1.05 for metal roofing)
- ✅ **power_points**: GFA ÷ 6m² (residential standard)
- ✅ **light_points**: GFA ÷ 10m² (residential standard)

### 3. productivity_standards
For each major trade:
- ✅ **Bricklaying**: 5.78 m²/person/day | Gang: 2 bricklayers + 1 labourer
- ✅ **Carpentry**: 2.0 m²/day walls, 20 m²/day roof | Gang: 2 carpenters + 1 labourer
- ✅ **Electrical**: 4hr minimum callout | Gang: 1 electrician + 1 apprentice
- ✅ **Plumbing**: 4hr minimum callout | Gang: 1 plumber + 1 apprentice

### 4. material_waste_factors
- ✅ Concrete: 1.05 (5%)
- ✅ Timber framing: 1.10 (10%)
- ✅ Brickwork/masonry: 1.07 (7%)
- ✅ Plasterboard: 1.10 (10%)
- ✅ Floor/wall tiles: 1.10 (10%)
- ✅ Carpet/vinyl: 1.15 (15%)
- ✅ Roof tiles: 1.08 (8%)
- ✅ Metal roofing: 1.05 (5%)
- ✅ Electrical cable: 1.05 (5%)
- ✅ Plumbing pipe: 1.05 (5%)

---

## Standards References Used

All templates reference:
- **STANDARDS-QUICK-REFERENCE.md** for productivity rates
- **STANDARDS-REFERENCE.md** for detailed explanations
- **NCC Volume 2** for residential building requirements
- **NRM Sections 2-5** for element classification

---

## Success Criteria Met

✅ All 20 residential templates have complete metadata
✅ Every derivation shows formula, calculation, waste factor, and NRM reference
✅ Productivity standards reference Australian industry data
✅ File saved and ready for review
✅ Quality matches commercial-with-assumptions.json (92KB) example

---

## File Location

**Output**: `temp-contechdata/contechdata-rates/templates/residential-with-assumptions.json`

Ready for Phase 2 integration and deployment.
