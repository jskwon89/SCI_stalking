# Barrier Overlap and Difference Tests

## Domain counts

         group   N mean_domain_count median_domain_count pct_two_or_more
 Non-reporting 333             1.417                   1           0.321
  Non-response 248             1.371                   1           0.278

## Non-response vs non-reporting domain differences

                   domain nonresponse_N nonresponse_prop nonreporting_N
      privacy_retaliation           248           0.1331            333
             minimization           248           0.7177            333
           evidence_legal           248           0.0927            333
          burden_distrust           248           0.0685            333
 relationship_victim_wish           248           0.1613            333
 nonreporting_prop difference_nonreporting_minus_nonresponse p_value cramer_V
            0.3724                                    0.2393  0.0000   0.2626
            0.3003                                   -0.4174  0.0000   0.4098
            0.2763                                    0.1835  0.0000   0.2235
            0.2733                                    0.2047  0.0000   0.2558
            0.1952                                    0.0339  0.3464   0.0391
  p_FDR
 0.0000
 0.0000
 0.0000
 0.0000
 0.3464

## Heatmap data

         group                   domain N_valid n_yes prop_yes
 Non-reporting          burden_distrust     333    91    0.273
 Non-reporting           evidence_legal     333    92    0.276
 Non-reporting             minimization     333   100    0.300
 Non-reporting      privacy_retaliation     333   124    0.372
 Non-reporting relationship_victim_wish     333    65    0.195
 Non-reporting        social_norm_blame       0     0       NA
  Non-response          burden_distrust     248    17    0.069
  Non-response           evidence_legal     248    23    0.093
  Non-response             minimization     248   178    0.718
  Non-response      privacy_retaliation     248    33    0.133
  Non-response relationship_victim_wish     248    40    0.161
  Non-response        social_norm_blame     248    49    0.198

## Top overlap pairs

         group                 domain_a                 domain_b N_valid
 Non-reporting      privacy_retaliation           evidence_legal     333
 Non-reporting           evidence_legal          burden_distrust     333
 Non-reporting      privacy_retaliation          burden_distrust     333
 Non-reporting             minimization          burden_distrust     333
 Non-reporting             minimization           evidence_legal     333
 Non-reporting             minimization relationship_victim_wish     333
 Non-reporting      privacy_retaliation relationship_victim_wish     333
 Non-reporting      privacy_retaliation             minimization     333
 Non-reporting           evidence_legal relationship_victim_wish     333
 Non-reporting          burden_distrust relationship_victim_wish     333
  Non-response             minimization        social_norm_blame     248
  Non-response             minimization relationship_victim_wish     248
  Non-response             minimization           evidence_legal     248
  Non-response      privacy_retaliation             minimization     248
  Non-response relationship_victim_wish        social_norm_blame     248
  Non-response             minimization          burden_distrust     248
  Non-response           evidence_legal        social_norm_blame     248
  Non-response      privacy_retaliation        social_norm_blame     248
  Non-response          burden_distrust        social_norm_blame     248
  Non-response      privacy_retaliation          burden_distrust     248
 overlap_n overlap_prop
        36        0.108
        36        0.108
        33        0.099
        19        0.057
        17        0.051
        15        0.045
        13        0.039
        11        0.033
         7        0.021
         7        0.021
        22        0.089
        18        0.073
        16        0.065
        15        0.060
        10        0.040
         9        0.036
         9        0.036
         8        0.032
         7        0.028
         5        0.020

Interpretation: these tables test whether decision-to-act barriers and institutional-entry barriers are structurally different. They should be used to support the sequential framework rather than expand the LCA model.
