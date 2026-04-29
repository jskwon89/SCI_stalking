## ----------------------------------------------------------------------------
## 29. Missing-data audit for sequential bystander response framework
##
## Purpose:
##   Reviewers often ask how analysis Ns were produced. This script creates a
##   compact missingness audit for:
##     - LCA indicators (Q40/Q41) among active responders
##     - Stage 1 logistic outcomes/covariates among witnesses
##     - R3STEP covariates among active responders
##     - Stage 3 barrier items among non-responders and non-reporters
##
## Outputs:
##   _outputs/29_missing_data_audit.csv
##   _outputs/29_analysis_sample_n.csv
##   _outputs/29_missing_data_summary.md
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
dir.create(out, recursive = TRUE, showWarnings = FALSE)

full <- readRDS(file.path(shared, "data_full.rds"))
w    <- readRDS(file.path(shared, "data_witness.rds"))
r    <- readRDS(file.path(shared, "data_responder.rds"))

num <- function(x) suppressWarnings(as.numeric(as.vector(x)))

miss_tbl <- function(df, vars, sample_name, block) {
  vars <- intersect(vars, names(df))
  bind_rows(lapply(vars, function(v) {
    x <- df[[v]]
    tibble(
      sample = sample_name,
      block = block,
      variable = v,
      N = nrow(df),
      missing_n = sum(is.na(x)),
      missing_pct = round(100 * mean(is.na(x)), 2),
      nonmissing_n = sum(!is.na(x))
    )
  }))
}

lca_indicators <- c(paste0("Q40_", 1:8), paste0("Q41_", 1:6))

stage1_core <- c(
  "female","age_cat","college","married","employed","one_person","disability",
  "own_victim","victim_blaming_z","crime_denial_z","stereotype_z","fear_z",
  "cjs_distrust_z","gender_awareness_z","gender_hierarchy_z",
  "stedu","support_awareness_z","seoul_policy_awareness_z",
  "dig","offcnt","freq_ord_z","threat","intimate","known_nonint",
  "gendered_case","severe_coharm","region"
)

stage1_outcomes <- c("active_response","institutional_response","q40_police",
                     "q42_police","online_withdrawal")

r3step_covariates <- c("stedu","dig","offcnt","freq_ord_z","intimate",
                       "severe_coharm","myth_z","fear_z","crime_denial_z",
                       "victim_blaming_z","support_awareness_z")

q43_vars  <- paste0("Q43_", 1:13)
q422_vars <- paste0("Q42_2_", 1:8)

nonresp   <- w %>% filter(num(active_response) == 0)
nonreport <- r %>% filter(num(q42_police) == 0)

audit <- bind_rows(
  miss_tbl(r, lca_indicators, "Active responders (N=501)", "Stage 2 LCA indicators"),
  miss_tbl(w, c(stage1_outcomes, stage1_core), "Witnesses (N=749)", "Stage 1 logistic outcomes/covariates"),
  miss_tbl(r, r3step_covariates, "Active responders (N=501)", "Stage 2 R3STEP covariates"),
  miss_tbl(nonresp, q43_vars, "Non-responders (N=248)", "Stage 3 Q43 non-response barriers"),
  miss_tbl(nonreport, q422_vars, "Non-reporting active responders", "Stage 3 Q42_2 non-reporting barriers")
) %>%
  arrange(block, desc(missing_pct), variable)

complete_n <- function(df, vars) {
  vars <- intersect(vars, names(df))
  sum(stats::complete.cases(df[, vars, drop = FALSE]))
}

analysis_n <- tibble(
  analysis = c(
    "Raw sample",
    "Stage 1 witness sample",
    "Stage 1 active-response logistic complete cases",
    "Stage 1 institutional-response logistic complete cases",
    "Stage 2 active-responder LCA sample",
    "Stage 2 LCA complete indicator rows",
    "Stage 2 R3STEP complete covariate rows",
    "Stage 3 non-response barrier sample",
    "Stage 3 non-reporting barrier sample"
  ),
  N = c(
    nrow(full),
    nrow(w),
    complete_n(w, c("active_response", stage1_core)),
    complete_n(w, c("institutional_response", stage1_core)),
    nrow(r),
    complete_n(r, lca_indicators),
    complete_n(r, r3step_covariates),
    nrow(nonresp),
    nrow(nonreport)
  ),
  note = c(
    "Original survey file",
    "Any witnessed stalking behavior in Q31/Q32",
    "Complete cases for HC3 region-adjusted logit",
    "Complete cases for HC3 region-adjusted logit",
    "Active responders used for primary Q40+Q41 LCA",
    "Mplus uses all rows with missing coded as -999; this row reports complete indicators only",
    "Covariate completeness for R3STEP auxiliary variables",
    "Witnesses who reported no active response",
    "Active responders with no police report in Q42"
  )
)

write.csv(audit, file.path(out, "29_missing_data_audit.csv"), row.names = FALSE)
write.csv(analysis_n, file.path(out, "29_analysis_sample_n.csv"), row.names = FALSE)

sink(file.path(out, "29_missing_data_summary.md"))
cat("# Missing-Data Audit\n\n")
cat("This audit documents analysis-specific Ns for the sequential bystander response framework.\n\n")
cat("## Analysis sample Ns\n\n")
print(as.data.frame(analysis_n), row.names = FALSE)
cat("\n## Variables with any missingness\n\n")
any_miss <- audit %>% filter(missing_n > 0)
if (nrow(any_miss) == 0) {
  cat("No missingness detected in audited variables after shared preprocessing.\n")
} else {
  print(as.data.frame(any_miss), row.names = FALSE)
}
cat("\n## Interpretation\n\n")
cat("Prevalence estimates are unweighted sample proportions because the source file did not provide a weighting variable. ")
cat("The audit supports transparent reporting of Stage 1, Stage 2, and Stage 3 analysis Ns.\n")
sink()

cat("Wrote:\n",
    file.path(out, "29_missing_data_audit.csv"), "\n",
    file.path(out, "29_analysis_sample_n.csv"), "\n",
    file.path(out, "29_missing_data_summary.md"), "\n")
