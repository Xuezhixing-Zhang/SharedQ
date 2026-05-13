# Random Walk Setting II Current Results Summary

- Objective: Binary-treatment no-sharing design.
- Expected production sample sizes: 100, 300, 500, 1000
- Expected production replicates per sample size: 200
- Production result files found: 4 of 4
- Missing production sample sizes: none

## Result Files

| File | n | Entries | Non-null |
| --- | ---: | ---: | ---: |
| `results_100.rds` | 100 | 200 | 200 |
| `results_1000.rds` | 1000 | 200 | 200 |
| `results_300.rds` | 300 | 200 | 200 |
| `results_500.rds` | 500 | 200 | 200 |

## Artifact Inventory

- Calibration artifacts: `alternative_pars.rds`, `calibration_separated_large.rds`, `calibration_separated_moderate.rds`, `calibration_separated_reversed.rds`, `data_original.rds`, `parameter_spec_runs.rds`, `test_alternative_pars.rds`
- Test artifacts: `test_one_replicate.rds`

## Evaluation Output

- `evaluation_summary.csv` contains mean and standard deviation summaries by setting, sample size, method, and metric.
- Metrics are flattened from each replicate's `evaluation_*` objects so vector bias outputs appear as indexed columns.

