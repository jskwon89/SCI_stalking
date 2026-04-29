# Pruned-Trigger LCA Sensitivity

Sample: active responders only, N = 501 

Indicators: Q40_1..Q40_8 + Q41_1, Q41_4, Q41_5, Q41_6.

Removed trigger items: Q41_2 (Escalation), Q41_3 (Others harmed), because they were involved in top local-dependence BVR pairs.

## Fit table

# A tibble: 5 × 13
      K     LL  npar   AIC   BIC  aBIC Entropy smallest_class  LMR_p BLRT_p
  <int>  <dbl> <dbl> <dbl> <dbl> <dbl>   <dbl>          <dbl>  <dbl>  <dbl>
1     2 -3108.    25 6266. 6371. 6292.   0.779         0.190  0           0
2     3 -3049.    38 6173. 6334. 6213.   0.672         0.214  0.0003      0
3     4 -3012.    51 6125. 6340. 6178.   0.689         0.0921 0.360       0
4     5 -2985.    64 6097. 6367. 6164.   0.759         0.0935 0.142       0
5     6 -2958.    77 6069. 6394. 6150.   0.801         0.0848 0.364       0
# ℹ 3 more variables: BLRT_draws <int>, CAIC <dbl>, AWE <dbl>

## 5-class item-response probabilities

   K class item prob_yes item_full           item_label
1  5     1   a1    0.248     Q40_1             Confront
2  5     1   a2    0.149     Q40_2             Persuade
3  5     1   a3    0.087     Q40_3      Job/school exit
4  5     1   a4    0.015     Q40_4         Shelter/move
5  5     1   a5    0.063     Q40_5     School/work help
6  5     1   a6    0.552     Q40_6         Network help
7  5     1   a7    0.293     Q40_7               Police
8  5     1   a8    0.111     Q40_8    Agency counseling
9  5     1   b1    0.222     Q41_1          Not romance
10 5     1   b4    0.051     Q41_4          Life threat
11 5     1   b5    0.164     Q41_5     Daily disruption
12 5     1   b6    0.574     Q41_6 Prevent another harm
13 5     2   a1    0.362     Q40_1             Confront
14 5     2   a2    0.410     Q40_2             Persuade
15 5     2   a3    0.386     Q40_3      Job/school exit
16 5     2   a4    0.285     Q40_4         Shelter/move
17 5     2   a5    0.412     Q40_5     School/work help
18 5     2   a6    0.662     Q40_6         Network help
19 5     2   a7    0.291     Q40_7               Police
20 5     2   a8    0.627     Q40_8    Agency counseling
21 5     2   b1    0.572     Q41_1          Not romance
22 5     2   b4    0.563     Q41_4          Life threat
23 5     2   b5    0.708     Q41_5     Daily disruption
24 5     2   b6    0.291     Q41_6 Prevent another harm
25 5     3   a1    0.076     Q40_1             Confront
26 5     3   a2    1.000     Q40_2             Persuade
27 5     3   a3    0.117     Q40_3      Job/school exit
28 5     3   a4    0.130     Q40_4         Shelter/move
29 5     3   a5    0.234     Q40_5     School/work help
30 5     3   a6    0.239     Q40_6         Network help
31 5     3   a7    0.085     Q40_7               Police
32 5     3   a8    0.000     Q40_8    Agency counseling
33 5     3   b1    0.103     Q41_1          Not romance
34 5     3   b4    0.542     Q41_4          Life threat
35 5     3   b5    0.189     Q41_5     Daily disruption
36 5     3   b6    0.000     Q41_6 Prevent another harm
37 5     4   a1    0.183     Q40_1             Confront
38 5     4   a2    0.000     Q40_2             Persuade
39 5     4   a3    0.438     Q40_3      Job/school exit
40 5     4   a4    0.340     Q40_4         Shelter/move
41 5     4   a5    0.162     Q40_5     School/work help
42 5     4   a6    0.119     Q40_6         Network help
43 5     4   a7    0.214     Q40_7               Police
44 5     4   a8    0.076     Q40_8    Agency counseling
45 5     4   b1    0.070     Q41_1          Not romance
46 5     4   b4    0.391     Q41_4          Life threat
47 5     4   b5    0.332     Q41_5     Daily disruption
48 5     4   b6    0.005     Q41_6 Prevent another harm
49 5     5   a1    0.573     Q40_1             Confront
50 5     5   a2    0.625     Q40_2             Persuade
51 5     5   a3    0.123     Q40_3      Job/school exit
52 5     5   a4    0.111     Q40_4         Shelter/move
53 5     5   a5    0.037     Q40_5     School/work help
54 5     5   a6    0.188     Q40_6         Network help
55 5     5   a7    0.000     Q40_7               Police
56 5     5   a8    0.000     Q40_8    Agency counseling
57 5     5   b1    0.927     Q41_1          Not romance
58 5     5   b4    0.000     Q41_4          Life threat
59 5     5   b5    0.096     Q41_5     Daily disruption
60 5     5   b6    0.043     Q41_6 Prevent another harm

## 5-class class sizes

  K class   n proportion
1 5     1 158 0.31536926
2 5     2  42 0.08383234
3 5     3  74 0.14770459
4 5     4 124 0.24750499
5 5     5 103 0.20558882
