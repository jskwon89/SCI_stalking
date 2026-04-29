# Policy Distal Outcomes by 5-Class LCA

Sample: active responders, N = 501 

Class labels are provisional and based on the item-response profile from script 19.

## Omnibus tests with FDR q < .10

                          distal     method statistic      p_value     p_fdr_BH
1       role_victim_support_top2 chi-square 42.899287 1.085795e-08 3.040225e-07
2  policy_police_protection_top3 chi-square 33.463171 9.600910e-07 1.344127e-05
3         policy_punishment_top3 chi-square 31.424305 2.508022e-06 2.340821e-05
4             role_confront_top2 chi-square 28.844258 8.408012e-06 5.885608e-05
5      policy_online_delete_top3 chi-square 27.896660 1.308911e-05 7.329899e-05
6                 edu_legal_top2 chi-square 21.690719 2.309237e-04 1.077644e-03
7        edu_bystander_role_top2 chi-square 18.305022 1.075693e-03 4.302773e-03
8     policy_secondary_harm_top3 chi-square 15.715699 3.425371e-03 1.198880e-02
9        seoul_service_use_count      ANOVA  3.569911 6.963592e-03 2.166451e-02
10          role_schoolwork_top2 chi-square 13.537210 8.928433e-03 2.499961e-02
11             role_network_top2 chi-square 12.543964 1.373301e-02 3.495674e-02
12              role_police_top2 chi-square 11.994913 1.738913e-02 4.057464e-02
13     support_service_use_count      ANOVA  2.746737 2.784168e-02 5.709612e-02
14          edu_humanrights_top2 chi-square 10.754679 2.946393e-02 5.709612e-02
15         seoul_service_use_any chi-square 10.514991 3.259112e-02 5.709612e-02
16    policy_perp_treatment_top3 chi-square 10.512419 3.262635e-02 5.709612e-02

## Class summary

# A tibble: 5 × 31
  class5 class5_label                      n role_confront_top2 role_police_top2
  <fct>  <fct>                         <int>              <dbl>            <dbl>
1 C1     Network-oriented prevention …    73              0.151            0.452
2 C2     Escalation-aware mixed respo…   146              0.171            0.370
3 C3     Life-threat protective respo…    96              0.146            0.469
4 C4     Boundary-clarification persu…   110              0.4              0.545
5 C5     Multi-action institutional r…    76              0.184            0.329
# ℹ 26 more variables: role_schoolwork_top2 <dbl>, role_network_top2 <dbl>,
#   role_agency_info_top2 <dbl>, role_punishment_top2 <dbl>,
#   role_victim_support_top2 <dbl>, edu_legal_top2 <dbl>,
#   edu_schoolwork_top2 <dbl>, edu_help_info_top2 <dbl>,
#   edu_humanrights_top2 <dbl>, edu_bystander_role_top2 <dbl>,
#   seoul_service_use_count <dbl>, seoul_service_use_any <dbl>,
#   seoul_digital_center_yes <dbl>, support_service_use_count <dbl>, …

Interpretation: these modal-class distal comparisons translate the LCA into policy-relevant needs. Use as descriptive/sensitivity evidence, with DU3STEP/manual BCH retained for classification-error-aware checks.
