# 37. Q35 × Q36 dyad cross-tabulation by latent class

- Date: 2026-05-04
- Source: 5-class LCA, modal-class assignment (Mplus R3STEP run; avepp .921, entropy .879)
- N = 501 (responder)

## Definition
- Dyad row = (Q35 피해자 성별) - (Q36 가해자 성별)
- 미상 absorbs Q35/Q36 ∈ {3=모르겠음, 4=기타, NA} on either side
- Column % computed within each class (denominator = column N)

## Class column N
- C1 = 73, C2 = 146, C3 = 96, C4 = 110, C5 = 76

## Files
- `37_q35q36_by_class_count.csv`  — 5 dyad rows × C1..C5 + Total + Total row
- `37_q35q36_by_class_pct.csv`    — column % (within class) + Overall % (within N=501)
- `37_q35q36_by_class_combined.csv` — display table (`n (col%)`) for paste-in
- `37_q35q36_chisq.csv`           — omnibus 5×5 association test (Pearson + Fisher MC)

## Note
- Pearson χ²(df=16) = 45.329, p = 0.0001235
- Fisher exact (B=20000): p = 0.00015
- Cell sparsity: min expected = 5.25, 0.0% of cells < 5

## Footer to copy into manuscript
> Among the 501 active responders, dyadic gender composition (Q35 victim ×
> Q36 perpetrator) was cross-tabulated against the 5-class latent profile
> using modal-class assignment (entropy .879). Cells report n (column %).
> Categories with Q35 or Q36 reported as 모르겠음/기타/missing were collapsed
> into 미상.
