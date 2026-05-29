# Supplementary Setting IV No Shared Todo

- Reuse Setting IV data preparation, treatment recoding, treatment allocation, and working Q-model structure.
- Add or locate the cleaned Project Quit / Forever Free source data required by Setting IV.
- Implement separated target builder for `pqff_separated_parsimonious`, `pqff_separated_reversed`, and `pqff_separated_large`.
- Implement calibration, validation, simulation, and evaluation scripts following the supplementary no-shared setting patterns.
- Run supplementary Setting IV parameter selection only after the calibration and validation tooling exists.
- Run bounded smoke checks before production calibration.
- Run production simulations only after default calibration passes validation.
- Do not reuse or report main Setting IV synthetic fallback outputs as supplementary no-shared results.
