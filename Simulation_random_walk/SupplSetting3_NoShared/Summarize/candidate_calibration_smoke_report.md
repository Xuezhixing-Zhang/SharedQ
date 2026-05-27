# Supplementary Setting III No Shared Candidate Calibration Smoke Report

- Tolerance: `0.03`
- Numerical slack: `1.49011611938477e-08`
- Overall status: `FAIL`

| Spec | Check | Group | Item | Target | Calibrated | Error | Pass |
| --- | --- | --- | --- | ---: | ---: | ---: | --- |
| separated_moderate | target_definition | theta_target | Q3_intercept | 0.1000 | 0.1000 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q3_O1 | 0.2500 | 0.2500 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q3_A1 | 0.5000 | 0.5000 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q3_O1A1 | 0.1500 | 0.1500 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q3_O2 | 0.6000 | 0.6000 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q3_A2 | 0.2500 | 0.2500 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q3_O2A2 | 0.2000 | 0.2000 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q3_A1A2 | 0.4500 | 0.4500 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q3_O3 | 0.4000 | 0.4000 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q3_A3_psi0 | -0.7500 | -0.7500 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q3_O3A3_psi1 | 0.7000 | 0.7000 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q3_A2A3_psi2 | -0.6000 | -0.6000 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q3_A1A2A3_psi3 | 0.4500 | 0.4500 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q2_intercept | 0.2000 | 0.2000 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q2_O1 | 0.2500 | 0.2500 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q2_A1 | 0.3500 | 0.3500 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q2_O1A1 | 0.1500 | 0.1500 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q2_O2 | 0.7000 | 0.7000 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q2_A2_psi0 | 0.3500 | 0.3500 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q2_O2A2_psi1 | -0.3500 | -0.3500 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q2_A1A2_psi2 | 0.5500 | 0.5500 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q1_intercept | 0.4000 | 0.4000 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q1_O1 | 0.5000 | 0.5000 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q1_A1_psi0 | 0.9000 | 0.9000 | 0.0000 | PASS |
| separated_moderate | target_definition | theta_target | Q1_O1A1_psi1 | 0.1500 | 0.1500 | 0.0000 | PASS |
| separated_moderate | coefficient | psi0 | Q3_A3 | -0.7500 | -0.7200 | 0.0300 | PASS |
| separated_moderate | coefficient | psi0 | Q2_A2 | 0.3500 | 0.3750 | 0.0250 | PASS |
| separated_moderate | coefficient | psi0 | Q1_A1 | 0.9000 | 0.9261 | 0.0261 | PASS |
| separated_moderate | difference | psi0 | Q3_A3 - Q2_A2 | -1.1000 | -1.0950 | 0.0050 | PASS |
| separated_moderate | difference | psi0 | Q3_A3 - Q1_A1 | -1.6500 | -1.6461 | 0.0039 | PASS |
| separated_moderate | difference | psi0 | Q2_A2 - Q1_A1 | -0.5500 | -0.5512 | -0.0012 | PASS |
| separated_moderate | coefficient | psi1 | Q3_O3A3 | 0.7000 | 0.6700 | -0.0300 | PASS |
| separated_moderate | coefficient | psi1 | Q2_O2A2 | -0.3500 | -0.3811 | -0.0311 | FAIL |
| separated_moderate | coefficient | psi1 | Q1_O1A1 | 0.1500 | 0.1210 | -0.0290 | PASS |
| separated_moderate | difference | psi1 | Q3_O3A3 - Q2_O2A2 | 1.0500 | 1.0511 | 0.0011 | PASS |
| separated_moderate | difference | psi1 | Q3_O3A3 - Q1_O1A1 | 0.5500 | 0.5490 | -0.0010 | PASS |
| separated_moderate | difference | psi1 | Q2_O2A2 - Q1_O1A1 | -0.5000 | -0.5021 | -0.0021 | PASS |
| separated_moderate | coefficient | psi2 | Q3_A2A3 | -0.6000 | -0.6000 | 0.0000 | PASS |
| separated_moderate | coefficient | psi2 | Q2_A1A2 | 0.5500 | 0.5205 | -0.0295 | PASS |
| separated_moderate | difference | psi2 | Q3_A2A3 - Q2_A1A2 | -1.1500 | -1.1205 | 0.0295 | PASS |
| separated_moderate | coefficient | psi3 | Q3_A1A2A3 | 0.4500 | 0.4200 | -0.0300 | PASS |
