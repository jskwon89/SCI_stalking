# Approximate Local-Dependence Diagnostics

Selected model: 5-class responder LCA. Diagnostic: binary item-pair BVR from observed vs model-implied two-way tables.

Pairs checked: 91 

Pairs with BVR > 3.84: 11 

Pairs with FDR q < .05: 3 

## Top 15 item pairs

   item1 item2           label1           label2 n_pair bvr_chisq      p_value
1  Q40_2 Q41_2         Persuade       Escalation    501 17.951288 2.266311e-05
2  Q40_3 Q41_3  Job/school exit    Others harmed    501 13.364288 2.564612e-04
3  Q41_2 Q41_5       Escalation Daily disruption    501  9.953861 1.605124e-03
4  Q41_3 Q41_5    Others harmed Daily disruption    501  8.050368 4.549442e-03
5  Q40_7 Q41_2           Police       Escalation    501  7.832166 5.132456e-03
6  Q40_1 Q41_2         Confront       Escalation    501  7.737732 5.407869e-03
7  Q40_4 Q41_3     Shelter/move    Others harmed    501  7.362375 6.660277e-03
8  Q40_5 Q41_3 School/work help    Others harmed    501  7.048561 7.932896e-03
9  Q40_2 Q40_3         Persuade  Job/school exit    501  5.246699 2.198845e-02
10 Q40_4 Q40_6     Shelter/move     Network help    501  4.701975 3.012797e-02
11 Q40_4 Q41_5     Shelter/move Daily disruption    501  4.133339 4.204632e-02
12 Q40_3 Q40_7  Job/school exit           Police    501  3.695335 5.456482e-02
13 Q40_2 Q40_5         Persuade School/work help    501  3.680959 5.503720e-02
14 Q40_5 Q41_5 School/work help Daily disruption    501  3.482643 6.201560e-02
15 Q40_1 Q40_6         Confront     Network help    501  3.335541 6.779810e-02
   max_abs_std_resid    p_fdr_BH flag_bvr_gt_3_84
1           2.750858 0.002062343             TRUE
2           2.619989 0.011668985             TRUE
3           2.071469 0.048688767             TRUE
4           1.928240 0.082019348             TRUE
5           2.035031 0.082019348             TRUE
6           1.895796 0.082019348             TRUE
7           2.084810 0.086583596             TRUE
8           2.040505 0.090236688             TRUE
9           1.667349 0.222327663             TRUE
10          1.657843 0.274164520             TRUE
11          1.609988 0.347837701             TRUE
12          1.518866 0.385260365            FALSE
13          1.430562 0.385260365            FALSE
14          1.445586 0.403101431            FALSE
15          1.260624 0.411308472            FALSE

Interpretation: large BVRs identify item pairs that may retain residual association after conditioning on class membership. Use this as a screening sensitivity check; if the same pairs are theoretically redundant, combine or discuss them.
