#!/usr/bin/env python3
"""
Fixed Validation Script for labour_productivity_constants

ISSUE RESOLVED:
- Removed check for non-existent 'code' field
- Uses 'activity_type' as identifier for labour records
- Documents presence of 'market' column (AU/NZ/UK)
- Validates critical fields that actually exist in the schema

This script validates the labour_productivity_constants CSV export and generates a report.
"""

import csv
import json
from datetime import datetime
from pathlib import Path
from collections import defaultdict

# Configuration
CSV_FILE = r"C:\dev\contech\temp-contechdata\contechdata-rates\heuristics-source\supabase-exports\labour_productivity_constants-20260103-v2.csv"
OUTPUT_DIR = r"C:\dev\contech\temp-contechdata\contechdata-rates\heuristics-source\supabase-exports"
REPORT_CSV = Path(OUTPUT_DIR) / "labour_validation_report-20260103-FIXED.csv"
REPORT_JSON = Path(OUTPUT_DIR) / "labour_validation_summary-20260103-FIXED.json"

# Define required fields that actually exist in the schema
REQUIRED_FIELDS = {
    'id': 'Primary identifier (UUID)',
    'activity_type': 'Work activity identifier',
    'trade_category': 'Trade classification',
    'output_unit': 'Unit of measurement',
}

# Fields expected to have numeric values
NUMERIC_FIELDS = {
    'hours_per_unit': 'Should be numeric or empty',
    'confidence_score': 'Should be numeric (0-1)',
}

# Fields that should not be empty (but may be)
RECOMMENDED_FIELDS = {
    'description': 'Activity description',
    'source_type': 'Data source type',
}

# Known optional fields
OPTIONAL_NUMERIC = {
    'minimum_hours': 'Optional minimum hours',
    'setup_hours': 'Optional setup hours',
    'effective_hours_per_day': 'Optional effective hours per day',
}


def validate_record(row_num, row):
    """Validate a single record and return list of issues."""
    issues = []

    # Check required fields exist and are non-empty
    for field, description in REQUIRED_FIELDS.items():
        if field not in row:
            issues.append({
                'severity': 'CRITICAL',
                'field': field,
                'issue': 'COLUMN_MISSING',
                'details': f'{description} - column not found in CSV'
            })
        elif not row[field] or row[field].strip() == '':
            issues.append({
                'severity': 'HIGH',
                'field': field,
                'issue': 'EMPTY_REQUIRED_FIELD',
                'details': f'{description} is empty'
            })

    # Validate numeric fields
    for field, description in NUMERIC_FIELDS.items():
        if field in row and row[field] and row[field].strip() != '':
            try:
                value = float(row[field])
                if field == 'confidence_score' and not (0 <= value <= 1):
                    issues.append({
                        'severity': 'MEDIUM',
                        'field': field,
                        'issue': 'INVALID_RANGE',
                        'details': f'Confidence score {value} not in range [0, 1]'
                    })
                elif field == 'hours_per_unit' and value <= 0:
                    issues.append({
                        'severity': 'HIGH',
                        'field': field,
                        'issue': 'INVALID_VALUE',
                        'details': f'Hours per unit {value} must be > 0'
                    })
            except ValueError:
                issues.append({
                    'severity': 'HIGH',
                    'field': field,
                    'issue': 'NON_NUMERIC',
                    'details': f'Expected numeric value, got: {row[field]}'
                })

    # Check recommended fields
    for field, description in RECOMMENDED_FIELDS.items():
        if field in row and (not row[field] or row[field].strip() == ''):
            issues.append({
                'severity': 'LOW',
                'field': field,
                'issue': 'EMPTY_RECOMMENDED_FIELD',
                'details': f'{description} is empty'
            })

    # Validate optional numeric fields if present
    for field, description in OPTIONAL_NUMERIC.items():
        if field in row and row[field] and row[field].strip() != '':
            try:
                value = float(row[field])
                if value < 0:
                    issues.append({
                        'severity': 'MEDIUM',
                        'field': field,
                        'issue': 'NEGATIVE_VALUE',
                        'details': f'{description} has negative value: {value}'
                    })
            except ValueError:
                issues.append({
                    'severity': 'LOW',
                    'field': field,
                    'issue': 'NON_NUMERIC',
                    'details': f'Expected numeric value, got: {row[field]}'
                })

    return issues


def analyze_data(records):
    """Analyze the full dataset for patterns and statistics."""
    stats = {
        'total_records': len(records),
        'activity_types': defaultdict(int),
        'trade_categories': defaultdict(int),
        'markets': defaultdict(int),
        'confidence_distribution': {
            'high': 0,    # >= 0.85
            'medium': 0,  # 0.60 - 0.84
            'low': 0,     # 0.30 - 0.59
            'very_low': 0  # < 0.30
        },
        'hours_per_unit_stats': {
            'populated': 0,
            'empty': 0,
            'min': None,
            'max': None,
            'avg': 0
        }
    }

    hours_values = []

    for row in records:
        # Activity type analysis
        if 'activity_type' in row and row['activity_type']:
            stats['activity_types'][row['activity_type']] += 1

        # Trade category analysis
        if 'trade_category' in row and row['trade_category']:
            stats['trade_categories'][row['trade_category']] += 1

        # Market analysis
        if 'market' in row and row['market']:
            stats['markets'][row['market']] += 1

        # Confidence score distribution
        if 'confidence_score' in row and row['confidence_score']:
            try:
                conf = float(row['confidence_score'])
                if conf >= 0.85:
                    stats['confidence_distribution']['high'] += 1
                elif conf >= 0.60:
                    stats['confidence_distribution']['medium'] += 1
                elif conf >= 0.30:
                    stats['confidence_distribution']['low'] += 1
                else:
                    stats['confidence_distribution']['very_low'] += 1
            except ValueError:
                pass

        # Hours per unit analysis
        if 'hours_per_unit' in row:
            if row['hours_per_unit'] and row['hours_per_unit'].strip() != '':
                try:
                    hours = float(row['hours_per_unit'])
                    stats['hours_per_unit_stats']['populated'] += 1
                    hours_values.append(hours)
                except ValueError:
                    pass
            else:
                stats['hours_per_unit_stats']['empty'] += 1

    if hours_values:
        stats['hours_per_unit_stats']['min'] = min(hours_values)
        stats['hours_per_unit_stats']['max'] = max(hours_values)
        stats['hours_per_unit_stats']['avg'] = sum(hours_values) / len(hours_values)

    return stats


def main():
    """Main validation function."""
    print("=" * 80)
    print("LABOUR PRODUCTIVITY CONSTANTS VALIDATION (FIXED)")
    print("=" * 80)
    print(f"\nValidation Date: {datetime.now().isoformat()}")
    print(f"CSV File: {CSV_FILE}")
    print(f"\nNOTE: This script FIXES the validator that incorrectly checked for")
    print(f"      a non-existent 'code' field. The actual identifier is 'activity_type'.")
    print(f"\nAdditional Notes:")
    print(f"  - 'market' column is present (AU/NZ/UK) but not validated here")
    print(f"  - Uses activity_type as the primary identifier for labour records")
    print("=" * 80)

    # Read and validate CSV
    records = []
    issues_by_severity = defaultdict(int)
    all_issues = []

    try:
        with open(CSV_FILE, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)

            for row_num, row in enumerate(reader, start=2):  # Start at 2 (after header)
                records.append(row)
                issues = validate_record(row_num, row)

                if issues:
                    for issue in issues:
                        issues_by_severity[issue['severity']] += 1
                        all_issues.append({
                            'row_num': row_num,
                            'activity_type': row.get('activity_type', 'N/A'),
                            'id': row.get('id', 'N/A'),
                            **issue
                        })

    except Exception as e:
        print(f"\nERROR: Failed to read CSV file: {e}")
        return False

    # Analyze data
    stats = analyze_data(records)

    # Generate report
    print(f"\n### SUMMARY ###\n")
    print(f"Total Records: {stats['total_records']}")
    print(f"Validation Issues Found: {len(all_issues)}")
    print(f"  - CRITICAL: {issues_by_severity['CRITICAL']}")
    print(f"  - HIGH: {issues_by_severity['HIGH']}")
    print(f"  - MEDIUM: {issues_by_severity['MEDIUM']}")
    print(f"  - LOW: {issues_by_severity['LOW']}")

    print(f"\n### DATA INTEGRITY CHECK ###\n")
    print(f"Activity Types: {len(stats['activity_types'])} unique values")
    print(f"Trade Categories: {len(stats['trade_categories'])} unique values")
    print(f"Markets: {len(stats['markets'])} (found: {', '.join(stats['markets'].keys())})")

    print(f"\n### HOURS PER UNIT ANALYSIS ###\n")
    print(f"Populated: {stats['hours_per_unit_stats']['populated']}")
    print(f"Empty/Null: {stats['hours_per_unit_stats']['empty']}")
    if stats['hours_per_unit_stats']['min'] is not None:
        print(f"Range: {stats['hours_per_unit_stats']['min']:.4f} - {stats['hours_per_unit_stats']['max']:.4f}")
        print(f"Average: {stats['hours_per_unit_stats']['avg']:.4f}")

    print(f"\n### CONFIDENCE SCORE DISTRIBUTION ###\n")
    for level, count in stats['confidence_distribution'].items():
        pct = (count / stats['total_records']) * 100 if stats['total_records'] > 0 else 0
        print(f"{level.upper():12} ({'>=' if level != 'very_low' else '<'} threshold): {count:4d} ({pct:5.1f}%)")

    print(f"\n### TOP ACTIVITY TYPES ###\n")
    for activity, count in sorted(stats['activity_types'].items(), key=lambda x: x[1], reverse=True)[:10]:
        pct = (count / stats['total_records']) * 100 if stats['total_records'] > 0 else 0
        print(f"  {activity:30s}: {count:4d} ({pct:5.1f}%)")

    print(f"\n### TOP TRADE CATEGORIES ###\n")
    for trade, count in sorted(stats['trade_categories'].items(), key=lambda x: x[1], reverse=True)[:10]:
        pct = (count / stats['total_records']) * 100 if stats['total_records'] > 0 else 0
        print(f"  {trade:30s}: {count:4d} ({pct:5.1f}%)")

    # Write CSV report
    print(f"\n### WRITING REPORTS ###\n")
    try:
        with open(REPORT_CSV, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=[
                'row_num', 'id', 'activity_type', 'severity', 'field', 'issue', 'details'
            ])
            writer.writeheader()
            writer.writerows(all_issues)
        print(f"[OK] CSV Report: {REPORT_CSV}")
        print(f"     ({len(all_issues)} issue records)")
    except Exception as e:
        print(f"[FAIL] Failed to write CSV report: {e}")
        return False

    # Write JSON summary
    try:
        summary = {
            'validation_date': datetime.now().isoformat(),
            'csv_file': CSV_FILE,
            'total_records': stats['total_records'],
            'validation_issues': {
                'total': len(all_issues),
                'by_severity': dict(issues_by_severity)
            },
            'data_statistics': {
                'activity_types_unique': len(stats['activity_types']),
                'trade_categories_unique': len(stats['trade_categories']),
                'markets_found': list(stats['markets'].keys()),
                'hours_per_unit': {
                    'populated_count': stats['hours_per_unit_stats']['populated'],
                    'empty_count': stats['hours_per_unit_stats']['empty'],
                    'min': stats['hours_per_unit_stats']['min'],
                    'max': stats['hours_per_unit_stats']['max'],
                    'avg': stats['hours_per_unit_stats']['avg'],
                },
                'confidence_score_distribution': dict(stats['confidence_distribution'])
            },
            'key_findings': [
                "FIXED: 'code' field validation removed (field does not exist)",
                "Using 'activity_type' as identifier for labour records",
                f"'market' column detected with values: {', '.join(stats['markets'].keys())}",
                f"Total records validated: {stats['total_records']}",
                f"Issues found: {len(all_issues)} (mostly LOW/MEDIUM severity)",
            ]
        }

        with open(REPORT_JSON, 'w', encoding='utf-8') as f:
            json.dump(summary, f, indent=2)
        print(f"[OK] JSON Summary: {REPORT_JSON}")
    except Exception as e:
        print(f"[FAIL] Failed to write JSON summary: {e}")
        return False

    # Final status
    print(f"\n### VALIDATION COMPLETE ###\n")
    if issues_by_severity['CRITICAL'] == 0 and issues_by_severity['HIGH'] == 0:
        print("Status: PASSED (with warnings)")
        print(f"Note: {issues_by_severity['MEDIUM'] + issues_by_severity['LOW']} LOW/MEDIUM issues found")
    elif issues_by_severity['CRITICAL'] == 0:
        print(f"Status: REVIEW RECOMMENDED ({issues_by_severity['HIGH']} HIGH severity issues)")
    else:
        print(f"Status: FAILED ({issues_by_severity['CRITICAL']} CRITICAL issues)")

    return True


if __name__ == '__main__':
    success = main()
    exit(0 if success else 1)
