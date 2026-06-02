# Setting I Candidate Calibration Default Report

- Tolerance: `0.01`
- Numerical slack: `1.49011611938477e-08`
- Overall status: `FAIL`

| Spec | Check | Group | Item | Target | Calibrated | Error | Pass |
| --- | --- | --- | --- | ---: | ---: | ---: | --- |
| balanced_small | target_definition | theta_target | Q3_intercept | 0.0000 | 0.0000 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q3_A1 | 0.1379 | 0.1500 | 0.0121 | FAIL |
| balanced_small | target_definition | theta_target | Q3_A2 | 0.2000 | 0.2000 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q3_A1A2 | 0.4000 | 0.4000 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q3_G1 | 0.8000 | 0.8000 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q3_A3 | -0.3500 | -0.3500 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q3_A1A3 | 0.6130 | 0.6200 | 0.0070 | FAIL |
| balanced_small | target_definition | theta_target | Q3_A2A3 | 0.6000 | 0.6000 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q2_intercept | 0.0000 | 0.0000 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q2_A1 | 0.1188 | 0.0900 | -0.0288 | FAIL |
| balanced_small | target_definition | theta_target | Q2_A2 | -0.3500 | -0.3500 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q2_A1A2 | 0.5986 | 0.6000 | 0.0014 | FAIL |
| balanced_small | target_definition | theta_target | Q1_intercept | 0.0000 | 0.0000 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q1_A1 | -0.2000 | -0.2000 | 0.0000 | PASS |
| balanced_small | coefficient | psi1 | Q3_A1 | 0.1500 | 0.1568 | 0.0068 | PASS |
| balanced_small | coefficient | psi1 | Q2_A1 | 0.0900 | 0.0900 | -0.0000 | PASS |
| balanced_small | difference | psi1 | Q3_A1 - Q2_A1 | 0.0600 | 0.0668 | 0.0068 | PASS |
| balanced_small | coefficient | psi2 | Q3_A3 | -0.3500 | -0.3469 | 0.0031 | PASS |
| balanced_small | coefficient | psi2 | Q2_A2 | -0.3500 | -0.3432 | 0.0068 | PASS |
| balanced_small | difference | psi2 | Q3_A3 - Q2_A2 | 0.0000 | -0.0037 | -0.0037 | PASS |
| balanced_small | coefficient | psi3 | Q3_A1A3 | 0.6200 | 0.6132 | -0.0068 | PASS |
| balanced_small | coefficient | psi3 | Q2_A1A2 | 0.6000 | 0.5939 | -0.0061 | PASS |
| balanced_small | difference | psi3 | Q3_A1A3 - Q2_A1A2 | 0.0200 | 0.0192 | -0.0008 | PASS |
