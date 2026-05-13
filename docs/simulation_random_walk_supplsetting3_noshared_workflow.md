# Supplementary Setting III No-Shared Workflow

## Design Goal

This supplementary setting uses the same continuous-covariate data-generating mechanism and 25-parameter Q-model as `Simulation_random_walk/Setting3`, but the population-projected decision effects are calibrated to be separated rather than shared.

Sample sizes: `100`, `300`, `500`, `1000`.

## Parameter Targets

`nloptr_Setting3.R` defines three no-sharing target groups:

- `separated_moderate`: baseline no-sharing target with moderate separation.
- `separated_reversed`: stage analogues have reversed signs.
- `separated_large`: larger cross-stage separation.

The candidate shared-effect analogues intentionally differ across stages:

- Main decision effects: `Q3_A3`, `Q2_A2`, `Q1_A1`.
- Observation-by-decision effects: `Q3_O3:A3`, `Q2_O2:A2`, `Q1_O1:A1`.
- Previous-treatment-by-decision effects: `Q3_A2:A3`, `Q2_A1:A2`.

## Execution Flow

1. Run `spec_calibration.R` for bounded multi-spec calibration, or run `run_setting3_parameter_search()` directly to create `alternative_pars.rds`.
2. Generate the population dataset with `Q_learning_Setting_3(gamma_true, save = TRUE)`.
3. Run `Simulation_Setting3.R`, which calls `Simu_III()` over the requested sample sizes.
4. `Simu_III()` fits conventional Q-learning, fused lasso SQ-learning, strict SharedQ, and fused ridge SQ-learning. SharedQ and fused methods use the same candidate shared pattern as Setting III, so they are intentionally misspecified under this supplementary setting.
5. Submit production runs with `submission.pbs`.

## Validation

Quick validation:

```bash
module load cmake/3.21.4 r/4.4.0
Rscript Simulation_random_walk/SupplSetting3_NoShared/test.R
```

Bounded one-replicate validation:

```bash
module load cmake/3.21.4 r/4.4.0
SUPPL_SETTING3_TEST_MODE=full Rscript Simulation_random_walk/SupplSetting3_NoShared/test.R
```

## Notes

- This folder intentionally does not reuse Setting III `.rds` artifacts. Calibration and population data must be regenerated here.
- The data mechanism follows the executable Setting III code, including inactive responder treatments encoded as `0`.
- `Q_SQlearning.R`, `Q_L2SQ.R`, and `Simulation_Setting3.R` expose bounded iteration controls for smoke tests.
