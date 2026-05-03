# 38. Dyad × Intimate cross-tab WITHIN each latent class

- Date: 2026-05-04
- Source: 5-class LCA, modal-class assignment (Mplus R3STEP; entropy .879, avepp .921)
- N = 501 (responder)

## Definitions
- dyad: Q35 victim × Q36 perpetrator (5 categories incl. 미상; same as script 37)
- intimate: Q34 ∈ {1..7} (current/former intimate partner; same as script 10)
- same-sex: dyad ∈ {남성-남성, 여성-여성}

## Question this answers
How much do the 'intimate-relationship' cases and the 'same-sex' cases overlap *within* a class?
Specifically: among intimate cases in C3, what share are same-sex?

## Files
- `38_dyad_intimate_by_class_count.csv`     — long: class, dyad(5), intimate(0/1), n
- `38_dyad_intimate_by_class_combined.csv`  — display: rows = dyad×intimate (10), cols = C1..C5
- `38_intimate_share_by_class.csv`          — per-class % intimate, % same-sex, P(same-sex | intimate)
- `38_within_class_independence.csv`        — per class: 5×2 χ²+Fisher MC, 2×2 OR(95% CI)+Fisher

## Test choice
- Pearson χ² reported but several cells have expected < 5 in some classes → primary inference uses Fisher exact (Monte Carlo, B=20000) for 5×2; exact Fisher for 2×2.

## Manuscript footer
> Within each latent class, dyadic gender composition (Q35×Q36) was cross-tabulated against intimate-partner status (Q34 ∈ 1..7). Independence within class was tested with Pearson χ² (5×2) and Fisher exact (Monte Carlo, B=20000) given cell sparsity; the same-sex/other × intimate/non-intimate 2×2 also reports an odds ratio with 95% CI. The proportion of same-sex cases within intimate cases is reported per class to characterize the overlap of relational context and gender composition.
