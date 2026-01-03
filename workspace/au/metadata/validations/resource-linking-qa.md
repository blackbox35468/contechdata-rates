# Resource Linking QA Report

**Generated**: 2026-01-03 13:27:00
**Status**: COMPLETE

## Summary

| Metric | Count | Percentage |
|--------|-------|------------|
| Total Rates | 777 | 100% |
| Labour Linked | 777 | 100.0% |
| Materials Linked | 0 | 0.0% |
| Plant Linked | 35 | 4.5% |

## By Group

| Group | Rates | Labour % | Materials % | Plant % |
|-------|-------|----------|-------------|---------|
| 0_facilitating | 17 | 100% | 0% | 41% |
| 1_substructure | 34 | 100% | 0% | 3% |
| 2_superstructure | 200 | 100% | 0% | 4% |
| 3_finishes | 81 | 100% | 0% | 5% |
| 4_fittings | 65 | 100% | 0% | 5% |
| 5_services | 215 | 100% | 0% | 2% |
| 8_external | 165 | 100% | 0% | 4% |

## Resource Libraries Used

| Type | Count |
|------|-------|
| Labour (LAB_AU_*) | 44 |
| Materials (MAT_AU_*) | 334 |
| Plant (PLT_AU_*) | 17 |

## Trade Detection Patterns

The following keyword patterns were used to detect trades:

| Pattern | Resource ID |
|---------|-------------|
| asbestos, hazmat, toxic | LAB_AU_CIVIL |
| electrical, power, cable | LAB_AU_ELECTRICIAN |
| plumb, pipe, drain | LAB_AU_PLUMBER |
| brick, block, masonry | LAB_AU_BRICKLAYER |
| paint, coat | LAB_AU_PAINTER |
| tile, floor | LAB_AU_TILER |
| roof, gutter | LAB_AU_ROOFER |
| concrete, slab | LAB_AU_CONCRETER |
| steel, weld | LAB_AU_STEEL_FIXER |
| timber, frame | LAB_AU_CARPENTER |
| plaster, gyprock | LAB_AU_PLASTERER |
| glaz, window | LAB_AU_GLAZIER |
| hvac, air con | LAB_AU_HVAC |
| default | LAB_AU_TRADES |

## Notes

- Labour: All rates have at least one linked labour resource
- Materials: Rates with generic "Materials allowance" keep inline values
- Plant: Only rates with identifiable plant needs get resource links

---

**QA Completed By**: Claude Opus 4.5
**Date**: 2026-01-03
