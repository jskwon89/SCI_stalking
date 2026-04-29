## ----------------------------------------------------------------------------
## 30. Build publication-ready tables for the manuscript author.
##   Strategy (per user request):
##     - Consolidate similar analyses into multi-sheet Excel workbooks
##     - Minimize file count
##   Output (in 전달용/):
##     1. Stalking_Bystander_Tables.xlsx   (single workbook, ~12 sheets)
##     2. README_for_author.md             (sheet description + how to read)
##     3. figures/                         (key figures only)
##     4. raw_outputs/                     (full raw CSV backup, optional)
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(tibble); library(readr); library(openxlsx)
})

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
out   <- file.path(root, "advanced_reproducible", "_outputs")
del   <- file.path(root, "advanced_reproducible", "전달용")
del_f <- file.path(del, "figures")
dir.create(del, recursive = TRUE, showWarnings = FALSE)
dir.create(del_f, recursive = TRUE, showWarnings = FALSE)

machine_labels <- c("Network_oriented_prevention","Escalation_aware_mixed",
                    "Life_threat_protective","Boundary_clarification",
                    "Multi_action_institutional")
class_labels <- c("C1 Network-oriented prevention responders",
                  "C2 Escalation-aware mixed responders",
                  "C3 Life-threat protective responders",
                  "C4 Boundary-clarification persuaders",
                  "C5 Multi-action institutional responders")

pretty_class_text <- function(x) {
  repl <- setNames(class_labels, machine_labels)
  for (nm in names(repl)) x <- gsub(nm, repl[[nm]], x, fixed = TRUE)
  x
}

## ---- Build sheets ----------------------------------------------------------
shared <- file.path(root, "advanced_reproducible", "_shared")
w <- readRDS(file.path(shared, "data_witness.rds"))
r <- readRDS(file.path(shared, "data_responder.rds"))

sheet_S1_sample <- tibble(
  Group = c("All witnesses","Active responders","Non-responders"),
  N     = c(nrow(w), sum(w$active_response == 1), sum(w$active_response == 0)),
  `Pct of witnesses` = c(100,
                         round(100 * sum(w$active_response == 1)/nrow(w), 1),
                         round(100 * sum(w$active_response == 0)/nrow(w), 1))
)

sheet_S2_lca_fit <- read_csv(file.path(out, "23_lca_extended_fit_table.csv"), show_col_types = FALSE) %>%
  select(K, LL, npar, AIC, BIC, aBIC, CAIC, AWE, Entropy, smallest_class,
         AvePP_min, AvePP_mean, OCC_min, LMR_p, BLRT_p, BLRT_draws) %>%
  mutate(across(c(LL, AIC, BIC, aBIC, CAIC, AWE), \(x) round(x, 1)),
         across(c(Entropy, smallest_class, AvePP_min, AvePP_mean), \(x) round(x, 3)),
         OCC_min = round(OCC_min, 2),
         LMR_p   = signif(LMR_p, 3),
         BLRT_p  = signif(BLRT_p, 3),
         note_BLRT = ifelse(BLRT_draws < 30,
                            "Unreliable (Mplus 7.0 limit, draws<30) - exclude from main text",
                            "ok"))

sheet_S3_item_response <- read_csv(file.path(out, "19_item_response_5class_wide.csv"),
                                    show_col_types = FALSE)
names(sheet_S3_item_response)[3:7] <- class_labels

sheet_S4_3vs5 <- read_csv(file.path(out, "19_3class_vs_5class_crosstab.csv"),
                           show_col_types = FALSE) %>%
  mutate(across(where(is.character), pretty_class_text))

## Logistic OR (HC3, region adjusted)
glm_all <- read_csv(file.path(out, "11_logistic_robust_all.csv"), show_col_types = FALSE)
key_terms <- c("stedu","dig","severe_coharm","intimate","known_nonint","freq_ord_z",
               "threat","crime_denial_z","fear_z","seoul_policy_awareness_z",
               "support_awareness_z","gender_awareness_z","gender_hierarchy_z",
               "victim_blaming_z","stereotype_z","cjs_distrust_z","female","college",
               "married","employed","one_person","disability","own_victim","gendered_case",
               "offcnt")
sheet_S5_logistic <- glm_all %>%
  filter(model == "logit_HC3", term %in% key_terms) %>%
  mutate(OR = round(OR, 3), OR_lo = round(OR_lo, 3), OR_hi = round(OR_hi, 3),
         p_raw = signif(p.value, 3), p_FDR = signif(p_fdr_BH, 3),
         sig = case_when(p_FDR < 0.001 ~ "***",
                         p_FDR < 0.01  ~ "**",
                         p_FDR < 0.05  ~ "*",
                         p_FDR < 0.10  ~ "†",
                         TRUE          ~ "")) %>%
  select(outcome, term, OR, OR_lo, OR_hi, p_raw, p_FDR, sig) %>%
  arrange(outcome, term)

sheet_S6_interaction <- read_csv(file.path(out, "11_dig_stedu_interaction.csv"),
                                  show_col_types = FALSE) %>%
  mutate(B = round(B, 3), SE_HC3 = round(SE_HC3, 3),
         p_HC3 = signif(p_HC3, 3), OR = round(OR, 3),
         LRT_chisq = round(LRT_chisq, 2), LRT_p = signif(LRT_p, 3))

## Class profile (modal-class PRIMARY)
om <- read_csv(file.path(out, "18_anova_omnibus.csv"), show_col_types = FALSE)
sheet_S7_modal_primary <- om %>%
  filter(p_fdr < 0.05) %>%
  select(variable, type, p_main, p_fdr, sig, eta_sq, cramer_V, per_class) %>%
  mutate(p_main = signif(p_main, 3), p_fdr = signif(p_fdr, 3),
         eta_sq = round(eta_sq, 3), cramer_V = round(cramer_V, 3),
         per_class = pretty_class_text(per_class)) %>%
  arrange(type, p_fdr)

## Class profile (BCH SENSITIVITY)
prof <- read_csv(file.path(out, "17_class_profile_table.csv"), show_col_types = FALSE)
sheet_S8_bch_sens <- prof %>%
  filter(p_fdr < 0.05) %>%
  select(variable, type, overall_mean, p_overall, p_fdr, sig,
         all_of(paste0(machine_labels, "_mean"))) %>%
  mutate(p_overall = signif(p_overall, 3), p_fdr = signif(p_fdr, 3))
names(sheet_S8_bch_sens)[7:11] <- class_labels

## R3STEP class-membership associations
mp_r3 <- file.path(root, "advanced_reproducible", "Mplus_responder_LCA_R3STEP")
r3file <- file.path(mp_r3, "responder_lca_5class_r3step.out")
L <- readLines(r3file, warn = FALSE)
parse_r3step <- function() {
  start <- grep("TESTS OF CATEGORICAL LATENT VARIABLE MULTINOMIAL", L)[1]
  if (is.na(start)) return(tibble())
  end <- grep("Parameterization using Reference Class 1", L)[1] - 1
  blk <- L[start:end]
  recs <- list(); cur_class <- NA
  for (i in seq_along(blk)) {
    m <- regmatches(blk[i], regexec("^\\s*C#([0-9]+)\\s+ON", blk[i]))[[1]]
    if (length(m) > 1) { cur_class <- as.integer(m[2]); next }
    parts <- strsplit(trimws(blk[i]), "\\s+")[[1]]
    if (length(parts) == 5 && !is.na(suppressWarnings(as.numeric(parts[2])))) {
      recs[[length(recs)+1]] <- data.frame(
        ref_class    = "C5 Multi-action institutional responders (reference)",
        target_class = paste0("C#", cur_class),
        associated_factor = parts[1],
        Estimate     = as.numeric(parts[2]),
        SE           = as.numeric(parts[3]),
        Est_SE       = as.numeric(parts[4]),
        P_value      = as.numeric(parts[5])
      )
    }
  }
  bind_rows(recs)
}
sheet_S9_r3step <- parse_r3step()
if (nrow(sheet_S9_r3step) > 0) {
  sheet_S9_r3step <- sheet_S9_r3step %>%
    mutate(OR = round(exp(Estimate), 3),
           sig = case_when(P_value < 0.001 ~ "***",
                           P_value < 0.01  ~ "**",
                           P_value < 0.05  ~ "*",
                           P_value < 0.10  ~ "†",
                           TRUE            ~ ""))
}

sheet_S10_mediation <- read_csv(file.path(out, "12_moderated_mediation_summary.csv"),
                                 show_col_types = FALSE)
sheet_S10b_evalue   <- read_csv(file.path(out, "12_evalue_table.csv"),
                                 show_col_types = FALSE)

sheet_S11_cfa <- tibble(
  Model = c("1-factor","2-factor (response, trigger)","3-factor (institutional, private, trigger)"),
  CFI   = c(0.302, 0.326, 0.322),
  TLI   = c(0.175, 0.193, 0.166),
  RMSEA = c(0.085, 0.084, 0.086),
  RMSEA_90CI = c("[0.076, 0.094]","[0.075, 0.093]","[0.077, 0.095]"),
  Decision = "Below conventional cutoffs (CFI >= .95, RMSEA <= .06)",
  Note  = "CFA non-fit supports a person-centered heterogeneity approach"
)

b1 <- read_csv(file.path(out, "22_nonresponse_barrier_domains.csv"), show_col_types = FALSE) %>%
  mutate(population = "Q43 non-responders (N=248)") %>%
  select(population, everything())
b2 <- read_csv(file.path(out, "22_nonreporting_barrier_domains.csv"), show_col_types = FALSE) %>%
  mutate(population = "Q42_2 non-reporting active responders (N=333)") %>%
  select(population, everything())
sheet_S12_barriers <- bind_rows(b1, b2)

sheet_S13_local_dep <- read_csv(file.path(out, "20_local_dependence_bvr.csv"),
                                 show_col_types = FALSE) %>%
  arrange(desc(bvr_chisq)) %>% slice_head(n = 20)

sheet_S14_policy <- read_csv(file.path(out, "21_policy_distal_omnibus.csv"),
                              show_col_types = FALSE)

sheet_S15_avepp <- read_csv(file.path(out, "23_avepp_by_class.csv"),
                             show_col_types = FALSE)

sheet_S16_q40_fit <- read_csv(file.path(out, "24_q40_only_fit.csv"), show_col_types = FALSE)
sheet_S16_q40_items <- read_csv(file.path(out, "24_q40_only_item_response.csv"), show_col_types = FALSE) %>%
  filter(K == 5)
sheet_S16_q40_sizes <- read_csv(file.path(out, "24_q40_only_class_sizes.csv"), show_col_types = FALSE) %>%
  filter(K == 5)

sheet_S17_pruned_fit <- read_csv(file.path(out, "25_pruned_fit.csv"), show_col_types = FALSE)
sheet_S17_pruned_items <- read_csv(file.path(out, "25_pruned_item_response.csv"), show_col_types = FALSE) %>%
  filter(K == 5)
sheet_S17_pruned_sizes <- read_csv(file.path(out, "25_pruned_class_sizes.csv"), show_col_types = FALSE) %>%
  filter(K == 5)

sheet_S18_agree_metrics <- read_csv(file.path(out, "26_sensitivity_agreement_metrics.csv"), show_col_types = FALSE)
sheet_S18_q40_cross <- read_csv(file.path(out, "26_primary_q40only_agreement.csv"), show_col_types = FALSE)
sheet_S18_pruned_cross <- read_csv(file.path(out, "26_primary_pruned_agreement.csv"), show_col_types = FALSE)

sheet_S19_blrt <- read_csv(file.path(out, "27_blrt_attempt_table.csv"), show_col_types = FALSE)

sheet_S20_ld_summary <- read_csv(file.path(out, "28_local_dependence_summary.csv"),
                                  show_col_types = FALSE)
sheet_S21_avepp_occ <- read_csv(file.path(out, "28_avepp_occ_5class.csv"),
                                 show_col_types = FALSE)
sheet_S22_class_compare <- read_csv(file.path(out, "28_class_solution_interpretability.csv"),
                                     show_col_types = FALSE)
sheet_S23_alt_agree_metrics <- read_csv(file.path(out, "28_alt_solution_agreement_metrics.csv"),
                                         show_col_types = FALSE)
sheet_S23_q40_k4_cross <- read_csv(file.path(out, "28_primary_q40only_k4_agreement.csv"),
                                    show_col_types = FALSE)
sheet_S23_pruned_k3_cross <- read_csv(file.path(out, "28_primary_pruned_k3_agreement.csv"),
                                       show_col_types = FALSE)

sheet_S24_sample_n <- read_csv(file.path(out, "29_analysis_sample_n.csv"),
                               show_col_types = FALSE)
sheet_S24_missing <- read_csv(file.path(out, "29_missing_data_audit.csv"),
                              show_col_types = FALSE)

sheet_S25_class_barriers <- read_csv(file.path(out, "31_class_specific_nonreport_barriers.csv"),
                                     show_col_types = FALSE)
sheet_S25_barrier_tests <- read_csv(file.path(out, "31_class_specific_barrier_tests.csv"),
                                    show_col_types = FALSE)
sheet_S25_barrier_resid <- read_csv(file.path(out, "31_class_specific_barrier_residuals.csv"),
                                    show_col_types = FALSE)

sheet_S26_c4c5 <- read_csv(file.path(out, "32_C4_C5_focal_contrast.csv"),
                           show_col_types = FALSE)

sheet_S27_barrier_diff <- read_csv(file.path(out, "33_barrier_domain_difference.csv"),
                                   show_col_types = FALSE)
sheet_S27_barrier_counts <- read_csv(file.path(out, "33_barrier_domain_counts.csv"),
                                     show_col_types = FALSE)
sheet_S27_barrier_heatmap <- read_csv(file.path(out, "33_barrier_heatmap_data.csv"),
                                      show_col_types = FALSE)
sheet_S27_barrier_overlap <- read_csv(file.path(out, "33_barrier_overlap_pairs.csv"),
                                      show_col_types = FALSE)

## --- Cover sheet (table directory) -----------------------------------------
cover <- tibble(
  Sheet = c("S1_Sample","S2_LCA_fit","S3_Item_response","S4_3vs5_crosstab",
            "S5_Logistic_OR","S6_DIGxStedu_interaction","S7_Class_profile_PRIMARY",
            "S8_Class_profile_BCH_sens","S9_R3STEP_associations",
            "S10_Mediation","S10b_Evalue","S11_CFA_nonfit","S12_Barriers",
            "S13_Local_dependence","S14_Policy_distals","S15_AvePP_by_class",
            "S16_Q40_only","S17_Pruned_trigger","S18_Agreement","S19_BLRT_attempt",
            "S20_LD_summary","S21_AvePP_OCC_5class","S22_Class_solution_compare",
            "S23_Alt_agreement","S24_Missing_audit","S25_Class_barriers",
            "S26_C4_C5_contrast","S27_Barrier_difference"),
  Description = c(
    "Sample composition: witnesses (749), active responders (501), non-responders (248)",
    "LCA fit indices k=2..6 (AIC/BIC/aBIC/CAIC/AWE/Entropy/AvePP/OCC/LMR; BLRT excluded due to Mplus 7.0 limit)",
    "Item-response probabilities for 5-class solution (clean labels)",
    "Cross-tab of 3-class vs 5-class modal assignment (sensitivity, display labels harmonized)",
    "Logistic OR (HC3 robust, region-adjusted, FDR-BH); Outcomes: active/institutional/q40_police/q42_police/online_withdrawal",
    "DIG x stedu interaction (LRT) by outcome",
    "Class profile by modal-class ANOVA/Welch/chi-square (PRIMARY)",
    "Class profile by BCH-weighted means (SENSITIVITY); binary [0,1] clipped",
    "R3STEP class-membership associated factors (reference class = C5)",
    "Moderated mediation (lavaan ML+bootstrap 5000): DIG -> serious -> institutional",
    "E-value (VanderWeele 2017) for stedu association robustness",
    "Categorical CFA (1F/2F/3F) - all below cutoffs, supports a person-centered heterogeneity approach",
    "Q43 non-response (N=248) and Q42_2 non-reporting (N=333) barrier domains",
    "Local-dependence BVR diagnostics, top 20 item pairs",
    "Policy and bystander-role distal outcomes by class (chi-sq, FDR)",
    "Average posterior probability (AvePP) and OCC by class for k=2..6",
    "Q40-only response LCA sensitivity: fit, 5-class item probabilities, class sizes",
    "Pruned-trigger LCA sensitivity: fit, 5-class item probabilities, class sizes",
    "Primary vs sensitivity class-assignment agreement: cross-tabs, Cramer's V, ARI",
    "Mplus TECH14/BLRT attempt log and bootstrap draw counts",
    "Reviewer-defense local-dependence summary: BVR, FDR flag, and sensitivity response",
    "Class-specific AvePP and OCC for the retained 5-class model",
    "3/4/5/6-class interpretability comparison for defending the K=5 choice",
    "Additional agreement checks: primary 5-class vs Q40-only K=4 and pruned-trigger K=3",
    "Missing-data audit and analysis-specific Ns for Stage 1/2/3",
    "Class-specific Q42_2 non-reporting barriers among active responders",
    "Focused C4 vs C5 contrast for the boundary-to-institutional-entry narrative",
    "Barrier overlap and non-response vs non-reporting domain difference tests"
  ),
  Notes = c(
    "Witnesses = Q31L/R/Q32L/R any 1; Responders = Q40_9 != 1",
    "Selected K=5: LMR rebound + entropy=.879 + AvePP_min=.842/AvePP_mean=.921 + OCC_min=29.90 + smallest class=14.5% + interpretability/policy utility",
    "Used to label classes; see README for class labels",
    "3-class is a coarser partition; the life-threat protective and multi-action institutional pathways are not separated cleanly",
    "Region (5 levels) added as fixed effect; cluster-robust SE not used (K=5 too few)",
    "Most are NS or marginal; q40/q42_police only show weak negative interactions",
    "Reported in main text; eta_sq for continuous, Cramer V for binary",
    "Used as sensitivity; some BCH binary proportions clipped to [0,1]",
    "DIG NS in all contrasts (p>.14); class membership is associated with severity/relation/cognition",
    "Indirect effects NS (p=.079, .093); moderated mediation diff p=.92 (NULL)",
    "stedu association E-value 4.45-4.59; supplementary robustness only",
    "CFA non-fit supports a person-centered heterogeneity approach",
    "71.8% non-responders cite minimization; 37.2% non-reporters cite privacy/retaliation",
    "11 pairs BVR>3.84, 3 pairs FDR<.05; flag in Discussion as model limitation",
    "13 of 16 outcomes show class differences (FDR q<.05); supports policy targeting",
    "Mplus 7.0 BLRT capped at low draw counts; AvePP/OCC are alternative diagnostics",
    "Sensitivity only; class-count replication is not required, behavioral axes are the criterion",
    "Sensitivity only; removes Q41_2 and Q41_3 due to local-dependence BVR",
    "ARI cutoffs: >=.80 very high, .60-.79 substantial, .40-.59 moderate, <.40 limited",
    "BLRT not retained as a primary enumeration criterion under Mplus 7 instability",
    "Use in supplement to show which item pairs drove local-dependence concern and how pruned-trigger LCA responds",
    "Use in Methods/Results to defend classification quality beyond min/mean summary",
    "Use in supplement to show why K=5 is a substantive/policy choice despite split information criteria",
    "Use in supplement; these checks are not replacement primary models",
    "Use in Methods to document that key analyses retain expected Ns; prevalence remains unweighted",
    "Use in Results/Supplement to show that non-reporting barriers differ by situational-response profile",
    "Use as a focal supplement: C4 has low institutional entry, C5 is the institutional benchmark",
    "Use in Discussion to support two-stage barriers: minimization blocks action; privacy/retaliation/evidence/distrust block reporting"
  )
)

## --- Build workbook --------------------------------------------------------
wb <- createWorkbook()

addWorksheet(wb, "Cover")
writeData(wb, "Cover", cover, headerStyle = createStyle(textDecoration = "bold"))
setColWidths(wb, "Cover", cols = 1:3, widths = c(34, 78, 70))

add_sheet <- function(name, df) {
  addWorksheet(wb, name)
  writeData(wb, name, df, headerStyle = createStyle(textDecoration = "bold"))
  setColWidths(wb, name, cols = 1:max(1, ncol(df)), widths = "auto")
}
add_sheet("S1_Sample",                  sheet_S1_sample)
add_sheet("S2_LCA_fit",                 sheet_S2_lca_fit)
add_sheet("S3_Item_response",           sheet_S3_item_response)
add_sheet("S4_3vs5_crosstab",           sheet_S4_3vs5)
add_sheet("S5_Logistic_OR",             sheet_S5_logistic)
add_sheet("S6_DIGxStedu_interaction",   sheet_S6_interaction)
add_sheet("S7_Class_profile_PRIMARY",   sheet_S7_modal_primary)
add_sheet("S8_Class_profile_BCH_sens",  sheet_S8_bch_sens)
add_sheet("S9_R3STEP_associations",     sheet_S9_r3step)
add_sheet("S10_Mediation",              sheet_S10_mediation)
add_sheet("S10b_Evalue",                sheet_S10b_evalue)
add_sheet("S11_CFA_nonfit",             sheet_S11_cfa)
add_sheet("S12_Barriers",               sheet_S12_barriers)
add_sheet("S13_Local_dependence",       sheet_S13_local_dep)
add_sheet("S14_Policy_distals",         sheet_S14_policy)
add_sheet("S15_AvePP_by_class",         sheet_S15_avepp)

add_multi_sheet <- function(name, fit_df, item_df, size_df) {
  addWorksheet(wb, name)
  writeData(wb, name, "Fit table", startRow = 1, startCol = 1)
  writeData(wb, name, fit_df, startRow = 2, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  next_row <- nrow(fit_df) + 5
  writeData(wb, name, "5-class item-response probabilities", startRow = next_row, startCol = 1)
  writeData(wb, name, item_df, startRow = next_row + 1, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  next_row2 <- next_row + nrow(item_df) + 4
  writeData(wb, name, "5-class class sizes", startRow = next_row2, startCol = 1)
  writeData(wb, name, size_df, startRow = next_row2 + 1, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  setColWidths(wb, name, cols = 1:20, widths = "auto")
}

add_agreement_sheet <- function() {
  addWorksheet(wb, "S18_Agreement")
  writeData(wb, "S18_Agreement", "Agreement metrics", startRow = 1, startCol = 1)
  writeData(wb, "S18_Agreement", sheet_S18_agree_metrics, startRow = 2, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  r2 <- nrow(sheet_S18_agree_metrics) + 5
  writeData(wb, "S18_Agreement", "Primary vs Q40-only cross-tab", startRow = r2, startCol = 1)
  writeData(wb, "S18_Agreement", sheet_S18_q40_cross, startRow = r2 + 1, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  r3 <- r2 + nrow(sheet_S18_q40_cross) + 4
  writeData(wb, "S18_Agreement", "Primary vs pruned-trigger cross-tab", startRow = r3, startCol = 1)
  writeData(wb, "S18_Agreement", sheet_S18_pruned_cross, startRow = r3 + 1, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  setColWidths(wb, "S18_Agreement", cols = 1:12, widths = "auto")
}

add_multi_sheet("S16_Q40_only", sheet_S16_q40_fit, sheet_S16_q40_items, sheet_S16_q40_sizes)
add_multi_sheet("S17_Pruned_trigger", sheet_S17_pruned_fit, sheet_S17_pruned_items, sheet_S17_pruned_sizes)
add_agreement_sheet()
add_sheet("S19_BLRT_attempt", sheet_S19_blrt)
add_sheet("S20_LD_summary", sheet_S20_ld_summary)
add_sheet("S21_AvePP_OCC_5class", sheet_S21_avepp_occ)
add_sheet("S22_Class_solution_compare", sheet_S22_class_compare)

add_alt_agreement_sheet <- function() {
  addWorksheet(wb, "S23_Alt_agreement")
  writeData(wb, "S23_Alt_agreement", "Additional agreement metrics", startRow = 1, startCol = 1)
  writeData(wb, "S23_Alt_agreement", sheet_S23_alt_agree_metrics, startRow = 2, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  r2 <- nrow(sheet_S23_alt_agree_metrics) + 5
  writeData(wb, "S23_Alt_agreement", "Primary 5-class vs Q40-only K=4 cross-tab",
            startRow = r2, startCol = 1)
  writeData(wb, "S23_Alt_agreement", sheet_S23_q40_k4_cross, startRow = r2 + 1, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  r3 <- r2 + nrow(sheet_S23_q40_k4_cross) + 4
  writeData(wb, "S23_Alt_agreement", "Primary 5-class vs pruned-trigger K=3 cross-tab",
            startRow = r3, startCol = 1)
  writeData(wb, "S23_Alt_agreement", sheet_S23_pruned_k3_cross, startRow = r3 + 1, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  setColWidths(wb, "S23_Alt_agreement", cols = 1:12, widths = "auto")
}
add_alt_agreement_sheet()

add_missing_sheet <- function() {
  addWorksheet(wb, "S24_Missing_audit")
  writeData(wb, "S24_Missing_audit", "Analysis-specific Ns", startRow = 1, startCol = 1)
  writeData(wb, "S24_Missing_audit", sheet_S24_sample_n, startRow = 2, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  r2 <- nrow(sheet_S24_sample_n) + 5
  writeData(wb, "S24_Missing_audit", "Variable-level missingness audit", startRow = r2, startCol = 1)
  writeData(wb, "S24_Missing_audit", sheet_S24_missing, startRow = r2 + 1, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  setColWidths(wb, "S24_Missing_audit", cols = 1:12, widths = "auto")
}

add_class_barrier_sheet <- function() {
  addWorksheet(wb, "S25_Class_barriers")
  writeData(wb, "S25_Class_barriers", "Class-specific non-reporting barrier proportions",
            startRow = 1, startCol = 1)
  writeData(wb, "S25_Class_barriers", sheet_S25_class_barriers, startRow = 2, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  r2 <- nrow(sheet_S25_class_barriers) + 5
  writeData(wb, "S25_Class_barriers", "Class-by-barrier omnibus tests",
            startRow = r2, startCol = 1)
  writeData(wb, "S25_Class_barriers", sheet_S25_barrier_tests, startRow = r2 + 1, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  r3 <- r2 + nrow(sheet_S25_barrier_tests) + 4
  writeData(wb, "S25_Class_barriers", "Standardized residuals for endorsed barriers",
            startRow = r3, startCol = 1)
  writeData(wb, "S25_Class_barriers", sheet_S25_barrier_resid, startRow = r3 + 1, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  setColWidths(wb, "S25_Class_barriers", cols = 1:12, widths = "auto")
}

add_barrier_difference_sheet <- function() {
  addWorksheet(wb, "S27_Barrier_difference")
  writeData(wb, "S27_Barrier_difference", "Domain counts", startRow = 1, startCol = 1)
  writeData(wb, "S27_Barrier_difference", sheet_S27_barrier_counts, startRow = 2, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  r2 <- nrow(sheet_S27_barrier_counts) + 5
  writeData(wb, "S27_Barrier_difference", "Non-response vs non-reporting domain differences",
            startRow = r2, startCol = 1)
  writeData(wb, "S27_Barrier_difference", sheet_S27_barrier_diff, startRow = r2 + 1, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  r3 <- r2 + nrow(sheet_S27_barrier_diff) + 4
  writeData(wb, "S27_Barrier_difference", "Heatmap data", startRow = r3, startCol = 1)
  writeData(wb, "S27_Barrier_difference", sheet_S27_barrier_heatmap, startRow = r3 + 1, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  r4 <- r3 + nrow(sheet_S27_barrier_heatmap) + 4
  writeData(wb, "S27_Barrier_difference", "Barrier overlap pairs", startRow = r4, startCol = 1)
  writeData(wb, "S27_Barrier_difference", sheet_S27_barrier_overlap, startRow = r4 + 1, startCol = 1,
            headerStyle = createStyle(textDecoration = "bold"))
  setColWidths(wb, "S27_Barrier_difference", cols = 1:12, widths = "auto")
}

add_missing_sheet()
add_class_barrier_sheet()
add_sheet("S26_C4_C5_contrast", sheet_S26_c4c5)
add_barrier_difference_sheet()

xlsx_path <- file.path(del, "Stalking_Bystander_Tables.xlsx")
saveWorkbook(wb, xlsx_path, overwrite = TRUE)
cat("Wrote workbook:", xlsx_path, "\n")
cat("Sheets:", length(names(wb)), "\n")

## --- Copy a small set of key figures only ----------------------------------
fig_keep <- c(
  file.path(out, "23_lca_fit_elbow_plot.png"),
  file.path(root, "advanced_reproducible", "multiverse_outputs",
            "figure_rf_variable_importance.png"),
  file.path(root, "advanced_reproducible", "multiverse_outputs",
            "figure_network_response_trigger.png"),
  file.path(root, "advanced_reproducible", "multiverse_outputs",
            "figure_adjusted_predictions_dig_education.png"),
  file.path(root, "Figure1_프로파일플롯.png"),
  file.path(root, "Figure1_profile_plot_EN.png")
)
for (f in fig_keep) if (file.exists(f)) file.copy(f, file.path(del_f, basename(f)), overwrite = TRUE)
cat("Figures copied to:", del_f, "(", length(list.files(del_f)), "files )\n")
