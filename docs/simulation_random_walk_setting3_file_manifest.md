# Setting III File Manifest

## Core Scripts

- `nloptr_Setting3.R`: nloptr calibration and bounded population data generator for the continuous-covariate setting.
- `spec_calibration.R`: bounded multi-spec calibration runner.
- `../calibration_runner_utils.R`: shared env-var parsing and spec selection helpers for calibration runners.
- `Q_datagenerating.R`: samples from `data_original.rds` and adds outcome noise.
- `Q_learning.R`: conventional Q-learning implementation used by simulation replicates.
- `Q_SQlearning.R`: fused lasso SQ-learning.
- `Q_L2SQ.R`: fused ridge SQ-learning.
- `Q_SharedQ.R`: strict shared-effect Q-learning.
- `Q_functions.R`: simulation wrapper and evaluation helper wiring.
- `Simulation_Setting3.R`: production simulation loop over sample sizes.
- `Evaluation.R`: post-run summary helpers.
- `test.R`: bounded smoke test.
- `submission.pbs`: PBS production submission script.
- `submission_specs.pbs`: PBS calibration submission script with `CALIBRATION_*` controls.

## Generated Artifacts

- `test_alternative_pars.rds`: bounded calibration artifact generated for smoke testing.
- `data_X.rds`: cached covariate/treatment/responder draws for bounded nloptr tests.
- `data_original.rds`: population dataset used by `Generate_data()`.
- `calibration_rw_sigma_moderate.rds`: default production calibration artifact.
- `results_*.rds`: simulation outputs written by `Simulation_Setting3.R`.

## Folder Layout

- `calibration/`: place production calibration outputs here.
- `tests/`: place extra test scripts here.
- `test_results/`: place smoke-test output artifacts here.
- `simulation_results/`: place production simulation outputs here if not using legacy root paths.
- `evaluation_results/`: place summarized evaluation tables here.
- `logs/`: place PBS stdout/stderr logs here.
- `docs/`: place all documents, handoff notes, and agent progress logs in the top-level repository document hub.
