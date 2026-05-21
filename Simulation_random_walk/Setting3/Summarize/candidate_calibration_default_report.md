# Setting III Candidate Calibration Default Report

- Tolerance: `0.01`
- Numerical slack: `1.49011611938477e-08`
- Overall status: `FAIL`

| Spec | Check | Group | Item | Target | Calibrated | Error | Pass |
| --- | --- | --- | --- | ---: | ---: | ---: | --- |
| rw_sigma_moderate | coefficient | psi0 | Q3_A3 | -0.2200 | -0.2200 | 0.0000 | PASS |
| rw_sigma_moderate | coefficient | psi0 | Q2_A2 | -0.3000 | -0.2900 | 0.0100 | PASS |
| rw_sigma_moderate | coefficient | psi0 | Q1_A1 | -0.3800 | -0.3700 | 0.0100 | FAIL |
| rw_sigma_moderate | difference | psi0 | Q3_A3 - Q2_A2 | 0.0800 | 0.0700 | -0.0100 | PASS |
| rw_sigma_moderate | difference | psi0 | Q3_A3 - Q1_A1 | 0.1600 | 0.1500 | -0.0100 | FAIL |
| rw_sigma_moderate | difference | psi0 | Q2_A2 - Q1_A1 | 0.0800 | 0.0800 | -0.0000 | PASS |
| rw_sigma_moderate | coefficient | psi1 | Q3_O3A3 | 0.5800 | 0.5700 | -0.0100 | PASS |
| rw_sigma_moderate | coefficient | psi1 | Q2_O2A2 | 0.5000 | 0.4900 | -0.0100 | PASS |
| rw_sigma_moderate | coefficient | psi1 | Q1_O1A1 | 0.4200 | 0.4100 | -0.0100 | FAIL |
| rw_sigma_moderate | difference | psi1 | Q3_O3A3 - Q2_O2A2 | 0.0800 | 0.0800 | 0.0000 | PASS |
| rw_sigma_moderate | difference | psi1 | Q3_O3A3 - Q1_O1A1 | 0.1600 | 0.1600 | 0.0000 | PASS |
| rw_sigma_moderate | difference | psi1 | Q2_O2A2 - Q1_O1A1 | 0.0800 | 0.0800 | 0.0000 | PASS |
| rw_sigma_moderate | coefficient | psi2 | Q3_A2A3 | 0.4100 | 0.4100 | 0.0000 | PASS |
| rw_sigma_moderate | coefficient | psi2 | Q2_A1A2 | 0.2900 | 0.3000 | 0.0100 | PASS |
| rw_sigma_moderate | difference | psi2 | Q3_A2A3 - Q2_A1A2 | 0.1200 | 0.1100 | -0.0100 | PASS |
| rw_sigma_moderate | coefficient | psi3 | Q3_A1A2A3 | -0.2800 | -0.2900 | -0.0100 | PASS |
