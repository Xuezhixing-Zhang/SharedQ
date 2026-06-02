# Setting IV Current Results Summary

- Objective: Project Quit / Forever Free two-stage synthetic-parametric shared design informed by cleaned PQ/FF structure only.
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

- Calibration artifacts: `calibration_pqff_shared_parsimonious.rds`
- Test artifacts: none

## Candidate Calibration

- Source mode: synthetic_parametric
- True-estimate workflow: target-to-truth synthetic population projection
- Design source complete consent rows used for aggregate constants: 469
- Projection Monte Carlo rows: 100000
- Calibration search rows: 20000
- Calibration starts: 5
- Search objective: 0.0000
- Sum absolute target difference: 0.0000
- Max absolute target difference: 0.0000
- Max absolute shared-pair difference: 0.0675

| Q2 parameter | Q1 parameter | Q2 theta | Q1 theta | Pair diff | Target diff |
| --- | --- | ---: | ---: | ---: | ---: |
| `Q2_PQSE` | `Q1_QuitSE` | 0.3560 | 0.4235 | -0.0675 | -0.0675 |
| `Q2_PQMotiv` | `Q1_QuitMotiv` | 0.2389 | 0.2320 | 0.0069 | 0.0069 |
| `Q2_LowEducation` | `Q1_LowEducation` | -0.0863 | -0.1149 | 0.0286 | 0.0286 |
| `Q2_PQSE_A_FF` | `Q1_QuitSE_A_efficacy` | 0.1116 | 0.1229 | -0.0112 | -0.0112 |
| `Q2_PQMotiv_A_FF` | `Q1_QuitMotiv_A_outcome` | 0.1322 | 0.1601 | -0.0279 | -0.0279 |
| `Q2_LowEducation_A_FF` | `Q1_LowEducation_A_story` | 0.1745 | 0.2000 | -0.0255 | -0.0255 |

## Accepted True Parameters

The accepted production calibration artifact is `calibration_pqff_shared_parsimonious.rds`. Accepted true estimates are the saved population-projected `theta` values after target-to-truth calibration/projection; do not report the scripted target vector alone.

| Parameter | Accepted true theta |
| --- | ---: |
| `Q2_intercept` | 0.1000 |
| `Q2_PQQuit` | 0.4000 |
| `Q2_PQSE` | 0.3560 |
| `Q2_PQMotiv` | 0.2389 |
| `Q2_LowEducation` | -0.0863 |
| `Q2_A_FF` | 0.1200 |
| `Q2_PQQuit_A_FF` | -0.0800 |
| `Q2_PQSE_A_FF` | 0.1116 |
| `Q2_PQMotiv_A_FF` | 0.1322 |
| `Q2_LowEducation_A_FF` | 0.1745 |
| `Q1_intercept` | 0.1000 |
| `Q1_QuitSE` | 0.4235 |
| `Q1_QuitMotiv` | 0.2320 |
| `Q1_LowEducation` | -0.1149 |
| `Q1_A_source` | 0.2000 |
| `Q1_A_outcome` | 0.0800 |
| `Q1_A_story` | 0.1800 |
| `Q1_A_efficacy` | 0.0800 |
| `Q1_A_multiple` | 0.0200 |
| `Q1_QuitSE_A_efficacy` | 0.1229 |
| `Q1_QuitMotiv_A_outcome` | 0.1601 |
| `Q1_LowEducation_A_story` | 0.2000 |

## Evaluation Output

- `evaluation_summary.csv` contains mean and standard deviation summaries by setting, sample size, method, and metric.
- Metrics are flattened from each replicate's `evaluation_*` objects so vector bias outputs appear as indexed columns.
