# Supplementary Setting III No Shared Candidate Calibration Report

- Tolerance: `0.03`
- Numerical slack: `1.49011611938477e-08`
- Overall status: `FAIL`

| Spec | Check | Group | Item | Target | Calibrated | Error | Pass |
| --- | --- | --- | --- | ---: | ---: | ---: | --- |
| separated_moderate | artifact |  | calibration_separated_moderate.rds |  |  |  | FAIL |
| separated_reversed | artifact |  | calibration_separated_reversed.rds |  |  |  | FAIL |
| separated_large | artifact |  | calibration_separated_large.rds |  |  |  | FAIL |
| smoke_default | coefficient | psi0 | Q3_A3 | -0.7500 | -0.0249 | 0.7251 | FAIL |
| smoke_default | coefficient | psi0 | Q2_A2 | 0.3500 | 0.5989 | 0.2489 | FAIL |
| smoke_default | coefficient | psi0 | Q1_A1 | 0.9000 | 0.2006 | -0.6994 | FAIL |
| smoke_default | difference | psi0 | Q3_A3 - Q2_A2 | -1.1000 | -0.6239 | 0.4761 | FAIL |
| smoke_default | difference | psi0 | Q3_A3 - Q1_A1 | -1.6500 | -0.2255 | 1.4245 | FAIL |
| smoke_default | difference | psi0 | Q2_A2 - Q1_A1 | -0.5500 | 0.3983 | 0.9483 | FAIL |
| smoke_default | coefficient | psi1 | Q3_O3A3 | 0.7000 | 0.8925 | 0.1925 | FAIL |
| smoke_default | coefficient | psi1 | Q2_O2A2 | -0.3500 | -0.1737 | 0.1763 | FAIL |
| smoke_default | coefficient | psi1 | Q1_O1A1 | 0.1500 | 0.0040 | -0.1460 | FAIL |
| smoke_default | difference | psi1 | Q3_O3A3 - Q2_O2A2 | 1.0500 | 1.0662 | 0.0162 | PASS |
| smoke_default | difference | psi1 | Q3_O3A3 - Q1_O1A1 | 0.5500 | 0.8885 | 0.3385 | FAIL |
| smoke_default | difference | psi1 | Q2_O2A2 - Q1_O1A1 | -0.5000 | -0.1777 | 0.3223 | FAIL |
| smoke_default | coefficient | psi2 | Q3_A2A3 | -0.6000 | -0.7877 | -0.1877 | FAIL |
| smoke_default | coefficient | psi2 | Q2_A1A2 | 0.5500 | 0.5822 | 0.0322 | FAIL |
| smoke_default | difference | psi2 | Q3_A2A3 - Q2_A1A2 | -1.1500 | -1.3699 | -0.2199 | FAIL |
| smoke_default | coefficient | psi3 | Q3_A1A2A3 | 0.4500 | -0.2337 | -0.6837 | FAIL |
