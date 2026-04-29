## ----------------------------------------------------------------------------
## 18. Classical post-LCA comparisons: ANOVA / Welch / Kruskal-Wallis / chi-square
##   with Tukey HSD or Bonferroni-adjusted pairwise tests.
##
##   Two complementary perspectives:
##     A. BCH-weighted (correct under LCA classification uncertainty) -- file 17
##     B. Modal-class ANOVA/χ²  (standard in LCA papers, easy to read)  -- THIS FILE
##
##   Output:
##     _outputs/18_anova_omnibus.csv     -- one-way omnibus per variable
##     _outputs/18_posthoc_tukey.csv     -- Tukey HSD pairwise (continuous)
##     _outputs/18_posthoc_chisq_pairs.csv -- pairwise 2x2 chi-sq (binary, Bonferroni)
##     _outputs/18_summary.md
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(tibble)
})

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
shared<- file.path(root, "advanced_reproducible", "_shared")
out   <- file.path(root, "advanced_reproducible", "_outputs")
mp_r3 <- file.path(root, "advanced_reproducible", "Mplus_responder_LCA_R3STEP")

K <- 5
class_labels <- c("Network_oriented_prevention","Escalation_aware_mixed",
                  "Life_threat_protective","Boundary_clarification",
                  "Multi_action_institutional")

cp_path <- file.path(mp_r3, "responder_lca_5class_r3step_cprob.dat")
hdr <- c(paste0("Q40_", 1:8), paste0("Q41_", 1:6),
         "stedu","dig","offcnt","freqz","intimate","severe",
         "mythz","fearz","crimez","victimz","supportz",
         paste0("CPROB", 1:5), "Class")
cp <- read.table(cp_path, header = FALSE)
names(cp) <- hdr
modal_int <- as.integer(cp$Class)

r <- readRDS(file.path(shared, "data_responder.rds"))
stopifnot(nrow(r) == nrow(cp))
r$Class <- factor(modal_int, levels = 1:K, labels = class_labels)

age_mid <- c("10s"=15, "20s"=25, "30s"=35, "40s"=45, "50s"=55, "60s"=65)
r$age_num <- unname(age_mid[as.character(r$age_cat)])

cont_vars <- c("age_num","dig","offcnt","total_type_count","coharm_count",
               "negative_impact_count","prosocial_change_count","freq_ord",
               "victim_blaming","crime_denial","stereotype","fear",
               "cjs_distrust","gender_awareness","gender_hierarchy",
               "support_awareness","seoul_policy_awareness")
bin_vars  <- c("female","college","married","employed","one_person","disability",
               "intimate","known_nonint","gendered_case","own_victim",
               "severe_coharm","threat","stedu","any_violence_education",
               "online_withdrawal","digital_coharm","q40_police","q42_police",
               "role_police_top2")

## ---------- (1) Continuous: ANOVA + Welch + Kruskal-Wallis + Levene ----------
omnibus_cont <- list(); posthoc_tukey <- list()
for (v in cont_vars) {
  if (!v %in% names(r)) next
  d <- r[, c("Class", v)] %>% drop_na()
  if (nrow(d) < 30) next
  fml <- as.formula(paste(v, "~ Class"))

  aov_fit <- aov(fml, data = d)
  aov_p   <- summary(aov_fit)[[1]][["Pr(>F)"]][1]
  aov_F   <- summary(aov_fit)[[1]][["F value"]][1]
  aov_df1 <- summary(aov_fit)[[1]][["Df"]][1]
  aov_df2 <- summary(aov_fit)[[1]][["Df"]][2]

  ## Welch (heteroscedastic) ANOVA
  oneway <- tryCatch(stats::oneway.test(fml, data = d, var.equal = FALSE),
                     error = function(e) NULL)
  welch_F <- if (!is.null(oneway)) unname(oneway$statistic) else NA
  welch_p <- if (!is.null(oneway)) unname(oneway$p.value)   else NA

  ## Kruskal-Wallis
  kw <- kruskal.test(fml, data = d)
  kw_chi <- unname(kw$statistic); kw_p <- unname(kw$p.value)

  ## Levene's test (for variance homogeneity)
  levene_p <- tryCatch({
    grp_med <- tapply(d[[v]], d$Class, median, na.rm = TRUE)
    abs_dev <- abs(d[[v]] - grp_med[as.character(d$Class)])
    summary(aov(abs_dev ~ d$Class))[[1]][["Pr(>F)"]][1]
  }, error = function(e) NA)

  ## Effect size eta-squared
  ss_total <- sum((d[[v]] - mean(d[[v]]))^2)
  ss_b     <- summary(aov_fit)[[1]][["Sum Sq"]][1]
  eta_sq   <- ss_b / ss_total

  ## Per-class mean (sd)
  msd <- d %>% group_by(Class) %>%
    summarise(M = mean(.data[[v]]), SD = sd(.data[[v]]), n = n(), .groups = "drop")
  msd_str <- paste(sprintf("%s: %.2f (%.2f, n=%d)",
                           msd$Class, msd$M, msd$SD, msd$n), collapse = "; ")

  omnibus_cont[[v]] <- data.frame(
    variable = v, type = "continuous",
    F_anova = round(aov_F, 2), df1 = aov_df1, df2 = aov_df2, p_anova = signif(aov_p, 3),
    F_welch = round(welch_F, 2), p_welch = signif(welch_p, 3),
    KW_chisq = round(kw_chi, 2), p_KW = signif(kw_p, 3),
    eta_sq  = round(eta_sq, 3),
    levene_p = signif(levene_p, 3),
    per_class = msd_str
  )

  ## Tukey HSD
  tk <- TukeyHSD(aov_fit)$Class
  posthoc_tukey[[v]] <- data.frame(
    variable = v,
    contrast = rownames(tk),
    diff = round(tk[, "diff"], 3),
    lwr  = round(tk[, "lwr"], 3),
    upr  = round(tk[, "upr"], 3),
    p_adj_Tukey = signif(tk[, "p adj"], 3)
  )
}

## ---------- (2) Binary: chi-square (Cramer V) + pairwise 2x2 with Bonferroni ----------
omnibus_bin <- list(); posthoc_pairs <- list()
n_pairs <- choose(K, 2)
for (v in bin_vars) {
  if (!v %in% names(r)) next
  d <- r[, c("Class", v)] %>% drop_na()
  if (nrow(d) < 30) next
  tab <- table(d$Class, d[[v]])
  if (any(dim(tab) < 2)) next
  ## Choose chi-sq vs Fisher: Fisher if any expected < 5
  chi <- suppressWarnings(chisq.test(tab))
  use_fisher <- any(chi$expected < 5)
  if (use_fisher) {
    fish <- fisher.test(tab, simulate.p.value = TRUE, B = 5000)
    chi_p <- fish$p.value
    chi_stat <- NA; chi_df <- NA
    test_used <- "Fisher_simulated"
  } else {
    chi_p <- chi$p.value; chi_stat <- unname(chi$statistic); chi_df <- unname(chi$parameter)
    test_used <- "Pearson_chisq"
  }
  ## Cramer's V
  N <- sum(tab); cv <- sqrt(chi$statistic / (N * (min(dim(tab)) - 1)))

  ## Per-class proportion
  prop <- d %>% group_by(Class) %>%
    summarise(p = mean(as.numeric(.data[[v]]), na.rm = TRUE), n = n(), .groups = "drop")
  prop_str <- paste(sprintf("%s: %.2f (n=%d)", prop$Class, prop$p, prop$n), collapse = "; ")

  omnibus_bin[[v]] <- data.frame(
    variable = v, type = "binary",
    test = test_used,
    chi_stat = round(chi_stat, 2), df = chi_df,
    p_omnibus = signif(chi_p, 3),
    cramer_V  = round(unname(cv), 3),
    per_class = prop_str
  )

  ## Pairwise 2x2 chi-square with Bonferroni
  pairs <- combn(class_labels, 2, simplify = FALSE)
  prs <- lapply(pairs, function(pp) {
    sub <- d[d$Class %in% pp, ]
    sub$Class <- droplevels(sub$Class)
    sub_tab <- table(sub$Class, sub[[v]])
    if (any(dim(sub_tab) < 2)) return(NULL)
    chi2 <- suppressWarnings(chisq.test(sub_tab))
    use_f <- any(chi2$expected < 5)
    if (use_f) {
      pp_val <- fisher.test(sub_tab)$p.value; tu <- "Fisher"
    } else {
      pp_val <- chi2$p.value; tu <- "chisq"
    }
    data.frame(variable = v,
               class_i = pp[1], class_j = pp[2],
               test = tu, p_pair = pp_val)
  })
  prs <- bind_rows(Filter(Negate(is.null), prs))
  prs$p_bonferroni <- pmin(prs$p_pair * n_pairs, 1)
  posthoc_pairs[[v]] <- prs
}

cont_df <- if (length(omnibus_cont) > 0) bind_rows(omnibus_cont) else
           data.frame(variable=character(), type=character(), p_welch=numeric())
bin_df  <- if (length(omnibus_bin) > 0) bind_rows(omnibus_bin) else
           data.frame(variable=character(), type=character(), p_omnibus=numeric())
## Ensure both have all needed columns before bind_rows
if (!"p_omnibus" %in% names(cont_df)) cont_df$p_omnibus <- NA_real_
if (!"p_welch"   %in% names(bin_df))  bin_df$p_welch    <- NA_real_

omnibus_df  <- bind_rows(cont_df, bin_df) %>%
  mutate(p_main = ifelse(type == "continuous", p_welch, p_omnibus),
         p_fdr = p.adjust(p_main, method = "BH"),
         sig = ifelse(p_fdr < 0.001, "***",
                ifelse(p_fdr < 0.01, "**",
                ifelse(p_fdr < 0.05, "*",
                ifelse(p_fdr < 0.10, "†", "")))))
tukey_df    <- bind_rows(posthoc_tukey)
chisq_pair_df <- bind_rows(posthoc_pairs)

write.csv(omnibus_df,  file.path(out, "18_anova_omnibus.csv"), row.names = FALSE)
write.csv(tukey_df,    file.path(out, "18_posthoc_tukey.csv"), row.names = FALSE)
write.csv(chisq_pair_df, file.path(out, "18_posthoc_chisq_pairs.csv"), row.names = FALSE)

sink(file.path(out, "18_summary.md"))
cat("# Post-LCA Group Comparison: ANOVA / Welch / KW / Chi-square\n\n")
cat("Sample: 501 responders, modal class assignment from R3STEP cprob (entropy = 0.879).\n\n")
cat("Methods:\n")
cat("- Continuous: one-way ANOVA + Welch + Kruskal-Wallis (sensitivity); Levene's test for variance equality; Tukey HSD post-hoc.\n")
cat("- Binary: Pearson chi-square (Fisher when any expected < 5, simulated 5000); Cramer V; pairwise 2x2 with Bonferroni correction.\n")
cat("- All omnibus p-values FDR(BH) corrected within table.\n\n")

cat("## Class sizes (modal)\n\n")
sz <- table(r$Class); for (k in 1:K)
  cat(sprintf("- %s: n = %d (%.1f%%)\n", names(sz)[k], sz[k], 100*sz[k]/sum(sz)))
cat("\n")

cat("## Significant variables (q < .05) — what makes classes differ\n\n")
sig <- omnibus_df %>% filter(p_fdr < 0.05) %>%
  select(variable, type, p_main, p_fdr, sig, eta_sq, cramer_V)
print(as.data.frame(sig), row.names = FALSE)
cat("\n\n## Top Tukey HSD pairwise (q < .05) — continuous\n\n")
print(as.data.frame(tukey_df %>% filter(p_adj_Tukey < 0.05) %>% arrange(p_adj_Tukey) %>% head(40)),
      row.names = FALSE)
cat("\n\n## Top pairwise binary (Bonferroni q < .05)\n\n")
print(as.data.frame(chisq_pair_df %>% filter(p_bonferroni < 0.05) %>% arrange(p_bonferroni) %>% head(40)),
      row.names = FALSE)
sink()

cat("Wrote:\n",
    file.path(out, "18_anova_omnibus.csv"), "\n",
    file.path(out, "18_posthoc_tukey.csv"), "\n",
    file.path(out, "18_posthoc_chisq_pairs.csv"), "\n",
    file.path(out, "18_summary.md"), "\n\n")

cat("=== Class sizes (modal) ===\n")
print(table(r$Class))
cat("\n=== Variables with FDR-significant class differences (omnibus) ===\n")
omnibus_df %>% filter(p_fdr < 0.05) %>%
  select(variable, type, p_main, p_fdr, sig) %>% as.data.frame() %>% print(row.names = FALSE)
