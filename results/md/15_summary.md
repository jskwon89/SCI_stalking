# BCH-style class differences on distal outcomes (manual implementation)

Mplus 7.0 lacks AUXILIARY = ...(BCH); manual BCH using R3STEP CPROB.

Classification diagonal D: 0.939, 0.94, 0.937, 0.947, 0.842 

## Overall Wald test of class equality (with FDR-BH correction across distals)

# A tibble: 11 × 6
   distal                  Wald    df p_overall    p_fdr sig  
   <chr>                  <dbl> <dbl>     <dbl>    <dbl> <chr>
 1 online_withdrawal       58.7     4  5.43e-12 1.49e-11 ***  
 2 digital_coharm          29.2     4  7.04e- 6 1.29e- 5 ***  
 3 q42_police              72.2     4  7.88e-15 2.89e-14 ***  
 4 role_police_top2        18.5     4  9.97e- 4 1.10e- 3 **   
 5 support_awareness       25.2     4  4.68e- 5 6.44e- 5 ***  
 6 seoul_policy_awareness  31.8     4  2.07e- 6 4.56e- 6 ***  
 7 freq_ord                16.4     4  2.48e- 3 2.48e- 3 **   
 8 severe_coharm           77.7     4  5.55e-16 3.05e-15 ***  
 9 intimate                25.2     4  4.54e- 5 6.44e- 5 ***  
10 fear                    22.9     4  1.33e- 4 1.62e- 4 ***  
11 crime_denial            91.3     4  0        0        ***  

## Class means (binary -> proportion; continuous -> mean) by distal

# A tibble: 55 × 7
   distal                 class label               mean raw_mean clipped     se
   <chr>                  <int> <chr>              <dbl>    <dbl> <lgl>    <dbl>
 1 online_withdrawal          1 Network_oriented… 0.0669   0.0669 FALSE   0.0290
 2 online_withdrawal          2 Escalation_aware… 0.272    0.272  FALSE   0.0359
 3 online_withdrawal          3 Life_threat_prot… 0.405    0.405  FALSE   0.0490
 4 online_withdrawal          4 Boundary_clarifi… 0.165    0.165  FALSE   0.0350
 5 online_withdrawal          5 Multi_action_ins… 0.448    0.448  FALSE   0.0642
 6 digital_coharm             1 Network_oriented… 0.116    0.116  FALSE   0.0371
 7 digital_coharm             2 Escalation_aware… 0.0733   0.0733 FALSE   0.0210
 8 digital_coharm             3 Life_threat_prot… 0.291    0.291  FALSE   0.0454
 9 digital_coharm             4 Boundary_clarifi… 0.103    0.103  FALSE   0.0287
10 digital_coharm             5 Multi_action_ins… 0.305    0.305  FALSE   0.0594
11 q42_police                 1 Network_oriented… 0.349    0.349  FALSE   0.0552
12 q42_police                 2 Escalation_aware… 0.292    0.292  FALSE   0.0367
13 q42_police                 3 Life_threat_prot… 0.509    0.509  FALSE   0.0499
14 q42_police                 4 Boundary_clarifi… 0.113    0.113  FALSE   0.0299
15 q42_police                 5 Multi_action_ins… 0.553    0.553  FALSE   0.0641
16 role_police_top2           1 Network_oriented… 0.459    0.459  FALSE   0.0578
17 role_police_top2           2 Escalation_aware… 0.371    0.371  FALSE   0.0389
18 role_police_top2           3 Life_threat_prot… 0.473    0.473  FALSE   0.0499
19 role_police_top2           4 Boundary_clarifi… 0.554    0.554  FALSE   0.0469
20 role_police_top2           5 Multi_action_ins… 0.267    0.267  FALSE   0.0571
21 support_awareness          1 Network_oriented… 2.47     2.47   FALSE   0.242 
22 support_awareness          2 Escalation_aware… 2.49     2.49   FALSE   0.187 
23 support_awareness          3 Life_threat_prot… 2.80     2.80   FALSE   0.234 
24 support_awareness          4 Boundary_clarifi… 2.82     2.82   FALSE   0.227 
25 support_awareness          5 Multi_action_ins… 4.01     4.01   FALSE   0.267 
26 seoul_policy_awareness     1 Network_oriented… 1.28     1.28   FALSE   0.174 
27 seoul_policy_awareness     2 Escalation_aware… 1.60     1.60   FALSE   0.144 
28 seoul_policy_awareness     3 Life_threat_prot… 2.13     2.13   FALSE   0.197 
29 seoul_policy_awareness     4 Boundary_clarifi… 1.66     1.66   FALSE   0.171 
30 seoul_policy_awareness     5 Multi_action_ins… 2.89     2.89   FALSE   0.258 
31 freq_ord                   1 Network_oriented… 1.66     1.66   FALSE   0.0906
32 freq_ord                   2 Escalation_aware… 2.02     2.02   FALSE   0.0769
33 freq_ord                   3 Life_threat_prot… 2.07     2.07   FALSE   0.0912
34 freq_ord                   4 Boundary_clarifi… 1.77     1.77   FALSE   0.0796
35 freq_ord                   5 Multi_action_ins… 1.98     1.98   FALSE   0.131 
36 severe_coharm              1 Network_oriented… 0.351    0.351  FALSE   0.0553
37 severe_coharm              2 Escalation_aware… 0.552    0.552  FALSE   0.0401
38 severe_coharm              3 Life_threat_prot… 0.759    0.759  FALSE   0.0427
39 severe_coharm              4 Boundary_clarifi… 0.405    0.405  FALSE   0.0463
40 severe_coharm              5 Multi_action_ins… 0.836    0.836  FALSE   0.0477
41 intimate                   1 Network_oriented… 0.459    0.459  FALSE   0.0578
42 intimate                   2 Escalation_aware… 0.637    0.637  FALSE   0.0387
43 intimate                   3 Life_threat_prot… 0.732    0.732  FALSE   0.0442
44 intimate                   4 Boundary_clarifi… 0.780    0.780  FALSE   0.0391
45 intimate                   5 Multi_action_ins… 0.595    0.595  FALSE   0.0633
46 fear                       1 Network_oriented… 3.41     3.41   FALSE   0.0871
47 fear                       2 Escalation_aware… 3.33     3.33   FALSE   0.0582
48 fear                       3 Life_threat_prot… 3.51     3.51   FALSE   0.0707
49 fear                       4 Boundary_clarifi… 3.53     3.53   FALSE   0.0662
50 fear                       5 Multi_action_ins… 3.83     3.83   FALSE   0.0912
51 crime_denial               1 Network_oriented… 1.58     1.58   FALSE   0.0655
52 crime_denial               2 Escalation_aware… 2.32     2.32   FALSE   0.0827
53 crime_denial               3 Life_threat_prot… 2.67     2.67   FALSE   0.119 
54 crime_denial               4 Boundary_clarifi… 1.92     1.92   FALSE   0.0978
55 crime_denial               5 Multi_action_ins… 1.77     1.77   FALSE   0.138 
