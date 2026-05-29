# Setting III Calibration Gate Candidate Selection

- Validation tolerance: `0.01`
- Overall status: `PASS`
- Promoted: `no`

| Source | Run | Spec | mc_n | Target Tol | Best Value | Max Abs Error | Failed Checks | Pass | Artifact |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | --- | --- |
| production | current | rw_sigma_moderate | 1000000 |   0.006 | 4.98005 | 0.00600025 | 0 | PASS | Setting3/calibration/calibration_rw_sigma_moderate.rds |
| gate_candidate | rs_tol006 | rw_sigma_moderate | 1000000 |   0.006 | 4.98005 | 0.00600025 | 0 | PASS | Setting3/calibration/gate_candidates/rs_tol006/calibration_rw_sigma_moderate.rds |
| gate_candidate | rs_tol008 | rw_sigma_moderate | 1000000 |   0.008 | 4.91257 |   0.008 | 0 | PASS | Setting3/calibration/gate_candidates/rs_tol008/calibration_rw_sigma_moderate.rds |
| gate_candidate | rs_tol010 | rw_sigma_moderate | 1000000 |    0.01 | 4.96343 |    0.01 | 0 | PASS | Setting3/calibration/gate_candidates/rs_tol010/calibration_rw_sigma_moderate.rds |
| gate_candidate | tol006 | rw_sigma_moderate | 1000000 |   0.006 | 5.06534 | 0.170057 | 8 | FAIL | Setting3/calibration/gate_candidates/tol006/calibration_rw_sigma_moderate.rds |
| gate_candidate | tol008 | rw_sigma_moderate | 1000000 |   0.008 | 5.05462 | 0.170057 | 8 | FAIL | Setting3/calibration/gate_candidates/tol008/calibration_rw_sigma_moderate.rds |

- Selected artifact: `Setting3/calibration/calibration_rw_sigma_moderate.rds`
