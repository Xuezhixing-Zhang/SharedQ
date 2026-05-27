# Project Quit / Forever Free Setting IV Parsimonious Design Summary

This file is a revised, parsimonious version of the Project Quit / Forever Free Setting IV simulation design. It replaces the earlier draft that used a broad set of demographic and behavioral covariates. The goal of this revision is to respect the randomized design and keep only the covariates needed to define clinically interpretable Q-learning histories and shared-parameter candidates.

The study is randomized:

- Stage 1, Project Quit (PQ), is a randomized fractional factorial design with five binary intervention components.
- Stage 2, Forever Free (FF), is a randomized binary intervention among participants with `FFConsent = 1`.

Therefore, the covariates below are not included for confounding control. They are included only because Q-learning requires a state/history and because the shared-parameter method needs scientifically interpretable cross-stage analogues.

## Common Simulation Plan

| Setting | Design goal | Sample sizes | Production replicates | Production/default spec |
| --- | --- | --- | ---: | --- |
| Setting IV | Two-stage Project Quit / Forever Free randomized-design mimic with a small number of truly near-shared behavioral effects. | `100`, `300`, `500`, `1000` | 200 per size | `pqff_shared_parsimonious` |
| Supplementary Setting IV No Shared | Same randomized two-stage mechanism, but the candidate shared effects are intentionally separated. | `100`, `300`, `500`, `1000` | 200 per size | `pqff_separated_parsimonious` |

Both settings compare conventional Q-learning, fused lasso SQ-learning, fused ridge SQ-learning, and strict SharedQ variants where applicable. The supplementary no-shared setting retains shared-pattern estimators as intentionally misspecified comparisons.

## Data Source And Stage Structure

The simulation is based on the cleaned Project Quit / Forever Free data.

- `Quit*` variables are baseline variables measured before Project Quit randomization.
- `PQ6*` variables are measured at the end of Project Quit, approximately 6 months after stage-1 randomization.
- `FF6*` variables are measured at the end of Forever Free, approximately 6 months after stage-2 randomization.
- `FFConsent` indicates whether a Project Quit participant consented to stage-2 randomization.
- `FFArm` is the stage-2 randomized Forever Free treatment among participants with `FFConsent = 1`.

The default two-stage analysis population is:

```text
FFConsent = 1
```

This keeps the two-stage Q-learning problem well-defined because `FFArm` is observed only among stage-2 consenters. Non-consent is a design feature rather than ordinary dropout, but the resulting dynamic treatment regime is conditional on being eligible and consenting to stage-2 randomization.

## Treatment Coding

Use scientifically oriented treatment codings. The raw signs in the cleaned file should be recoded before fitting the Q-model:

```text
A_source   = -SOURCE.DEPTH      # +1 = high source personalization, -1 = low source personalization
A_outcome  =  OUTCOME.DEPTH     # +1 = high outcome-expectation depth, -1 = low depth
A_story    =  STORY.DEPTH       # +1 = high success-story depth, -1 = low depth
A_efficacy =  EFFICACY.DEPTH    # +1 = high efficacy-expectation depth, -1 = low depth
A_multiple = -EXPOSURE          # +1 = multiple exposure, -1 = single exposure
A_FF       =  FFArm             # +1 = Forever Free booster/intervention, -1 = control
```

Before production runs, verify the sign of `FFArm` against the final project codebook. If `FFArm = +1` is not the booster/intervention arm, reverse `A_FF`.

The stage-1 treatment vector is:

```text
A1 = (A_source, A_outcome, A_story, A_efficacy, A_multiple)
```

The stage-2 treatment is:

```text
A2 = A_FF
```

Stage-1 treatments should be sampled from the 16 observed Project Quit fractional-factorial combinations. Stage-2 treatment should be sampled according to the observed Forever Free randomization ratio among consenters, approximately:

```text
P(A_FF = +1) = 2 / 3,   P(A_FF = -1) = 1 / 3
```

A balanced `1 / 2` versus `1 / 2` stage-2 sensitivity version can be added later, but the default real-data mimic should use the empirical allocation ratio.

## Parsimonious Covariate Coding

The default simulation should use a small state vector.

### Stage-1 baseline state

```text
QuitSE        = QuitOverallSEBin
QuitMotiv     = QuitOverallMotivBin
LowEducation  = 1 - EDUCATION
```

### Stage-2 pre-randomization state

```text
PQQuit        = PQ6Quitstatus
PQSE          = PQ6OverallSEBin
PQMotiv       = PQ6OverallMotivBin
LowEducation  = 1 - EDUCATION
```

### Excluded from the default design

The following variables are excluded from the default Setting IV design:

```text
Age, Gender, RaceWhite, RaceBlack, HMO, QuitCigsPerDay,
PQ6OverallSatBin, PQ6MonthsNS, sqrtPQ6NumOfAttempts,
FF6OverallSatBin, FF6MonthsNS, sqrtFF6NumOfAttempts,
and other transformed exploratory variables.
```

These variables may be useful in real-data sensitivity analyses, but they are not needed in the default simulation setting because treatment assignment is randomized and the simulation objective is to evaluate shared-parameter learning, not to reproduce every empirical association in the dataset.

## Outcome Definition

The recommended primary simulation reward is cumulative abstinence:

```text
Y_primary = Y_PQ + Y_FF
```

where:

```text
Y_PQ = Project Quit 6-month 7-day point-prevalence abstinence
Y_FF = Forever Free 6-month 7-day point-prevalence abstinence
```

The executable simulation may generate these as binary Bernoulli outcomes through a calibrated logistic mechanism or as continuous latent rewards with additive error. For compatibility with classical Q-learning wrappers, the default calibration should project the generated outcome onto the working linear Q-model even when the data-generating mechanism is Bernoulli.

## Working Q-Models

The stage-2 working Q-model is:

```text
Q2(H2, A_FF) = intercept
             + PQQuit + PQSE + PQMotiv + LowEducation
             + A_FF
             + PQQuit:A_FF
             + PQSE:A_FF
             + PQMotiv:A_FF
             + LowEducation:A_FF
```

The stage-1 working Q-model is:

```text
Q1(H1, A1) = intercept
           + QuitSE + QuitMotiv + LowEducation
           + A_source + A_outcome + A_story + A_efficacy + A_multiple
           + QuitSE:A_efficacy
           + QuitMotiv:A_outcome
           + LowEducation:A_story
```

The stage-1 model keeps all five randomized Project Quit components because they jointly define the fractional factorial intervention. The covariate history is deliberately small.

## Sharing Relationship Summary

The word `shared` has two roles here. In Setting IV, selected Q-parameters are truly intended to be near-shared by design. In the supplementary no-shared setting, the same terms are only candidate shared groups used by the estimators; the data-generating target deliberately does not share them.

| Setting | Truly shared or near-shared by design | Sigma relationship |
| --- | --- | --- |
| Setting IV | Near-shared main-effect pairs: `Q2_PQSE / Q1_QuitSE`, `Q2_PQMotiv / Q1_QuitMotiv`, and `Q2_LowEducation / Q1_LowEducation`. Near-shared moderator analogue pairs: `Q2_PQSE:A_FF / Q1_QuitSE:A_efficacy`, `Q2_PQMotiv:A_FF / Q1_QuitMotiv:A_outcome`, and `Q2_LowEducation:A_FF / Q1_LowEducation:A_story`. | For each pair, both true coefficients are independently generated as `theta_j^(d) = mu_j + delta_j^(d)`, where `delta_j^(d) ~ N(0, sigma_shared^2)`. Thus `sigma_shared` is the SD of the random deviation around the latent common effect, not a deterministic offset. Moderator analogue pairs should be treated as weaker sharing candidates than main-effect pairs. |
| Supplementary Setting IV No Shared | None. The Setting IV candidate pairs are intentionally separated. | No `sigma` relationship is used. Shared-pattern estimators are misspecified comparisons. |

## Calibration Objective And Constraints

Calibrated true values should be generated by searching for outcome-model coefficients `gamma` whose large-population projected Q-coefficients are close to the hand-specified `theta_target`. For a proposed `gamma`, the calibration code should generate or reuse a Monte Carlo population, project the implied Q-model coefficients `theta(gamma)`, and minimize:

```text
sum((theta(gamma) - theta_target)^2)
```

The saved post-search score should report:

```text
sum(abs(theta(gamma) - theta_target))
```

The optimizer can follow the existing simulation suite and use derivative-free COBYLA (`NLOPT_LN_COBYLA`) with random starts from `runif(gamma_length, -1, 1)`. Raw `gamma` may remain unbounded unless numerical instability requires finite bounds.

| Setting | Calibration constraints to use |
| --- | --- |
| Setting IV | Constrain the six intended shared pairs listed under `pqff_shared_parsimonious` to their current targets within `0.01`; also constrain each intended pair difference to its implied target difference within `0.01`. |
| Supplementary Setting IV No Shared | Use the same candidate-pair constraints as Setting IV, but center them on separated no-shared targets within `0.03` rather than near-shared targets. |

Accepted calibration artifacts should pass a validation script analogous to the current random-walk validation gate. Until that is done, the values below are design targets, not accepted production true values.

## Setting IV

Setting IV is a two-stage Project Quit / Forever Free randomized-design mimic with five binary fractional-factorial stage-1 treatment components, one binary stage-2 treatment, and a small state vector. It is designed to evaluate whether shared-parameter Q-learning improves estimation when selected behavioral constructs have similar effects before Project Quit and before Forever Free.

The executable data mechanism should proceed as follows:

```text
1. Restrict the default two-stage analysis population to FFConsent = 1.
2. Sample the baseline state H1 = (QuitSE, QuitMotiv, LowEducation) from the cleaned data.
3. Generate or resample stage-1 treatment A1 from the observed 16-arm fractional-factorial design.
4. Generate or resample the pre-stage-2 history H2 = (PQQuit, PQSE, PQMotiv, LowEducation).
5. Generate A_FF with P(A_FF = +1) = 2/3.
6. Generate Y_primary from a calibrated outcome model whose projected Q-coefficients match the targets below.
```

The simplest executable version may resample complete empirical two-stage histories among consenters and regenerate only `Y_primary`. A more mechanistic version may separately model the transition from baseline variables to the `PQ6*` variables. Final calibrated values may differ between these implementations.

### Target shared coefficients

| Spec | Seed | Shared means | Shared sigmas | Implied target shared coefficients |
| --- | ---: | --- | --- | --- |
| `pqff_shared_parsimonious` | 601 | `SE_main=0.35`, `Motiv_main=0.24`, `LowEdu_main=-0.08`, `SE_treat=0.16`, `Motiv_treat=0.14`, `LowEdu_treat=0.18` | `0.04`, `0.03`, `0.02`, `0.03`, `0.03`, `0.04` | `Q2_PQSE=0.3560`, `Q1_QuitSE=0.4235`; `Q2_PQMotiv=0.2389`, `Q1_QuitMotiv=0.2320`; `Q2_LowEducation=-0.0863`, `Q1_LowEducation=-0.1149`; `Q2_PQSE:A_FF=0.1116`, `Q1_QuitSE:A_efficacy=0.1229`; `Q2_PQMotiv:A_FF=0.1322`, `Q1_QuitMotiv:A_outcome=0.1601`; `Q2_LowEducation:A_FF=0.1745`, `Q1_LowEducation:A_story=0.2000` |
| `pqff_shared_tight` | 602 | Same means as `pqff_shared_parsimonious` | `0.02`, `0.015`, `0.01`, `0.015`, `0.015`, `0.02` | `Q2_PQSE=0.3236`, `Q1_QuitSE=0.3487`; `Q2_PQMotiv=0.2247`, `Q1_QuitMotiv=0.2274`; `Q2_LowEducation=-0.0875`, `Q1_LowEducation=-0.0895`; `Q2_PQSE:A_FF=0.1501`, `Q1_QuitSE:A_efficacy=0.1240`; `Q2_PQMotiv:A_FF=0.1365`, `Q1_QuitMotiv:A_outcome=0.1394`; `Q2_LowEducation:A_FF=0.1870`, `Q1_LowEducation:A_story=0.1934` |
| `pqff_shared_wide` | 603 | Same means as `pqff_shared_parsimonious` | `0.08`, `0.06`, `0.04`, `0.06`, `0.06`, `0.08` | `Q2_PQSE=0.4823`, `Q1_QuitSE=0.3222`; `Q2_PQMotiv=0.2341`, `Q1_QuitMotiv=0.2962`; `Q2_LowEducation=-0.0711`, `Q1_LowEducation=0.0278`; `Q2_PQSE:A_FF=0.1290`, `Q1_QuitSE:A_efficacy=0.0976`; `Q2_PQMotiv:A_FF=0.1355`, `Q1_QuitMotiv:A_outcome=0.2704`; `Q2_LowEducation:A_FF=0.1713`, `Q1_LowEducation:A_story=0.3401` |

### Other target Q-coefficients

The following coefficients are not part of the shared-parameter groups but should be included to keep the treatment problem meaningful.

| Spec | Unshared target coefficients |
| --- | --- |
| `pqff_shared_parsimonious` | `Q1_A_source=0.20`; `Q1_A_story=0.18`; `Q1_A_outcome=0.08`; `Q1_A_efficacy=0.08`; `Q1_A_multiple=0.02`; `Q2_A_FF=0.12`; `Q2_PQQuit=0.40`; `Q2_PQQuit:A_FF=-0.08` |

### Accepted calibrated true values

No accepted calibrated true values exist yet for Setting IV. After calibration, add a table with the same structure used in the existing simulation summary.

| Spec | Parameter group | Calibrated true values |
| --- | --- | --- |
| `pqff_shared_parsimonious` | `Q2_PQSE / Q1_QuitSE` | Pending calibration. |
| `pqff_shared_parsimonious` | `Q2_PQMotiv / Q1_QuitMotiv` | Pending calibration. |
| `pqff_shared_parsimonious` | `Q2_LowEducation / Q1_LowEducation` | Pending calibration. |
| `pqff_shared_parsimonious` | `Q2_PQSE:A_FF / Q1_QuitSE:A_efficacy` | Pending calibration. |
| `pqff_shared_parsimonious` | `Q2_PQMotiv:A_FF / Q1_QuitMotiv:A_outcome` | Pending calibration. |
| `pqff_shared_parsimonious` | `Q2_LowEducation:A_FF / Q1_LowEducation:A_story` | Pending calibration. |

## Supplementary Setting IV No Shared

The supplementary no-shared setting uses the same empirical covariate distribution, treatment coding, fractional-factorial stage-1 design, stage-2 treatment allocation, outcome definition, and working Q-models as Setting IV. The only change is the target Q-parameter pattern: the Setting IV analogue groups are intentionally separated rather than shared.

This setting is designed to quantify the cost of imposing or encouraging sharing when the scientific sharing assumption is false.

### Target separated coefficients

| Spec | Seed | Target separated coefficients |
| --- | ---: | --- |
| `pqff_separated_parsimonious` | 701 | `Q2_PQSE=0.55`, `Q1_QuitSE=-0.05`; `Q2_PQMotiv=-0.15`, `Q1_QuitMotiv=0.45`; `Q2_LowEducation=0.30`, `Q1_LowEducation=-0.25`; `Q2_PQSE:A_FF=0.45`, `Q1_QuitSE:A_efficacy=-0.25`; `Q2_PQMotiv:A_FF=-0.30`, `Q1_QuitMotiv:A_outcome=0.32`; `Q2_LowEducation:A_FF=0.50`, `Q1_LowEducation:A_story=-0.20` |
| `pqff_separated_reversed` | 702 | `Q2_PQSE=-0.35`, `Q1_QuitSE=0.50`; `Q2_PQMotiv=0.40`, `Q1_QuitMotiv=-0.20`; `Q2_LowEducation=-0.30`, `Q1_LowEducation=0.25`; `Q2_PQSE:A_FF=-0.40`, `Q1_QuitSE:A_efficacy=0.30`; `Q2_PQMotiv:A_FF=0.36`, `Q1_QuitMotiv:A_outcome=-0.26`; `Q2_LowEducation:A_FF=-0.42`, `Q1_LowEducation:A_story=0.28` |
| `pqff_separated_large` | 703 | `Q2_PQSE=0.75`, `Q1_QuitSE=-0.25`; `Q2_PQMotiv=-0.35`, `Q1_QuitMotiv=0.65`; `Q2_LowEducation=0.50`, `Q1_LowEducation=-0.45`; `Q2_PQSE:A_FF=0.65`, `Q1_QuitSE:A_efficacy=-0.45`; `Q2_PQMotiv:A_FF=-0.50`, `Q1_QuitMotiv:A_outcome=0.52`; `Q2_LowEducation:A_FF=0.72`, `Q1_LowEducation:A_story=-0.40` |

### Other target Q-coefficients

Use the same unshared treatment and intermediate-history targets as Setting IV unless a sensitivity study requires a different treatment-effect regime:

| Spec | Unshared target coefficients |
| --- | --- |
| `pqff_separated_parsimonious` | `Q1_A_source=0.20`; `Q1_A_story=0.18`; `Q1_A_outcome=0.08`; `Q1_A_efficacy=0.08`; `Q1_A_multiple=0.02`; `Q2_A_FF=0.12`; `Q2_PQQuit=0.40`; `Q2_PQQuit:A_FF=-0.08` |

### Accepted calibrated true values

No accepted calibrated true values exist yet for the supplementary no-shared setting.

| Spec | Parameter group | Calibrated true values |
| --- | --- | --- |
| `pqff_separated_parsimonious` | `Q2_PQSE / Q1_QuitSE` | Pending calibration. |
| `pqff_separated_parsimonious` | `Q2_PQMotiv / Q1_QuitMotiv` | Pending calibration. |
| `pqff_separated_parsimonious` | `Q2_LowEducation / Q1_LowEducation` | Pending calibration. |
| `pqff_separated_parsimonious` | `Q2_PQSE:A_FF / Q1_QuitSE:A_efficacy` | Pending calibration. |
| `pqff_separated_parsimonious` | `Q2_PQMotiv:A_FF / Q1_QuitMotiv:A_outcome` | Pending calibration. |
| `pqff_separated_parsimonious` | `Q2_LowEducation:A_FF / Q1_LowEducation:A_story` | Pending calibration. |

## Notes For Implementation

1. Do not adjust for many covariates by default. Randomization protects treatment comparisons, and the simulation goal is methodological clarity.
2. Keep all five stage-1 randomized intervention components because they define the Project Quit fractional factorial design.
3. Keep only three baseline state variables by default: self-efficacy, motivation, and education.
4. Include `PQQuit` at stage 2 because it is a clinically important intermediate state and part of the observed treatment history.
5. Treat moderator sharing as weaker than main-effect sharing because the Project Quit components and Forever Free booster are not identical interventions.
6. Use the no-shared supplementary setting to demonstrate the robustness cost when the sharing assumption is false.
