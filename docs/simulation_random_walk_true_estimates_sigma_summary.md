# True Estimate And Sigma Summary

Values are the best available population-projected Q-parameter estimates saved in each calibration `.rds` artifact, not the hand-specified targets. Bounded calibration artifacts use small `mc_n` and optimizer budgets unless production calibration has replaced them.

## Setting I

Setting | Spec | Sigma | Parameter group | True estimates
--- | --- | --- | --- | ---
I | balanced_small | psi1=0.0300 | psi1: Q3_A1 / Q2_A1 | Q3_A1=0.3351; Q2_A1=0.2530
I | balanced_small | psi2=0.0300 | psi2: Q3_A3 / Q2_A2 | Q3_A3=-0.4366; Q2_A2=-0.4323
I | balanced_small | psi3=0.0300 | psi3: Q3_A1A3 / Q2_A1A2 | Q3_A1A3=0.5849; Q2_A1A2=0.6973
I | tighter_small | psi1=0.0150 | psi1: Q3_A1 / Q2_A1 | Q3_A1=0.3200; Q2_A1=0.3088
I | tighter_small | psi2=0.0200 | psi2: Q3_A3 / Q2_A2 | Q3_A3=-0.4500; Q2_A2=-0.4485
I | tighter_small | psi3=0.0200 | psi3: Q3_A1A3 / Q2_A1A2 | Q3_A1A3=0.6000; Q2_A1A2=0.7342
I | wider_small | psi1=0.0500 | psi1: Q3_A1 / Q2_A1 | Q3_A1=0.3609; Q2_A1=0.1934
I | wider_small | psi2=0.0500 | psi2: Q3_A3 / Q2_A2 | Q3_A3=-0.4091; Q2_A2=-0.4091
I | wider_small | psi3=0.0500 | psi3: Q3_A1A3 / Q2_A1A2 | Q3_A1A3=0.5591; Q2_A1A2=0.6219

## Setting II

Setting | Spec | Sigma | Parameter group | True estimates
--- | --- | --- | --- | ---
II | separated_moderate | NA (no shared target) | Q3_A1 / Q2_A1 | Q3_A1=0.3236; Q2_A1=0.1284
II | separated_moderate | NA (no shared target) | Q3_A3 / Q2_A2 | Q3_A3=-0.1438; Q2_A2=0.3220
II | separated_moderate | NA (no shared target) | Q3_A1A3 / Q2_A1A2 | Q3_A1A3=0.4569; Q2_A1A2=0.1071
II | separated_reversed | NA (no shared target) | Q3_A1 / Q2_A1 | Q3_A1=-0.0802; Q2_A1=-0.1307
II | separated_reversed | NA (no shared target) | Q3_A3 / Q2_A2 | Q3_A3=0.1122; Q2_A2=-0.0435
II | separated_reversed | NA (no shared target) | Q3_A1A3 / Q2_A1A2 | Q3_A1A3=-0.5458; Q2_A1A2=0.0383
II | separated_large | NA (no shared target) | Q3_A1 / Q2_A1 | Q3_A1=0.3070; Q2_A1=0.2834
II | separated_large | NA (no shared target) | Q3_A3 / Q2_A2 | Q3_A3=-0.0068; Q2_A2=0.3078
II | separated_large | NA (no shared target) | Q3_A1A3 / Q2_A1A2 | Q3_A1A3=0.0976; Q2_A1A2=0.0188

## Setting III

Setting | Spec | Sigma | Parameter group | True estimates
--- | --- | --- | --- | ---
III | rw_sigma_moderate | psi0=0.0800 | psi0: Q3_A3 / Q2_A2 / Q1_A1 | Q3_A3=-0.5456; Q2_A2=-0.3875; Q1_A1=0.2054
III | rw_sigma_moderate | psi1=0.0800 | psi1: Q3_O3:A3 / Q2_O2:A2 / Q1_O1:A1 | Q3_O3:A3=0.5027; Q2_O2:A2=0.3052; Q1_O1:A1=0.5181
III | rw_sigma_moderate | psi2=0.0600 | psi2: Q3_A2:A3 / Q2_A1:A2 | Q3_A2:A3=0.2904; Q2_A1:A2=-0.0602
III | rw_sigma_moderate | NA (unpaired) | Q3_A1:A2:A3 | Q3_A1:A2:A3=-0.0604
III | rw_sigma_tight | psi0=0.0400 | psi0: Q3_A3 / Q2_A2 / Q1_A1 | Q3_A3=-0.7413; Q2_A2=-0.3583; Q1_A1=0.0064
III | rw_sigma_tight | psi1=0.0400 | psi1: Q3_O3:A3 / Q2_O2:A2 / Q1_O1:A1 | Q3_O3:A3=0.5008; Q2_O2:A2=0.6248; Q1_O1:A1=0.5596
III | rw_sigma_tight | psi2=0.0300 | psi2: Q3_A2:A3 / Q2_A1:A2 | Q3_A2:A3=0.5891; Q2_A1:A2=0.2408
III | rw_sigma_tight | NA (unpaired) | Q3_A1:A2:A3 | Q3_A1:A2:A3=-0.0609
III | rw_sigma_wide | psi0=0.1500 | psi0: Q3_A3 / Q2_A2 / Q1_A1 | Q3_A3=-0.5500; Q2_A2=-0.2010; Q1_A1=0.0232
III | rw_sigma_wide | psi1=0.1500 | psi1: Q3_O3:A3 / Q2_O2:A2 / Q1_O1:A1 | Q3_O3:A3=0.5000; Q2_O2:A2=0.3509; Q1_O1:A1=0.4978
III | rw_sigma_wide | psi2=0.1000 | psi2: Q3_A2:A3 / Q2_A1:A2 | Q3_A2:A3=0.0898; Q2_A1:A2=0.2454
III | rw_sigma_wide | NA (unpaired) | Q3_A1:A2:A3 | Q3_A1:A2:A3=-0.0874

## Supplementary Setting III No Shared

Setting | Spec | Sigma | Parameter group | True estimates
--- | --- | --- | --- | ---
Supplementary III no-shared | smoke_default | NA (no shared target) | Q3_A3 / Q2_A2 / Q1_A1 | Q3_A3=-0.0249; Q2_A2=0.5989; Q1_A1=0.2006
Supplementary III no-shared | smoke_default | NA (no shared target) | Q3_O3:A3 / Q2_O2:A2 / Q1_O1:A1 | Q3_O3:A3=0.8925; Q2_O2:A2=-0.1737; Q1_O1:A1=0.0040
Supplementary III no-shared | smoke_default | NA (no shared target) | Q3_A2:A3 / Q2_A1:A2 | Q3_A2:A3=-0.7877; Q2_A1:A2=0.5822
Supplementary III no-shared | smoke_default | NA (unpaired) | Q3_A1:A2:A3 | Q3_A1:A2:A3=-0.2337

