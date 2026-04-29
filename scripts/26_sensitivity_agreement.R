## ----------------------------------------------------------------------------
## 26. Agreement between primary and sensitivity LCA modal assignments
##
## Comparisons:
##   - Primary Q40+Q41 5-class model vs Q40-only 5-class sensitivity
##   - Primary Q40+Q41 5-class model vs pruned-trigger 5-class sensitivity
##
## Metrics:
##   - Modal cross-tabulation
##   - Cramer's V
##   - Adjusted Rand Index (ARI)
##
## ARI interpretation:
##   >= .80    very high agreement
##   .60-.79   substantial agreement
##   .40-.59   moderate agreement
##   < .40     limited agreement
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({ library(dplyr); library(tibble) })

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
adv  <- file.path(root, "advanced_reproducible")
out  <- file.path(adv, "_outputs")
primary_mp <- file.path(adv, "Mplus_LCA_enum")
q40_mp <- file.path(adv, "Mplus_Q40_only_response")
pruned_mp <- file.path(adv, "Mplus_pruned_trigger_LCA")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

read_modal <- function(file, item_cols, k) {
  stopifnot(file.exists(file), file.info(file)$size > 0)
  d <- read.table(file, header = FALSE)
  modal <- as.integer(d[, ncol(d)])
  if (length(modal) != 501) stop("Unexpected N in ", file, ": ", length(modal))
  factor(modal, levels = 1:k, labels = paste0("C", 1:k))
}

primary <- read_modal(file.path(primary_mp, "enum_5class.dat"), item_cols = 14, k = 5)
q40only <- read_modal(file.path(q40_mp, "q40only_5class.dat"), item_cols = 8, k = 5)
pruned  <- read_modal(file.path(pruned_mp, "pruned_5class.dat"), item_cols = 12, k = 5)

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

write_cross <- function(x, y, file) {
  tab <- as.data.frame.matrix(table(primary = x, sensitivity = y))
  tab$primary_class <- rownames(tab)
  tab <- tab[, c("primary_class", setdiff(names(tab), "primary_class"))]
  write.csv(tab, file, row.names = FALSE)
  tab
}

cross_q40 <- write_cross(primary, q40only, file.path(out, "26_primary_q40only_agreement.csv"))
cross_pruned <- write_cross(primary, pruned, file.path(out, "26_primary_pruned_agreement.csv"))

summary_tbl <- tibble(
  comparison = c("Primary 5-class vs Q40-only 5-class",
                 "Primary 5-class vs pruned-trigger 5-class"),
  n = c(length(primary), length(primary)),
  cramer_V = c(cramers_v(primary, q40only), cramers_v(primary, pruned)),
  ARI = c(adjusted_rand_index(primary, q40only),
          adjusted_rand_index(primary, pruned))
) %>%
  mutate(cramer_V = round(cramer_V, 3),
         ARI = round(ARI, 3),
         ARI_interpretation = vapply(ARI, ari_label, character(1)))

write.csv(summary_tbl, file.path(out, "26_sensitivity_agreement_metrics.csv"), row.names = FALSE)

sink(file.path(out, "26_sensitivity_agreement_summary.md"))
cat("# Sensitivity Agreement Metrics\n\n")
cat("Comparisons use modal assignments for N = 501 active responders.\n\n")
cat("ARI cutoffs were defined before inspecting results: >=.80 very high, .60-.79 substantial, .40-.59 moderate, <.40 limited agreement.\n\n")
cat("## Metrics\n\n")
print(summary_tbl)
cat("\n## Primary vs Q40-only cross-tab\n\n")
print(cross_q40)
cat("\n## Primary vs pruned-trigger cross-tab\n\n")
print(cross_pruned)
cat("\nInterpretation: exact class-number or label replication was not required. The sensitivity question is whether the broad response axes remain visible when trigger items are excluded or pruned.\n")
sink()

cat("Wrote:\n",
    file.path(out, "26_primary_q40only_agreement.csv"), "\n",
    file.path(out, "26_primary_pruned_agreement.csv"), "\n",
    file.path(out, "26_sensitivity_agreement_metrics.csv"), "\n",
    file.path(out, "26_sensitivity_agreement_summary.md"), "\n")
