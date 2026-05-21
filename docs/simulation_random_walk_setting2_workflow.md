# Setting II Workflow

## Design Goal

Setting II uses the same binary-treatment, real-data-mimic structure as Setting I, but the candidate shared parameters are intentionally not shared. The shared-model methods are retained as misspecified comparisons.

Sample sizes: `100`, `300`, `500`, `1000`.

## Parameter Groups

The current bounded calibration script proposes three no-sharing target groups in `nloptr_Setting2.R`:

- `separated_moderate`: moderate separation across all candidate shared pairs.
- `separated_reversed`: opposite signs across candidate shared pairs.
- `separated_large`: larger separation with stronger stage-3 and stage-2 effects.

The bounded calibration command is:

```bash
module load cmake/3.21.4 r/4.4.0
Rscript Simulation_random_walk/Setting2/spec_calibration.R
```

Current bounded calibration artifacts:

- `calibration_separated_moderate.rds`
- `calibration_separated_reversed.rds`
- `calibration_separated_large.rds`
- `parameter_spec_runs.rds`

The default production calibration artifact is `calibration_separated_moderate.rds`; rerun it with production `mc_n`, optimizer budget, and a passing candidate-validation report before production simulations.

## Execution Flow

1. Run `spec_calibration.R` to obtain `gamma_true` and population-projected `theta_true` for `calibration_separated_moderate.rds`.
2. Generate the population dataset with `Q_learning_Setting_2(gamma_true, save = TRUE)`.
3. Run `Simulation_Setting2.R`, which loops over the requested sample sizes and calls `Simu_II()`.
4. `Simu_II()` fits conventional Q-learning, fused lasso SQ-learning, strict SharedQ, fused ridge SQ-learning, and the misspecified shared-pattern variants.
5. Submit production runs with `submission.pbs`.

## Validation

Quick validation:

```bash
module load cmake/3.21.4 r/4.4.0
Rscript Simulation_random_walk/Setting2/test.R
```

The quick test verifies bounded nloptr calibration, population generation, conventional Q-learning, direct L1/L2/shared method calls, and evaluation.

## Notes

- L1 paths can emit convergence warnings at very small smoke-test sample sizes. The wrapper continues when a fit returns usable coefficients.
- The true and misspecified `D` matrices are deliberately retained from Setting I so the no-sharing design evaluates how much shrinkage/shared constraints hurt when sharing is false.
