#!/usr/bin/env python3
"""
NRM Mapping Enrichment Script
==============================

Enriches composite rate seed data with detailed NRM1 and NRM2 mappings
from the crosswalk CSV. Uses fuzzy string matching and scoring to find
the best Level 4 code match for each composite rate.

Usage:
    python enrich_nrm_mappings.py

Author: AI Assistant
Date: 2026-01-03
"""

import csv
import json
import os
import re
from collections import defaultdict
from dataclasses import dataclass
from difflib import SequenceMatcher
from pathlib import Path
from typing import Dict, List, Optional, Tuple


@dataclass
class CrosswalkEntry:
    """Represents a single row from the NRM crosswalk CSV."""
    nrm1_l4_code: str
    nrm1_l3_code: str
    nrm1_l2_code: str
    nrm1_description: str
    nrm1_unit: str
    nrm2_primary_ws: str
    nrm2_primary_ws_name: str
    nrm2_primary_items: str
    nrm2_secondary_ws: str
    confidence: str
    matched_keywords: str
    notes: str


@dataclass
class MatchScore:
    """Scoring breakdown for a crosswalk match."""
    unit_score: float
    description_score: float
    keyword_score: float
    total_score: float
    confidence: str


class NRMEnricher:
    """Main enrichment engine."""

    # Unit equivalence mappings
    UNIT_EQUIVALENTS = {
        'm²': ['m2', 'sqm', 'sq.m'],
        'm³': ['m3', 'cum', 'cu.m'],
        'm': ['lm', 'lin.m', 'linear m'],
        'nr': ['no', 'each', 'item', 'ea'],
        'item': ['nr', 'no', 'each', 'ea'],
    }

    # Confidence thresholds
    CONFIDENCE_HIGH = 0.75
    CONFIDENCE_MEDIUM = 0.50

    def __init__(self, crosswalk_path: str, rates_dir: str, output_dir: str):
        self.crosswalk_path = Path(crosswalk_path)
        self.rates_dir = Path(rates_dir)
        self.output_dir = Path(output_dir)
        self.crosswalk: Dict[str, List[CrosswalkEntry]] = defaultdict(list)
        self.stats = {
            'total_rates': 0,
            'total_files': 0,
            'high_confidence': 0,
            'medium_confidence': 0,
            'low_confidence': 0,
            'no_match': 0,
            'by_section': defaultdict(lambda: {'total': 0, 'high': 0, 'medium': 0, 'low': 0}),
        }

    def load_crosswalk(self):
        """Load crosswalk CSV and index by NRM1 L2 code."""
        print(f"Loading crosswalk from {self.crosswalk_path}")

        with open(self.crosswalk_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                entry = CrosswalkEntry(
                    nrm1_l4_code=row['nrm1_l4_code'],
                    nrm1_l3_code=row['nrm1_l3_code'],
                    nrm1_l2_code=row['nrm1_l2_code'],
                    nrm1_description=row['nrm1_description'],
                    nrm1_unit=row['nrm1_unit'],
                    nrm2_primary_ws=row['nrm2_primary_ws'],
                    nrm2_primary_ws_name=row['nrm2_primary_ws_name'],
                    nrm2_primary_items=row['nrm2_primary_items'],
                    nrm2_secondary_ws=row['nrm2_secondary_ws'],
                    confidence=row['confidence'],
                    matched_keywords=row['matched_keywords'],
                    notes=row['notes'],
                )
                self.crosswalk[entry.nrm1_l2_code].append(entry)

        print(f"Loaded {sum(len(v) for v in self.crosswalk.values())} crosswalk entries")
        print(f"Covering {len(self.crosswalk)} NRM1 L2 codes")

    def normalize_unit(self, unit: str) -> str:
        """Normalize unit strings for comparison."""
        unit = unit.lower().strip()

        # Check if this unit is in our equivalents
        for standard, variants in self.UNIT_EQUIVALENTS.items():
            if unit in [standard.lower()] + variants:
                return standard

        return unit

    def units_compatible(self, unit1: str, unit2: str) -> bool:
        """Check if two units are compatible."""
        norm1 = self.normalize_unit(unit1)
        norm2 = self.normalize_unit(unit2)

        if norm1 == norm2:
            return True

        # Check multi-unit fields (e.g., "m2/m3" or "nr/m")
        if '/' in norm2:
            return norm1 in norm2.split('/')

        return False

    def calculate_text_similarity(self, text1: str, text2: str) -> float:
        """Calculate similarity between two text strings using difflib."""
        # Normalize: lowercase, remove extra spaces
        t1 = ' '.join(text1.lower().split())
        t2 = ' '.join(text2.lower().split())

        return SequenceMatcher(None, t1, t2).ratio()

    def extract_keywords(self, text: str) -> set:
        """Extract meaningful keywords from text."""
        # Remove common words
        stopwords = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
                    'of', 'with', 'by', 'from', 'as', 'is', 'are', 'was', 'were', 'be',
                    'been', 'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will',
                    'would', 'should', 'could', 'may', 'might', 'must', 'can', 'details',
                    'stated', 'including', 'type'}

        # Split on non-alphanumeric, lowercase, filter stopwords
        words = re.findall(r'\b\w+\b', text.lower())
        return {w for w in words if w not in stopwords and len(w) > 2}

    def score_match(self, rate: dict, entry: CrosswalkEntry) -> MatchScore:
        """Score how well a rate matches a crosswalk entry."""

        # 1. Unit compatibility (40% weight)
        unit_score = 1.0 if self.units_compatible(rate['unit'], entry.nrm1_unit) else 0.0

        # 2. Description similarity (40% weight)
        rate_text = f"{rate.get('name', '')} {rate.get('description', '')}"
        description_score = self.calculate_text_similarity(rate_text, entry.nrm1_description)

        # 3. Keyword overlap (20% weight)
        keyword_score = 0.0
        if entry.matched_keywords:
            crosswalk_keywords = set(k.strip().lower() for k in entry.matched_keywords.split(','))
            rate_keywords = self.extract_keywords(rate_text)

            if crosswalk_keywords and rate_keywords:
                overlap = crosswalk_keywords & rate_keywords
                keyword_score = len(overlap) / max(len(crosswalk_keywords), len(rate_keywords))

        # Calculate weighted total
        total_score = (unit_score * 0.4) + (description_score * 0.4) + (keyword_score * 0.2)

        # Determine confidence level
        if total_score >= self.CONFIDENCE_HIGH:
            confidence = 'High'
        elif total_score >= self.CONFIDENCE_MEDIUM:
            confidence = 'Medium'
        else:
            confidence = 'Low'

        return MatchScore(
            unit_score=unit_score,
            description_score=description_score,
            keyword_score=keyword_score,
            total_score=total_score,
            confidence=confidence,
        )

    def find_best_match(self, rate: dict) -> Optional[Tuple[CrosswalkEntry, MatchScore]]:
        """Find the best crosswalk match for a rate."""
        nrm1_code = rate.get('nrm1_code', '')

        if not nrm1_code:
            return None

        # Get all crosswalk entries for this L2 code
        candidates = self.crosswalk.get(nrm1_code, [])

        if not candidates:
            return None

        # Score all candidates
        scored = [(entry, self.score_match(rate, entry)) for entry in candidates]

        # Sort by total score descending
        scored.sort(key=lambda x: x[1].total_score, reverse=True)

        # Return best match
        return scored[0] if scored else None

    def enrich_rate(self, rate: dict) -> dict:
        """Enrich a single rate with NRM mappings."""
        match_result = self.find_best_match(rate)

        if match_result:
            entry, score = match_result

            # Add new NRM1 fields
            rate['nrm1_l4_code'] = entry.nrm1_l4_code
            rate['nrm1_l3_code'] = entry.nrm1_l3_code
            rate['nrm1_l2_code'] = entry.nrm1_l2_code
            rate['nrm1_description'] = entry.nrm1_description

            # Add NRM2 mappings
            rate['nrm2_primary_ws'] = entry.nrm2_primary_ws
            rate['nrm2_primary_ws_name'] = entry.nrm2_primary_ws_name
            rate['nrm2_primary_items'] = entry.nrm2_primary_items
            rate['nrm2_secondary_ws'] = entry.nrm2_secondary_ws

            # Add mapping confidence
            rate['mapping_confidence'] = score.confidence

            # Update stats
            section = entry.nrm1_l2_code.split('.')[0]
            self.stats['by_section'][section]['total'] += 1
            self.stats['by_section'][section][score.confidence.lower()] += 1

            if score.confidence == 'High':
                self.stats['high_confidence'] += 1
            elif score.confidence == 'Medium':
                self.stats['medium_confidence'] += 1
            else:
                self.stats['low_confidence'] += 1
        else:
            # No match found - preserve original nrm1_code as nrm1_l2_code
            rate['nrm1_l2_code'] = rate.get('nrm1_code', '')
            rate['nrm1_l4_code'] = ''
            rate['nrm1_l3_code'] = ''
            rate['nrm1_description'] = ''
            rate['nrm2_primary_ws'] = ''
            rate['nrm2_primary_ws_name'] = ''
            rate['nrm2_primary_items'] = ''
            rate['nrm2_secondary_ws'] = ''
            rate['mapping_confidence'] = 'None'
            self.stats['no_match'] += 1

        # Remove old fields
        rate.pop('nrm1_code', None)
        rate.pop('nrm2_codes', None)

        return rate

    def process_file(self, filepath: Path):
        """Process a single JSON file."""
        print(f"\nProcessing {filepath.name}...")

        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)

        rates = data.get('rates', [])
        print(f"  Found {len(rates)} rates")

        # Enrich each rate
        for rate in rates:
            self.enrich_rate(rate)
            self.stats['total_rates'] += 1

        # Update meta
        data['meta']['enriched_date'] = '2026-01-03'
        data['meta']['crosswalk_version'] = 'NRM1_L4_to_NRM2_Crosswalk.csv'

        # Save back to same location
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

        print(f"  [OK] Updated {len(rates)} rates")
        self.stats['total_files'] += 1

    def process_all_files(self):
        """Process all group_*.json files in the rates directory."""
        json_files = sorted(self.rates_dir.glob('group_*.json'))

        if not json_files:
            print(f"No group_*.json files found in {self.rates_dir}")
            return

        print(f"\nFound {len(json_files)} JSON files to process")

        for filepath in json_files:
            self.process_file(filepath)

    def generate_qa_report(self):
        """Generate a QA report markdown file."""
        output_path = self.output_dir / 'nrm-mapping-qa.md'

        # Ensure output directory exists
        self.output_dir.mkdir(parents=True, exist_ok=True)

        print(f"\nGenerating QA report at {output_path}")

        with open(output_path, 'w', encoding='utf-8') as f:
            f.write("# NRM Mapping QA Report\n\n")
            f.write(f"**Generated**: 2026-01-03\n\n")
            f.write(f"**Crosswalk Source**: `NRM1_L4_to_NRM2_Crosswalk.csv`\n\n")

            # Summary statistics
            f.write("## Summary Statistics\n\n")
            f.write(f"- **Total Files Processed**: {self.stats['total_files']}\n")
            f.write(f"- **Total Rates Processed**: {self.stats['total_rates']}\n\n")

            # Confidence breakdown
            f.write("## Mapping Confidence Breakdown\n\n")
            total_with_match = self.stats['total_rates'] - self.stats['no_match']

            if total_with_match > 0:
                high_pct = (self.stats['high_confidence'] / total_with_match) * 100
                medium_pct = (self.stats['medium_confidence'] / total_with_match) * 100
                low_pct = (self.stats['low_confidence'] / total_with_match) * 100
            else:
                high_pct = medium_pct = low_pct = 0

            f.write(f"| Confidence Level | Count | Percentage |\n")
            f.write(f"|------------------|-------|------------|\n")
            f.write(f"| High (≥75%)      | {self.stats['high_confidence']} | {high_pct:.1f}% |\n")
            f.write(f"| Medium (50-75%)  | {self.stats['medium_confidence']} | {medium_pct:.1f}% |\n")
            f.write(f"| Low (<50%)       | {self.stats['low_confidence']} | {low_pct:.1f}% |\n")
            f.write(f"| No Match         | {self.stats['no_match']} | - |\n\n")

            # Section breakdown
            f.write("## Statistics by NRM Section\n\n")
            f.write("| Section | Total | High | Medium | Low |\n")
            f.write("|---------|-------|------|--------|-----|\n")

            for section in sorted(self.stats['by_section'].keys()):
                data = self.stats['by_section'][section]
                f.write(f"| {section} | {data['total']} | {data['high']} | {data['medium']} | {data['low']} |\n")

            # Low confidence items requiring review
            f.write("\n## Items Requiring Manual Review\n\n")
            f.write("The following items have low confidence mappings and should be manually reviewed:\n\n")

            # Re-read files to collect low confidence items
            low_confidence_items = []
            for filepath in sorted(self.rates_dir.glob('group_*.json')):
                with open(filepath, 'r', encoding='utf-8') as rf:
                    data = json.load(rf)
                    for rate in data.get('rates', []):
                        if rate.get('mapping_confidence') == 'Low':
                            low_confidence_items.append({
                                'file': filepath.name,
                                'code': rate.get('code', ''),
                                'name': rate.get('name', ''),
                                'unit': rate.get('unit', ''),
                                'nrm1_l2_code': rate.get('nrm1_l2_code', ''),
                                'nrm1_l4_code': rate.get('nrm1_l4_code', ''),
                                'nrm1_description': rate.get('nrm1_description', ''),
                            })

            if low_confidence_items:
                f.write(f"**Total Low Confidence Items**: {len(low_confidence_items)}\n\n")
                f.write("| File | Code | Name | Unit | L2 Code | L4 Code | NRM1 Description |\n")
                f.write("|------|------|------|------|---------|---------|------------------|\n")

                for item in low_confidence_items[:50]:  # Limit to first 50
                    f.write(f"| {item['file']} | {item['code']} | {item['name']} | {item['unit']} | ")
                    f.write(f"{item['nrm1_l2_code']} | {item['nrm1_l4_code']} | {item['nrm1_description'][:50]}... |\n")

                if len(low_confidence_items) > 50:
                    f.write(f"\n*Showing first 50 of {len(low_confidence_items)} items*\n")
            else:
                f.write("[OK] No low confidence items found!\n")

            # No match items
            no_match_items = []
            for filepath in sorted(self.rates_dir.glob('group_*.json')):
                with open(filepath, 'r', encoding='utf-8') as rf:
                    data = json.load(rf)
                    for rate in data.get('rates', []):
                        if rate.get('mapping_confidence') == 'None':
                            no_match_items.append({
                                'file': filepath.name,
                                'code': rate.get('code', ''),
                                'name': rate.get('name', ''),
                                'unit': rate.get('unit', ''),
                                'nrm1_l2_code': rate.get('nrm1_l2_code', ''),
                            })

            if no_match_items:
                f.write("\n## Items With No Matches\n\n")
                f.write(f"**Total No Match Items**: {len(no_match_items)}\n\n")
                f.write("| File | Code | Name | Unit | Original L2 Code |\n")
                f.write("|------|------|------|------|------------------|\n")

                for item in no_match_items:
                    f.write(f"| {item['file']} | {item['code']} | {item['name']} | {item['unit']} | {item['nrm1_l2_code']} |\n")

        print(f"[OK] QA report generated")

    def run(self):
        """Execute the full enrichment pipeline."""
        print("="*70)
        print("NRM Mapping Enrichment Script")
        print("="*70)

        # Step 1: Load crosswalk
        self.load_crosswalk()

        # Step 2: Process all JSON files
        self.process_all_files()

        # Step 3: Generate QA report
        self.generate_qa_report()

        # Summary
        print("\n" + "="*70)
        print("ENRICHMENT COMPLETE")
        print("="*70)
        print(f"Files processed: {self.stats['total_files']}")
        print(f"Rates enriched: {self.stats['total_rates']}")
        print(f"  - High confidence: {self.stats['high_confidence']}")
        print(f"  - Medium confidence: {self.stats['medium_confidence']}")
        print(f"  - Low confidence: {self.stats['low_confidence']}")
        print(f"  - No match: {self.stats['no_match']}")
        print("="*70)


def main():
    """Main entry point."""
    # Define paths
    base_dir = Path(__file__).parent.parent
    crosswalk_path = base_dir / 'NRM' / 'NRM1_L4_to_NRM2_Crosswalk.csv'
    rates_dir = base_dir / 'au' / 'seed-data' / 'composite_rates'
    output_dir = base_dir / 'workspace' / 'au' / 'metadata' / 'validations'

    # Validate paths exist
    if not crosswalk_path.exists():
        print(f"ERROR: Crosswalk file not found: {crosswalk_path}")
        return 1

    if not rates_dir.exists():
        print(f"ERROR: Rates directory not found: {rates_dir}")
        return 1

    # Run enrichment
    enricher = NRMEnricher(
        crosswalk_path=str(crosswalk_path),
        rates_dir=str(rates_dir),
        output_dir=str(output_dir),
    )

    enricher.run()

    return 0


if __name__ == '__main__':
    exit(main())
