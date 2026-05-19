# Setting I File Manifest

## Core Scripts

- `nloptr_Setting1.R`: random-walk near-sharing calibration.
- `spec_calibration.R`: runs the bounded Setting I parameter groups.
- `../calibration_runner_utils.R`: shared env-var parsing and spec selection helpers for calibration runners.
- `Q_datagenerating.R`: samples from `data_original.rds` and adds outcome noise.
- `Q_Conventional.R`: conventional backward-induction Q-learning.
- `Q_SQlearning.R`: fused lasso SQ-learning.
- `Q_L2SQ.R`: fused ridge SQ-learning.
- `Q_SharedQ.R`: strict shared-effect Q-learning.
- `Q_functions.R`: simulation wrapper and evaluation helper wiring.
- `Simulation_Setting1.R`: production simulation loop over sample sizes.
- `Evaluation.R`: post-run summary helpers.
- `test.R`: bounded smoke test.
- `submission.pbs`: PBS production submission script.
- `submission_specs.pbs`: PBS calibration submission script with `CALIBRATION_*` controls.

## Generated Artifacts

- `test_alternative_pars.rds`: bounded nloptr artifact for smoke tests.
- `calibration_*.rds`: bounded parameter-group calibration outputs.
- `shared_parameter_spec_runs.rds`: summary of bounded calibration specs.
- `data_original.rds`: population dataset used by `Generate_data()`.
- `results_*.rds`: simulation outputs written by `Simulation_Setting1.R`.
- `test_one_replicate.rds`: full bounded one-replicate test output.

## Folder Layout

- `calibration/`: place long calibration outputs here.
- `tests/`: place additional test scripts here.
- `test_results/`: place smoke-test result artifacts here.
- `simulation_results/`: place production simulation outputs here if not using legacy root paths.
- `evaluation_results/`: place summarized evaluation tables here.
- `logs/`: place PBS stdout/stderr logs here.
- `docs/`: place all documents, handoff notes, and agent progress logs in the top-level repository document hub.
