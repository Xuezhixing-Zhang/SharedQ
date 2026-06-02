# Supplementary Setting IV No Shared

This folder is the implementation workspace for the no-shared Project Quit / Forever Free supplementary design described in `RANDOM_WALK_SETTING_DESIGN_SUMMARY.md`.

## Scope

- Default scenario: `pqff_separated_parsimonious`
- Simulation type: synthetic-parametric
- Population, treatment coding, treatment allocation, state variables, transition model, and reward definition match Setting IV.
- Candidate shared groups are intentionally separated in the true target parameters.

## Implementation Status

This folder uses the shared Setting IV implementation through `Simulation_Setting4_NoShared.R`, with artifacts written under this supplementary folder.

Run Supplementary Setting IV No Shared with:

```bash
module load r/4.4.0
Rscript Simulation_random_walk/SupplSetting4_NoShared/Simulation_Setting4_NoShared.R
```

Accepted calibration artifacts must have `source_mode = "synthetic_parametric"`. Do not reuse main Setting IV shared artifacts as no-shared results.

Accepted true estimates for this supplementary setting must come from the calibration artifact's saved population-projected `theta`, not directly from the separated target vector. Regenerate them by forcing recalibration (`SETTING4_RECALIBRATE=1`), which rebuilds the target, constructs/calibrates `gamma`, projects the synthetic working Q coefficients on a large Monte Carlo population, saves the resulting `theta`, and then runs production simulations from that artifact.
