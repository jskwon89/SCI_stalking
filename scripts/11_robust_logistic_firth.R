## ----------------------------------------------------------------------------
## 11. Robust logistic regression suite (replaces Part2 + extends)
##   - Standard logistic with HC3 robust SE
##   - Cluster-robust SE by region (Q2R)
##   - Firth penalized logit for rare-event outcomes (q40_police, q42_police)
##   - Formal DIG x stedu interaction test
##   - FDR (BH) adjustment within outcome family
##   Outputs: <root>/advanced_reproducible/_outputs/11_*.csv
##            <root>/advanced_reproducible/_outputs/11_logistic_summary.md
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(broom); library(sandwich); library(lmtest)
  library(logistf); library(tibble)
})

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
shared<- file.path(root, "advanced_reproducible", "_shared")
out   <- file.path(root, "advanced_reproducible", "_outputs")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

w <- readRDS(file.path(shared, "data_witness.rds"))
r <- readRDS(file.path(shared, "data_responder.rds"))

core <- c("female","age_cat","college","married","employed","one_person","disability",
          "own_victim","victim_blaming_z","crime_denial_z","stereotype_z","fear_z",
          "cjs_distrust_z","gender_awareness_z","gender_hierarchy_z",
          "stedu","support_awareness_z","seoul_policy_awareness_z",
          "dig","offcnt","freq_ord_z","threat","intimate","known_nonint",
          "gendered_case","severe_coharm",
          "region")  # NEW: region as fixed effect (5 levels, includes intercept reference)

fit_one <- function(df, y, preds, add_inter = NULL) {
  formula_text <- paste(y, "~", paste(c(preds, add_inter), collapse = " + "))
  cols <- unique(c(y, preds, "region"))
  dat <- df[, cols] %>% drop_na()
  fit <- glm(as.formula(formula_text), data = dat, family = binomial())
  vc_hc3 <- sandwich::vcovHC(fit, type = "HC3")
  ct_hc3 <- lmtest::coeftest(fit, vcov. = vc_hc3)
  ## Cluster-robust SE not used as primary because K=5 regions is too few
  ## for asymptotic CR theory. Disable to avoid misleading inference.
  vc_cl  <- NULL
  ct_cl  <- NULL

  tidy_robust <- function(ct, label) {
    tibble(
      outcome  = y, model = label,
      term     = rownames(ct),
      estimate = unname(ct[, "Estimate"]),
      std.error= unname(ct[, "Std. Error"]),
      z        = unname(ct[, "z value"]),
      p.value  = unname(ct[, "Pr(>|z|)"]),
      OR       = exp(unname(ct[, "Estimate"])),
      OR_lo    = exp(unname(ct[, "Estimate"]) - 1.96 * unname(ct[, "Std. Error"])),
      OR_hi    = exp(unname(ct[, "Estimate"]) + 1.96 * unname(ct[, "Std. Error"]))
    ) %>% filter(term != "(Intercept)")
  }

  hc3_tbl <- tidy_robust(ct_hc3, "logit_HC3")
  cl_tbl  <- if (!is.null(ct_cl)) tidy_robust(ct_cl, "logit_clusterRobust_region") else tibble()

  firth_tbl <- tibble()
  event_rate <- mean(dat[[y]] == 1)
  if (event_rate < 0.20 || event_rate > 0.80) {
    fit_f <- tryCatch(
      logistf(as.formula(formula_text), data = dat, plconf = NULL),
      error = function(e) NULL
    )
    if (!is.null(fit_f)) {
      firth_tbl <- tibble(
        outcome  = y, model = "firth_penalized",
        term     = names(fit_f$coefficients),
        estimate = unname(fit_f$coefficients),
        std.error= sqrt(diag(fit_f$var)),
        z        = NA_real_,
        p.value  = unname(fit_f$prob),
        OR       = exp(unname(fit_f$coefficients)),
        OR_lo    = exp(unname(fit_f$ci.lower)),
        OR_hi    = exp(unname(fit_f$ci.upper))
      ) %>% filter(term != "(Intercept)")
    }
  }
  bind_rows(hc3_tbl, cl_tbl, firth_tbl)
}

## ----- Outcomes -----
## NOTE: region has only 5 levels (n=42, 214, 92, 213, 188). Cluster-robust SE
## with K=5 clusters is unreliable (asymptotic theory requires K -> Inf). We
## include region as fixed effects in core predictors (via age_cat... and so on)
## and report cluster-robust SE only for sensitivity, not as primary inference.
##
## NOTE: digital_coharm dropped from primary outcomes because Q37_5 (the
## indicator) is also a component of severe_coharm (Q37_3,4,5,6,8), which
## causes deterministic collinearity. Use online_withdrawal as the digital
## distal outcome instead.
outcomes <- list(
  active_response        = list(df = w, n_min = 749, fam = "active"),
  institutional_response = list(df = w, n_min = 749, fam = "institutional"),
  q40_police             = list(df = w, n_min = 749, fam = "police"),
  q42_police             = list(df = r, n_min = 501, fam = "police"),
  online_withdrawal      = list(df = w, n_min = 749, fam = "withdrawal")
)

all_main <- bind_rows(lapply(names(outcomes), function(y) {
  spec <- outcomes[[y]]
  fit_one(spec$df, y, core)
}))

## ----- DIG x stedu interaction (formal test) -----
inter_tests <- bind_rows(lapply(names(outcomes), function(y) {
  spec <- outcomes[[y]]
  cols <- unique(c(y, core, "region"))
  d <- spec$df[, cols] %>% drop_na()
  m0 <- glm(as.formula(paste(y, "~", paste(core, collapse = " + "))), data = d, family = binomial())
  m1 <- glm(as.formula(paste(y, "~", paste(c(core, "dig:stedu"), collapse = " + "))), data = d, family = binomial())
  vc <- sandwich::vcovHC(m1, type = "HC3")
  ct <- lmtest::coeftest(m1, vcov. = vc)
  ix_idx <- grep("^(dig:stedu|stedu:dig)$", rownames(ct))
  if (length(ix_idx) == 0) {
    return(tibble(outcome = y, interaction_term = "dig:stedu",
                  B = NA, SE_HC3 = NA, p_HC3 = NA, OR = NA,
                  LRT_chisq = NA, LRT_df = NA, LRT_p = NA))
  }
  ix_row <- ct[ix_idx, , drop = FALSE]
  lr <- anova(m0, m1, test = "Chisq")
  tibble(
    outcome   = y,
    interaction_term = "dig:stedu",
    B         = unname(ix_row[1, "Estimate"]),
    SE_HC3    = unname(ix_row[1, "Std. Error"]),
    p_HC3     = unname(ix_row[1, "Pr(>|z|)"]),
    OR        = exp(unname(ix_row[1, "Estimate"])),
    LRT_chisq = unname(lr$Deviance[2]),
    LRT_df    = unname(lr$Df[2]),
    LRT_p     = unname(lr$`Pr(>Chi)`[2])
  )
}))

## ----- FDR within outcome family for HC3 main effects -----
all_main_fdr <- all_main %>%
  group_by(outcome, model) %>%
  mutate(p_fdr_BH = p.adjust(p.value, method = "BH"),
         p_holm   = p.adjust(p.value, method = "holm")) %>%
  ungroup()

write.csv(all_main_fdr, file.path(out, "11_logistic_robust_all.csv"), row.names = FALSE)
write.csv(inter_tests,  file.path(out, "11_dig_stedu_interaction.csv"), row.names = FALSE)

## ----- Summary md -----
sink(file.path(out, "11_logistic_summary.md"))
cat("# Robust Logistic Regression — Summary\n\n")
cat("Sample sizes: witnesses =", nrow(w), ", responders =", nrow(r), "\n\n")
cat("Standard errors: HC3 sandwich. Cluster-robust by region NOT used as primary because K=5 regions is too few for asymptotic CR theory; HC3 is preferred.\n")
cat("Firth penalized logit reported for outcomes with event rate < 20% or > 80%.\n\n")
cat("Multiple-comparison correction: Benjamini-Hochberg FDR within (outcome, SE-type).\n\n")

cat("## DIG x stedu interaction tests\n\n")
print(inter_tests, n = Inf)
cat("\n\n## Selected significant terms (q < .05 after FDR) — HC3 model\n\n")
sig <- all_main_fdr %>% filter(model == "logit_HC3", p_fdr_BH < 0.05) %>%
  select(outcome, term, OR, OR_lo, OR_hi, p.value, p_fdr_BH) %>% arrange(outcome, p_fdr_BH)
print(sig, n = Inf)

cat("\n\n## Firth vs HC3 OR comparison for rare-event outcomes\n\n")
firth_compare <- all_main_fdr %>%
  filter(outcome %in% c("q40_police","q42_police","institutional_response","online_withdrawal","digital_coharm"),
         term %in% c("dig","stedu","severe_coharm","intimate","known_nonint","seoul_policy_awareness_z")) %>%
  select(outcome, model, term, OR, p.value) %>% arrange(outcome, term, model)
print(firth_compare, n = Inf)
sink()

cat("Wrote:\n",
    file.path(out, "11_logistic_robust_all.csv"), "\n",
    file.path(out, "11_dig_stedu_interaction.csv"), "\n",
    file.path(out, "11_logistic_summary.md"), "\n")
