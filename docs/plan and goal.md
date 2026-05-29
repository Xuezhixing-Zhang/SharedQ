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
- [x] RW-CAL 4: Recalibrate/accept the corrected random-shared Setting I and Setting III default specs; regenerate candidate calibration reports and gate selection reports.
- [x] RW-CAL 5: Rerun production simulations only after corrected default production calibration specs pass validation.
- [x] RW-CAL 6: Regenerate summaries, update logs/docs, commit, and push accepted scripts and summary outputs.
- [x] SET-IV 1: Add Project Quit / Forever Free Setting IV root design note and initialize `Setting4` plus `SupplSetting4_NoShared` folder structures.
- [ ] SET-IV 2: Implement Setting IV data preparation, target builders, calibration, validation, simulation, and evaluation scripts.

## Current Progress Summary

- Completed document consolidation: `RANDOM_WALK_SETTING_DESIGN_SUMMARY.md` is the root reference for setting design, sample sizes, target parameters, true-sharing relationships, primary outcome models, and current calibrated true-value summaries.
- Completed calibration tooling: all four random-walk calibration scripts now impose target-centered candidate coefficient windows and implied-difference constraints. Setting I and Setting III use strict `0.01` windows; Setting II and Supplementary Setting III No Shared retain `0.03` windows around their intentionally separated targets.
- Completed validation tooling: `Simulation_random_walk/validate_candidate_calibration.R` checks production calibration artifacts with per-setting tolerances and writes candidate coefficient/difference reports; `Simulation_random_walk/run_candidate_calibration_smoke.R` runs bounded calibration smoke checks into ignored local artifact folders and writes smoke reports.
- Completed RW-CAL 3 decision: rerun default-spec calibration first with larger optimizer budgets and multiple starts; keep no-shared settings centered on separated targets; do not force exact equality or zero differences.
- Current production calibration status: all four active random-walk default specs pass validation as of 2026-05-28. Setting I now represents the feasible `balanced_small` target as random shared draws using seed `63`, `shared_mu=(0.1251519160,-0.35,0.6158834940)`, and `shared_sigma=(0.0187658541,0,0.0083599859)`, yielding accepted targets `Q3_A1=0.1500`, `Q2_A1=0.0900`, `Q3_A3=-0.3500`, `Q2_A2=-0.3500`, `Q3_A1A3=0.6200`, and `Q2_A1A2=0.6000`. Setting III `rs_tol006` remains the promoted default. Setting II and Supplementary Setting III No Shared keep their separated no-shared target definitions.
- Current bounded smoke status: older low-budget Setting I smoke reports are stale relative to the accepted 2026-05-28 target representation. The active gate is the default validation report and gate-selection report, both of which pass for Setting I after the feasible random-shared target update. Setting III default validation and gate selection also pass after `rs_tol006` promotion.
- Current scheduler checkpoint: the full production simulations submitted on 2026-05-27 as `516131.hn-10-03`, `516132.hn-10-03`, `516133.hn-10-03`, and `516134.hn-10-03` were canceled after the shared-parameter design error was identified. They must not be used for tables or method claims.
- Current implementation status: Setting I and Setting III target builders now draw random shared true coefficients from normal deviations around latent means using the spec seed. Validation and gate selection now also check that a calibration artifact's stored `theta_target` matches the current script-generated target, so old deterministic artifacts cannot pass.
- Current replacement calibration selection status: selection was rerun on 2026-05-28. Setting I and Setting III gate-selection reports now pass. Setting I's current production artifact passes after the feasible target was re-expressed through the random-shared draw rule; Setting III `rs_tol006` is promoted.
- Current production result status: all four active random-walk production simulations submitted on 2026-05-28 completed by 2026-05-29. Setting I `523877.hn-10-03`, Setting II `523878.hn-10-03`, Setting III `523879.hn-10-03`, and Supplementary Setting III No Shared `523880.hn-10-03` each produced complete `200/200` replicate outputs for `n = 100, 300, 500, 1000`. Full evaluation summaries and manuscript-style tables were regenerated under `Simulation_random_walk/Writing/generated_tables/`.
- Setting IV setup status: `PROJECT_QUIT_FOREVER_FREE_SETTING_IV_DESIGN.md` is the root design note for the Project Quit / Forever Free parsimonious two-stage design. The main `Simulation_random_walk/Setting4/` folder now has executable data-generation, Q-learning, helper, and simulation wrappers with strict production mode requiring `SETTING4_SOURCE_DATA`. A synthetic fallback run completed for `n = 100, 300, 500, 1000` with `200/200` non-null replicates per sample size, but these are code/evaluation smoke artifacts only and are not accepted production Setting IV results. `Simulation_random_walk/SupplSetting4_NoShared/` remains initialized but not implemented.
- Current tuning policy: if any calibration job or default validation report fails, follow `docs/random_walk_calibration_tuning_strategy.md`; submit isolated parallel gate candidates before serial retries, adjust optimizer constraints before scientific targets, and only adjust scientific parameter targets after repeated material failures are documented.
- Next real work: review `Simulation_random_walk/Writing/generated_tables/method_claim_check.*` and the generated main/supplement Word tables, then decide final method-claim language. Separately, locate or add the cleaned PQ/FF data needed for production Setting IV.
- Setting IV next work: run production Setting IV only after locating or adding the cleaned PQ/FF source data. A workspace/home search on 2026-05-28 did not find files containing the required `FFConsent`, `FFArm`, `QuitOverall*`, `PQ6*`, or treatment-depth variables. Once data is available, run `Simulation_random_walk/Setting4/Simulation_Setting4.R` with `SETTING4_SOURCE_DATA=/path/to/data` and without `SETTING4_ALLOW_SYNTHETIC=1`, then add/validate a production calibration gate analogous to Settings I-III. Setting IV must not be included in production tables until default calibration artifacts exist and pass validation.
- Current user-requested workflow: the active random-walk production simulations and full table/evaluation regeneration are complete. Setting IV synthetic fallback simulation/evaluation is complete, but production Setting IV remains blocked on cleaned PQ/FF source data and accepted calibration/validation artifacts.

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
