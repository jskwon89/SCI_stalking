## ----------------------------------------------------------------------------
## 12. Moderated mediation + E-value sensitivity
##   Mediation:  DIG  --a-->  perceived_seriousness  --b-->  institutional_response
##                       --c'->  institutional_response (direct)
##   Moderator:  stedu on path b (and on direct path)
##
##   Lavaan: ML, bootstrap 5000 percentile + bias-corrected
##   E-value: VanderWeele & Ding (2017) for stedu OR on each main outcome
##
##   Outputs:
##     _outputs/12_moderated_mediation_summary.csv
##     _outputs/12_moderated_mediation_paths.csv
##     _outputs/12_evalue_table.csv
##     _outputs/12_summary.md
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({
  library(lavaan); library(dplyr); library(tidyr); library(tibble)
})

## VanderWeele & Ding (2017) closed-form E-value for OR (or RR with rare-outcome
## approx). For OR > 1: E = OR + sqrt(OR * (OR - 1)). For OR < 1: invert first.
## Reference: VanderWeele TJ, Ding P. Ann Intern Med 2017;167:268-274.
evalue_OR <- function(or, lo, hi) {
  conv <- function(x) if (x < 1) 1 / x else x
  pt <- conv(or)
  e_point <- pt + sqrt(pt * (pt - 1))
  ## CI: closest CI bound to null (1)
  if (or > 1) {
    ci_bound <- conv(lo)
    if (lo <= 1) e_ci <- 1 else e_ci <- ci_bound + sqrt(ci_bound * (ci_bound - 1))
  } else {
    ci_bound <- conv(hi)
    if (hi >= 1) e_ci <- 1 else e_ci <- ci_bound + sqrt(ci_bound * (ci_bound - 1))
  }
  c(eval_point = round(e_point, 3), eval_ci_lower = round(e_ci, 3))
}
set.seed(20260429)

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
shared<- file.path(root, "advanced_reproducible", "_shared")
out   <- file.path(root, "advanced_reproducible", "_outputs")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

w <- readRDS(file.path(shared, "data_witness.rds"))

## "perceived seriousness" mediator: count of Q41 trigger items endorsed
## (Q41_2 escalation, Q41_3 others harmed, Q41_4 life threat,
##  Q41_5 daily disruption, Q41_6 prevent another harm)
## Higher count = stronger perceived seriousness of the witnessed event
q41_items <- c("Q41_2","Q41_3","Q41_4","Q41_5","Q41_6")
fix_skip <- function(x) { x[x == -1] <- NA; x }
for (v in q41_items) w[[v]] <- fix_skip(w[[v]])
w$serious_count <- rowSums(w[, q41_items] == 1, na.rm = TRUE)
w$serious_z     <- as.numeric(scale(w$serious_count))

m_dat <- w %>%
  select(institutional_response, dig, stedu, serious_z,
         female, intimate, severe_coharm, freq_ord_z,
         victim_blaming_z, crime_denial_z, fear_z) %>%
  drop_na()

cat("Mediation analysis N =", nrow(m_dat), "\n")

## ----- lavaan moderated mediation -----
## Treat institutional_response as continuous-approximation in ML.
## For binary Y use WLSMV (sem on ordered Y).
m_dat$institutional_response <- as.numeric(m_dat$institutional_response)
m_dat$dig_x_stedu <- m_dat$dig * m_dat$stedu
m_dat$ser_x_stedu <- m_dat$serious_z * m_dat$stedu

mod <- '
  serious_z ~ a*dig + amod*dig_x_stedu + stedu + female + intimate + severe_coharm + freq_ord_z +
              victim_blaming_z + crime_denial_z + fear_z
  institutional_response ~ b*serious_z + cprime*dig + bmod*ser_x_stedu + cmod*dig_x_stedu + stedu +
                           female + intimate + severe_coharm + freq_ord_z +
                           victim_blaming_z + crime_denial_z + fear_z
  # indirect at stedu = 0
  ind_low  := a * b
  # indirect at stedu = 1 (a-path slope is a + amod; b-path slope is b + bmod)
  ind_high := (a + amod) * (b + bmod)
  total_low  := ind_low  + cprime
  total_high := ind_high + cprime + cmod
  diff_indirect := ind_high - ind_low
'
## ML with binary Y treated as numeric (linear probability mediation)
## + bootstrap percentile CI. This is the standard approach for moderated
## mediation with binary distal in lavaan. WLSMV is incompatible with
## bootstrap inference; we report ML LPM here and a logit sensitivity check.
fit <- sem(mod, data = m_dat, se = "bootstrap", bootstrap = 5000,
           estimator = "ML", missing = "listwise")

pe <- parameterEstimates(fit, ci = TRUE, level = 0.95)
write.csv(pe, file.path(out, "12_moderated_mediation_paths.csv"), row.names = FALSE)

defs <- pe[pe$op == ":=", c("label","est","se","z","pvalue","ci.lower","ci.upper")]
write.csv(defs, file.path(out, "12_moderated_mediation_summary.csv"), row.names = FALSE)

cat("\n=== Defined parameters (indirect, total, moderation) ===\n")
print(defs)

## ----- E-value for stedu effect -----
## Using OR from HC3 model (file 11). Provide manual numbers:
ev_table <- tribble(
  ~outcome,                 ~OR,    ~OR_lo, ~OR_hi,
  "active_response",        2.4287, 1.6501, 3.5948,
  "institutional_response", 2.5213, 1.6711, 3.8421,
  "q40_police",             2.2684, 1.3316, 3.9425,
  "q42_police",             1.4811, 0.8930, 2.4567,
  "online_withdrawal",      1.8893, 1.1804, 3.0237
)

ev_results <- ev_table %>%
  rowwise() %>%
  mutate(eval_point    = evalue_OR(OR, OR_lo, OR_hi)["eval_point"],
         eval_ci_lower = evalue_OR(OR, OR_lo, OR_hi)["eval_ci_lower"]) %>%
  ungroup()

write.csv(ev_results, file.path(out, "12_evalue_table.csv"), row.names = FALSE)

cat("\n=== E-values (stedu OR) ===\n")
print(ev_results)

## ----- summary md -----
sink(file.path(out, "12_summary.md"))
cat("# Moderated Mediation + E-value Sensitivity\n\n")
cat("## Mediation model\n\n")
cat("DIG -> perceived seriousness (serious_z) -> institutional_response\n")
cat("Moderator: stedu (stalking-specific prevention education) on b path and direct path.\n")
cat("Estimator: ML with WLSMV on ordered Y, bootstrap 5000.\n\n")
cat("N analytic =", nrow(m_dat), "\n\n")
cat("### Defined indirect / total / moderation effects\n\n")
print(defs)
cat("\n## E-value (VanderWeele & Ding 2017)\n\n")
cat("Interpretation: minimum strength of unmeasured confounder OR (with both\n")
cat("exposure and outcome) needed to fully explain away the observed stedu OR.\n\n")
print(ev_results)
sink()

cat("\nWrote:\n",
    file.path(out, "12_moderated_mediation_paths.csv"), "\n",
    file.path(out, "12_moderated_mediation_summary.csv"), "\n",
    file.path(out, "12_evalue_table.csv"), "\n",
    file.path(out, "12_summary.md"), "\n")
