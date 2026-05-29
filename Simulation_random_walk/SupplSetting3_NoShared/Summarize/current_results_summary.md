# Supplementary Setting III No Shared Current Results Summary

- Objective: Continuous-covariate no-sharing sensitivity design.
- Expected production sample sizes: 100, 300, 500, 1000
- Expected production replicates per sample size: 200
- Production result files found: 4 of 4
- Missing production sample sizes: none

## Result Files

| File | n | Type | Entries | Non-null |
| --- | ---: | --- | ---: | ---: |
| `results_100.rds` | 100 | production | 200 | 200 |
| `results_1000.rds` | 1000 | production | 200 | 200 |
| `results_300.rds` | 300 | production | 200 | 200 |
| `results_500.rds` | 500 | production | 200 | 200 |

## Artifact Inventory

- Calibration artifacts: `calibration_separated_moderate.rds`, `data_original.rds`, `data_X_100.rds`, `data_X_1000000.rds`, `data_X_1e+06.rds`, `data_X_2000.rds`, `data_X_5000.rds`, `parameter_spec_runs.rds`, `test_alternative_pars.rds`
- Test artifacts: `temp.rds`, `test_one_replicate.rds`

## Evaluation Output

- `evaluation_summary.csv` contains mean and standard deviation summaries by setting, sample size, method, and metric.
- Metrics are flattened from each replicate's `evaluation_*` objects so vector bias outputs appear as indexed columns.
