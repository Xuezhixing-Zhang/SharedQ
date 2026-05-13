# Supplementary Setting III No-Shared File Manifest

## Core Scripts

- `nloptr_Setting3.R`: continuous-covariate population generator and no-shared calibration target definitions.
- `Q_datagenerating.R`: samples from this folder's `data_original.rds` and adds outcome noise.
- `Q_learning.R`: conventional Q-learning implementation.
- `Q_SQlearning.R`: fused lasso SQ-learning with bounded iteration controls.
- `Q_L2SQ.R`: fused ridge SQ-learning with bounded iteration controls.
- `Q_SharedQ.R`: strict shared-effect Q-learning, intentionally misspecified here.
- `Q_functions.R`: replicate wrapper and evaluation helper.
- `Simulation_Setting3.R`: production simulation loop over sample sizes.
- `Evaluation.R`: post-run summary helpers.
- `spec_calibration.R`: bounded multi-spec calibration runner.
- `test.R`: quick and bounded full validation entry point.
- `submission.pbs`: production PBS submission script.

## Generated Artifacts

- `test_alternative_pars.rds`: bounded smoke-test calibration artifact.
- `data_X_*.rds`: cached covariate/treatment/responder draws for a given Monte Carlo size.
- `data_original.rds`: population dataset used by `Generate_data()`.
- `alternative_pars.rds`: intended production calibration artifact.
- `calibration_separated_*.rds`: optional multi-spec calibration artifacts.
- `parameter_spec_runs.rds`: summary of multi-spec calibration runs.
- `results_*.rds`: simulation outputs written by `Simulation_Setting3.R`.
- `test_one_replicate.rds`: optional bounded full smoke-test output.

## Folder Layout

- `calibration/`: place production calibration outputs here if using non-root artifact paths.
- `tests/`: place extra test scripts here.
- `test_results/`: place smoke-test output artifacts here.
- `simulation_results/`: place production simulation outputs here if not using legacy root paths.
- `evaluation_results/`: place summarized evaluation tables here.
- `logs/`: place PBS stdout/stderr logs here.
- `docs/`: place all documents, handoff notes, agent progress logs, and checks in the top-level repository document hub.
