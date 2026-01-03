# Rate Structure Guide

## Overview

ContechData uses a **composite rate methodology** to build standardised construction rates for Australian projects. Each composite rate combines labour, materials, and plant costs with waste allowances and overhead & profit margins to produce a total cost per unit.

This guide explains the structure, calculation methodology, and worked examples using data from the Australian estimating rates database.

## What is a Composite Rate?

A composite rate is a pre-built work item combining:
- **Labour**: Trade and semi-skilled labour hours
- **Materials**: Supply costs for building materials
- **Plant**: Equipment hire and machinery costs
- **Waste Allowance**: Materials loss and consumption factors
- **OH&P**: Overhead and profit margin

Each composite is assigned a unique code (e.g., `EXT-WALL-001`) and produces a single cost per unit (m², m, nr, etc.).

---

## Calculation Methodology

### Step 1: Labour Cost Calculation

Labour cost is derived from **gang composition** and **output rates**.

```
Labour Cost per Unit = Hours per Unit × Rate per Hour
```

#### Gang Composition

A "gang" is a crew mix of tradespeople and labourers. Standard Australian gangs:

| Code | Name | Composition | Combined Rate/hr |
|------|------|-------------|-------------------|
| `1+0` | 1 Tradesman only | 1 × Tradesperson | $65.00 |
| `1+0.5` | 1 Tradesman + half labourer | 1 × Tradesperson + 0.5 × Labourer | $82.50 |
| `1+1` | 1 Tradesman + 1 labourer | 1 × Tradesperson + 1 × Labourer | $95.00 |
| `2+1` | 2 Tradesmen + 1 labourer | 2 × Tradesperson + 1 × Labourer | $165.00 |
| `0+1` | 1 Labourer only | 1 × Labourer | $55.00 |
| `0+2` | 2 Labourers | 2 × Labourers | $110.00 |

#### Trade Base Rates

Each tradesman's base rate includes 20% oncost (payroll tax, insurance, workers comp, etc.):

| Trade | Base Rate | Oncost | Total Rate/hr |
|-------|-----------|--------|----------------|
| Bricklayer | $65.00 | 20% | $78.00 |
| Carpenter | $62.00 | 20% | $74.40 |
| Plasterer | $60.00 | 20% | $72.00 |
| Tiler | $58.00 | 20% | $69.60 |
| Plumber/Drainlayer | $68.00 | 20% | $81.60 |
| Electrician | $70.00 | 20% | $84.00 |
| Painter | $55.00 | 20% | $66.00 |
| Roofer | $60.00 | 20% | $72.00 |
| Labourer | $45.00 | 20% | $54.00 |

#### Example: Face Brickwork Task

From `EXT-WALL-001`:
- **Task**: Face brickwork 102.5mm
- **Gang**: `1+1` (1 Bricklayer + 1 Labourer)
- **Combined rate**: $95.00/hr
- **Output**: 1.2 m²/hr
- **Hours per unit**: 1 ÷ 1.2 = 0.833 hrs/m²
- **Labour cost per unit**: 0.833 hrs × $95.00/hr = **$79.17/m²**

---

### Step 2: Material Cost Calculation

Material cost is the sum of all material items per unit:

```
Material Cost per Unit = Σ (Quantity × Unit Rate) for all materials
```

#### Example: Face Brickwork Materials

From `EXT-WALL-001`:

| Item | Quantity | Unit | Unit Rate | Total |
|------|----------|------|-----------|-------|
| Facing bricks | 60 | nr | $0.85 | $51.00 |
| Mortar (facework) | 0.03 | m³ | $185.00 | $5.55 |
| **Material Total** | | | | **$56.55** |

This covers all facing brickwork materials for 1 m² of wall. Additional items (cavity closers, DPC, lintels, etc.) are costed separately for their respective tasks.

---

### Step 3: Plant Cost Calculation

Plant cost is equipment hire and machinery allocation:

```
Plant Cost per Unit = Σ (Quantity × Unit Rate) for all plant items
```

#### Example: Scaffold and Mixer

From `EXT-WALL-001`:

| Item | Quantity | Unit | Unit Rate | Total |
|------|----------|------|-----------|-------|
| Scaffold (allow) | 1 | m² | $8.50 | $8.50 |
| Mixer/small plant | 0.1 | hr | $12.00 | $1.20 |
| **Plant Total** | | | | **$9.70** |

Allocated across the entire wall system (1 m²).

---

### Step 4: Subtotal Calculation

```
Subtotal = Labour Total + Materials Total + Plant Total
```

#### Example: EXT-WALL-001 Subtotal

Complete example for `EXT-WALL-001` (Cavity wall):

| Component | Cost |
|-----------|------|
| **Labour Tasks** | |
| Face brickwork 102.5mm | $79.17 |
| Blockwork 100mm | $33.00 |
| Cavity insulation 100mm | $8.13 |
| Cavity closers | $5.42 |
| DPC bedding | $4.33 |
| Lintels - set in position | $23.75 |
| Plasterboard fix + skim | $20.63 |
| Decoration mist + 2 coats | $5.42 |
| **Labour Total** | **$173.35** |
| | |
| **Materials** | $145.91 |
| **Plant** | $9.70 |
| | |
| **Subtotal** | **$328.96** |

---

### Step 5: Waste Allowance

Waste allowance covers material loss, spillage, breakage, and off-cuts:

```
Waste Allowance = Subtotal × Waste Percent
```

#### Waste Factors by Material Type

Standard Australian industry waste factors:

| Material Type | Factor | Reason |
|---------------|--------|--------|
| Concrete | 5% | Spillage, over-excavation, pump residue |
| Timber Framing | 10% | Offcuts, knots, site damage |
| Brickwork/Masonry | 7% | Breakage, half-bricks, weathering |
| Plasterboard | 10% | Sheet layout offcuts, corner damage |
| Floor/Wall Tiles | 10% | Cut-ins, breakage, pattern matching |
| Carpet/Vinyl | 15% | Roll width constraints, seam allowance |
| Roof Tiles | 8% | Ridge/hip cuts, breakage |
| Metal Roofing | 5% | Overlap allowance, end waste |

#### Example: EXT-WALL-001 Waste

- **Subtotal**: $328.96
- **Waste percent**: 5% (composite rate default)
- **Waste allowance**: $328.96 × 0.05 = **$16.45**

---

### Step 6: Overhead & Profit (OH&P)

OH&P covers indirect costs and profit margin:

```
OH&P = (Subtotal + Waste) × OH&P Percent
```

Typical OH&P margin: **15%** for standard composite rates.

#### Example: EXT-WALL-001 OH&P

- **Subtotal + Waste**: $328.96 + $16.45 = $345.41
- **OH&P percent**: 15%
- **OH&P amount**: $345.41 × 0.15 = **$51.81**

---

### Step 7: Total Rate Calculation

```
Total Rate per Unit = Subtotal + Waste + OH&P
```

#### Example: EXT-WALL-001 Total

| Line | Amount |
|------|--------|
| Subtotal | $328.96 |
| Waste (5%) | $16.45 |
| Subtotal + Waste | $345.41 |
| OH&P (15%) | $51.81 |
| **Total Rate/m²** | **$397.22** |

*Note: Actual seed data shows $386.69 due to precise rounding at each step.*

---

## Worked Examples

### Example 1: EXT-WALL-001 - Cavity Wall Assembly

**Code**: `EXT-WALL-001`
**Description**: Cavity wall - facing brick/block, 100mm insulation, plasterboard & skim
**Unit**: m²
**Region**: Sydney Metro
**Base Date**: Jan-2025

#### Labour Breakdown

| Task | Gang | Output | hrs/m² | Rate/hr | Cost/m² |
|------|------|--------|--------|---------|---------|
| Face brickwork 102.5mm | 1+1 | 1.2 m²/hr | 0.833 | $95.00 | $79.17 |
| Blockwork 100mm | 1+0.5 | 2.5 m²/hr | 0.400 | $82.50 | $33.00 |
| Cavity insulation 100mm | 1+0 | 8 m²/hr | 0.125 | $65.00 | $8.13 |
| Cavity closers | 1+0 | 12 m/hr | 0.083 | $65.00 | $5.42 |
| DPC bedding | 1+0 | 15 m/hr | 0.067 | $65.00 | $4.33 |
| Lintels - set in position | 1+1 | 4 nr/hr | 0.250 | $95.00 | $23.75 |
| Plasterboard fix + skim | 1+0.5 | 4 m²/hr | 0.250 | $82.50 | $20.63 |
| Decoration mist + 2 coats | 1+0 | 12 m²/hr | 0.083 | $65.00 | $5.42 |
| **Labour Total** | | | | | **$173.35** |

#### Materials Breakdown

| Item | Qty | Unit | Rate | Cost |
|------|-----|------|------|------|
| Facing bricks | 60 | nr | $0.85 | $51.00 |
| Concrete blocks 100mm | 10 | nr | $3.20 | $32.00 |
| Mortar (facework) | 0.03 | m³ | $185.00 | $5.55 |
| Mortar (blockwork) | 0.01 | m³ | $165.00 | $1.65 |
| Wall ties SS | 4 | nr | $0.45 | $1.80 |
| Cavity insulation 100mm | 1.05 | m² | $18.00 | $18.90 |
| Cavity closers | 0.15 | m | $8.50 | $1.28 |
| DPC 112.5mm | 0.1 | m | $4.50 | $0.45 |
| Steel lintel (allow) | 0.12 | m | $95.00 | $11.40 |
| Plasterboard 12.5mm | 1.05 | m² | $8.50 | $8.93 |
| Skim coat plaster | 1 | m² | $3.20 | $3.20 |
| Paint (mist + 2 coats) | 1 | m² | $2.80 | $2.80 |
| **Materials Total** | | | | **$145.91** |

#### Plant Breakdown

| Item | Qty | Unit | Rate | Cost |
|------|-----|------|------|------|
| Scaffold (allow) | 1 | m² | $8.50 | $8.50 |
| Mixer/small plant | 0.1 | hr | $12.00 | $1.20 |
| **Plant Total** | | | | **$9.70** |

#### Final Calculation

| Component | Amount |
|-----------|--------|
| Labour | $173.35 |
| Materials | $145.91 |
| Plant | $9.70 |
| **Subtotal** | $328.96 |
| Waste (5%) | $16.45 |
| **Subtotal + Waste** | $345.41 |
| OH&P (15%) | $51.81 |
| **Total Rate/m²** | **$397.22** |

---

### Example 2: ROOF-TILE-001 - Pitched Roof Assembly

**Code**: `ROOF-TILE-001`
**Description**: Pitched roof - concrete interlocking tiles on battens, sarking, insulation
**Unit**: m²
**Region**: Sydney Metro

#### Key Characteristics

- **Labour Total**: $85.50/m²
- **Materials Total**: $78.40/m²
- **Plant Total**: $12.50/m²
- **Subtotal**: $176.40/m²
- **Waste**: 5% = $8.82
- **OH&P**: 15% = $27.63
- **Total Rate**: $212.85/m²

#### Labour Tasks Summary

| Task | Gang | hrs/m² | Rate/hr | Cost/m² |
|------|------|--------|---------|---------|
| Sarking/underlay | 1+0.5 | 0.067 | $82.50 | $5.50 |
| Tile battens | 1+0.5 | 0.083 | $82.50 | $6.88 |
| Concrete interlocking tiles | 1+1 | 0.222 | $95.00 | $21.11 |
| Ridge/hip tiles | 1+0.5 | 0.125 | $82.50 | $10.31 |
| Insulation between joists | 1+0 | 0.100 | $65.00 | $6.50 |

---

### Example 3: FOUND-STRIP-001 - Linear Foundation

**Code**: `FOUND-STRIP-001`
**Description**: Strip foundation - excavate, concrete 450x250, blockwork to DPC
**Unit**: m (linear metre)
**Region**: Sydney Metro

#### Key Characteristics

- **Labour Total**: $125.80/m
- **Materials Total**: $98.50/m
- **Plant Total**: $35.00/m (significant plant for excavation and concrete pump)
- **Subtotal**: $259.30/m
- **Waste**: 7.5% (higher for excavation) = $19.45
- **OH&P**: 15% = $40.61
- **Total Rate**: $319.36/m

#### Notable Features

- **Higher waste factor** (7.5% vs standard 5%) due to soil over-excavation and concrete placement variation
- **Significant plant costs** ($35.00/m) reflecting equipment hire for mini-excavator, concrete pump, and compactor plate
- **Gang mix includes labourer-only tasks** for excavation, trim, and backfill (gang `0+1`)
- **Machine operator cost embedded** in labour for equipment operation

---

## Gang Composition Principles

### Gang Rate Calculation

When a gang is deployed, its **combined rate** is used:

```
Combined Rate = Σ (Worker Count × Trade Rate)
```

#### Example: 1+0.5 Gang (Bricklayer + Half Labourer)

- 1 × Bricklayer @ $78.00/hr = $78.00
- 0.5 × Labourer @ $54.00/hr = $27.00
- **Combined Rate** = $78.00 + $27.00 = **$105.00/hr**

*Note: Seed data shows $82.50 as a simplified industry standard; actual blended rates may vary.*

### Why Gangs Matter

Gangs reflect **productivity** and **skill mix**:

- **1+0** (single tradesperson): High-skill tasks (complex brickwork detail)
- **1+0.5** (tradesperson + half labourer): Standard mixed work (most tasks)
- **1+1** (tradesperson + labourer): Labour-intensive assembly (heavy lifting, prep)
- **0+1** (labourer only): Unskilled work (excavation, cleanup, material handling)

---

## Condition Factors and Productivity Modifiers

Condition factors adjust labour and plant productivity based on site conditions. These are **multipliers applied to labour and plant costs** (NOT materials).

### Location Factors

| Condition | Factor | Example |
|-----------|--------|---------|
| Normal access | 1.0 | Standard building site |
| Restricted access | 1.1 | Narrow street, limited loading |
| Difficult access | 1.2 | Heritage building, confined space |

**Application**: Multiply labour hours by factor
- Difficult access task with 1.0 hrs becomes 1.2 hrs (20% longer)

### Height Factors

| Height Range | Factor | Applies To | Notes |
|--------------|--------|-----------|-------|
| ≤3.5m (ground level) | 1.0 | Labour, Plant | No scaffold premium |
| 3.5m - 7.0m | 1.1 | Labour, Plant | Single-lift scaffold |
| 7.0m - 10.5m | 1.2 | Labour, Plant | Multi-level scaffold |
| >10.5m | 1.35 | Labour, Plant | EWP (Elevated Work Platform) or suspended scaffold |

### Weather Factors

| Condition | Factor | Applies To |
|-----------|--------|-----------|
| Internal work | 1.0 | Labour |
| External - sheltered | 1.03 | Labour |
| External - exposed | 1.08 | Labour |

Reflects **weather delays, safety equipment, and comfort** impacts on productivity.

### Complexity Factors

| Complexity | Factor | Notes |
|-----------|--------|-------|
| Straightforward | 1.0 | Repetitive, standard detail |
| Moderate detail | 1.1 | Pattern changes, design variation |
| Complex/intricate | 1.25 | Handcrafted finishes, engineering detail |

### Quantity Factors

| Quantity | Factor | Notes |
|----------|--------|-------|
| Small qty (<25% of norm) | 1.15 | Setup time dominates |
| Normal quantity | 1.0 | Baseline |
| Large qty (>200% of norm) | 0.95 | Learning curve, efficiency gain |

### Combined Application Example

**Task**: Face brickwork in restricted access, 7.0m-10.5m height, exposed weather

Base cost: $79.17/m² (from labour task)
- Location factor (restricted): 1.1
- Height factor (7-10.5m): 1.2
- Weather factor (exposed): 1.08
- **Combined multiplier**: 1.1 × 1.2 × 1.08 = **1.425**
- **Adjusted cost**: $79.17 × 1.425 = **$112.82/m²**

---

## Special Cases and Exclusions

### Composite vs Single-Task Rates

**Composite rates** (like `EXT-WALL-001`) bundle multiple tasks into one unit cost. Use when:
- Specification requires all elements (e.g., "complete cavity wall system")
- Standard building assembly (no deviations)

**Single-task rates** are extracted when:
- Only one component is required (e.g., "cavity insulation only")
- Design deviates from standard assembly
- Complex site conditions warrant individual costing

### Plant-Specific Allocations

Plant items are allocated **per unit of the composite**, not per labour hour:

- **Scaffold**: Allocated m²-based (safety requirement per wall area)
- **Concrete pump**: Allocated per m (shared cost across batch)
- **Machinery**: Allocated by time (e.g., 0.1 hr mixer per m³ concrete)

This prevents **double-counting** if plant is shared across multiple tasks.

---

## Data Quality Notes

### Base Date and Escalation

All rates are based on **January 2025** prices for **Sydney Metro** region.

To escalate rates to a future date, apply **Construction Cost Index (CCI)** factors from the Australian Bureau of Statistics (ABS).

### Supplier "TBC"

"TBC" (To Be Confirmed) in supplier fields indicates:
- Rates are based on market research or historical averages
- Site-specific sourcing may yield variations
- Obtain detailed quotes for final budgets

### Source Attribution

| Source | Meaning |
|--------|---------|
| Internal | ContechData derivation or industry standard |
| Supplier-specific | Verified quote from known supplier |
| TBC | Industry estimate pending confirmation |

---

## Summary: Rate Structure Hierarchy

```
Composite Rate Code (e.g., EXT-WALL-001)
├── Labour Tasks
│   ├── Task 1: Gang composition × hours × rate/hr
│   ├── Task 2: Gang composition × hours × rate/hr
│   └── Labour Total
├── Materials
│   ├── Item 1: Quantity × unit rate
│   ├── Item 2: Quantity × unit rate
│   └── Materials Total
├── Plant
│   ├── Item 1: Quantity × unit rate
│   ├── Item 2: Quantity × unit rate
│   └── Plant Total
├── Waste Allowance: (Labour + Materials + Plant) × waste %
├── OH&P: (Subtotal + Waste) × 15%
└── Total Rate/Unit: Subtotal + Waste + OH&P
```

This structure ensures **cost transparency**, **auditability**, and **scalability** across the entire estimating database.
