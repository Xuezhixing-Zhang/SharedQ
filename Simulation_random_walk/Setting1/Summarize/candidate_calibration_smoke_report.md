# Setting I Candidate Calibration Smoke Report

- Tolerance: `0.01`
- Numerical slack: `1.49011611938477e-08`
- Overall status: `FAIL`

| Spec | Check | Group | Item | Target | Calibrated | Error | Pass |
| --- | --- | --- | --- | ---: | ---: | ---: | --- |
| balanced_small | coefficient | psi1 | Q3_A1 | 0.2300 | 0.2506 | 0.0206 | FAIL |
| balanced_small | coefficient | psi1 | Q2_A1 | 0.1700 | 0.1700 | -0.0000 | PASS |
| balanced_small | difference | psi1 | Q3_A1 - Q2_A1 | 0.0600 | 0.0806 | 0.0206 | FAIL |
| balanced_small | coefficient | psi2 | Q3_A3 | -0.5700 | -0.5673 | 0.0027 | PASS |
| balanced_small | coefficient | psi2 | Q2_A2 | -0.6300 | -0.6176 | 0.0124 | FAIL |
| balanced_small | difference | psi2 | Q3_A3 - Q2_A2 | 0.0600 | 0.0503 | -0.0097 | PASS |
| balanced_small | coefficient | psi3 | Q3_A1A3 | 0.8300 | 0.8094 | -0.0206 | FAIL |
| balanced_small | coefficient | psi3 | Q2_A1A2 | 0.7700 | 0.7494 | -0.0206 | FAIL |
| balanced_small | difference | psi3 | Q3_A1A3 - Q2_A1A2 | 0.0600 | 0.0600 | -0.0000 | PASS |
