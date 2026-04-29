# Categorical CFA — Q40 (response) + Q41 (trigger) Indicators

Sample: responders (N=501), WLSMV estimator, theta parameterization.

| Model | df | CFI | TLI | RMSEA | RMSEA 90% CI | Notes |
|---|---:|---:|---:|---:|---|---|
| 1-factor (general response) | 77 | **0.302** | **0.175** | **0.085** | 0.076–0.094 | Catastrophic fit |
| 2-factor (response, trigger) | 76 | **0.326** | **0.193** | **0.084** | 0.075–0.093 | Catastrophic fit |
| 3-factor (institutional, private, trigger) | 74 | **0.322** | **0.166** | **0.086** | 0.077–0.095 | PSI non-positive in liberal spec; cleaned spec still fails |

## Interpretation

All three CFA specifications fall well below conventional thresholds (CFI ≥ .95, TLI ≥ .95, RMSEA ≤ .06). This is an empirical confirmation that the eight bystander response items (Q40_1–Q40_8) and six trigger items (Q41_1–Q41_6) **do NOT have a coherent continuous latent-factor structure**.

This finding is methodologically important:

1. The EFA in `efa_tetrachoric_3factor.txt` (TLI = −.594, RMSEA = .648) was not a software glitch — it reflects substantive non-factor structure of the data.
2. The categorical latent-class (LCA) approach used in the main analysis is the **correct measurement model** for these items: bystander responses are heterogeneous *categorical patterns* (e.g., direct confrontation vs. agency referral vs. network help) rather than positions on a continuous severity scale.
3. CFA / SEM-based mediation should be reported as Linear Probability Model (LPM) approximations only, with proper LPM caveats.

## Implication for the paper

Replace the EFA section with this CFA "non-fit" report and frame it as **measurement-model justification for LCA**, not as a measurement model in its own right.

Recommended single sentence in the methods:
> "Confirmatory factor models on the eight response and six trigger items (1-, 2-, 3-factor solutions, WLSMV, theta parameterization) all yielded poor fit (CFI ≤ .33, TLI ≤ .19, RMSEA ≥ .08), indicating that the items do not form a coherent continuous latent-factor structure and supporting a categorical latent-class measurement model."
