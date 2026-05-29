# Setting IV: Project Quit / Forever Free Shared Design

This folder is the implementation workspace for the Project Quit / Forever Free Setting IV design described in `PROJECT_QUIT_FOREVER_FREE_SETTING_IV_DESIGN.md`.

## Scope

- Main scenario: `pqff_shared_parsimonious`
- Population: `FFConsent = 1`
- Stage 1 treatment: five Project Quit fractional-factorial components
- Stage 2 treatment: Forever Free arm, default allocation `P(A_FF = +1) = 2/3`
- Primary reward: `Y_primary = Y_PQ + Y_FF`

## Shared-Parameter Rule

The shared true coefficients must follow the project-wide random shared rule:

```text
theta_j^(d) = mu_j + delta_j^(d),  delta_j^(d) ~ N(0, sigma_shared^2)
```

Do not implement Setting IV shared targets as deterministic `mu + sigma` or `mu - sigma` offsets.

## Implementation Status

The folder now has executable data-generation, Q-learning, helper, and simulation wrappers:

- `Q_datagenerating.R`
- `Q_learning.R`
- `Q_functions.R`
- `Simulation_Setting4.R`

Production mode is strict: it requires a cleaned Project Quit / Forever Free source data file through `SETTING4_SOURCE_DATA`. If that file is absent, the script stops unless `SETTING4_ALLOW_SYNTHETIC=1` is set.

Synthetic fallback mode has been run for `n = 100, 300, 500, 1000` with `200/200` non-null replicates per sample size. These outputs exercise the code and evaluation path only. They are not accepted production Setting IV results, and they must not be used in manuscript tables or method claims.

Production Setting IV remains blocked until the cleaned PQ/FF source data is supplied, production calibration is generated, and a validation gate analogous to Settings I-III passes.
