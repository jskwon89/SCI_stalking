# LCA item-response probabilities + 3-class vs 5-class sensitivity

## (a) Item-response probabilities (5-class, wide format)

# A tibble: 14 × 7
   item_full item_label              C1    C2    C3    C4    C5
   <chr>     <chr>                <dbl> <dbl> <dbl> <dbl> <dbl>
 1 Q40_1     Confront             0.176 0.243 0.08  0.509 0.371
 2 Q40_2     Persuade             0.19  0.26  0.473 0.59  0.253
 3 Q40_3     Job/school exit      0.099 0.289 0.261 0.11  0.256
 4 Q40_4     Shelter/move         0     0.13  0.341 0.125 0.167
 5 Q40_5     School/work help     0.053 0.107 0.255 0.058 0.241
 6 Q40_6     Network help         0.54  0.185 0.276 0.225 0.612
 7 Q40_7     Police               0.273 0.156 0.201 0.019 0.338
 8 Q40_8     Agency counseling    0.059 0.035 0.073 0     0.453
 9 Q41_1     Not romance          0.046 0     0.062 1     0.612
10 Q41_2     Escalation           0.051 0.438 0.366 0.281 0.486
11 Q41_3     Others harmed        0.056 0.455 0.231 0.129 0.389
12 Q41_4     Life threat          0.019 0     1     0     0.318
13 Q41_5     Daily disruption     0.094 0.338 0.16  0.092 0.503
14 Q41_6     Prevent another harm 1     0     0     0.044 0.36 

## (b) Cross-tabulation: 3-class x 5-class modal assignment

   1  2   3 total_5class
1 70  0   3           73
2  0  0 146          146
3  0  0  96           96
4  1 84  25          110
5  8  1  67           76


Interpretation: each row shows how a 5-class member is distributed across the 3-class solution. Diagonal-like patterns mean the 3-class is a coarsening of the 5-class.
