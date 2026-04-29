# Q40-Only Response LCA Sensitivity

Sample: active responders only, N = 501 

Indicators: Q40_1..Q40_8 response actions only.

Purpose: this sensitivity was not intended to reproduce the exact number of primary classes, but to examine whether major behavioral axes remain visible when trigger/risk-recognition items are excluded.

## Fit table

# A tibble: 5 × 13
      K     LL  npar   AIC   BIC  aBIC Entropy smallest_class  LMR_p BLRT_p
  <int>  <dbl> <dbl> <dbl> <dbl> <dbl>   <dbl>          <dbl>  <dbl>  <dbl>
1     2 -2014.    17 4061. 4133. 4079.   0.749         0.202  0           0
2     3 -1990.    26 4031. 4141. 4059.   0.788         0.159  0           0
3     4 -1968.    35 4006. 4154. 4043.   0.883         0.154  0.0003      0
4     5 -1945.    44 3979. 4164. 4024.   0.894         0.0268 0.022       0
5     6 -1926.    53 3958. 4182. 4013.   0.886         0.0346 0.0387      0
# ℹ 3 more variables: BLRT_draws <int>, CAIC <dbl>, AWE <dbl>

## 5-class item-response probabilities

   K class item prob_yes item_full        item_label
1  5     1   a1    0.852     Q40_1          Confront
2  5     1   a2    0.867     Q40_2          Persuade
3  5     1   a3    0.348     Q40_3   Job/school exit
4  5     1   a4    0.243     Q40_4      Shelter/move
5  5     1   a5    0.619     Q40_5  School/work help
6  5     1   a6    1.000     Q40_6      Network help
7  5     1   a7    0.853     Q40_7            Police
8  5     1   a8    0.377     Q40_8 Agency counseling
9  5     2   a1    1.000     Q40_1          Confront
10 5     2   a2    0.393     Q40_2          Persuade
11 5     2   a3    0.136     Q40_3   Job/school exit
12 5     2   a4    0.039     Q40_4      Shelter/move
13 5     2   a5    0.000     Q40_5  School/work help
14 5     2   a6    0.138     Q40_6      Network help
15 5     2   a7    0.068     Q40_7            Police
16 5     2   a8    0.009     Q40_8 Agency counseling
17 5     3   a1    0.123     Q40_1          Confront
18 5     3   a2    0.000     Q40_2          Persuade
19 5     3   a3    0.146     Q40_3   Job/school exit
20 5     3   a4    0.069     Q40_4      Shelter/move
21 5     3   a5    0.105     Q40_5  School/work help
22 5     3   a6    1.000     Q40_6      Network help
23 5     3   a7    0.161     Q40_7            Police
24 5     3   a8    0.183     Q40_8 Agency counseling
25 5     4   a1    0.000     Q40_1          Confront
26 5     4   a2    1.000     Q40_2          Persuade
27 5     4   a3    0.072     Q40_3   Job/school exit
28 5     4   a4    0.124     Q40_4      Shelter/move
29 5     4   a5    0.171     Q40_5  School/work help
30 5     4   a6    0.274     Q40_6      Network help
31 5     4   a7    0.033     Q40_7            Police
32 5     4   a8    0.000     Q40_8 Agency counseling
33 5     5   a1    0.106     Q40_1          Confront
34 5     5   a2    0.154     Q40_2          Persuade
35 5     5   a3    0.370     Q40_3   Job/school exit
36 5     5   a4    0.292     Q40_4      Shelter/move
37 5     5   a5    0.186     Q40_5  School/work help
38 5     5   a6    0.000     Q40_6      Network help
39 5     5   a7    0.302     Q40_7            Police
40 5     5   a8    0.169     Q40_8 Agency counseling

## 5-class class sizes

  K class   n proportion
1 5     1  12  0.0239521
2 5     2  99  0.1976048
3 5     3 121  0.2415170
4 5     4 113  0.2255489
5 5     5 156  0.3113772
