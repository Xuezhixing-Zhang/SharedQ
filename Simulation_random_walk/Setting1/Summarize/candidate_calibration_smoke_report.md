# Setting I Candidate Calibration Smoke Report

- Tolerance: `0.01`
- Numerical slack: `1.49011611938477e-08`
- Overall status: `FAIL`

| Spec | Check | Group | Item | Target | Calibrated | Error | Pass |
| --- | --- | --- | --- | ---: | ---: | ---: | --- |
| balanced_small | target_definition | theta_target | Q3_intercept | 0.0000 | 0.0000 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q3_A1 | 0.1102 | 0.1102 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q3_A2 | 0.2000 | 0.2000 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q3_A1A2 | 0.4000 | 0.4000 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q3_G1 | 0.8000 | 0.8000 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q3_A3 | -0.3500 | -0.3500 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q3_A1A3 | 0.6033 | 0.6033 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q3_A2A3 | 0.6000 | 0.6000 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q2_intercept | 0.0000 | 0.0000 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q2_A1 | 0.1366 | 0.1366 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q2_A2 | -0.3500 | -0.3500 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q2_A1A2 | 0.6121 | 0.6121 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q1_intercept | 0.0000 | 0.0000 | 0.0000 | PASS |
| balanced_small | target_definition | theta_target | Q1_A1 | -0.2000 | -0.2000 | 0.0000 | PASS |
| balanced_small | coefficient | psi1 | Q3_A1 | 0.1102 | 0.2069 | 0.0966 | FAIL |
| balanced_small | coefficient | psi1 | Q2_A1 | 0.1366 | 0.1291 | -0.0075 | PASS |
| balanced_small | difference | psi1 | Q3_A1 - Q2_A1 | -0.0264 | 0.0778 | 0.1041 | FAIL |
| balanced_small | coefficient | psi2 | Q3_A3 | -0.3500 | -0.2534 | 0.0966 | FAIL |
| balanced_small | coefficient | psi2 | Q2_A2 | -0.3500 | -0.3425 | 0.0075 | PASS |
| balanced_small | difference | psi2 | Q3_A3 - Q2_A2 | 0.0000 | 0.0892 | 0.0892 | FAIL |
| balanced_small | coefficient | psi3 | Q3_A1A3 | 0.6033 | 0.5066 | -0.0966 | FAIL |
| balanced_small | coefficient | psi3 | Q2_A1A2 | 0.6121 | 0.6135 | 0.0014 | PASS |
| balanced_small | difference | psi3 | Q3_A1A3 - Q2_A1A2 | -0.0089 | -0.1069 | -0.0980 | FAIL |
