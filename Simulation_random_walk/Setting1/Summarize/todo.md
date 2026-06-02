# Random Walk Setting I Todo

- Keep code-file objectives and parameter choices synchronized with the corresponding top-level management document.
- Rerun `Rscript Simulation_random_walk/summarize_setting_results.R` after any new simulation output is produced.
- Production output files are present for all expected sample sizes; review `evaluation_summary.csv` before manuscript table generation.
- Revise `balanced_small` before final reporting: replace high-precision `shared_mu`/`shared_sigma` with rounded values and reduce the `Q3_A1` / `Q2_A1` target gap from the current `0.0600` to a clearly near-shared gap, preferably at most `0.02`.
- After revising the Setting I target, rerun Setting I calibration/gate validation and promote only an artifact whose target vector and calibrated true values satisfy the near-shared gap criterion.
- Rerun Setting I production simulations only after the revised calibration passes; then regenerate summaries and manuscript tables so Setting I results are aligned with the revised design.
- Keep large `.rds` artifacts local or move them to Git LFS/external storage if versioning is required.
