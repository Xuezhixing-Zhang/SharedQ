# Supplementary Setting IV No Shared Current Results Summary

- Objective: Project Quit / Forever Free two-stage synthetic-parametric no-sharing sensitivity design.
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

- Calibration artifacts: `calibration_pqff_separated_parsimonious.rds`
- Test artifacts: none

## Candidate Calibration

- Source mode: synthetic_parametric
- Design source complete consent rows used for aggregate constants: 469
- Projection Monte Carlo rows: 100000
- Calibration search rows: 20000
- Calibration starts: 5
- Search objective: 0.0000
- Sum absolute target difference: 0.0000
- Max absolute target difference: 0.0000
- Max absolute shared-pair difference: 0.7000

| Q2 parameter | Q1 parameter | Q2 theta | Q1 theta | Pair diff | Target diff |
| --- | --- | ---: | ---: | ---: | ---: |
| `Q2_PQSE` | `Q1_QuitSE` | 0.5500 | -0.0500 | 0.6000 | 0.6000 |
| `Q2_PQMotiv` | `Q1_QuitMotiv` | -0.1500 | 0.4500 | -0.6000 | -0.6000 |
| `Q2_LowEducation` | `Q1_LowEducation` | 0.3000 | -0.2500 | 0.5500 | 0.5500 |
| `Q2_PQSE_A_FF` | `Q1_QuitSE_A_efficacy` | 0.4500 | -0.2500 | 0.7000 | 0.7000 |
| `Q2_PQMotiv_A_FF` | `Q1_QuitMotiv_A_outcome` | -0.3000 | 0.3200 | -0.6200 | -0.6200 |
| `Q2_LowEducation_A_FF` | `Q1_LowEducation_A_story` | 0.5000 | -0.2000 | 0.7000 | 0.7000 |

## Evaluation Output

- `evaluation_summary.csv` contains mean and standard deviation summaries by setting, sample size, method, and metric.
- Metrics are flattened from each replicate's `evaluation_*` objects so vector bias outputs appear as indexed columns.
