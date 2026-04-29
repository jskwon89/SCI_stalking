## ----------------------------------------------------------------------------
## 28. Reviewer-defense tables for LCA reporting
##
## Adds compact supplemental tables requested after review:
##   1) Local-dependence summary table with sensitivity response
##   2) Class-specific AvePP/OCC table for the retained 5-class model
##   3) 3/4/5/6-class interpretability comparison table
##   4) Additional agreement checks:
##        - Primary 5-class vs Q40-only K=4
##        - Primary 5-class vs pruned-trigger K=3
##
## These are supplemental/defense tables. They do not replace the primary
## Q40+Q41 5-class situational-response profile model.
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({ library(dplyr); library(tibble); library(readr) })

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
adv  <- file.path(root, "advanced_reproducible")
out  <- file.path(adv, "_outputs")
mp_primary <- file.path(adv, "Mplus_LCA_enum")
mp_q40     <- file.path(adv, "Mplus_Q40_only_response")
mp_pruned  <- file.path(adv, "Mplus_pruned_trigger_LCA")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

class_labels <- c(
  "C1 Network-oriented prevention responders",
  "C2 Escalation-aware mixed responders",
  "C3 Life-threat protective responders",
  "C4 Boundary-clarification persuaders",
  "C5 Multi-action institutional responders"
)

## ---- 1. Local-dependence summary ------------------------------------------
ld <- read_csv(file.path(out, "20_local_dependence_bvr.csv"), show_col_types = FALSE)

ld_summary <- ld %>%
  filter(flag_bvr_gt_3_84 | p_fdr_BH < .05) %>%
  arrange(desc(bvr_chisq)) %>%
  mutate(
    pair = paste0(item1, " (", label1, ") x ", item2, " (", label2, ")"),
    FDR_flag = p_fdr_BH < .05,
    sensitivity_response = case_when(
      item1 %in% c("Q41_2", "Q41_3") | item2 %in% c("Q41_2", "Q41_3") ~
        "Addressed by pruned-trigger LCA removing Q41_2 and Q41_3",
      TRUE ~
        "Reported as residual local dependence; retained for theoretical coherence"
    ),
    manuscript_use = case_when(
      FDR_flag ~ "Report in local-dependence supplemental table and mention in limitations",
      TRUE ~ "Supplemental diagnostic only"
    )
  ) %>%
  transmute(
    item1, label1, item2, label2, pair, n_pair,
    BVR = round(bvr_chisq, 3),
    p_value = signif(p_value, 3),
    p_FDR = signif(p_fdr_BH, 3),
    FDR_flag,
    max_abs_std_resid = round(max_abs_std_resid, 3),
    sensitivity_response,
    manuscript_use
  )

write_csv(ld_summary, file.path(out, "28_local_dependence_summary.csv"))

## ---- 2. AvePP/OCC by class for selected K=5 -------------------------------
ave <- read_csv(file.path(out, "23_avepp_by_class.csv"), show_col_types = FALSE)

avepp_occ_5 <- ave %>%
  filter(K == 5) %>%
  mutate(
    class_label = class_labels[class],
    modal_n = round(modal_prop * 501),
    modal_pct = 100 * modal_prop,
    classification_note = case_when(
      AvePP >= .90 ~ "Excellent AvePP",
      AvePP >= .80 ~ "Acceptable AvePP",
      TRUE ~ "Low AvePP"
    ),
    OCC_note = case_when(
      OCC >= 20 ~ "Strong OCC",
      OCC >= 5 ~ "Acceptable OCC",
      TRUE ~ "Weak OCC"
    )
  ) %>%
  transmute(
    K, class, class_label, modal_n,
    modal_pct = round(modal_pct, 1),
    AvePP = round(AvePP, 3),
    OCC = round(OCC, 2),
    classification_note,
    OCC_note
  )

write_csv(avepp_occ_5, file.path(out, "28_avepp_occ_5class.csv"))

## ---- 3. 3/4/5/6-class interpretability comparison -------------------------
fit <- read_csv(file.path(out, "23_lca_extended_fit_table.csv"), show_col_types = FALSE)
fit_sub <- fit %>% filter(K %in% 3:6)

class_compare <- fit_sub %>%
  mutate(
    information_criterion_signal = case_when(
      K == 3 ~ "Favored by BIC/CAIC; parsimonious benchmark",
      K == 4 ~ "Intermediate; no information-criterion minimum",
      K == 5 ~ "Not IC minimum; retained by classification quality and interpretability",
      K == 6 ~ "Favored by AIC/aBIC but not BIC/CAIC/AWE"
    ),
    interpretability_summary = case_when(
      K == 3 ~ "Coarse solution; collapses several active-response pathways and loses institutional gatekeeping detail",
      K == 4 ~ "Adds differentiation but does not cleanly separate the boundary-clarification and institutional-entry contrast",
      K == 5 ~ "Primary solution; separates network/prevention, escalation-aware mixed, life-threat protective, boundary-clarification, and multi-action institutional profiles",
      K == 6 ~ "Adds complexity without a clear additional policy target; LMR is non-significant"
    ),
    limitation = case_when(
      K == 3 ~ "Too coarse for the manuscript's policy targeting claim",
      K == 4 ~ "LMR non-significant and lower classification clarity than K=5",
      K == 5 ~ "Requires explicit justification because ICs are split",
      K == 6 ~ "More complex and less parsimonious; smaller classes and no clear theoretical gain"
    ),
    manuscript_role = case_when(
      K == 5 ~ "Primary model",
      TRUE ~ "Full reporting in supplement"
    )
  ) %>%
  transmute(
    K,
    AIC = round(AIC, 1), BIC = round(BIC, 1), aBIC = round(aBIC, 1),
    CAIC = round(CAIC, 1), AWE = round(AWE, 1),
    entropy = round(Entropy, 3),
    smallest_class_pct = round(100 * smallest_class, 1),
    AvePP_min = round(AvePP_min, 3),
    AvePP_mean = round(AvePP_mean, 3),
    OCC_min = round(OCC_min, 2),
    LMR_p = signif(LMR_p, 3),
    information_criterion_signal,
    interpretability_summary,
    limitation,
    manuscript_role
  )

write_csv(class_compare, file.path(out, "28_class_solution_interpretability.csv"))

## ---- 4. Additional agreement checks ---------------------------------------
read_modal <- function(file, k, labels = NULL) {
  stopifnot(file.exists(file), file.info(file)$size > 0)
  d <- read.table(file, header = FALSE)
  modal <- as.integer(d[, ncol(d)])
  if (length(modal) != 501) stop("Unexpected N in ", file, ": ", length(modal))
  if (is.null(labels)) labels <- paste0("C", 1:k)
  factor(modal, levels = 1:k, labels = labels)
}

cramers_v <- function(x, y) {
  tab <- table(x, y)
  chi <- suppressWarnings(chisq.test(tab, correct = FALSE))
  n <- sum(tab)
  denom <- n * (min(nrow(tab), ncol(tab)) - 1)
  if (denom <= 0) return(NA_real_)
  as.numeric(sqrt(chi$statistic / denom))
}

adjusted_rand_index <- function(x, y) {
  tab <- table(x, y)
  choose2 <- function(z) z * (z - 1) / 2
  n <- sum(tab)
  sum_comb <- sum(choose2(tab))
  row_comb <- sum(choose2(rowSums(tab)))
  col_comb <- sum(choose2(colSums(tab)))
  total_comb <- choose2(n)
  expected <- row_comb * col_comb / total_comb
  max_index <- 0.5 * (row_comb + col_comb)
  denom <- max_index - expected
  if (abs(denom) < 1e-12) return(NA_real_)
  as.numeric((sum_comb - expected) / denom)
}

ari_label <- function(x) {
  if (is.na(x)) return(NA_character_)
  if (x >= .80) return("very high agreement")
  if (x >= .60) return("substantial agreement")
  if (x >= .40) return("moderate agreement")
  "limited agreement"
}

write_cross <- function(primary, sensitivity, file) {
  tab <- as.data.frame.matrix(table(primary = primary, sensitivity = sensitivity))
  tab$primary_class <- rownames(tab)
  tab <- tab[, c("primary_class", setdiff(names(tab), "primary_class"))]
  write_csv(tab, file)
  tab
}

primary5 <- read_modal(file.path(mp_primary, "enum_5class.dat"), 5, class_labels)
q40_k4 <- read_modal(file.path(mp_q40, "q40only_4class.dat"), 4,
                     paste0("Q40-only K4 C", 1:4))
pruned_k3 <- read_modal(file.path(mp_pruned, "pruned_3class.dat"), 3,
                        paste0("Pruned-trigger K3 C", 1:3))

cross_q40_k4 <- write_cross(
  primary5, q40_k4,
  file.path(out, "28_primary_q40only_k4_agreement.csv")
)
cross_pruned_k3 <- write_cross(
  primary5, pruned_k3,
  file.path(out, "28_primary_pruned_k3_agreement.csv")
)

alt_agree <- tibble(
  comparison = c("Primary 5-class vs Q40-only K=4",
                 "Primary 5-class vs pruned-trigger K=3"),
  n = 501,
  cramer_V = c(cramers_v(primary5, q40_k4),
               cramers_v(primary5, pruned_k3)),
  ARI = c(adjusted_rand_index(primary5, q40_k4),
          adjusted_rand_index(primary5, pruned_k3))
) %>%
  mutate(
    cramer_V = round(cramer_V, 3),
    ARI = round(ARI, 3),
    ARI_interpretation = vapply(ARI, ari_label, character(1)),
    manuscript_interpretation = c(
      "Behavior-only K=4 shows whether broad action axes remain visible without trigger items; not a replacement primary solution",
      "Pruned K=3 is a parsimonious local-dependence sensitivity; useful to show what is collapsed when trigger pairs are removed"
    )
  )

write_csv(alt_agree, file.path(out, "28_alt_solution_agreement_metrics.csv"))

## ---- Summary --------------------------------------------------------------
sink(file.path(out, "28_review_defense_summary.md"))
cat("# Reviewer-Defense Tables\n\n")
cat("These tables supplement the primary Q40+Q41 5-class situational-response profile model.\n\n")
cat("## Local-dependence summary\n\n")
print(as.data.frame(ld_summary), row.names = FALSE, right = FALSE)
cat("\n## Class-specific AvePP/OCC for selected 5-class model\n\n")
print(as.data.frame(avepp_occ_5), row.names = FALSE, right = FALSE)
cat("\n## 3/4/5/6-class interpretability comparison\n\n")
print(as.data.frame(class_compare), row.names = FALSE, right = FALSE)
cat("\n## Additional agreement metrics\n\n")
print(as.data.frame(alt_agree), row.names = FALSE, right = FALSE)
cat("\n## Narrative to use\n\n")
cat("The sensitivity checks do not aim to reproduce the exact primary class labels. ")
cat("Instead, they show what is lost when trigger/risk-recognition items are excluded or pruned. ")
cat("Q40-only and pruned-trigger alternatives support retaining the primary model as a situational-response profile model, ")
cat("while documenting local-dependence and information-criterion trade-offs transparently.\n")
sink()

cat("Wrote:\n",
    file.path(out, "28_local_dependence_summary.csv"), "\n",
    file.path(out, "28_avepp_occ_5class.csv"), "\n",
    file.path(out, "28_class_solution_interpretability.csv"), "\n",
    file.path(out, "28_alt_solution_agreement_metrics.csv"), "\n",
    file.path(out, "28_primary_q40only_k4_agreement.csv"), "\n",
    file.path(out, "28_primary_pruned_k3_agreement.csv"), "\n",
    file.path(out, "28_review_defense_summary.md"), "\n")
