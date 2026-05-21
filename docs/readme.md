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

## Required Updates During Work

- Update `docs/plan and goal.md` when starting a milestone, completing a milestone, or changing the planned milestone order.
- Update today's log every time a meaningful decision, blocker, command result, or verification outcome occurs.
- Use `Rscript Simulation_random_walk/run_candidate_calibration_smoke.R` for bounded constrained calibration checks; it writes ignored `.rds` artifacts under each setting's `calibration/candidate_constraint_smoke/` folder and text reports under `Summarize/`. Set `CALIBRATION_SPEC_MODE=default` to run only the production/default spec, `CALIBRATION_SPECS` for a comma-separated subset, `CALIBRATION_TARGET_TOLERANCE` for a stricter internal optimizer window, or `CALIBRATION_REPORT_ONLY=1` to regenerate reports from existing smoke artifacts.
- Run `Rscript Simulation_random_walk/validate_candidate_calibration.R` after calibration artifacts are generated or changed; do not treat production simulation outputs as final until candidate coefficients and implied differences pass the documented per-setting tolerance (`0.01` for Setting I/III, `0.03` for no-shared settings). Use `VALIDATION_SPEC_MODE=default` for the production-simulation gate, `VALIDATION_SPECS` for a comma-separated subset, and `VALIDATION_REPORT_STEM` if the report should not overwrite the all-spec report.
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

For per-setting file management, artifact layout, parameter choices, seeds, and result status, read the matching management file:

- `docs/simulation_random_walk_setting1_management.md`
- `docs/simulation_random_walk_setting2_management.md`
- `docs/simulation_random_walk_setting3_management.md`
- `docs/simulation_random_walk_supplsetting3_noshared_management.md`

For current generated-result summaries and next actions, read each setting's `Summarize/current_results_summary.md` and `Summarize/todo.md`.

For candidate-parameter calibration status, read each setting's `Summarize/candidate_calibration_report.md` after running `Simulation_random_walk/validate_candidate_calibration.R`.

For bounded candidate-calibration smoke status, read each setting's `Summarize/candidate_calibration_smoke_report.md` after running `Simulation_random_walk/run_candidate_calibration_smoke.R`.

Production simulations read the accepted default calibration artifacts directly: `calibration_balanced_small.rds`, `calibration_separated_moderate.rds`, `calibration_rw_sigma_moderate.rds`, and supplementary `calibration_separated_moderate.rds`. Do not launch production simulation jobs until those default artifacts pass candidate validation.

For the current project state and next real work, read the `Current Progress Summary` and active `RW-CAL` milestones in `docs/plan and goal.md`.

## Document Naming

All documents live directly under `docs/`. Source paths are encoded into lowercase, underscore-separated filenames to avoid collisions between settings.

Examples:

- `Simulation_random_walk/Setting1/Workflow.md` becomes `docs/simulation_random_walk_setting1_workflow.md`.
- `Simulation_random_walk/Setting2/File_Manifest.md` becomes `docs/simulation_random_walk_setting2_file_manifest.md`.
- `Simulation_random_walk/Setting1/working_log/2026-04-29_codex_log.md` becomes `docs/simulation_random_walk_setting1_2026-04-29_codex_log.md`.

Do not create new scattered markdown or log files outside `docs/` unless a tool temporarily generates one and the same milestone moves it here.

Exception: `RANDOM_WALK_SETTING_DESIGN_SUMMARY.md` intentionally lives at the repository root as the single consolidated random-walk design and true-parameter reference.
