# Plan And Goal

This checklist records current milestones for repository document management and simulation workflow continuity.

## Active Goal

Recalibrate the random-walk simulation suite so candidate shared parameters and candidate shared analogues have calibrated true values close to their implied targets. Each accepted calibration must pass candidate coefficient and implied-difference validation before production simulations are rerun.

## Active Milestones

- [x] RW-FM 1: Add per-setting management documents and update agent control docs.
- [x] RW-FM 2: Move local generated artifacts into per-setting folders and update scripts/PBS paths.
- [x] RW-FM 3: Generate per-setting `Summarize/` outputs for current results and todo status.
- [x] RW-FM 4: Run smoke tests and path validation after relocation.
- [x] RW-FM 5: Final validation, log update, commit, and push.
- [x] RW-DOC 1: Consolidate random-walk setting design, sample sizes, parameter targets, and calibrated true values into a root markdown reference; remove redundant design-only markdown files.
- [x] RW-CAL 1: Add target-centered candidate constraints and validation tooling for all random-walk settings.
- [x] RW-CAL 2: Run bounded constrained calibration smoke checks for Setting I, Setting II, Setting III, and Supplementary Setting III No Shared.
- [ ] RW-CAL 3: Review bounded smoke failures and decide whether to increase optimizer budget/starts, relax or revise infeasible implied targets, or split default versus stress-test acceptance criteria.
- [ ] RW-CAL 4: Run production constrained calibration for all accepted default and sensitivity specs; regenerate candidate calibration reports.
- [ ] RW-CAL 5: Rerun production simulations only after default production calibration specs pass validation.
- [ ] RW-CAL 6: Regenerate summaries, update logs/docs, commit, and push accepted scripts and summary outputs.

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
- Candidate-parameter recalibration now uses target-centered constraints with tolerance `0.03` for both individual coefficients and implied pair/group differences.
- `Simulation_random_walk/validate_candidate_calibration.R` writes `candidate_calibration_report.md` and `.csv` into each setting's `Summarize/` folder; a passing report is required before production simulations are accepted.
- `Simulation_random_walk/run_candidate_calibration_smoke.R` writes bounded smoke artifacts under ignored `calibration/candidate_constraint_smoke/` folders and `candidate_calibration_smoke_report.md`/`.csv` summaries. The current smoke reports fail the `0.03` gate: Setting II `separated_moderate` mostly passes, Setting III and supplementary moderate are close on several terms, but Setting I sensitivity specs, Setting II reversed/large, and supplementary large have larger misses that need review before production calibration.

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
