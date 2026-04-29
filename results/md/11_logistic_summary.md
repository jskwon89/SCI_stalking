# Robust Logistic Regression — Summary

Sample sizes: witnesses = 749 , responders = 501 

Standard errors: HC3 sandwich. Cluster-robust by region NOT used as primary because K=5 regions is too few for asymptotic CR theory; HC3 is preferred.
Firth penalized logit reported for outcomes with event rate < 20% or > 80%.

Multiple-comparison correction: Benjamini-Hochberg FDR within (outcome, SE-type).

## DIG x stedu interaction tests

# A tibble: 5 × 9
  outcome   interaction_term       B SE_HC3  p_HC3    OR LRT_chisq LRT_df  LRT_p
  <chr>     <chr>              <dbl>  <dbl>  <dbl> <dbl>     <dbl>  <dbl>  <dbl>
1 active_r… dig:stedu         0.0518  0.133 0.697  1.05      0.165      1 0.684 
2 institut… dig:stedu        -0.114   0.130 0.379  0.892     0.975      1 0.323 
3 q40_poli… dig:stedu        -0.297   0.162 0.0671 0.743     3.94       1 0.0471
4 q42_poli… dig:stedu        -0.263   0.144 0.0677 0.769     3.61       1 0.0573
5 online_w… dig:stedu        -0.135   0.134 0.313  0.874     1.15       1 0.284 


## Selected significant terms (q < .05 after FDR) — HC3 model

# A tibble: 8 × 7
  outcome                term             OR OR_lo OR_hi       p.value  p_fdr_BH
  <chr>                  <chr>         <dbl> <dbl> <dbl>         <dbl>     <dbl>
1 active_response        stedu          2.50  1.66  3.77 0.0000130       2.21e-4
2 active_response        severe_coharm  2.59  1.71  3.94 0.00000723      2.21e-4
3 active_response        freq_ord_z     1.62  1.25  2.09 0.000275        3.12e-3
4 active_response        intimate       2.65  1.53  4.56 0.000464        3.94e-3
5 active_response        known_nonint   2.40  1.33  4.35 0.00382         2.60e-2
6 institutional_response severe_coharm  3.33  2.12  5.22 0.000000163     5.55e-6
7 institutional_response stedu          2.57  1.61  4.09 0.0000687       1.17e-3
8 online_withdrawal      severe_coharm  4.60  2.76  7.65 0.00000000451   1.53e-7


## Firth vs HC3 OR comparison for rare-event outcomes

# A tibble: 36 × 5
   outcome                model           term                       OR  p.value
   <chr>                  <chr>           <chr>                   <dbl>    <dbl>
 1 institutional_response logit_HC3       dig                     1.20  2.72e- 2
 2 institutional_response logit_HC3       intimate                1.46  2.83e- 1
 3 institutional_response logit_HC3       known_nonint            2.23  3.23e- 2
 4 institutional_response logit_HC3       seoul_policy_awareness… 1.37  1.85e- 2
 5 institutional_response logit_HC3       severe_coharm           3.33  1.63e- 7
 6 institutional_response logit_HC3       stedu                   2.57  6.87e- 5
 7 online_withdrawal      firth_penalized dig                     0.913 2.55e- 1
 8 online_withdrawal      logit_HC3       dig                     0.905 2.47e- 1
 9 online_withdrawal      firth_penalized intimate                0.922 8.21e- 1
10 online_withdrawal      logit_HC3       intimate                0.939 8.74e- 1
11 online_withdrawal      firth_penalized known_nonint            1.10  7.99e- 1
12 online_withdrawal      logit_HC3       known_nonint            1.13  7.67e- 1
13 online_withdrawal      firth_penalized seoul_policy_awareness… 1.10  4.85e- 1
14 online_withdrawal      logit_HC3       seoul_policy_awareness… 1.10  5.04e- 1
15 online_withdrawal      firth_penalized severe_coharm           4.18  1.32e-10
16 online_withdrawal      logit_HC3       severe_coharm           4.60  4.51e- 9
17 online_withdrawal      firth_penalized stedu                   1.87  4.58e- 3
18 online_withdrawal      logit_HC3       stedu                   1.95  6.09e- 3
19 q40_police             firth_penalized dig                     1.05  5.57e- 1
20 q40_police             logit_HC3       dig                     1.06  6.18e- 1
21 q40_police             firth_penalized intimate                0.916 8.23e- 1
22 q40_police             logit_HC3       intimate                0.933 8.79e- 1
23 q40_police             firth_penalized known_nonint            0.910 8.29e- 1
24 q40_police             logit_HC3       known_nonint            0.916 8.59e- 1
25 q40_police             firth_penalized seoul_policy_awareness… 1.50  5.41e- 3
26 q40_police             logit_HC3       seoul_policy_awareness… 1.55  1.43e- 2
27 q40_police             firth_penalized severe_coharm           2.28  1.64e- 3
28 q40_police             logit_HC3       severe_coharm           2.44  4.80e- 3
29 q40_police             firth_penalized stedu                   2.12  4.00e- 3
30 q40_police             logit_HC3       stedu                   2.26  1.15e- 2
31 q42_police             logit_HC3       dig                     1.12  2.21e- 1
32 q42_police             logit_HC3       intimate                1.05  9.13e- 1
33 q42_police             logit_HC3       known_nonint            0.809 6.67e- 1
34 q42_police             logit_HC3       seoul_policy_awareness… 1.37  3.99e- 2
35 q42_police             logit_HC3       severe_coharm           2.28  2.43e- 3
36 q42_police             logit_HC3       stedu                   1.51  1.18e- 1
