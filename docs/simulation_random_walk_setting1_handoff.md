# Setting I Handoff

## Environment

- Load R with:
  `module load cmake/3.21.4 r/4.4.0`
- `nloptr` is installed in the user library:
  `~/R/x86_64-pc-linux-gnu-library/4.4`

## Files Added For Validation

- `test.R`: reproducible setting I validation entry point.
  - Default mode: `quick`
  - Optional mode: `full`
  - Example:
    `Rscript Simulation_random_walk/Setting1/test.R`
  - Full one-replicate test:
    `SETTING1_TEST_MODE=full Rscript Simulation_random_walk/Setting1/test.R`

- `test_alternative_pars.rds`: bounded parameter-search artifact for smoke tests.
- `spec_calibration.R`: runs several bounded shared-parameter calibration specifications.
- `docs/simulation_random_walk_setting1_shared_parameter_specifications.md`: records shared-parameter scenarios, seeds, and output files.
- `submission_test.pbs`: one-replicate node-side validation job.
- `submission_specs.pbs`: shared-parameter calibration node-side job.

## Main Fixes Already Made

- Corrected all stale absolute paths from old `Setting1` locations to `Simulation_random_walk/Setting1`.
- Reworked `nloptr_Setting1.R` to reflect the random-walk shared-parameter design instead of exact sharing.
- Made `nloptr` a runtime requirement only when the parameter search is actually called.
- Added bounded controls for:
  - Monte Carlo size
  - optimizer budget
  - CV lambda grids
  - CV retries
- Added bounded multi-spec shared-parameter calibration support and saved `.rds` outputs.
- Added `run_setting1_smoke_test()` in `Simulation_Setting1.R`.
- Added automatic interaction-column preparation for:
  - `A1A2`
  - `A1A3`
  - `A2A3`
- Fixed the CV indexing bug in:
  - `Q_SQlearning.R`
  - `Q_L2SQ.R`
- Fixed evaluation summary bug in `Evaluation.R` for `A2_bias_summary`.
- Updated `submission.pbs` to point at the correct setting I directory.

## Important Stability Fixes

- `Q_learning()` and `Q_learning_Setting_1()` can hit singular regressions on small samples.
- Missing coefficients from `lm()` were causing `NA` pseudo-outcomes and downstream crashes.
- `safe_extract_coef()` now zero-fills missing coefficients before:
  - decision updates
  - theta assembly
- Penalized methods now use `results_1$theta` as warm start instead of raw `coef()` vectors that can contain `NA`.
- If all CV lambdas fail, the code now falls back to the first lambda with a warning instead of aborting immediately.

## Current Workflow

1. `run_setting1_parameter_search()` creates a pars file.
2. `Q_learning_Setting_1(..., save = TRUE)` creates `data_original.rds`.
3. `Generate_data()` samples from `data_original.rds` and adds noise.
4. `Simu_I()` runs:
   - conventional Q-learning
   - L1 fused method
   - L1 misspecified method
   - SharedQ
   - SharedQ misspecified
   - L2 fused method
   - L2 misspecified method
5. `run_setting1_simulation()` wraps repeated runs and saves `results_*.rds`.

## What Has Been Verified

- `source("Simulation_random_walk/Setting1/Q_functions.R")` works.
- `Q_learning()` returns a 14-parameter vector with no `NA`.
- `evaluate()` runs.
- `SQlearning()`, `SQlearning_L2()`, `SharedQ()`, and `SharedQ_mis()` run on sampled test data.
- `CV_SQlearning()` and `CV_SQlearning_L2()` both run at least on direct bounded test calls.
- Reduced `nloptr` search runs and writes `test_alternative_pars.rds`.
- `Rscript Simulation_random_walk/Setting1/spec_calibration.R` runs and writes:
  - `calibration_balanced_small.rds`
  - `calibration_tighter_small.rds`
  - `calibration_wider_small.rds`
  - `shared_parameter_spec_runs.rds`
- `Rscript Simulation_random_walk/Setting1/test.R` passes in `quick` mode.
- `run_setting1_simulation()` now gets through:
  - `results_1`
  - `evaluation_1`
  - into `results_2_CV`

## Submitted PBS Jobs

- Calibration job:
  - Script: `Simulation_random_walk/Setting1/submission_specs.pbs`
  - Job ID: `469335.hn-10-03`
  - Status checked with `qstat -x`: `F`
  - Output file: `./sim_rw_s1_specs.out`
  - Outcome: completed successfully and wrote the bounded calibration `.rds` files.

- One-replicate test job:
  - Script: `Simulation_random_walk/Setting1/submission_test.pbs`
  - Job ID: `469336.hn-10-03`
  - Status at last check: `R`
  - Output file: expected at `./sim_rw_s1_test.out`

## PBS Notes

- `qsub` requires escalation from this sandbox because PBS tries to create temp files under `/var/tmp`.
- PBS output files are currently landing in the repo root (`SharedQ/`) because `#PBS -o` is relative to the submit location.
- The next agent should check:
  - `qstat 469336.hn-10-03`
  - `qstat -x 469336.hn-10-03` after completion
  - `./sim_rw_s1_test.out`

## Current Bottleneck

- The remaining issue is runtime and robustness inside the L1 CV path during full wrapper execution.
- Small direct CV calls work, but full `Simu_I()` smoke tests still spend most of their time in `results_2_CV`.
- This is no longer an immediate path/specification failure; it is a testability and runtime issue.

## Recommended Next To-Do List

- Keep one-replicate testing as the default validation workflow before any full batch run.
- Run:
  `Rscript Simulation_random_walk/Setting1/test.R`
- Then run:
  `SETTING1_TEST_MODE=full Rscript Simulation_random_walk/Setting1/test.R`
- If the full mode still hangs too long, reduce the L1/L2 lambda grids further for smoke tests.
- Consider caching fold splits inside `run_cv_grid()` so retries do not resample folds indirectly.
- Consider a debug flag that skips misspecified scenarios during smoke tests.
- Once one-replicate smoke tests complete cleanly, rerun:
  `run_setting1_smoke_test()`
- After that, restore larger lambda grids and larger `mc_n` for production runs.

## Notes For Future Agents

- Do not assume long runtime means a broken path; most immediate code-level path and `NA` failures have already been fixed.
- The highest-value next target is the lasso CV runtime path, not the conventional or L2 paths.
