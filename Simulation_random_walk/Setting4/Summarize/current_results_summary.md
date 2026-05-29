# Setting IV Current Results Summary

- Objective: Project Quit / Forever Free two-stage shared design. Current executable outputs are synthetic fallback runs unless a cleaned PQ/FF source data file is supplied through SETTING4_SOURCE_DATA.
- Expected production sample sizes: 100, 300, 500, 1000
- Expected production replicates per sample size: 200
- Production result files found: 0 of 4
- Missing production sample sizes: 100, 300, 500, 1000
- Non-production result sample sizes present: 100, 300, 500, 1000
- Note: Synthetic fallback files are useful for exercising code and evaluation paths, but they are not accepted production Setting IV results.

## Result Files

| File | n | Type | Entries | Non-null |
| --- | ---: | --- | ---: | ---: |
| `results_100_synthetic.rds` | 100 | synthetic fallback | 200 | 200 |
| `results_1000_synthetic.rds` | 1000 | synthetic fallback | 200 | 200 |
| `results_300_synthetic.rds` | 300 | synthetic fallback | 200 | 200 |
| `results_500_synthetic.rds` | 500 | synthetic fallback | 200 | 200 |

## Artifact Inventory

- Calibration artifacts: `calibration_pqff_shared_parsimonious_synthetic.rds`
- Test artifacts: none

## Evaluation Output

- `evaluation_summary.csv` contains mean and standard deviation summaries by setting, sample size, method, and metric.
- Metrics are flattened from each replicate's `evaluation_*` objects so vector bias outputs appear as indexed columns.
