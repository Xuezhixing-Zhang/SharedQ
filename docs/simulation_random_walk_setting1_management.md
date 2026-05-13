# Random Walk Setting I Management

## Objective

Setting I mimics the real-data binary-treatment design and targets near-shared effects across the last two stages. It is intended to show that fused shared-Q methods can reduce bias for approximately shared parameters and remain tolerable under mild misspecification.

## Simulation Design

- Stages: three-stage binary treatment design.
- Sample sizes: `100`, `300`, `500`, `1000`.
- Production replicates: `200` per sample size.
- Response mechanism: `P(R1 = 1) = 0.59`; `P(R2 = 1 | A1 = 1) = 0.23`; `P(R2 = 1 | A1 = -1) = 0.13`.
- Candidate near-shared pairs: `Q3_A1 / Q2_A1`, `Q3_A3 / Q2_A2`, `Q3_A1A3 / Q2_A1A2`.
- Production defaults: simulation seed `12345`, population/calibration default seed `1234`, `mc_n = 1000000`, `search_maxeval = 100000`, `search_local_maxeval = 20000`.
- Smoke-test defaults: seed `1`, `mc_n = 5000`, `search_maxeval = 50`, `search_local_maxeval = 20`.

## Parameter Choices

| Spec | Seed | Shared means | Shared sigmas | Purpose |
| --- | ---: | --- | --- | --- |
| `balanced_small` | `101` | `psi1=0.20`, `psi2=-0.60`, `psi3=0.80` | `0.03`, `0.03`, `0.03` | Baseline near-sharing |
| `tighter_small` | `202` | `psi1=0.16`, `psi2=-0.52`, `psi3=0.68` | `0.015`, `0.02`, `0.02` | Closer-to-exact sharing |
| `wider_small` | `303` | `psi1=0.24`, `psi2=-0.68`, `psi3=0.92` | `0.05`, `0.05`, `0.05` | Wider random-walk deviations |

## Code File Usage

| File | Usage and objective |
| --- | --- |
| `nloptr_Setting1.R` | Defines near-shared targets, population projection, and `nloptr` calibration. |
| `spec_calibration.R` | Runs bounded multi-spec calibration for the three parameter choices. |
| `Q_datagenerating.R` | Samples simulation data from `data_original.rds` and adds outcome noise. |
| `Q_Conventional.R` | Fits conventional backward-induction Q-learning. |
| `Q_SQlearning.R` | Fits fused lasso SQ-learning for true and misspecified sharing patterns. |
| `Q_L2SQ.R` | Fits fused ridge SQ-learning for true and misspecified sharing patterns. |
| `Q_SharedQ.R` | Fits strict shared-effect Q-learning and misspecified shared models. |
| `Q_functions.R` | Runs one complete simulation replicate and returns model fits plus evaluations. |
| `Simulation_Setting1.R` | Runs production and smoke-test loops over sample sizes and replicates. |
| `Evaluation.R` | Summarizes saved replicate outputs for assignment metrics and bias metrics. |
| `test.R` | Runs quick and optional bounded full validation. |
| `submission*.pbs` | Cluster entry points for production, large, test, and calibration jobs. |

## Artifact Structure

- `calibration/`: `alternative_pars.rds`, `test_alternative_pars.rds`, `calibration_*.rds`, `shared_parameter_spec_runs.rds`.
- `simulation_results/`: `results_*.rds`.
- `test_results/`: `test_one_replicate.rds`.
- `logs/`: PBS and simulation output logs.
- `Summarize/`: generated summaries, evaluation tables, and next-step notes.

## Current Results

- Production-like results currently exist for `n = 100`, `300`, `500`, and `1000`, each with `200` non-null replicates.
- Smoke-test result `results_30.rds` exists with `1` non-null replicate.
- Next work: move artifacts into the structure above, regenerate summary tables, and keep binary artifacts local unless Git LFS is introduced.
