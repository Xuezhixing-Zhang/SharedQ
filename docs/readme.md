# Agent Document Guide

This folder is the single document hub for the SharedQ workspace. Future agents should start here before reading code or running simulations.

## Start Of Work Checklist

1. Read `docs/readme.md`.
2. Read `docs/plan and goal.md` and identify the current incomplete milestone.
3. Read today's log file in `docs/`, named as `YYYY-MM-DD_log.md`. If it does not exist, create it before starting work.
4. Read the setting-specific workflow, manifest, design, and handoff documents listed in the relevant milestone.
5. Update `docs/plan and goal.md` and today's log before making code or document changes.

## Required Updates During Work

- Update `docs/plan and goal.md` when starting a milestone, completing a milestone, or changing the planned milestone order.
- Update today's log every time a meaningful decision, blocker, command result, or verification outcome occurs.
- After each milestone is complete, commit the relevant changes and push them to the configured Git remote.
- If push fails, record the exact blocker in today's log before moving to the next milestone.

## Current Primary Work Area

The active research workflow is the simulation random walk setting suite. For Setting I work, read:

- `docs/simulation_random_walk_setting1_workflow.md`
- `docs/simulation_random_walk_setting1_file_manifest.md`
- `docs/simulation_random_walk_setting1_handoff.md`
- `docs/simulation_random_walk_setting1_agent_work.md`
- `docs/simulation_random_walk_setting1_setting_i_design.md`
- `docs/simulation_random_walk_setting1_shared_parameter_specifications.md`
- `docs/the_algorithm.md`

For Setting II, Setting III, and supplementary no-shared work, read the matching `simulation_random_walk_*_workflow.md` and `simulation_random_walk_*_file_manifest.md` files.

For per-setting file management, artifact layout, parameter choices, seeds, and result status, read the matching management file:

- `docs/simulation_random_walk_setting1_management.md`
- `docs/simulation_random_walk_setting2_management.md`
- `docs/simulation_random_walk_setting3_management.md`
- `docs/simulation_random_walk_supplsetting3_noshared_management.md`

For current generated-result summaries and next actions, read each setting's `Summarize/current_results_summary.md` and `Summarize/todo.md`.

## Document Naming

All documents live directly under `docs/`. Source paths are encoded into lowercase, underscore-separated filenames to avoid collisions between settings.

Examples:

- `Simulation_random_walk/Setting1/Workflow.md` becomes `docs/simulation_random_walk_setting1_workflow.md`.
- `Simulation_random_walk/Setting2/File_Manifest.md` becomes `docs/simulation_random_walk_setting2_file_manifest.md`.
- `Simulation_random_walk/Setting1/working_log/2026-04-29_codex_log.md` becomes `docs/simulation_random_walk_setting1_2026-04-29_codex_log.md`.

Do not create new scattered markdown or log files outside `docs/` unless a tool temporarily generates one and the same milestone moves it here.
