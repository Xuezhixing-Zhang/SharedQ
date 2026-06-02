# Supplementary Setting IV No Shared Todo

- Keep code-file objectives and parameter choices synchronized with the corresponding top-level management document.
- Rerun `Rscript Simulation_random_walk/summarize_setting_results.R` after any new simulation output is produced.
- Production output files are present for all expected sample sizes; review `evaluation_summary.csv` before manuscript table generation.
- Accepted true estimates must come from the synthetic-parametric target-to-truth calibration/projection artifact's saved `theta`, not from the scripted `theta_target` vector alone.
- Keep this setting paired with Setting IV when regenerating manuscript tables.
- Do not reuse main Setting IV shared artifacts as no-shared results.
- Keep large `.rds` artifacts local or move them to Git LFS/external storage if versioning is required.
