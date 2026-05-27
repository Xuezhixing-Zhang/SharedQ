# Setting III Candidate Calibration Default Report

- Tolerance: `0.01`
- Numerical slack: `1.49011611938477e-08`
- Overall status: `FAIL`

| Spec | Check | Group | Item | Target | Calibrated | Error | Pass |
| --- | --- | --- | --- | ---: | ---: | ---: | --- |
| rw_sigma_moderate | target_definition | theta_target | Q3_intercept | 0.1000 | 0.1000 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q3_O1 | 0.2500 | 0.2500 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q3_A1 | 0.5000 | 0.5000 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q3_O1A1 | 0.1500 | 0.1500 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q3_O2 | 0.6000 | 0.6000 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q3_A2 | 0.2500 | 0.2500 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q3_O2A2 | 0.2000 | 0.2000 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q3_A1A2 | 0.4500 | 0.4500 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q3_O3 | 0.4000 | 0.4000 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q3_A3_psi0 | -0.3077 | -0.2200 | 0.0877 | FAIL |
| rw_sigma_moderate | target_definition | theta_target | Q3_O3A3_psi1 | 0.4630 | 0.5800 | 0.1170 | FAIL |
| rw_sigma_moderate | target_definition | theta_target | Q3_A2A3_psi2 | 0.3462 | 0.4100 | 0.0638 | FAIL |
| rw_sigma_moderate | target_definition | theta_target | Q3_A1A2A3_psi3 | -0.2800 | -0.2800 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q2_intercept | 0.2000 | 0.2000 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q2_O1 | 0.2500 | 0.2500 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q2_A1 | 0.3500 | 0.3500 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q2_O1A1 | 0.1500 | 0.1500 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q2_O2 | 0.7000 | 0.7000 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q2_A2_psi0 | -0.1997 | -0.3000 | -0.1003 | FAIL |
| rw_sigma_moderate | target_definition | theta_target | Q2_O2A2_psi1 | 0.5521 | 0.5000 | -0.0521 | FAIL |
| rw_sigma_moderate | target_definition | theta_target | Q2_A1A2_psi2 | 0.2504 | 0.2900 | 0.0396 | FAIL |
| rw_sigma_moderate | target_definition | theta_target | Q1_intercept | 0.4000 | 0.4000 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q1_O1 | 0.5000 | 0.5000 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q1_A1_psi0 | -0.2099 | -0.3800 | -0.1701 | FAIL |
| rw_sigma_moderate | target_definition | theta_target | Q1_O1A1_psi1 | 0.5803 | 0.4200 | -0.1603 | FAIL |
| rw_sigma_moderate | coefficient | psi0 | Q3_A3 | -0.2200 | -0.2200 | 0.0000 | PASS |
| rw_sigma_moderate | coefficient | psi0 | Q2_A2 | -0.3000 | -0.2940 | 0.0060 | PASS |
| rw_sigma_moderate | coefficient | psi0 | Q1_A1 | -0.3800 | -0.3740 | 0.0060 | PASS |
| rw_sigma_moderate | difference | psi0 | Q3_A3 - Q2_A2 | 0.0800 | 0.0740 | -0.0060 | PASS |
| rw_sigma_moderate | difference | psi0 | Q3_A3 - Q1_A1 | 0.1600 | 0.1540 | -0.0060 | PASS |
| rw_sigma_moderate | difference | psi0 | Q2_A2 - Q1_A1 | 0.0800 | 0.0800 | -0.0000 | PASS |
| rw_sigma_moderate | coefficient | psi1 | Q3_O3A3 | 0.5800 | 0.5740 | -0.0060 | PASS |
| rw_sigma_moderate | coefficient | psi1 | Q2_O2A2 | 0.5000 | 0.4940 | -0.0060 | PASS |
| rw_sigma_moderate | coefficient | psi1 | Q1_O1A1 | 0.4200 | 0.4140 | -0.0060 | PASS |
| rw_sigma_moderate | difference | psi1 | Q3_O3A3 - Q2_O2A2 | 0.0800 | 0.0800 | 0.0000 | PASS |
| rw_sigma_moderate | difference | psi1 | Q3_O3A3 - Q1_O1A1 | 0.1600 | 0.1600 | -0.0000 | PASS |
| rw_sigma_moderate | difference | psi1 | Q2_O2A2 - Q1_O1A1 | 0.0800 | 0.0800 | -0.0000 | PASS |
| rw_sigma_moderate | coefficient | psi2 | Q3_A2A3 | 0.4100 | 0.4101 | 0.0001 | PASS |
| rw_sigma_moderate | coefficient | psi2 | Q2_A1A2 | 0.2900 | 0.2841 | -0.0059 | PASS |
| rw_sigma_moderate | difference | psi2 | Q3_A2A3 - Q2_A1A2 | 0.1200 | 0.1260 | 0.0060 | PASS |
| rw_sigma_moderate | coefficient | psi3 | Q3_A1A2A3 | -0.2800 | -0.2860 | -0.0060 | PASS |
