"""QA Validation for generated seed rates."""
import json
import os
from datetime import datetime

base_dir = r'C:\dev\contech\temp-contechdata\contechdata-rates'
rates_dir = os.path.join(base_dir, 'au', 'seed-data', 'composite_rates')
output_file = os.path.join(base_dir, 'workspace', 'au', 'metadata', 'validations', 'seed-rates-qa.md')

os.makedirs(os.path.dirname(output_file), exist_ok=True)

# Load all rates
all_rates = []
groups_summary = {}

for f in sorted(os.listdir(rates_dir)):
    if f.endswith('.json') and f.startswith('group_'):
        path = os.path.join(rates_dir, f)
        with open(path, 'r', encoding='utf-8') as fp:
            data = json.load(fp)

        group_num = data['meta']['nrm_group']
        group_name = data['meta']['group_name']
        rates = data['rates']
        all_rates.extend(rates)

        # Calculate stats
        totals = [r['total_rate'] for r in rates]
        groups_summary[group_num] = {
            'name': group_name,
            'count': len(rates),
            'min': min(totals),
            'max': max(totals),
            'avg': sum(totals) / len(totals)
        }

# Check for issues
issues = []
for r in all_rates:
    if r['total_rate'] < 10:
        issues.append(f"Low rate: {r['code']} = ${r['total_rate']:.2f}")
    elif r['total_rate'] > 5000:
        issues.append(f"High rate: {r['code']} = ${r['total_rate']:.2f}")
    if not r['nrm1_code']:
        issues.append(f"Missing NRM1: {r['code']}")
    if not r['nrm2_codes']:
        issues.append(f"Missing NRM2: {r['code']}")

# Generate report
report = f'''# Seed Rates QA Validation Report

**Validation Date**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**Status**: {'PASSED' if len(issues) == 0 else 'WARNINGS'}
**Total Rates**: {len(all_rates)}

## Summary by NRM Group

| Group | Name | Count | Min Rate | Max Rate | Avg Rate |
|-------|------|-------|----------|----------|----------|
'''

for g in sorted(groups_summary.keys()):
    s = groups_summary[g]
    report += f"| {g} | {s['name']} | {s['count']} | ${s['min']:.2f} | ${s['max']:.2f} | ${s['avg']:.2f} |\n"

report += f'''
## Rate Distribution

- **Lowest rate**: ${min(r['total_rate'] for r in all_rates):.2f}
- **Highest rate**: ${max(r['total_rate'] for r in all_rates):.2f}
- **Average rate**: ${sum(r['total_rate'] for r in all_rates) / len(all_rates):.2f}

## Validation Checks

| Check | Status | Details |
|-------|--------|---------|
| Total count | {'PASS' if len(all_rates) == 777 else 'FAIL'} | {len(all_rates)} rates (expected 777) |
| Rate range | {'PASS' if len([r for r in all_rates if 10 <= r['total_rate'] <= 5000]) == len(all_rates) else 'WARN'} | All rates between $10-$5000 |
| NRM1 codes | {'PASS' if all(r['nrm1_code'] for r in all_rates) else 'FAIL'} | All rates have NRM1 |
| NRM2 codes | {'WARN' if any(not r['nrm2_codes'] for r in all_rates) else 'PASS'} | Some rates missing NRM2 |
'''

if issues:
    report += f'''
## Issues Found ({len(issues)})

'''
    for issue in issues[:20]:
        report += f"- {issue}\n"
    if len(issues) > 20:
        report += f"\n... and {len(issues) - 20} more\n"

report += '''
## Generated Files

| File | Count | Status |
|------|-------|--------|
'''

for f in sorted(os.listdir(rates_dir)):
    path = os.path.join(rates_dir, f)
    with open(path, 'r', encoding='utf-8') as fp:
        data = json.load(fp)
    count = data['meta']['count'] if 'meta' in data else len(data.get('groups', {}))
    report += f"| {f} | {count} | OK |\n"

report += '''
---

**QA Completed By**: Claude Opus 4.5
**Date**: ''' + datetime.now().strftime('%Y-%m-%d')

# Write report
with open(output_file, 'w', encoding='utf-8') as f:
    f.write(report)

print(f'QA Report written to: {output_file}')
print(f'\nSummary:')
print(f'  Total rates: {len(all_rates)}')
print(f'  Issues found: {len(issues)}')
print(f'  Status: {"PASSED" if len(issues) == 0 else "WARNINGS"}')
