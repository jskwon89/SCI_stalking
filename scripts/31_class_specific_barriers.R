## ----------------------------------------------------------------------------
## 31. Class-specific non-reporting barriers among active responders
##
## Purpose:
##   Link Stage 2 profiles to Stage 3 reporting barriers. The manuscript's key
##   policy narrative is that C4 has active/persuasive intervention but almost no
##   institutional entry. This table checks whether non-reporting barriers differ
##   by the primary 5-class modal assignment.
##
## Outputs:
##   _outputs/31_class_specific_nonreport_barriers.csv
##   _outputs/31_class_specific_barrier_tests.csv
##   _outputs/31_class_specific_barrier_residuals.csv
##   _outputs/31_class_specific_barriers_summary.md
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(tibble)
})

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
adv    <- file.path(root, "advanced_reproducible")
shared <- file.path(adv, "_shared")
out    <- file.path(adv, "_outputs")
mp_r3  <- file.path(adv, "Mplus_responder_LCA_R3STEP")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

num <- function(x) suppressWarnings(as.numeric(as.vector(x)))
yes <- function(x) ifelse(num(x) == 1, 1, ifelse(num(x) == 0, 0, NA_real_))
any_domain <- function(df, vars) {
  as.numeric(rowSums(sapply(vars, function(vv) yes(df[[vv]]) == 1), na.rm = TRUE) > 0)
}

class_labels <- c("Network_oriented_prevention","Escalation_aware_mixed",
                  "Life_threat_protective","Boundary_clarification",
                  "Multi_action_institutional")
display_labels <- c("C1 Network-oriented prevention responders",
                    "C2 Escalation-aware mixed responders",
                    "C3 Life-threat protective responders",
                    "C4 Boundary-clarification persuaders",
                    "C5 Multi-action institutional responders")

read_primary_class <- function() {
  cp_path <- file.path(mp_r3, "responder_lca_5class_r3step_cprob.dat")
  hdr <- c(paste0("Q40_", 1:8), paste0("Q41_", 1:6),
           "stedu","dig","offcnt","freqz","intimate","severe",
           "mythz","fearz","crimez","victimz","supportz",
           paste0("CPROB", 1:5), "Class")
  cp <- read.table(cp_path, header = FALSE)
  names(cp) <- hdr
  factor(as.integer(cp$Class), levels = 1:5, labels = class_labels)
}

cramers_v <- function(tab) {
  chi <- suppressWarnings(chisq.test(tab))
  n <- sum(tab)
  if (n == 0) return(NA_real_)
  as.numeric(sqrt(chi$statistic / (n * (min(dim(tab)) - 1))))
}

r <- readRDS(file.path(shared, "data_responder.rds"))
r$Class <- read_primary_class()
r$Class_label <- factor(display_labels[as.integer(r$Class)],
                        levels = display_labels)

q422_vars <- paste0("Q42_2_", 1:8)
nonreport <- r %>% filter(num(q42_police) == 0)

nonreport$barrier_discouraged_victimwish <- any_domain(nonreport, q422_vars[c(1, 7)])
nonreport$barrier_privacy_retaliation    <- any_domain(nonreport, q422_vars[c(2, 3)])
nonreport$barrier_evidence_legalrisk     <- yes(nonreport$Q42_2_4)
nonreport$barrier_institutional_distrust <- yes(nonreport$Q42_2_5)
nonreport$barrier_minimization           <- yes(nonreport$Q42_2_6)
nonreport$barrier_other                  <- yes(nonreport$Q42_2_8)

domains <- c(
  barrier_discouraged_victimwish = "discouraged/victim wish",
  barrier_privacy_retaliation = "privacy/retaliation",
  barrier_evidence_legalrisk = "evidence/legal risk",
  barrier_institutional_distrust = "institutional distrust",
  barrier_minimization = "minimization",
  barrier_other = "other"
)

class_totals <- r %>%
  count(Class_label, name = "active_class_n") %>%
  mutate(active_class_pct = round(100 * active_class_n / sum(active_class_n), 1))

nonreport_totals <- nonreport %>%
  count(Class_label, name = "nonreport_n")

barrier_summary <- bind_rows(lapply(names(domains), function(v) {
  nonreport %>%
    group_by(Class_label) %>%
    summarise(
      domain = domains[[v]],
      n_nonreport_valid = sum(!is.na(.data[[v]])),
      n_yes = sum(.data[[v]] == 1, na.rm = TRUE),
      prop_yes = mean(.data[[v]], na.rm = TRUE),
      .groups = "drop"
    )
})) %>%
  left_join(class_totals, by = "Class_label") %>%
  left_join(nonreport_totals, by = "Class_label") %>%
  mutate(
    nonreport_pct_of_active_class = round(100 * nonreport_n / active_class_n, 1),
    prop_yes = round(prop_yes, 3)
  ) %>%
  select(Class_label, active_class_n, nonreport_n, nonreport_pct_of_active_class,
         domain, n_nonreport_valid, n_yes, prop_yes)

test_rows <- list()
resid_rows <- list()
for (v in names(domains)) {
  d <- nonreport[, c("Class_label", v)] %>% drop_na()
  tab <- table(d$Class_label, d[[v]])
  if (all(dim(tab) == c(5, 2))) {
    chi <- suppressWarnings(chisq.test(tab))
    use_fisher <- any(chi$expected < 5)
    p <- if (use_fisher) fisher.test(tab, simulate.p.value = TRUE, B = 10000)$p.value else chi$p.value
    test_rows[[v]] <- tibble(
      domain = domains[[v]],
      test = ifelse(use_fisher, "Fisher simulated", "Pearson chi-square"),
      N = sum(tab),
      statistic = ifelse(use_fisher, NA_real_, as.numeric(chi$statistic)),
      df = ifelse(use_fisher, NA_real_, as.numeric(chi$parameter)),
      p_value = p,
      cramer_V = cramers_v(tab)
    )
    yes_col <- if ("1" %in% colnames(chi$stdres)) "1" else tail(colnames(chi$stdres), 1)
    rr <- tibble(
      domain = domains[[v]],
      Class_label = rownames(chi$stdres),
      std_resid_yes = as.numeric(chi$stdres[, yes_col])
    )
    resid_rows[[v]] <- rr
  }
}

tests <- bind_rows(test_rows) %>%
  mutate(p_FDR = p.adjust(p_value, method = "BH"),
         across(c(statistic, p_value, p_FDR, cramer_V), ~ round(.x, 4)))
resids <- bind_rows(resid_rows) %>%
  mutate(std_resid_yes = round(std_resid_yes, 3)) %>%
  arrange(domain, desc(abs(std_resid_yes)))

write.csv(barrier_summary, file.path(out, "31_class_specific_nonreport_barriers.csv"), row.names = FALSE)
write.csv(tests, file.path(out, "31_class_specific_barrier_tests.csv"), row.names = FALSE)
write.csv(resids, file.path(out, "31_class_specific_barrier_residuals.csv"), row.names = FALSE)

sink(file.path(out, "31_class_specific_barriers_summary.md"))
cat("# Class-Specific Non-reporting Barriers\n\n")
cat("Sample: active responders who did not report to police, N =", nrow(nonreport), "\n\n")
cat("## Non-reporting sample by primary class\n\n")
print(as.data.frame(nonreport_totals), row.names = FALSE)
cat("\n## Barrier proportions by class\n\n")
print(as.data.frame(barrier_summary), row.names = FALSE)
cat("\n## Class-by-barrier tests\n\n")
print(as.data.frame(tests), row.names = FALSE)
cat("\n## Standardized residuals for barrier endorsement\n\n")
print(as.data.frame(resids), row.names = FALSE)
cat("\nInterpretation: this analysis links the Stage 2 situational-response profiles to Stage 3 reporting barriers. ")
cat("It should be reported as a targeted supplement, not as a replacement for the primary LCA.\n")
sink()

cat("Wrote:\n",
    file.path(out, "31_class_specific_nonreport_barriers.csv"), "\n",
    file.path(out, "31_class_specific_barrier_tests.csv"), "\n",
    file.path(out, "31_class_specific_barrier_residuals.csv"), "\n",
    file.path(out, "31_class_specific_barriers_summary.md"), "\n")
