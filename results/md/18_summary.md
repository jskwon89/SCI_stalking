# Post-LCA Group Comparison: ANOVA / Welch / KW / Chi-square

Sample: 501 responders, modal class assignment from R3STEP cprob (entropy = 0.879).

Methods:
- Continuous: one-way ANOVA + Welch + Kruskal-Wallis (sensitivity); Levene's test for variance equality; Tukey HSD post-hoc.
- Binary: Pearson chi-square (Fisher when any expected < 5, simulated 5000); Cramer V; pairwise 2x2 with Bonferroni correction.
- All omnibus p-values FDR(BH) corrected within table.

## Class sizes (modal)

- Network_oriented_prevention: n = 73 (14.6%)
- Escalation_aware_mixed: n = 146 (29.1%)
- Life_threat_protective: n = 96 (19.2%)
- Boundary_clarification: n = 110 (22.0%)
- Multi_action_institutional: n = 76 (15.2%)

## Significant variables (q < .05) — what makes classes differ

               variable   type   p_main        p_fdr sig eta_sq cramer_V
             disability binary 3.00e-03 5.700000e-03  **     NA    0.178
               intimate binary 2.69e-04 6.388750e-04 ***     NA    0.206
          gendered_case binary 3.82e-06 1.451600e-05 ***     NA    0.247
             own_victim binary 1.80e-02 2.630769e-02   *     NA    0.154
          severe_coharm binary 3.86e-09 7.334000e-08 ***     NA    0.300
                 threat binary 3.49e-04 7.367778e-04 ***     NA    0.204
                  stedu binary 5.27e-03 9.102727e-03  **     NA    0.172
 any_violence_education binary 2.66e-04 6.388750e-04 ***     NA    0.207
      online_withdrawal binary 1.52e-06 7.220000e-06 ***     NA    0.255
         digital_coharm binary 1.30e-05 4.116667e-05 ***     NA    0.236
             q40_police binary 7.72e-09 7.334000e-08 ***     NA    0.295
             q42_police binary 1.43e-08 9.056667e-08 ***     NA    0.291
       role_police_top2 binary 1.74e-02 2.630769e-02   *     NA    0.155


## Top Tukey HSD pairwise (q < .05) — continuous

               variable                                               contrast
  negative_impact_count Multi_action_institutional-Network_oriented_prevention
 prosocial_change_count      Multi_action_institutional-Escalation_aware_mixed
 prosocial_change_count Multi_action_institutional-Network_oriented_prevention
           coharm_count Multi_action_institutional-Network_oriented_prevention
  negative_impact_count     Life_threat_protective-Network_oriented_prevention
           crime_denial     Life_threat_protective-Network_oriented_prevention
           coharm_count      Multi_action_institutional-Escalation_aware_mixed
  negative_impact_count      Multi_action_institutional-Escalation_aware_mixed
  negative_impact_count      Multi_action_institutional-Boundary_clarification
           coharm_count      Multi_action_institutional-Boundary_clarification
       total_type_count     Life_threat_protective-Network_oriented_prevention
           crime_denial          Boundary_clarification-Life_threat_protective
           crime_denial     Escalation_aware_mixed-Network_oriented_prevention
           coharm_count     Life_threat_protective-Network_oriented_prevention
 prosocial_change_count      Multi_action_institutional-Boundary_clarification
                 offcnt     Life_threat_protective-Network_oriented_prevention
           crime_denial      Multi_action_institutional-Life_threat_protective
       total_type_count Multi_action_institutional-Network_oriented_prevention
                    dig     Life_threat_protective-Network_oriented_prevention
         victim_blaming     Escalation_aware_mixed-Network_oriented_prevention
         victim_blaming     Life_threat_protective-Network_oriented_prevention
  negative_impact_count          Life_threat_protective-Escalation_aware_mixed
           coharm_count          Life_threat_protective-Escalation_aware_mixed
                 offcnt Multi_action_institutional-Network_oriented_prevention
                    dig Multi_action_institutional-Network_oriented_prevention
 prosocial_change_count      Multi_action_institutional-Life_threat_protective
       gender_awareness      Multi_action_institutional-Escalation_aware_mixed
 seoul_policy_awareness Multi_action_institutional-Network_oriented_prevention
  negative_impact_count          Boundary_clarification-Life_threat_protective
       gender_hierarchy     Life_threat_protective-Network_oriented_prevention
                   fear      Multi_action_institutional-Escalation_aware_mixed
           cjs_distrust      Multi_action_institutional-Escalation_aware_mixed
 prosocial_change_count          Life_threat_protective-Escalation_aware_mixed
  negative_impact_count     Boundary_clarification-Network_oriented_prevention
  negative_impact_count     Escalation_aware_mixed-Network_oriented_prevention
       total_type_count     Escalation_aware_mixed-Network_oriented_prevention
                    dig          Boundary_clarification-Life_threat_protective
                 offcnt     Escalation_aware_mixed-Network_oriented_prevention
 seoul_policy_awareness      Multi_action_institutional-Escalation_aware_mixed
       total_type_count          Boundary_clarification-Life_threat_protective
   diff    lwr    upr p_adj_Tukey
  1.105  0.742  1.469    1.15e-10
  1.155  0.742  1.568    1.16e-10
  1.210  0.731  1.689    2.52e-10
  1.430  0.854  2.007    4.28e-10
  0.839  0.495  1.184    8.04e-10
  1.065  0.627  1.502    8.32e-10
  1.143  0.645  1.640    7.14e-09
  0.708  0.394  1.022    1.39e-08
  0.685  0.354  1.016    2.41e-07
  1.026  0.502  1.551    1.30e-06
  3.148  1.466  4.829    4.21e-06
 -0.734 -1.128 -0.341    4.63e-06
  0.733  0.329  1.137    9.24e-06
  0.987  0.441  1.534    1.01e-05
  0.787  0.352  1.223    1.01e-05
  1.979  0.854  3.104    1.92e-05
 -0.737 -1.170 -0.304    3.92e-05
  2.945  1.171  4.720    6.75e-05
  1.169  0.444  1.893    1.20e-04
  0.678  0.257  1.099    1.25e-04
  0.716  0.260  1.173    2.03e-04
  0.442  0.150  0.733    3.75e-04
  0.700  0.238  1.162    3.83e-04
  1.797  0.610  2.984    3.86e-04
  1.149  0.384  1.913    4.40e-04
  0.661  0.213  1.110    5.96e-04
  0.513  0.162  0.863    6.79e-04
  1.144  0.314  1.974    1.68e-03
 -0.420 -0.729 -0.110    2.17e-03
  0.435  0.108  0.762    2.71e-03
  0.364  0.082  0.645    4.02e-03
  0.461  0.103  0.818    4.13e-03
  0.494  0.110  0.878    4.21e-03
  0.420  0.085  0.755    5.86e-03
  0.397  0.079  0.715    6.08e-03
  1.911  0.359  3.463    7.18e-03
 -0.800 -1.452 -0.148    7.42e-03
  1.274  0.235  2.312    7.50e-03
  0.877  0.161  1.594    7.66e-03
 -1.840 -3.352 -0.328    8.20e-03


## Top pairwise binary (Bonferroni q < .05)

               variable                     class_i                    class_j
             q40_police      Boundary_clarification Multi_action_institutional
             q42_police      Life_threat_protective     Boundary_clarification
             q40_police Network_oriented_prevention     Boundary_clarification
          gendered_case Network_oriented_prevention     Life_threat_protective
             q42_police      Boundary_clarification Multi_action_institutional
          severe_coharm Network_oriented_prevention     Life_threat_protective
          severe_coharm      Life_threat_protective     Boundary_clarification
      online_withdrawal Network_oriented_prevention     Life_threat_protective
             q40_police      Life_threat_protective     Boundary_clarification
          severe_coharm Network_oriented_prevention Multi_action_institutional
         digital_coharm      Escalation_aware_mixed     Life_threat_protective
                 threat Network_oriented_prevention     Life_threat_protective
          severe_coharm      Boundary_clarification Multi_action_institutional
      online_withdrawal Network_oriented_prevention Multi_action_institutional
               intimate Network_oriented_prevention     Boundary_clarification
          gendered_case Network_oriented_prevention     Escalation_aware_mixed
                 threat Network_oriented_prevention     Escalation_aware_mixed
             q40_police      Escalation_aware_mixed     Boundary_clarification
      online_withdrawal      Life_threat_protective     Boundary_clarification
             q42_police Network_oriented_prevention     Boundary_clarification
         digital_coharm      Escalation_aware_mixed Multi_action_institutional
               intimate Network_oriented_prevention     Life_threat_protective
             q42_police      Escalation_aware_mixed     Life_threat_protective
                 threat Network_oriented_prevention     Boundary_clarification
             q40_police      Escalation_aware_mixed Multi_action_institutional
 any_violence_education      Life_threat_protective     Boundary_clarification
         digital_coharm      Life_threat_protective     Boundary_clarification
          severe_coharm      Escalation_aware_mixed     Life_threat_protective
      online_withdrawal Network_oriented_prevention     Escalation_aware_mixed
             q42_police      Escalation_aware_mixed     Boundary_clarification
      online_withdrawal      Boundary_clarification Multi_action_institutional
 any_violence_education      Boundary_clarification Multi_action_institutional
 any_violence_education Network_oriented_prevention     Life_threat_protective
                 threat Network_oriented_prevention Multi_action_institutional
             disability Network_oriented_prevention     Life_threat_protective
 any_violence_education Network_oriented_prevention Multi_action_institutional
  test       p_pair p_bonferroni
 chisq 3.354616e-10 3.354616e-09
 chisq 6.546378e-09 6.546378e-08
 chisq 5.263575e-08 5.263575e-07
 chisq 3.856098e-07 3.856098e-06
 chisq 3.974738e-07 3.974738e-06
 chisq 7.092761e-07 7.092761e-06
 chisq 1.439394e-06 1.439394e-05
 chisq 5.481310e-06 5.481310e-05
 chisq 7.330056e-06 7.330056e-05
 chisq 1.404709e-05 1.404709e-04
 chisq 1.716465e-05 1.716465e-04
 chisq 2.834330e-05 2.834330e-04
 chisq 3.427813e-05 3.427813e-04
 chisq 3.854541e-05 3.854541e-04
 chisq 4.029880e-05 4.029880e-04
 chisq 5.407536e-05 5.407536e-04
 chisq 9.525014e-05 9.525014e-04
 chisq 1.350143e-04 1.350143e-03
 chisq 3.677345e-04 3.677345e-03
 chisq 4.901397e-04 4.901397e-03
 chisq 6.615750e-04 6.615750e-03
 chisq 8.777961e-04 8.777961e-03
 chisq 1.156516e-03 1.156516e-02
 chisq 1.331629e-03 1.331629e-02
 chisq 1.487466e-03 1.487466e-02
 chisq 1.679465e-03 1.679465e-02
 chisq 1.759409e-03 1.759409e-02
 chisq 1.830419e-03 1.830419e-02
 chisq 1.880392e-03 1.880392e-02
 chisq 2.426326e-03 2.426326e-02
 chisq 2.449868e-03 2.449868e-02
 chisq 2.481820e-03 2.481820e-02
 chisq 2.648345e-03 2.648345e-02
 chisq 2.749903e-03 2.749903e-02
 chisq 2.872099e-03 2.872099e-02
 chisq 3.473232e-03 3.473232e-02
