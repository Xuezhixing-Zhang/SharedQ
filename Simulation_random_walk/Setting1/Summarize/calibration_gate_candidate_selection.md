# Setting I Calibration Gate Candidate Selection

- Validation tolerance: `0.01`
- Overall status: `PASS`
- Promoted: `no`

| Source | Run | Spec | mc_n | Target Tol | Best Value | Max Abs Error | Failed Checks | Pass | Artifact |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | --- | --- |
| production | current | balanced_small | 1000000 |   0.006 | 3.04982 | 0.00684995 | 0 | PASS | Setting1/calibration/calibration_balanced_small.rds |
| gate_candidate | tol006 | balanced_small | 1000000 |   0.006 | 3.04982 | 0.00684995 | 0 | PASS | Setting1/calibration/gate_candidates/tol006/calibration_balanced_small.rds |
| gate_candidate | tol008 | balanced_small | 1000000 |   0.008 | 3.34301 | 0.00823135 | 0 | PASS | Setting1/calibration/gate_candidates/tol008/calibration_balanced_small.rds |
| gate_candidate | rs_tol006 | balanced_small | 1000000 |   0.006 | 2.99167 | 0.0896296 | 12 | FAIL | Setting1/calibration/gate_candidates/rs_tol006/calibration_balanced_small.rds |
| gate_candidate | rs_tol008 | balanced_small | 1000000 |   0.008 | 2.99272 | 0.0897171 | 12 | FAIL | Setting1/calibration/gate_candidates/rs_tol008/calibration_balanced_small.rds |
| gate_candidate | rs_tol010 | balanced_small | 1000000 |    0.01 | 2.98938 | 0.0897319 | 12 | FAIL | Setting1/calibration/gate_candidates/rs_tol010/calibration_balanced_small.rds |

- Selected artifact: `Setting1/calibration/calibration_balanced_small.rds`
