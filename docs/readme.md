# Agent Document Guide

This folder is the single document hub for the SharedQ workspace. Future agents should start here before reading code or running simulations.

## Start Of Work Checklist

1. Read `docs/readme.md`.
2. Read `docs/plan and goal.md` and identify the current incomplete milestone.
3. Read today's log file in `docs/`, named as `YYYY-MM-DD_log.md`. If it does not exist, create it before starting work.
4. Read `RANDOM_WALK_SETTING_DESIGN_SUMMARY.md` for the consolidated random-walk setting designs, sample sizes, target parameters, and calibrated true values.
5. Read the setting-specific workflow, manifest, management, and handoff documents listed in the relevant milestone.
6. Update `docs/plan and goal.md` and today's log before making code or document changes.
7. For any random-walk calibration or production-simulation work, run candidate-parameter validation before accepting calibration artifacts or launching production simulations.

## Critical Shared-Parameter Rule

In true shared or near-shared simulation settings, the shared relationship is part of the true data-generating coefficients, not an assumption imposed on fitted estimates. Each shared coefficient must be generated as `theta_j^(d) = mu_j + delta_j^(d)`, with `delta_j^(d) ~ N(0, sigma_shared^2)`. Therefore `sigma_shared` is the standard deviation of the random deviation around the latent common effect `mu_j`: `sigma_shared = 0` gives exact sharing, small positive values give close but non-identical coefficients, and larger values weaken the shared relationship. Do not use deterministic offsets such as `mu + sigma`, `mu`, or `mu - sigma` to define shared true parameters.

## Required Updates During Work

- Update `docs/plan and goal.md` when starting a milestone, completing a milestone, or changing the planned milestone order.
- Update today's log every time a meaningful decision, blocker, command result, or verification outcome occurs.
- Use `Rscript Simulation_random_walk/run_candidate_calibration_smoke.R` for bounded constrained calibration checks; it writes ignored `.rds` artifacts under each setting's `calibration/candidate_constraint_smoke/` folder and text reports under `Summarize/`. Set `CALIBRATION_SPEC_MODE=default` to run only the production/default spec, `CALIBRATION_SPECS` for a comma-separated subset, `CALIBRATION_TARGET_TOLERANCE` for a stricter internal optimizer window, or `CALIBRATION_REPORT_ONLY=1` to regenerate reports from existing smoke artifacts.
- Use `Simulation_random_walk/submission_calibration_gate_candidate.pbs` for concurrent production-scale gate candidates. Set `CALIBRATION_SETTING`, `CALIBRATION_GATE_PROFILE`, `CALIBRATION_TARGET_TOLERANCE`, and `CALIBRATION_OUTPUT_DIR` so each candidate writes under `calibration/gate_candidates/<profile>/` instead of overwriting production artifacts.
- Run `Rscript Simulation_random_walk/select_calibration_gate_candidate.R` after gate candidates finish; it writes `Summarize/calibration_gate_candidate_selection.*` and ranks passing candidates by max absolute validation error. Set `CALIBRATION_GATE_PROMOTE=1` only when the best passing candidate should replace the production calibration artifact.
- Run `Rscript Simulation_random_walk/validate_candidate_calibration.R` after calibration artifacts are generated or changed; do not treat production simulation outputs as final until candidate coefficients and implied differences pass the documented per-setting tolerance (`0.01` for Setting I/III, `0.03` for no-shared settings). Use `VALIDATION_SPEC_MODE=default` for the production-simulation gate, `VALIDATION_SPECS` for a comma-separated subset, and `VALIDATION_REPORT_STEM` if the report should not overwrite the all-spec report.
- Validation must also confirm that each calibration artifact's stored `theta_target` matches the current script-generated target. This prevents old deterministic-offset shared artifacts from passing after the shared-parameter design changes.
- After each milestone is complete, commit the relevant changes and push them to the configured Git remote.
- If push fails, record the exact blocker in today's log before moving to the next milestone.

## Current Primary Work Area

The active research workflow is the simulation random walk setting suite. For Setting I work, read:

- `RANDOM_WALK_SETTING_DESIGN_SUMMARY.md`
- `docs/simulation_random_walk_setting1_workflow.md`
- `docs/simulation_random_walk_setting1_file_manifest.md`
- `docs/simulation_random_walk_setting1_handoff.md`
- `docs/simulation_random_walk_setting1_agent_work.md`
- `docs/the_algorithm.md`

For Setting II, Setting III, and supplementary no-shared work, read `RANDOM_WALK_SETTING_DESIGN_SUMMARY.md` plus the matching `simulation_random_walk_*_workflow.md` and `simulation_random_walk_*_file_manifest.md` files.

For Project Quit / Forever Free Setting IV work, read `PROJECT_QUIT_FOREVER_FREE_SETTING_IV_DESIGN.md` first, then use `Simulation_random_walk/Setting4/` and `Simulation_random_walk/SupplSetting4_NoShared/` as the implementation folders. Setting IV shared true parameters must also follow the random shared rule in this README.

Setting IV now has executable main-folder scripts and synthetic fallback outputs, but it still has no accepted production calibration or production results. Before production simulation work, supply the cleaned Project Quit / Forever Free source data through `SETTING4_SOURCE_DATA`, run production calibration, add the same validation gate used by the earlier settings, and rerun production simulations without `SETTING4_ALLOW_SYNTHETIC=1`. The synthetic files are for code/evaluation smoke coverage only. The relevant todo files are:

- `Simulation_random_walk/Setting4/Summarize/todo.md`
- `Simulation_random_walk/SupplSetting4_NoShared/Summarize/todo.md`

For per-setting file management, artifact layout, parameter choices, seeds, and result status, read the matching management file:

- `docs/simulation_random_walk_setting1_management.md`
- `docs/simulation_random_walk_setting2_management.md`
- `docs/simulation_random_walk_setting3_management.md`
- `docs/simulation_random_walk_supplsetting3_noshared_management.md`

For current generated-result summaries and next actions, read each setting's `Summarize/current_results_summary.md` and `Summarize/todo.md`.

For candidate-parameter calibration status, read each setting's `Summarize/candidate_calibration_report.md` after running `Simulation_random_walk/validate_candidate_calibration.R`.

For bounded candidate-calibration smoke status, read each setting's `Summarize/candidate_calibration_smoke_report.md` after running `Simulation_random_walk/run_candidate_calibration_smoke.R`.

Production simulations read the accepted default calibration artifacts directly: `calibration_balanced_small.rds`, `calibration_separated_moderate.rds`, `calibration_rw_sigma_moderate.rds`, and supplementary `calibration_separated_moderate.rds`. Do not launch production simulation jobs until those default artifacts pass candidate validation.

Setting IV has no accepted production calibration artifacts yet. Do not add Setting IV to production table generation or launch accepted production simulations until cleaned PQ/FF source data exists, calibration and validation tooling exists, and the default specs pass validation. Do not use `results_*_synthetic.rds` in manuscript tables or method claims.

If any calibration job or default validation report fails, follow `docs/random_walk_calibration_tuning_strategy.md` before changing parameter targets, constraints, or launching another production attempt.

For the current project state and next real work, read the `Current Progress Summary` and active `RW-CAL` milestones in `docs/plan and goal.md`.

## Document Naming

All documents live directly under `docs/`. Source paths are encoded into lowercase, underscore-separated filenames to avoid collisions between settings.

Examples:

- `Simulation_random_walk/Setting1/Workflow.md` becomes `docs/simulation_random_walk_setting1_workflow.md`.
- `Simulation_random_walk/Setting2/File_Manifest.md` becomes `docs/simulation_random_walk_setting2_file_manifest.md`.
- `Simulation_random_walk/Setting1/working_log/YYYY-MM-DD_codex_log.md` becomes `docs/simulation_random_walk_setting1_YYYY-MM-DD_codex_log.md`.

Do not create new scattered markdown or log files outside `docs/` unless a tool temporarily generates one and the same milestone moves it here.

Exception: `RANDOM_WALK_SETTING_DESIGN_SUMMARY.md` intentionally lives at the repository root as the single consolidated random-walk design and true-parameter reference.
