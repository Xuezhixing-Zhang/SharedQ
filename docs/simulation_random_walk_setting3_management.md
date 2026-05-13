# Random Walk Setting III Management

## Objective

Setting III uses a continuous-covariate three-stage design with random-walk shared effects. It evaluates shared-effect estimators when several decision-effect analogues are close but not identical across stages.

## Simulation Design

- Stages: three-stage continuous-covariate design.
- Sample sizes: `100`, `300`, `500`, `1000`.
- Production replicates: `200` per sample size.
- Candidate shared-effect groups: main decision effects, observation-by-decision effects, and previous-treatment-by-decision effects.
- Production defaults: simulation seed `12345`, population generator seed `4321`, `mc_n = 1000000`, `search_maxeval = 8000`, `search_local_maxeval = 8000`.
- Smoke-test defaults: seed `1`, `mc_n = 2000`, `search_maxeval = 10`, `search_local_maxeval = 5`.

## Parameter Choices

| Spec | Seed | Means | Sigmas | Purpose |
| --- | ---: | --- | --- | --- |
| `rw_sigma_moderate` | `401` | `psi0=-0.30`, `psi1=0.50`, `psi2=0.35` | `0.08`, `0.08`, `0.06` | Production random-walk scenario |
| `rw_sigma_tight` | `402` | `psi0=-0.30`, `psi1=0.50`, `psi2=0.35` | `0.04`, `0.04`, `0.03` | Closer-to-exact sharing |
| `rw_sigma_wide` | `403` | `psi0=-0.30`, `psi1=0.50`, `psi2=0.35` | `0.15`, `0.15`, `0.10` | Wider deviations |

## Code File Usage

| File | Usage and objective |
| --- | --- |
| `nloptr_Setting3.R` | Defines continuous-covariate targets, cached covariate draws, and calibration search. |
| `spec_calibration.R` | Runs bounded calibration across Setting III random-walk specs. |
| `Q_datagenerating.R` | Samples from `data_original.rds` and adds outcome noise. |
| `Q_learning.R` | Conventional Q-learning implementation used by replicates. |
| `Q_SQlearning.R` | Fits fused lasso SQ-learning. |
| `Q_L2SQ.R` | Fits fused ridge SQ-learning. |
| `Q_SharedQ.R` | Fits strict shared-effect Q-learning. |
| `Q_functions.R` | Runs one full simulation replicate and writes temporary sampled data. |
| `Simulation_Setting3.R` | Runs production and smoke-test simulations. |
| `Evaluation.R` | Summarizes assignment and shared-effect bias metrics. |
| `test.R` | Runs quick validation. |
| `submission*.pbs` | Cluster entry points for production, large, and calibration jobs. |

## Artifact Structure

- `calibration/`: `alternative_pars.rds`, `test_alternative_pars.rds`, `calibration_*.rds`, `parameter_spec_runs.rds`, `data_X*.rds` caches.
- `simulation_results/`: `results_*.rds`.
- `test_results/`: smoke-test and temporary test outputs.
- `logs/`: PBS and simulation output logs.
- `Summarize/`: generated summaries, evaluation tables, and next-step notes.

## Current Results

- Production-like results currently exist for `n = 100`, `300`, `500`, and `1000`, each with `200` non-null replicates.
- Next work: move artifacts into the structure above, regenerate summary tables, and keep large binary artifacts local unless Git LFS is introduced.
