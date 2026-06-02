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
