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

The folder structure is initialized only. Calibration, simulation, Q-learning wrappers, PBS scripts, validation reports, and production summaries are pending.
