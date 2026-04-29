# Class Enumeration — Responder-Only LCA

Indicators: Q40_1..Q40_8 + Q41_1..Q41_6 (14 binary).
Estimator: ML; STARTS = 1000 200; STITERATIONS = 20.

## Fit table

# A tibble: 5 × 11
      K     LL  npar   AIC   BIC  aBIC Entropy smallest_class  LMR_p BLRT_p
  <int>  <dbl> <dbl> <dbl> <dbl> <dbl>   <dbl>          <dbl>  <dbl>  <dbl>
1     2 -3717.    29 7492. 7615. 7523.   0.881          0.159 0.0005      0
2     3 -3639.    44 7366. 7552. 7412.   0.886          0.148 0.0006      0
3     4 -3595.    59 7308. 7557. 7369.   0.822          0.147 0.276       0
4     5 -3563.    74 7275. 7587. 7352.   0.879          0.145 0.0108      0
5     6 -3532.    89 7241. 7617. 7334.   0.873          0.108 0.515       0
# ℹ 1 more variable: BLRT_draws <int>

## Decision criteria
- BIC (lower = better)
- aBIC (sample-size adjusted; lower = better)
- Entropy (>= .80 acceptable, >= .90 strong)
- Smallest class >= 5% to avoid micro-classes
- LMR p < .05 vs. k-1; BLRT p < .05 strongly favors k
- Theoretical interpretability

