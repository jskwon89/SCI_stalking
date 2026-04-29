# Extended LCA Fit Reporting

N = 501 

## Extended fit table

  K        LL npar      AIC      BIC     aBIC Entropy smallest_class  LMR_p
1 2 -3717.225   29 7492.450 7614.732 7522.684   0.881         0.1588 0.0005
2 3 -3639.119   44 7366.239 7551.770 7412.111   0.886         0.1485 0.0006
3 4 -3594.938   59 7307.876 7556.656 7369.386   0.822         0.1470 0.2764
4 5 -3563.416   74 7274.832 7586.861 7351.980   0.879         0.1446 0.0108
5 6 -3531.612   89 7241.225 7616.503 7334.011   0.873         0.1080 0.5151
  BLRT_p BLRT_draws     CAIC      AWE AvePP_min AvePP_mean  OCC_min best_AIC
1      0          5 7643.732 7882.013 0.8425556  0.9167157 23.78102    FALSE
2      0          5 7595.769 7957.299 0.8879765  0.9200389 27.63889    FALSE
3      0         10 7615.656 8100.436 0.8076714  0.8939501 12.07130    FALSE
4      0         10 7660.861 8268.890 0.8424211  0.9210041 29.89554    FALSE
5      0         20 7705.502 8436.780 0.8676721  0.9131324 33.19565     TRUE
  best_BIC best_aBIC best_CAIC best_AWE
1    FALSE     FALSE     FALSE     TRUE
2     TRUE     FALSE      TRUE    FALSE
3    FALSE     FALSE     FALSE    FALSE
4    FALSE     FALSE     FALSE    FALSE
5    FALSE      TRUE     FALSE    FALSE

## AvePP by class

   K class modal_prop     AvePP      OCC
1  2     1  0.1796407 0.8425556 24.43827
2  2     2  0.8203593 0.9908759 23.78102
3  3     1  0.1576846 0.8894430 42.97515
4  3     2  0.1696607 0.8879765 38.79418
5  3     3  0.6726547 0.9826973 27.63889
6  4     1  0.5189621 0.9286885 12.07130
7  4     2  0.1477046 0.9417703 93.32465
8  4     3  0.1397206 0.8076714 25.85652
9  4     4  0.1936128 0.8976701 36.53624
10 5     1  0.1457086 0.9390411 90.31676
11 5     2  0.2914172 0.9400205 38.10749
12 5     3  0.1916168 0.9370104 62.75661
13 5     4  0.2195609 0.9465273 62.91944
14 5     5  0.1516966 0.8424211 29.89554
15 6     1  0.1217565 0.8676721 47.29630
16 6     2  0.1437126 0.9411944 95.36429
17 6     3  0.2435130 0.9381475 47.11873
18 6     4  0.1117764 0.9138214 84.26244
19 6     5  0.1816367 0.8804945 33.19565
20 6     6  0.1976048 0.9374646 60.87236

Interpretation: information criteria favor the most parsimonious defensible solution, while AvePP and entropy describe classification quality. Entropy should not be used as the primary class-number criterion. If a 5-class model is retained, justify it by theoretical and policy differentiation, not by BIC alone.
