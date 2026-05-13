# Setting III Workflow

## Design Goal

Setting III uses the continuous-covariate three-stage design. The current code keeps the shared-pattern comparison structure from the Q-Shared setup and calibrates a population-level target using `nloptr`.

Sample sizes: `100`, `300`, `500`, `1000`.

## Current Calibration

`nloptr_Setting3.R` now exposes `run_setting3_parameter_search()` instead of launching the optimizer on source. This makes smoke tests and future production searches controllable.

Smoke-test calibration already verified:

```bash
module load cmake/3.21.4 r/4.4.0
Rscript -e 'source("Simulation_random_walk/Setting3/nloptr_Setting3.R"); run_setting3_parameter_search(output_path="Simulation_random_walk/Setting3/test_alternative_pars.rds", mc_n=2000, maxeval=10, local_maxeval=5, print_level=0)'
```

For production, increase `mc_n`, `maxeval`, and `local_maxeval`, then save to `alternative_pars.rds`.

## Execution Flow

1. Use `run_setting3_parameter_search()` to calibrate `gamma_true` and `theta_true`.
2. Generate the population dataset with `Q_learning_Setting_3(gamma_true, save = TRUE)`.
3. Run `Simulation_Setting3.R`, which calls `Simu_III()` over the requested sample sizes.
4. `Simu_III()` fits conventional Q-learning, fused lasso SQ-learning, SharedQ, and fused ridge SQ-learning.
5. Submit production runs with `submission.pbs`.

## Validation

Quick validation:

```bash
module load cmake/3.21.4 r/4.4.0
Rscript Simulation_random_walk/Setting3/test.R
```

The quick test verifies that bounded calibration artifacts can be read, a bounded population dataset can be generated, conventional Q-learning returns 25 parameters, and evaluation runs.

## Notes For Next Agent

- `docs/simulation_random_walk_setting3_setting_iii.md` suggests trying multiple `sigma` values. That specification still needs a full multi-spec calibration wrapper analogous to Setting I/II if those scenarios are required for production.
- The current quick-test artifact is intentionally small and should not be used as a final population truth.
- The production scripts are path-corrected for `Simulation_random_walk/Setting3`.
