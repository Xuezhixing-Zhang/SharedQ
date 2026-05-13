# Random Walk Setting II Management

## Objective

Setting II keeps the binary-treatment real-data-mimic framework but deliberately separates candidate shared effects. It evaluates whether flexible fused methods avoid the bias introduced by strict sharing when sharing is false.

## Simulation Design

- Stages: three-stage binary treatment design.
- Sample sizes: `100`, `300`, `500`, `1000`.
- Production replicates: `200` per sample size.
- Response mechanism matches Setting I.
- Candidate sharing pairs are intentionally separated: `Q3_A1 / Q2_A1`, `Q3_A3 / Q2_A2`, `Q3_A1A3 / Q2_A1A2`.
- Production defaults: simulation seed `12345`, population/calibration default seed `1234`, `mc_n = 1000000`, `search_maxeval = 100000`, `search_local_maxeval = 20000`.
- Smoke-test defaults: seed `1`, `mc_n = 5000`, `search_maxeval = 50`, `search_local_maxeval = 20`.

## Parameter Choices

| Spec | Seed | Target decision effects | Purpose |
| --- | ---: | --- | --- |
| `separated_moderate` | `101` | `Q3_A1=0.55`, `Q3_A3=-0.70`, `Q3_A1A3=0.95`; `Q2_A1=-0.15`, `Q2_A2=0.45`, `Q2_A1A2=-0.35`; `Q1_A1=0.20` | Primary no-sharing scenario |
| `separated_reversed` | `202` | `Q3_A1=-0.50`, `Q3_A3=0.65`, `Q3_A1A3=-0.85`; `Q2_A1=0.30`, `Q2_A2=-0.45`, `Q2_A1A2=0.45`; `Q1_A1=-0.10` | Opposite-sign stress test |
| `separated_large` | `303` | `Q3_A1=0.75`, `Q3_A3=-0.90`, `Q3_A1A3=1.15`; `Q2_A1=-0.35`, `Q2_A2=0.65`, `Q2_A1A2=-0.55`; `Q1_A1=0.30` | Larger separation |

## Code File Usage

| File | Usage and objective |
| --- | --- |
| `nloptr_Setting2.R` | Defines no-sharing targets and calibrates data-generating `gamma`. |
| `spec_calibration.R` | Runs bounded calibration for all Setting II target groups. |
| `Q_datagenerating.R` | Samples from `data_original.rds` and adds outcome noise. |
| `Q_Conventional.R` | Fits conventional Q-learning. |
| `Q_SQlearning.R` | Fits fused lasso SQ-learning and misspecified variants. |
| `Q_L2SQ.R` | Fits fused ridge SQ-learning and misspecified variants. |
| `Q_SharedQ.R` | Fits strict shared-effect models, intentionally misspecified here. |
| `Q_functions.R` | Runs one full simulation replicate and collects evaluations. |
| `Simulation_Setting2.R` | Runs production and smoke-test simulations. |
| `Evaluation.R` | Summarizes replicate metrics and bias outputs. |
| `test.R` | Runs quick and optional bounded full validation. |
| `submission*.pbs` | Cluster entry points for production and large jobs. |

## Artifact Structure

- `calibration/`: `alternative_pars.rds`, `test_alternative_pars.rds`, `calibration_*.rds`, `parameter_spec_runs.rds`.
- `simulation_results/`: `results_*.rds`.
- `test_results/`: `test_one_replicate.rds`.
- `logs/`: PBS and simulation output logs.
- `Summarize/`: generated summaries, evaluation tables, and next-step notes.

## Current Results

- Production-like results currently exist for `n = 100`, `300`, `500`, and `1000`, each with `200` non-null replicates.
- Next work: move artifacts into the structure above, regenerate summary tables, and keep large binary artifacts local unless Git LFS is introduced.
