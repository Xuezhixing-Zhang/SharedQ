# Setting II File Manifest

## Core Scripts

- `nloptr_Setting2.R`: bounded and production nloptr calibration for no-sharing target parameters.
- `spec_calibration.R`: runs the three proposed parameter groups.
- `Q_datagenerating.R`: samples from `data_original.rds` and adds outcome noise.
- `Q_Conventional.R`: conventional backward-induction Q-learning.
- `Q_SQlearning.R`: fused lasso SQ-learning.
- `Q_L2SQ.R`: fused ridge SQ-learning.
- `Q_SharedQ.R`: strict shared-effect Q-learning.
- `Q_functions.R`: simulation wrapper and evaluation helper wiring.
- `Simulation_Setting2.R`: production simulation loop over sample sizes.
- `Evaluation.R`: post-run summary helpers.
- `test.R`: bounded smoke test.
- `submission.pbs`: PBS production submission script.

## Generated Artifacts

- `test_alternative_pars.rds`: bounded nloptr artifact created by `test.R`.
- `calibration_*.rds`: bounded calibration artifacts created by `spec_calibration.R`.
- `parameter_spec_runs.rds`: summary of bounded calibration specs.
- `data_original.rds`: population dataset used by `Generate_data()`.
- `results_*.rds`: simulation outputs written by `Simulation_Setting2.R`.

## Folder Layout

- `calibration/`: place long calibration outputs here when running production searches.
- `tests/`: place additional test scripts here if they are not primary entry points.
- `test_results/`: place smoke-test result artifacts here.
- `simulation_results/`: place production simulation outputs here if not using the legacy root paths.
- `evaluation_results/`: place summarized evaluation tables here.
- `logs/`: place PBS stdout/stderr logs here.
- `docs/`: place all documents, handoff notes, and agent progress logs in the top-level repository document hub.
