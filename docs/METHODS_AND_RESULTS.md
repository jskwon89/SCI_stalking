# Stalking Bystander Analysis: Methods and Results

Updated: 2026-04-29  
Reproducible command: `run_all.cmd` or `Rscript run_all.R`  
Core software: R 4.4.1, Mplus 7.0

This document fixes the analytic frame for the manuscript as a **sequential bystander response framework**, not a simple behavior-only typology.

## Sequential Framework

| Stage | Analytic sample | Question | Main analysis |
|---|---:|---|---|
| Stage 1 | Witnesses, N=749 | Who takes any action, and who uses institutional pathways? | Region-adjusted logistic associations |
| Stage 2 | Active responders, N=501 | How do risk recognition, relationship interpretation, and actions combine? | Primary Q40+Q41 5-class situational-response profiles |
| Stage 3 | Non-responders N=248; non-reporting active responders N=333 | Where does response stop? | Barrier domain analysis |

Sampling weights were not applied because the original data file did not contain a weighting variable. Prevalence estimates should be interpreted as unweighted sample proportions; relative associations and class separation are the main inferential targets.

## Data and Samples

Source data: `D:/2026/SCI/Stalking/kor_data_20240048.sav`.

| Group | N | Definition |
|---|---:|---|
| Full sample | 2,500 | Seoul citizen survey respondents |
| Witnesses | 749 | Any stalking witnessing item positive |
| Active responders | 501 | Witnesses with Q40_9 != 1 |
| Non-responders | 248 | Witnesses with Q40_9 = 1 |

Key variables include DIG, prevention education (`stedu`), severe co-harm, relationship type, witnessing frequency, institutional response, police reporting, online withdrawal, support awareness, and policy awareness.

## Stage 1: Response Initiation and Institutional Pathways

Models use logistic regression with HC3 robust SEs, Firth logit for sparse outcomes, FDR-BH correction, and region fixed effects. Region cluster-robust SEs were not used because only five region clusters were available.

### Active Response Among Witnesses

| Associated factor | OR | 95% CI | FDR p |
|---|---:|---|---:|
| Prevention education (`stedu`) | 2.50 | 1.66-3.77 | 2.2e-4 |
| Severe co-harm | 2.59 | 1.71-3.94 | 2.2e-4 |
| Witnessing frequency | 1.62 | 1.25-2.09 | 3.1e-3 |
| Intimate relationship case | 2.65 | 1.53-4.56 | 3.9e-3 |
| Known non-intimate relationship | 2.40 | 1.33-4.35 | 2.6e-2 |
| DIG | About 1.00 | - | NS |

### Institutional Response

Severe co-harm and prevention education remain robustly associated with institutional response. DIG is weakly associated in the raw HC3 test (OR=1.20, raw p=.027), but **not robust after FDR correction** (q=.135). The manuscript should not state that digital exposure alone is sufficient to explain intervention.

DIG x stedu interactions are generally null or marginal and should remain robustness/supplement material.

## Stage 2: Primary LCA Among Active Responders

The primary LCA uses 14 binary indicators: Q40_1-Q40_8 response behaviors and Q41_1-Q41_6 trigger/risk-recognition items. Because the indicators combine behavior and trigger interpretation, the manuscript should use **situational-response profiles among active responders**.

### Class Enumeration

| K | LL | AIC | BIC | aBIC | Entropy | Smallest class | LMR p |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 2 | -3717 | 7492 | 7615 | 7523 | .881 | 15.9% | .0005 |
| 3 | -3639 | 7366 | 7552 | 7412 | .886 | 14.8% | .0006 |
| 4 | -3595 | 7308 | 7557 | 7369 | .822 | 14.7% | .276 |
| 5 | -3563 | 7275 | 7587 | 7352 | .879 | 14.5% | .011 |
| 6 | -3532 | 7241 | 7617 | 7334 | .873 | 10.8% | .515 |

Information criteria do not uniformly select K=5: BIC/CAIC favor K=3, AWE favors K=2, and AIC/aBIC favor K=6. The 5-class model is retained by a balanced enumeration logic: LMR rebound at K=5, entropy=.879, AvePP_min=.842, AvePP_mean=.921, OCC_min=29.90, smallest class=14.5%, no micro-class, interpretability, and policy utility.

BLRT was requested using TECH14, but bootstrap solutions were unstable under the available Mplus 7 environment; therefore BLRT is documented in `_outputs/27_blrt_attempt_log.md` and not retained as a primary enumeration criterion.

### Final Class Labels

| Class | Label | N | % |
|---:|---|---:|---:|
| C1 | Network-oriented prevention responders | 73 | 14.6 |
| C2 | Escalation-aware mixed responders | 146 | 29.1 |
| C3 | Life-threat protective responders | 96 | 19.2 |
| C4 | Boundary-clarification persuaders | 110 | 22.0 |
| C5 | Multi-action institutional responders | 76 | 15.2 |

Interpretation should emphasize that C4 represents a policy-relevant group with intervention willingness but almost no reporting, whereas C5 represents multi-channel institutional entry.

## Core Sensitivity Checks

Two sensitivity LCAs were added after reviewer feedback.

| Script | Purpose | Key output |
|---|---|---|
| `24_q40_only_response_lca.R` | Uses only Q40_1-Q40_8 behavior items | `_outputs/24_q40_only_fit.csv`, item profile, class sizes |
| `25_pruned_trigger_lca.R` | Removes Q41_2 and Q41_3 to address top local-dependence pairs | `_outputs/25_pruned_fit.csv`, item profile, class sizes |
| `26_sensitivity_agreement.R` | Compares primary vs sensitivity modal assignment | Cramer's V and ARI |
| `27_blrt_attempt_log.R` | Records TECH14/BLRT instability | `_outputs/27_blrt_attempt_log.md` |
| `28_review_defense_tables.R` | Adds reviewer-defense tables for local dependence, AvePP/OCC, class-solution comparison, and alternate agreement | `_outputs/28_review_defense_summary.md` |
| `29_missing_data_audit.R` | Documents analysis-specific Ns and variable-level missingness | `_outputs/29_missing_data_summary.md` |
| `31_class_specific_barriers.R` | Links primary classes to Q42_2 non-reporting barriers | `_outputs/31_class_specific_barriers_summary.md` |
| `32_C4_C5_focal_contrast.R` | Tests the focal C4 boundary-clarification vs C5 institutional benchmark contrast | `_outputs/32_C4_C5_focal_contrast_summary.md` |
| `33_barrier_overlap_difference.R` | Tests whether non-response and non-reporting barrier structures differ | `_outputs/33_barrier_overlap_difference_summary.md` |

Agreement metrics:

| Comparison | Cramer's V | ARI | Interpretation |
|---|---:|---:|---|
| Primary vs Q40-only | .322 | .084 | Limited modal agreement |
| Primary vs pruned-trigger | .642 | .365 | Stronger association, still limited ARI |
| Primary vs Q40-only K=4 | .329 | .072 | Limited modal agreement |
| Primary vs pruned-trigger K=3 | .713 | .270 | Strong Cramer's V, limited ARI |

The Q40-only model is not meant to reproduce the exact primary class count. It checks whether major behavioral axes remain visible without Q41 trigger items. The pruned-trigger model shows that removing Q41_2 and Q41_3 does not simply replace the primary model; rather, Q41 trigger/risk-recognition items meaningfully differentiate the primary situational-response profiles. The cross-tabs should be described as stability diagnostics: Q40-only alternatives show behavior-only axes but limited modal overlap, whereas pruned-trigger alternatives retain a stronger association with the primary model while still collapsing some situational distinctions.

## Local Dependence

`20_lca_local_dependence.R` found 11 item pairs with BVR > 3.84 and 3 pairs significant after FDR correction. The top pairs involve Q40_2 x Q41_2 and Q40_3 x Q41_3. `28_review_defense_tables.R` now writes `_outputs/28_local_dependence_summary.csv`, which explicitly lists each flagged item pair, its BVR/FDR status, and the corresponding sensitivity response. This should be reported as a modeled diagnostic, not merely as a limitation.

## Class-Solution Defense Tables

The reviewer-defense tables add two model-selection supplements:

- `_outputs/28_avepp_occ_5class.csv`: class-specific AvePP/OCC for the retained 5-class model. C1-C4 have excellent AvePP (.937-.947), and C5 remains acceptable (AvePP=.842, OCC=29.90).
- `_outputs/28_class_solution_interpretability.csv`: 3/4/5/6-class interpretability comparison. K=3 is the parsimonious BIC/CAIC benchmark, K=4 is intermediate with weaker classification clarity, K=5 is the primary policy-interpretable model, and K=6 adds complexity without a clear additional policy target.

## R3STEP and Class Validation

R3STEP class-membership associations should be described as **associated factors**, not predictors or causal effects. C5 is retained as the reference class because it is the policy benchmark for institutional entry.

Across R3STEP and modal-class validation, the class structure is mainly organized by severity, relationship context, prevention education, fear/cognition, and support/policy awareness. DIG is not robust as a class-membership separator.

Modal-class ANOVA/chi-square remains the primary external validation because manual BCH is treated as sensitivity. BCH-style outputs are retained as robustness only.

## Stage 3: Barriers

### Non-response Barriers, N=248

The dominant barrier is minimization: 71.8% of non-responders are classified in the "not serious enough" domain. This maps naturally onto the noticing/interpretation stages of the Latané-Darley model.

### Non-reporting Barriers Among Active Responders, N=333

The dominant barrier is privacy/retaliation concern (37.2%), followed by non-seriousness, evidence/legal burden, institutional distrust, and victim preference/relationship concerns. This maps onto responsibility, safety, and implementation stages.

### Class-Specific Non-reporting Barriers

`31_class_specific_barriers.R` connects Stage 2 profiles to Stage 3 reporting barriers. Non-reporting rates differ sharply by class: C4 Boundary-clarification persuaders have the highest non-reporting share (96/110, 87.3%), whereas C5 Multi-action institutional responders have a lower but still non-trivial non-reporting share (40/76, 52.6%).

Barrier endorsement among non-reporters differs by class for all main domains after FDR correction:

| Barrier domain | Omnibus p_FDR | Cramer's V | Pattern to report cautiously |
|---|---:|---:|---|
| Privacy/retaliation | .0001 | .291 | Higher in C3/C5 non-reporters than C4 |
| Evidence/legal risk | .0017 | .244 | Highest in C5 non-reporters |
| Discouraged/victim wish | .0088 | .213 | Higher in C4/C5 than C1-C3 |
| Minimization | .0241 | .191 | Highest in C1 and elevated in C4 |
| Institutional distrust | .0488 | .173 | Highest in C5 non-reporters |

This prevents overclaiming. C4's key contribution is not that one unique barrier fully explains the class; rather, C4 is the largest institutional-entry failure group. Among those who still do not report, barrier mixes vary across classes, supporting tailored policy messaging.

### C4 vs C5 Focal Contrast

`32_C4_C5_focal_contrast.R` directly contrasts C4 with C5. C5 is much more institutionally connected than C4:

| Variable | C4 | C5 | Contrast |
|---|---:|---:|---:|
| Institutional response | .073 | .776 | OR=41.00 |
| Q40 police action | .009 | .355 | OR=40.56 |
| Q42 police report | .127 | .474 | OR=6.00 |
| Severe co-harm | .418 | .737 | OR=3.82 |
| Prevention education | .509 | .711 | OR=2.34 |
| Seoul policy awareness | 1.69 | 2.49 | Mean diff=.80 |
| Support awareness | 2.86 | 3.55 | Mean diff=.70 |

This is the strongest direct evidence for the manuscript's policy benchmark narrative: C4 shows willingness to intervene without institutional entry, while C5 combines multi-action response with institutional pathways and greater support/policy awareness.

### Barrier Structure Difference

`33_barrier_overlap_difference.R` confirms that non-response and non-reporting barriers are structurally different. Non-response is dominated by minimization (71.8%), whereas non-reporting shows higher privacy/retaliation (37.2%), evidence/legal risk (27.6%), and burden/institutional distrust (27.3%). These domain differences are FDR-significant except relationship/victim-wish barriers.

## CFA, E-value, and Robustness

Categorical CFA alternatives (1F, 2F, 3F) showed poor fit (CFI <= .33), which **supports a person-centered heterogeneity approach**. This should not be written as proof that LCA is the only valid measurement model.

E-values for prevention education are retained as supplementary robustness checks only. Because the design is cross-sectional, the text should use association language throughout.

## Output Map

| Purpose | File |
|---|---|
| Q40-only sensitivity | `_outputs/24_q40_only_fit.csv`, `_outputs/24_q40_only_summary.md` |
| Pruned-trigger sensitivity | `_outputs/25_pruned_fit.csv`, `_outputs/25_pruned_summary.md` |
| Agreement metrics | `_outputs/26_sensitivity_agreement_summary.md` |
| BLRT attempt log | `_outputs/27_blrt_attempt_log.md` |
| Reviewer-defense tables | `_outputs/28_review_defense_summary.md` |
| Local-dependence summary | `_outputs/28_local_dependence_summary.csv` |
| AvePP/OCC by class | `_outputs/28_avepp_occ_5class.csv` |
| 3/4/5/6 interpretability comparison | `_outputs/28_class_solution_interpretability.csv` |
| Alternate agreement checks | `_outputs/28_alt_solution_agreement_metrics.csv` |
| Missing-data audit | `_outputs/29_missing_data_audit.csv`, `_outputs/29_analysis_sample_n.csv` |
| Class-specific non-reporting barriers | `_outputs/31_class_specific_nonreport_barriers.csv`, `_outputs/31_class_specific_barrier_tests.csv` |
| C4 vs C5 focal contrast | `_outputs/32_C4_C5_focal_contrast.csv` |
| Barrier overlap/difference | `_outputs/33_barrier_domain_difference.csv`, `_outputs/33_barrier_heatmap_data.csv` |
| Author workbook | `전달용/Stalking_Bystander_Tables.xlsx` |
| Verification | `VERIFICATION.md` |
