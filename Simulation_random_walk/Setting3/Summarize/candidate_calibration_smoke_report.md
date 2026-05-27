# Setting III Candidate Calibration Smoke Report

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
| rw_sigma_moderate | target_definition | theta_target | Q3_A3_psi0 | -0.3077 | -0.3077 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q3_O3A3_psi1 | 0.4630 | 0.4630 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q3_A2A3_psi2 | 0.3462 | 0.3462 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q3_A1A2A3_psi3 | -0.2800 | -0.2800 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q2_intercept | 0.2000 | 0.2000 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q2_O1 | 0.2500 | 0.2500 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q2_A1 | 0.3500 | 0.3500 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q2_O1A1 | 0.1500 | 0.1500 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q2_O2 | 0.7000 | 0.7000 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q2_A2_psi0 | -0.1997 | -0.1997 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q2_O2A2_psi1 | 0.5521 | 0.5521 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q2_A1A2_psi2 | 0.2504 | 0.2504 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q1_intercept | 0.4000 | 0.4000 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q1_O1 | 0.5000 | 0.5000 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q1_A1_psi0 | -0.2099 | -0.2099 | 0.0000 | PASS |
| rw_sigma_moderate | target_definition | theta_target | Q1_O1A1_psi1 | 0.5803 | 0.5803 | 0.0000 | PASS |
| rw_sigma_moderate | coefficient | psi0 | Q3_A3 | -0.3077 | -0.1985 | 0.1092 | FAIL |
| rw_sigma_moderate | coefficient | psi0 | Q2_A2 | -0.1997 | -0.2002 | -0.0005 | PASS |
| rw_sigma_moderate | coefficient | psi0 | Q1_A1 | -0.2099 | -0.1006 | 0.1094 | FAIL |
| rw_sigma_moderate | difference | psi0 | Q3_A3 - Q2_A2 | -0.1080 | 0.0018 | 0.1097 | FAIL |
| rw_sigma_moderate | difference | psi0 | Q3_A3 - Q1_A1 | -0.0977 | -0.0979 | -0.0002 | PASS |
| rw_sigma_moderate | difference | psi0 | Q2_A2 - Q1_A1 | 0.0102 | -0.0997 | -0.1099 | FAIL |
| rw_sigma_moderate | coefficient | psi1 | Q3_O3A3 | 0.4630 | 0.3538 | -0.1092 | FAIL |
| rw_sigma_moderate | coefficient | psi1 | Q2_O2A2 | 0.5521 | 0.5391 | -0.0130 | FAIL |
| rw_sigma_moderate | coefficient | psi1 | Q1_O1A1 | 0.5803 | 0.4706 | -0.1097 | FAIL |
| rw_sigma_moderate | difference | psi1 | Q3_O3A3 - Q2_O2A2 | -0.0892 | -0.1853 | -0.0962 | FAIL |
| rw_sigma_moderate | difference | psi1 | Q3_O3A3 - Q1_O1A1 | -0.1173 | -0.1169 | 0.0005 | PASS |
| rw_sigma_moderate | difference | psi1 | Q2_O2A2 - Q1_O1A1 | -0.0282 | 0.0685 | 0.0966 | FAIL |
| rw_sigma_moderate | coefficient | psi2 | Q3_A2A3 | 0.3462 | 0.3462 | 0.0000 | PASS |
| rw_sigma_moderate | coefficient | psi2 | Q2_A1A2 | 0.2504 | 0.1390 | -0.1114 | FAIL |
| rw_sigma_moderate | difference | psi2 | Q3_A2A3 - Q2_A1A2 | 0.0958 | 0.2072 | 0.1114 | FAIL |
| rw_sigma_moderate | coefficient | psi3 | Q3_A1A2A3 | -0.2800 | -0.2878 | -0.0078 | PASS |
