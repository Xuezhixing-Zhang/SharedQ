# Setting I Candidate Calibration Smoke Report

- Tolerance: `0.03`
- Overall status: `FAIL`

| Spec | Check | Group | Item | Target | Calibrated | Error | Pass |
| --- | --- | --- | --- | ---: | ---: | ---: | --- |
| balanced_small | coefficient | psi1 | Q3_A1 | 0.2300 | 0.2300 | 0.0000 | PASS |
| balanced_small | coefficient | psi1 | Q2_A1 | 0.1700 | 0.1295 | -0.0405 | FAIL |
| balanced_small | difference | psi1 | Q3_A1 - Q2_A1 | 0.0600 | 0.1005 | 0.0405 | FAIL |
| balanced_small | coefficient | psi2 | Q3_A3 | -0.5700 | -0.5400 | 0.0300 | PASS |
| balanced_small | coefficient | psi2 | Q2_A2 | -0.6300 | -0.5895 | 0.0405 | FAIL |
| balanced_small | difference | psi2 | Q3_A3 - Q2_A2 | 0.0600 | 0.0495 | -0.0105 | PASS |
| balanced_small | coefficient | psi3 | Q3_A1A3 | 0.8300 | 0.8000 | -0.0300 | FAIL |
| balanced_small | coefficient | psi3 | Q2_A1A2 | 0.7700 | 0.7490 | -0.0210 | PASS |
| balanced_small | difference | psi3 | Q3_A1A3 - Q2_A1A2 | 0.0600 | 0.0510 | -0.0090 | PASS |
| tighter_small | coefficient | psi1 | Q3_A1 | 0.1750 | 0.1750 | 0.0000 | PASS |
| tighter_small | coefficient | psi1 | Q2_A1 | 0.1450 | -0.0908 | -0.2358 | FAIL |
| tighter_small | difference | psi1 | Q3_A1 - Q2_A1 | 0.0300 | 0.2658 | 0.2358 | FAIL |
| tighter_small | coefficient | psi2 | Q3_A3 | -0.5000 | -0.2642 | 0.2358 | FAIL |
| tighter_small | coefficient | psi2 | Q2_A2 | -0.5400 | -0.3042 | 0.2358 | FAIL |
| tighter_small | difference | psi2 | Q3_A3 - Q2_A2 | 0.0400 | 0.0400 | -0.0000 | PASS |
| tighter_small | coefficient | psi3 | Q3_A1A3 | 0.7000 | 0.4642 | -0.2358 | FAIL |
| tighter_small | coefficient | psi3 | Q2_A1A2 | 0.6600 | 0.4506 | -0.2094 | FAIL |
| tighter_small | difference | psi3 | Q3_A1A3 - Q2_A1A2 | 0.0400 | 0.0136 | -0.0264 | PASS |
| wider_small | coefficient | psi1 | Q3_A1 | 0.2900 | 0.4439 | 0.1539 | FAIL |
| wider_small | coefficient | psi1 | Q2_A1 | 0.1900 | 0.1578 | -0.0322 | FAIL |
| wider_small | difference | psi1 | Q3_A1 - Q2_A1 | 0.1000 | 0.2861 | 0.1861 | FAIL |
| wider_small | coefficient | psi2 | Q3_A3 | -0.6300 | -0.4439 | 0.1861 | FAIL |
| wider_small | coefficient | psi2 | Q2_A2 | -0.7300 | -0.5439 | 0.1861 | FAIL |
| wider_small | difference | psi2 | Q3_A3 - Q2_A2 | 0.1000 | 0.1000 | 0.0000 | PASS |
| wider_small | coefficient | psi3 | Q3_A1A3 | 0.9700 | 0.7839 | -0.1861 | FAIL |
| wider_small | coefficient | psi3 | Q2_A1A2 | 0.8700 | 0.6839 | -0.1861 | FAIL |
| wider_small | difference | psi3 | Q3_A1A3 - Q2_A1A2 | 0.1000 | 0.1000 | -0.0000 | PASS |
