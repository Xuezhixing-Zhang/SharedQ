# Supplementary Random Walk Setting III No-Shared Management

## Objective

This supplementary setting reuses the continuous-covariate Setting III mechanism but calibrates separated, no-shared decision effects. It checks whether fused/shared estimators remain unbiased when the shared-effect assumption is false.

## Simulation Design

- Stages: three-stage continuous-covariate design.
- Sample sizes: `100`, `300`, `500`, `1000`.
- Production replicates: `200` per sample size.
- Candidate shared-effect analogues are intentionally separated: main decision effects, observation-by-decision effects, and previous-treatment-by-decision effects.
- Production defaults: simulation seed `12345`, population generator seed `4321`, `mc_n = 1000000`, `search_maxeval = 8000`, `search_local_maxeval = 8000`, candidate target tolerance `0.03`.
- Smoke-test defaults: seed `1`, `mc_n = 2000`, `search_maxeval = 10`, `search_local_maxeval = 5`.

## Parameter Choices

| Spec | Seed | Target values | Purpose |
| --- | ---: | --- | --- |
| `separated_moderate` | `501` | `q3_a3=-0.75`, `q2_a2=0.35`, `q1_a1=0.90`; `q3_o3a3=0.70`, `q2_o2a2=-0.35`, `q1_o1a1=0.15`; `q3_a2a3=-0.60`, `q2_a1a2=0.55`, `q3_a1a2a3=0.45` | Baseline no-sharing |
| `separated_reversed` | `502` | `q3_a3=0.80`, `q2_a2=-0.45`, `q1_a1=0.20`; `q3_o3a3=-0.65`, `q2_o2a2=0.40`, `q1_o1a1=-0.10`; `q3_a2a3=0.55`, `q2_a1a2=-0.50`, `q3_a1a2a3=0.35` | Reversed-sign stress test |
| `separated_large` | `503` | `q3_a3=-1.00`, `q2_a2=0.55`, `q1_a1=1.20`; `q3_o3a3=0.90`, `q2_o2a2=-0.55`, `q1_o1a1=0.05`; `q3_a2a3=-0.85`, `q2_a1a2=0.75`, `q3_a1a2a3=0.60` | Larger separation |

## Code File Usage

| File | Usage and objective |
| --- | --- |
| `nloptr_Setting3.R` | Defines no-shared continuous-covariate targets and calibration search. |
| `spec_calibration.R` | Runs bounded calibration across supplementary no-shared specs; supports `CALIBRATION_*` env controls for spec subsets and optimizer budgets. |
| `Q_datagenerating.R` | Samples from this setting's `data_original.rds` and adds outcome noise. |
| `Q_learning.R` | Conventional Q-learning implementation. |
| `Q_SQlearning.R` | Fits fused lasso SQ-learning with bounded iteration controls. |
| `Q_L2SQ.R` | Fits fused ridge SQ-learning with bounded iteration controls. |
| `Q_SharedQ.R` | Fits strict shared-effect Q-learning, intentionally misspecified here. |
| `Q_functions.R` | Runs one full replicate and writes temporary sampled data. |
| `Simulation_Setting3.R` | Runs production and smoke-test simulations. |
| `Evaluation.R` | Summarizes assignment and bias metrics. |
| `test.R` | Runs quick and bounded full validation. |
| `submission*.pbs` | Cluster entry points for production, large, and calibration jobs. |

## Artifact Structure

- `calibration/`: `alternative_pars.rds`, `test_alternative_pars.rds`, optional `calibration_*.rds`, `parameter_spec_runs.rds`, `data_X*.rds` caches.
- `simulation_results/`: `results_*.rds`.
- `test_results/`: `test_one_replicate.rds` and smoke-test outputs.
- `logs/`: PBS and simulation output logs.
- `Summarize/`: generated summaries, evaluation tables, and next-step notes.

## Current Results

- No production `results_*.rds` files are currently present.
- Existing artifacts are smoke-test oriented: `test_alternative_pars.rds`, `test_one_replicate.rds`, `data_X_2000.rds`, `data_original.rds`, and `temp.rds`.
- Next work: move artifacts into the structure above, generate summary status files, and run production simulations after calibration is accepted.
