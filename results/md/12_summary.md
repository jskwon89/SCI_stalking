# Moderated Mediation + E-value Sensitivity

## Mediation model

DIG -> perceived seriousness (serious_z) -> institutional_response
Moderator: stedu (stalking-specific prevention education) on b path and direct path.
Estimator: ML with WLSMV on ordered Y, bootstrap 5000.

N analytic = 749 

### Defined indirect / total / moderation effects

           label    est    se      z pvalue ci.lower ci.upper
91       ind_low  0.013 0.007  1.759  0.079   -0.001    0.028
92      ind_high  0.012 0.007  1.682  0.093   -0.002    0.027
93     total_low  0.021 0.016  1.263  0.206   -0.011    0.053
94    total_high  0.022 0.015  1.464  0.143   -0.006    0.052
95 diff_indirect -0.001 0.010 -0.102  0.919   -0.021    0.018

## E-value (VanderWeele & Ding 2017)

Interpretation: minimum strength of unmeasured confounder OR (with both
exposure and outcome) needed to fully explain away the observed stedu OR.

# A tibble: 5 × 6
  outcome                   OR OR_lo OR_hi eval_point eval_ci_lower
  <chr>                  <dbl> <dbl> <dbl>      <dbl>         <dbl>
1 active_response         2.43 1.65   3.59       4.29          2.69
2 institutional_response  2.52 1.67   3.84       4.48          2.73
3 q40_police              2.27 1.33   3.94       3.96          2.00
4 q42_police              1.48 0.893  2.46       2.33          1   
5 online_withdrawal       1.89 1.18   3.02       3.19          1.64
