# Setting IV Todo

- Keep code-file objectives and parameter choices synchronized with the corresponding top-level management document.
- Rerun `Rscript Simulation_random_walk/summarize_setting_results.R` after any new simulation output is produced.
- Missing production outputs for n = 100, 300, 500, 1000. Run production simulation after adding the cleaned Project Quit / Forever Free source data and accepted calibration artifacts.
- Synthetic fallback files are useful for exercising code and evaluation paths, but they are not accepted production Setting IV results.
- Locate or add the cleaned Project Quit / Forever Free source data with the required columns from `PROJECT_QUIT_FOREVER_FREE_SETTING_IV_DESIGN.md`.
- Run production mode with `SETTING4_SOURCE_DATA=/path/to/data` and without `SETTING4_ALLOW_SYNTHETIC=1`.
- Add and validate a production calibration gate analogous to Settings I-III before using Setting IV in manuscript tables.
- Do not include `results_*_synthetic.rds` or synthetic calibration artifacts in production method claims.
- Keep large `.rds` artifacts local or move them to Git LFS/external storage if versioning is required.
