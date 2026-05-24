# Random-Walk Calibration Tuning Strategy

This strategy is mandatory for future random-walk calibration tuning. If a calibration job fails or a default candidate validation report fails, do not proceed to production simulations. Diagnose the failure, tune systematically, and record the attempted settings in the daily log and `docs/plan and goal.md`.

## Acceptance Gate

- Keep validation acceptance fixed unless there is an explicit project decision to change the scientific target:
  - Setting I and Setting III: candidate validation tolerance `0.01`.
  - Setting II and Supplementary Setting III No Shared: candidate validation tolerance `0.03`.
- Production simulations may run only after all four default specs pass:
  - Setting I: `balanced_small`
  - Setting II: `separated_moderate`
  - Setting III: `rw_sigma_moderate`
  - Supplementary Setting III No Shared: `separated_moderate`

## Failure Classification

After any calibration job completes, run:

```bash
module load r/4.4.0
VALIDATION_SPEC_MODE=default Rscript Simulation_random_walk/validate_candidate_calibration.R
```

Classify each failed setting before changing anything:

- Runtime failure: PBS killed the job, R exited, missing output artifact, or log contains `Error`/`Execution halted`.
- Boundary failure: only a few checks miss by numerical boundary amounts near the tolerance.
- Material target failure: candidate coefficients or implied differences miss by much more than the tolerance.
- Apparent infeasibility: repeated high-budget retries fail with similar material misses.

## Monitoring Cadence

- Check active calibration jobs with `qstat -u e1404425`.
- For production-scale default calibration jobs, wait at least `3-4` hours before the first non-urgent follow-up unless the log shows an immediate runtime error.
- Expected runtime ranges:
  - Setting I default calibration: usually under `4` hours; higher-effort retries may take longer.
  - Setting III default calibration: usually `1-4` hours.
  - Supplementary Setting III No Shared default calibration: usually `1-4` hours.
  - Setting II default calibration: high variance; expect `12-24` hours and allow up to the submitted walltime unless logs show a failure.
- If any job reaches `24` hours, inspect the matching log and artifact timestamp before deciding whether to keep waiting, stop, or retune.
- If a job reaches walltime or exits without updating its artifact, classify it as a runtime failure and follow the tuning ladder.

## Tuning Ladder

1. Runtime failure:
   - Increase walltime or move to a longer queue first.
   - Keep scientific targets and validation tolerances unchanged.
   - Reuse the same default spec and record the old/new job IDs.

2. Boundary failure:
   - Tighten only the optimizer's internal target window, not the acceptance gate.
   - Use `CALIBRATION_TARGET_TOLERANCE=0.008` for shared settings and `0.028` for no-shared settings.
   - Increase starts to `CALIBRATION_N_STARTS=5` if the retry still lands on the boundary.

3. Material target failure:
   - First increase optimizer search effort: `CALIBRATION_MAXEVAL=150000`, `CALIBRATION_LOCAL_MAXEVAL=30000`, `CALIBRATION_N_STARTS=5`.
   - If needed, run lower-cost feasibility probes with smaller `CALIBRATION_MC_N` before another full `mc_n=1000000` run.
   - Compare failures by max absolute candidate error and number of failed checks; keep the best artifact only if it passes validation.

4. Apparent infeasibility:
   - Tune parameter targets systematically while preserving the intended setting role.
   - Setting I: keep near-shared signs and pair structure; try smaller `shared_sigma` values before changing `shared_mu`.
   - Setting III: keep random-walk ordering; try smaller sigma magnitudes before changing means.
   - Setting II and Supplementary No Shared: keep the no-shared sign/separation pattern; shrink separated target magnitudes gradually before changing signs.
   - Any changed scientific target must be documented in `RANDOM_WALK_SETTING_DESIGN_SUMMARY.md` before production simulation.

## Parallel Gate Candidate Strategy

- When launching a production-scale calibration retry, prefer submitting multiple isolated internal gate candidates at the same time instead of serially trying one `CALIBRATION_TARGET_TOLERANCE`.
- Keep the acceptance gate fixed: `0.01` for Setting I/III and `0.03` for Setting II/Supplementary No Shared. Only vary the optimizer's internal target window and search budget unless the failure is classified as apparent infeasibility.
- Candidate artifacts must write to `calibration/gate_candidates/<profile>/` via `CALIBRATION_OUTPUT_DIR`; do not let parallel jobs overwrite the production artifact names directly.
- Default internal gate grids:
  - Setting I and Setting III: run or compare `CALIBRATION_TARGET_TOLERANCE` values `0.006`, `0.008`, and `0.009`.
  - Setting II and Supplementary Setting III No Shared: run or compare `CALIBRATION_TARGET_TOLERANCE` values `0.024`, `0.027`, and `0.029`.
- The current production artifact may count as one candidate if it was generated with a documented gate value.
- After candidate jobs finish, run `Rscript Simulation_random_walk/select_calibration_gate_candidate.R`. Select the passing candidate with the smallest max absolute candidate-validation error, using mean absolute error and optimizer `best_value` as tie-breakers.
- Promote a selected gate candidate to the production artifact path only after the selector report shows `PASS`. Use `CALIBRATION_GATE_PROMOTE=1 Rscript Simulation_random_walk/select_calibration_gate_candidate.R` when promotion is intended.

## Reporting Rule

For each tuning attempt, record:

- setting, spec, job ID, queue, walltime, `mc_n`, optimizer budgets, starts, and internal target tolerance;
- whether the output artifact timestamp changed;
- validation status and the largest failed candidate error;
- whether the next action is retry, constraint tuning, target tuning, or production simulation.
