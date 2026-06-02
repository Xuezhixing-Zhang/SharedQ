# Random Walk Setting I Todo

- Keep code-file objectives and parameter choices synchronized with the corresponding top-level management document.
- Rerun `Rscript Simulation_random_walk/summarize_setting_results.R` after any new simulation output is produced.
- Production output files are present for all expected sample sizes, but they predate the rounded `balanced_small` target revision and should not be used for final Setting I reporting.
- Rerun Setting I calibration/gate validation and promote only an artifact whose target vector and calibrated true values satisfy the revised near-shared design.
- Rerun Setting I production simulations only after the revised calibration passes; then regenerate summaries and manuscript tables so Setting I results are aligned with the revised design.
- Keep large `.rds` artifacts local or move them to Git LFS/external storage if versioning is required.
