# Plan And Goal

This checklist records current milestones for repository document management and simulation workflow continuity.

## Active Goal

Correct and rerun the random-walk simulation suite under the required random shared true-parameter design. In Setting I and Setting III, each true shared coefficient must be generated as `theta_j^(d) = mu_j + delta_j^(d)`, with `delta_j^(d) ~ N(0, sigma_shared^2)`, before calibration. Each accepted calibration must pass both current-target-definition validation and candidate coefficient/difference validation before production simulations are rerun.

## Active Milestones

- [x] RW-FM 1: Add per-setting management documents and update agent control docs.
- [x] RW-FM 2: Move local generated artifacts into per-setting folders and update scripts/PBS paths.
- [x] RW-FM 3: Generate per-setting `Summarize/` outputs for current results and todo status.
- [x] RW-FM 4: Run smoke tests and path validation after relocation.
- [x] RW-FM 5: Final validation, log update, commit, and push.
- [x] RW-DOC 1: Consolidate random-walk setting design, sample sizes, parameter targets, and calibrated true values into a root markdown reference; remove redundant design-only markdown files.
- [x] RW-CAL 1: Add target-centered candidate constraints and validation tooling for all random-walk settings.
- [x] RW-CAL 2: Run bounded constrained calibration smoke checks for Setting I, Setting II, Setting III, and Supplementary Setting III No Shared.
- [x] RW-CAL 3: Review bounded smoke failures and decide whether to increase optimizer budget/starts, relax or revise infeasible implied targets, or split default versus stress-test acceptance criteria.
- [ ] RW-CAL 4: Recalibrate the corrected random-shared Setting I and Setting III default specs; regenerate candidate calibration reports and gate selection reports.
- [ ] RW-CAL 5: Rerun production simulations only after corrected default production calibration specs pass validation.
- [ ] RW-CAL 6: Regenerate summaries, update logs/docs, commit, and push accepted scripts and summary outputs.

## Current Progress Summary

- Completed document consolidation: `RANDOM_WALK_SETTING_DESIGN_SUMMARY.md` is the root reference for setting design, sample sizes, target parameters, true-sharing relationships, primary outcome models, and current calibrated true-value summaries.
- Completed calibration tooling: all four random-walk calibration scripts now impose target-centered candidate coefficient windows and implied-difference constraints. Setting I and Setting III use strict `0.01` windows; Setting II and Supplementary Setting III No Shared retain `0.03` windows around their intentionally separated targets.
- Completed validation tooling: `Simulation_random_walk/validate_candidate_calibration.R` checks production calibration artifacts with per-setting tolerances and writes candidate coefficient/difference reports; `Simulation_random_walk/run_candidate_calibration_smoke.R` runs bounded calibration smoke checks into ignored local artifact folders and writes smoke reports.
- Completed RW-CAL 3 decision: rerun default-spec calibration first with larger optimizer budgets and multiple starts; keep no-shared settings centered on separated targets; do not force exact equality or zero differences.
- Current production calibration status: superseded for Setting I and Setting III. The earlier May 27 promoted artifacts used deterministic shared targets (`mu +/- sigma` or ordered offsets) instead of random deviations around `mu`, so they are not accepted under the corrected design. Setting II and Supplementary Setting III No Shared keep their separated no-shared target definitions.
- Current bounded smoke status: rerun under the corrected random-shared targets. Setting I and Setting III smoke artifacts now match the current script-generated `theta_target`, but the low-budget optimizer does not reach the coefficient/difference gate. The corrected default target draws are `balanced_small`: `Q3_A1=0.1102`, `Q2_A1=0.1366`, `Q3_A3=-0.3500`, `Q2_A2=-0.3500`, `Q3_A1A3=0.6033`, `Q2_A1A2=0.6121`; and `rw_sigma_moderate`: `Q3_A3=-0.3077`, `Q2_A2=-0.1997`, `Q1_A1=-0.2099`, `Q3_O3:A3=0.4630`, `Q2_O2:A2=0.5521`, `Q1_O1:A1=0.5803`, `Q3_A2:A3=0.3462`, `Q2_A1:A2=0.2504`.
- Current scheduler checkpoint: the full production simulations submitted on 2026-05-27 as `516131.hn-10-03`, `516132.hn-10-03`, `516133.hn-10-03`, and `516134.hn-10-03` were canceled after the shared-parameter design error was identified. They must not be used for tables or method claims.
- Current implementation status: Setting I and Setting III target builders now draw random shared true coefficients from normal deviations around latent means using the spec seed. Validation and gate selection now also check that a calibration artifact's stored `theta_target` matches the current script-generated target, so old deterministic artifacts cannot pass.
- Current replacement calibration jobs: Setting I `rs_tol006` `516208.hn-10-03`, `rs_tol008` `516209.hn-10-03`, `rs_tol010` `516210.hn-10-03`; Setting III `rs_tol006` `516211.hn-10-03`, `rs_tol010` `516212.hn-10-03`, `rs_tol008` `516213.hn-10-03`. All were submitted on queue `long` with production-scale `mc_n=1000000`, `maxeval=150000`, `local_maxeval=30000`, and `n_starts=5`.
- Current tuning policy: if any calibration job or default validation report fails, follow `docs/random_walk_calibration_tuning_strategy.md`; submit isolated parallel gate candidates before serial retries, adjust optimizer constraints before scientific targets, and only adjust scientific parameter targets after repeated material failures are documented.
- Next real work: monitor the six replacement gate-candidate calibration jobs. After they finish, run `CALIBRATION_GATE_SETTINGS=Setting1,Setting3 Rscript Simulation_random_walk/select_calibration_gate_candidate.R`; promote only passing corrected artifacts, run `VALIDATION_SPEC_MODE=default Rscript Simulation_random_walk/validate_candidate_calibration.R`, then rerun full simulations for all settings and regenerate summaries/tables. The evaluation phase should still check whether the proposed method beats old SharedQ and conventional Q in most settings before writing manuscript-facing tables.

## Artifact Versioning Policy

- Large generated `.rds` files are local artifacts and should not be pushed to normal Git history.
- Commit and push docs, scripts, folder placeholders, and summary outputs after each milestone.
- If the project later needs binary result history, use Git LFS or an external artifact store.

## Current RW-FM Notes

- Generated `.rds` and `.out` artifacts have been moved into setting-local `calibration/`, `simulation_results/`, `test_results/`, and `logs/` folders.
- Scripts now use the categorized paths for calibration inputs, population datasets, simulation results, test outputs, and PBS logs.
- Each setting has a `Summarize/` folder reserved for generated result summaries and next-step notes.
- `Simulation_random_walk/summarize_setting_results.R` now generates per-setting `current_results_summary.md`, `evaluation_summary.csv`, and `todo.md`.
- Quick smoke tests pass for Setting I, Setting II, Setting III, and Supplementary Setting III No Shared after relocation.
- Test scripts now restore pre-existing `calibration/data_original.rds` after bounded population-generation checks, preventing smoke tests from overwriting production Monte Carlo population files.
- Path validation confirms no generated `.rds` or `.out` files remain in the old shallow setting folders.
- `RANDOM_WALK_SETTING_DESIGN_SUMMARY.md` is now the single root-level reference for random-walk setting designs, sample sizes, parameter targets, and calibrated true-value summaries.
- Candidate-parameter recalibration now uses target-centered constraints for both individual coefficients and implied pair/group differences, with `0.01` tolerance for true near-shared random-walk settings and `0.03` tolerance for no-shared settings.
- `Simulation_random_walk/validate_candidate_calibration.R` writes `candidate_calibration_report.md` and `.csv` into each setting's `Summarize/` folder using per-setting tolerances; a passing report is required before production simulations are accepted.
- `Simulation_random_walk/run_candidate_calibration_smoke.R` writes bounded smoke artifacts under ignored `calibration/candidate_constraint_smoke/` folders and `candidate_calibration_smoke_report.md`/`.csv` summaries. The runner supports `CALIBRATION_SPEC_MODE`, `CALIBRATION_SPECS`, `CALIBRATION_MC_N`, `CALIBRATION_MAXEVAL`, `CALIBRATION_LOCAL_MAXEVAL`, `CALIBRATION_N_STARTS`, `CALIBRATION_PRINT_LEVEL`, and `CALIBRATION_TARGET_TOLERANCE`.

## Milestones

- [x] Milestone 1: Repair usable Git metadata.
  - External Git metadata initialized at `/tmp/SharedQ.git` because the workspace `.git` directory is read-only and invalid.
  - Remote configured as `git@github.com:Xuezhixing-Zhang/SharedQ.git`.
  - GitHub connector verified the remote repository exists and is empty.
  - SSH shell access to GitHub currently times out on port 22, so pushes may be blocked from this environment.

- [x] Milestone 2: Create document control files.
  - Create `docs/readme.md`.
  - Create `docs/plan and goal.md`.
  - Create `docs/2026-05-13_log.md`.
  - Commit and push the milestone if possible. Local commit is ready; shell push depends on SSH connectivity.

- [x] Milestone 3: Move all document files into `docs/`.
  - Move all markdown, text-like readme, working log, and `.docx` report files.
  - Use source-prefixed filenames to avoid collisions.
  - Update this checklist and today's log.
  - Commit and push the milestone if possible. Shell push is blocked until GitHub SSH credentials are fixed.

- [x] Milestone 4: Update stale references.
  - Update markdown references to moved documents.
  - Update `Simulation_random_walk/summarize_true_estimates.R` to write the generated summary into `docs/`.
  - Update this checklist and today's log.
  - Commit and push the milestone if possible. Push is ready to retry after the deploy key is added to GitHub with write access.

- [x] Milestone 5: Validate final layout.
  - Confirm all documents are under `docs/`.
  - Search for stale document paths.
  - Check Git status.
  - Record final verification notes.
  - Commit and push the milestone if possible. Final local commits were pushed successfully after deploy-key access was enabled.

## Current Notes

- Normal `git` commands do not work in this checkout because `.git` is an empty read-only directory.
- Use `git --git-dir=/tmp/SharedQ.git --work-tree=/data/cheungyb/home/e1404425/SharedQ ...` for local Git operations in this session.
- Do not move code, `.rds`, `.out`, images, or simulation data as part of this document-management task.
- Shell push on `github.com:22` timed out in this environment, so pushes use GitHub SSH over port 443.
- New deploy key generated at `/data/cheungyb/home/e1404425/.ssh/sharedq_deploy_key`; it is now configured for this session's Git pushes.
- Latest pushed branch: `main` to `ssh://git@ssh.github.com:443/Xuezhixing-Zhang/SharedQ.git`.
