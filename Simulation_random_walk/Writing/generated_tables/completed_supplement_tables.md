# Completed Supplementary Tables

Tables follow the structure of `docs/reports_suppl_tables_and_figures.docx`.

Suppl Table 1: True Positives and False Positives for SQ learning with L1 penalty. For each setting, we run 200 replicates.

| setting | n | method | true_positives | false_positives |
| --- | --- | --- | --- | --- |
| I | 100 | SQ learning (L1 penalty) | 0.630 (0.484) | 0.000 (0.000) |
| I | 100 | Misspecified SQ learning (L1 penalty) | 0.345 (0.477) | 0.250 (0.663) |
| I | 300 | SQ learning (L1 penalty) | 0.610 (0.489) | 0.000 (0.000) |
| I | 300 | Misspecified SQ learning (L1 penalty) | 0.230 (0.422) | 0.000 (0.000) |
| I | 500 | SQ learning (L1 penalty) | 0.550 (0.499) | 0.000 (0.000) |
| I | 500 | Misspecified SQ learning (L1 penalty) | 0.215 (0.412) | 0.000 (0.000) |
| I | 1000 | SQ learning (L1 penalty) | 0.375 (0.485) | 0.000 (0.000) |
| I | 1000 | Misspecified SQ learning (L1 penalty) | 0.090 (0.287) | 0.000 (0.000) |
| II | 100 | SQ learning (L1 penalty) |  | 0.035 (0.184) |
| II | 100 | Misspecified SQ learning (L1 penalty) |  | 0.460 (0.820) |
| II | 300 | SQ learning (L1 penalty) |  | 0.000 (0.000) |
| II | 300 | Misspecified SQ learning (L1 penalty) |  | 0.550 (0.528) |
| II | 500 | SQ learning (L1 penalty) |  | 0.000 (0.000) |
| II | 500 | Misspecified SQ learning (L1 penalty) |  | 0.655 (0.477) |
| II | 1000 | SQ learning (L1 penalty) |  | 0.000 (0.000) |
| II | 1000 | Misspecified SQ learning (L1 penalty) |  | 0.845 (0.363) |
| III | 100 | SQ learning (L1 penalty) | 0.000 (0.000) |  |
| III | 300 | SQ learning (L1 penalty) | 0.000 (0.000) |  |
| III | 500 | SQ learning (L1 penalty) | 0.000 (0.000) |  |
| III | 1000 | SQ learning (L1 penalty) | 0.000 (0.000) |  |
| Suppl III No Shared | 100 | SQ learning (L1 penalty) |  | 0.000 (0.000) |
| Suppl III No Shared | 300 | SQ learning (L1 penalty) |  | 0.000 (0.000) |
| Suppl III No Shared | 500 | SQ learning (L1 penalty) |  | 0.000 (0.000) |
| Suppl III No Shared | 1000 | SQ learning (L1 penalty) |  | 0.000 (0.000) |
| IV | 100 | SQ learning (L1 penalty) | 0.000 (0.000) |  |
| IV | 300 | SQ learning (L1 penalty) | 0.000 (0.000) |  |
| IV | 500 | SQ learning (L1 penalty) | 0.000 (0.000) |  |
| IV | 1000 | SQ learning (L1 penalty) | 0.000 (0.000) |  |
| Suppl IV No Shared | 100 | SQ learning (L1 penalty) |  | 0.000 (0.000) |
| Suppl IV No Shared | 300 | SQ learning (L1 penalty) |  | 0.000 (0.000) |
| Suppl IV No Shared | 500 | SQ learning (L1 penalty) |  | 0.000 (0.000) |
| Suppl IV No Shared | 1000 | SQ learning (L1 penalty) |  | 0.000 (0.000) |

Supplementary simulation results for Setting III No Shared.

| setting | n | method | allocation_matching | weighted_allocation_matching | bias_a1 | bias_a2 | bias_a3 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Suppl III No Shared | 100 | Q learning | 0.862 (0.070) | 0.932 (0.035) | -0.006 (0.194) | -0.025 (0.203) | -0.005 (0.164) |
| Suppl III No Shared | 100 | Q shared | 0.599 (0.090) | 0.765 (0.059) | -0.258 (0.285) | 0.268 (0.285) | 1.368 (0.285) |
| Suppl III No Shared | 100 | SQ learning (L1 penalty) | 0.839 (0.073) | 0.921 (0.037) | -0.024 (0.188) | -0.067 (0.197) | 0.110 (0.168) |
| Suppl III No Shared | 100 | SQ learning (L2 penalty) | 0.844 (0.074) | 0.923 (0.038) | -0.031 (0.188) | -0.085 (0.182) | 0.154 (0.176) |
| Suppl III No Shared | 300 | Q learning | 0.925 (0.036) | 0.964 (0.017) | -0.002 (0.099) | 0.004 (0.105) | 0.000 (0.088) |
| Suppl III No Shared | 300 | Q shared | 0.602 (0.060) | 0.768 (0.037) | -0.350 (0.129) | 0.176 (0.129) | 1.276 (0.129) |
| Suppl III No Shared | 300 | SQ learning (L1 penalty) | 0.900 (0.051) | 0.952 (0.025) | -0.030 (0.102) | -0.041 (0.105) | 0.140 (0.092) |
| Suppl III No Shared | 300 | SQ learning (L2 penalty) | 0.903 (0.046) | 0.953 (0.023) | -0.036 (0.099) | -0.060 (0.095) | 0.173 (0.096) |
| Suppl III No Shared | 500 | Q learning | 0.942 (0.030) | 0.972 (0.015) | -0.004 (0.080) | -0.006 (0.078) | 0.001 (0.071) |
| Suppl III No Shared | 500 | Q shared | 0.606 (0.046) | 0.772 (0.028) | -0.360 (0.092) | 0.166 (0.092) | 1.266 (0.092) |
| Suppl III No Shared | 500 | SQ learning (L1 penalty) | 0.908 (0.044) | 0.956 (0.022) | -0.034 (0.081) | -0.052 (0.078) | 0.153 (0.075) |
| Suppl III No Shared | 500 | SQ learning (L2 penalty) | 0.915 (0.042) | 0.959 (0.021) | -0.039 (0.077) | -0.070 (0.069) | 0.182 (0.075) |
| Suppl III No Shared | 1000 | Q learning | 0.962 (0.019) | 0.982 (0.009) | -0.005 (0.053) | 0.001 (0.051) | -0.000 (0.045) |
| Suppl III No Shared | 1000 | Q shared | 0.607 (0.035) | 0.773 (0.022) | -0.385 (0.062) | 0.141 (0.062) | 1.241 (0.062) |
| Suppl III No Shared | 1000 | SQ learning (L1 penalty) | 0.929 (0.028) | 0.966 (0.014) | -0.037 (0.054) | -0.050 (0.049) | 0.156 (0.049) |
| Suppl III No Shared | 1000 | SQ learning (L2 penalty) | 0.933 (0.026) | 0.968 (0.013) | -0.043 (0.051) | -0.067 (0.045) | 0.179 (0.054) |

Supplementary simulation results for Setting IV No Shared.

| setting | n | method | allocation_matching | weighted_allocation_matching | a_ff_match | mean_abs_bias |
| --- | --- | --- | --- | --- | --- | --- |
| Suppl IV No Shared | 100 | Q learning | 0.387 (0.242) | 0.790 (0.095) | 0.918 (0.075) | 0.146308255910489 |
| Suppl IV No Shared | 100 | Q shared | 0.097 (0.114) | 0.644 (0.084) | 0.754 (0.137) | 0.23099314820603 |
| Suppl IV No Shared | 100 | SQ learning (L1 penalty) | 0.321 (0.233) | 0.763 (0.097) | 0.893 (0.080) | 0.152462225709301 |
| Suppl IV No Shared | 100 | SQ learning (L2 penalty) | 0.314 (0.218) | 0.761 (0.092) | 0.892 (0.081) | 0.146260800809801 |
| Suppl IV No Shared | 300 | Q learning | 0.601 (0.238) | 0.868 (0.082) | 0.974 (0.040) | 0.0846080036240941 |
| Suppl IV No Shared | 300 | Q shared | 0.170 (0.115) | 0.701 (0.066) | 0.811 (0.071) | 0.2047568943675 |
| Suppl IV No Shared | 300 | SQ learning (L1 penalty) | 0.500 (0.233) | 0.833 (0.083) | 0.960 (0.052) | 0.0965314670864797 |
| Suppl IV No Shared | 300 | SQ learning (L2 penalty) | 0.469 (0.229) | 0.821 (0.083) | 0.956 (0.054) | 0.0953629800373925 |
| Suppl IV No Shared | 500 | Q learning | 0.712 (0.209) | 0.905 (0.072) | 0.980 (0.036) | 0.0633860480968314 |
| Suppl IV No Shared | 500 | Q shared | 0.199 (0.105) | 0.719 (0.056) | 0.823 (0.054) | 0.19613902029022 |
| Suppl IV No Shared | 500 | SQ learning (L1 penalty) | 0.573 (0.218) | 0.859 (0.076) | 0.974 (0.043) | 0.0787531256095479 |
| Suppl IV No Shared | 500 | SQ learning (L2 penalty) | 0.532 (0.208) | 0.844 (0.074) | 0.971 (0.045) | 0.0797872260157779 |
| Suppl IV No Shared | 1000 | Q learning | 0.825 (0.159) | 0.943 (0.053) | 0.989 (0.021) | 0.0441025477947627 |
| Suppl IV No Shared | 1000 | Q shared | 0.246 (0.067) | 0.744 (0.032) | 0.833 (0.028) | 0.188276650545661 |
| Suppl IV No Shared | 1000 | SQ learning (L1 penalty) | 0.677 (0.165) | 0.894 (0.055) | 0.987 (0.023) | 0.0641870168459644 |
| Suppl IV No Shared | 1000 | SQ learning (L2 penalty) | 0.628 (0.166) | 0.877 (0.056) | 0.985 (0.028) | 0.0677493968107401 |
