# Sensitivity Agreement Metrics

Comparisons use modal assignments for N = 501 active responders.

ARI cutoffs were defined before inspecting results: >=.80 very high, .60-.79 substantial, .40-.59 moderate, <.40 limited agreement.

## Metrics

# A tibble: 2 × 5
  comparison                                 n cramer_V   ARI ARI_interpretation
  <chr>                                  <int>    <dbl> <dbl> <chr>             
1 Primary 5-class vs Q40-only 5-class      501    0.322 0.084 limited agreement 
2 Primary 5-class vs pruned-trigger 5-c…   501    0.642 0.365 limited agreement 

## Primary vs Q40-only cross-tab

   primary_class C1 C2 C3 C4 C5
C1            C1  1 10 35  9 18
C2            C2  0 28 25 32 61
C3            C3  1  5 10 34 46
C4            C4  0 50 14 35 11
C5            C5 10  6 37  3 20

## Primary vs pruned-trigger cross-tab

   primary_class C1 C2 C3 C4 C5
C1            C1 73  0  0  0  0
C2            C2 44  0 34 66  2
C3            C3  0  6 40 50  0
C4            C4 10  0  0  4 96
C5            C5 31 36  0  4  5

Interpretation: exact class-number or label replication was not required. The sensitivity question is whether the broad response axes remain visible when trigger items are excluded or pruned.
