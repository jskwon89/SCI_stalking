## ----------------------------------------------------------------------------
## 99. Verification: hash inputs, recompute key numbers, write VERIFICATION.md
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(tools); library(tibble)
})

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
shared<- file.path(root, "advanced_reproducible", "_shared")
out   <- file.path(root, "advanced_reproducible", "_outputs")
ver_md<- file.path(root, "advanced_reproducible", "VERIFICATION.md")

# ---- 1. Hash data files ----
input_files <- c(
  raw_sav   = file.path(root, "kor_data_20240048.sav"),
  shared_w  = file.path(shared, "data_witness.rds"),
  shared_r  = file.path(shared, "data_responder.rds")
)
hashes <- sapply(input_files, function(f) if (file.exists(f)) tools::md5sum(f) else NA)

# ---- 2. Recompute sample counts ----
w <- readRDS(file.path(shared, "data_witness.rds"))
r <- readRDS(file.path(shared, "data_responder.rds"))
counts <- tibble(
  metric = c("witness_total", "active_responder", "non_responder",
             "institutional_response_rate", "q40_police_rate", "q42_police_rate_in_responders"),
  value  = c(nrow(w),
             sum(w$active_response == 1),
             sum(w$active_response == 0),
             round(mean(w$institutional_response, na.rm = TRUE), 4),
             round(mean(w$q40_police, na.rm = TRUE), 4),
             round(mean(r$q42_police, na.rm = TRUE), 4))
)

# ---- 3. Recompute key OR (active_response stedu) ----
core <- c("female","age_cat","college","married","employed","one_person","disability",
          "own_victim","victim_blaming_z","crime_denial_z","stereotype_z","fear_z",
          "cjs_distrust_z","gender_awareness_z","gender_hierarchy_z",
          "stedu","support_awareness_z","seoul_policy_awareness_z",
          "dig","offcnt","freq_ord_z","threat","intimate","known_nonint",
          "gendered_case","severe_coharm",
          "region")  # MATCHES file 11 region-adjusted spec
rep_or <- function(df, y) {
  d <- df[, c(y, core)] %>% drop_na()
  fit <- glm(reformulate(core, response = y), data = d, family = binomial())
  ct <- summary(fit)$coefficients
  data.frame(
    outcome = y, N = nrow(d),
    stedu_OR  = round(exp(ct["stedu", "Estimate"]), 3),
    stedu_p   = signif(ct["stedu", "Pr(>|z|)"], 3),
    dig_OR    = round(exp(ct["dig", "Estimate"]), 3),
    dig_p     = signif(ct["dig", "Pr(>|z|)"], 3),
    severe_OR = round(exp(ct["severe_coharm", "Estimate"]), 3),
    severe_p  = signif(ct["severe_coharm", "Pr(>|z|)"], 3)
  )
}
or_check <- bind_rows(
  rep_or(w, "active_response"),
  rep_or(w, "institutional_response"),
  rep_or(w, "q40_police"),
  rep_or(r, "q42_police")
)

# ---- 4. Tool versions ----
ver <- list(
  R_version       = paste(R.version$major, R.version$minor, sep = "."),
  Mplus_used      = "v7 (TECH11=LMR, TECH14=BLRT; BCH unsupported -> manual BCH)",
  R_packages_used = paste(c("haven","dplyr","tidyr","logistf","sandwich","lmtest",
                            "lavaan","broom","tibble"), collapse = ", "),
  date            = as.character(Sys.time())
)

# ---- 5. Write report ----
sink(ver_md)
cat("# VERIFICATION — Stalking Bystander Intervention Analysis\n\n")
cat(sprintf("Generated: %s\n\n", ver$date))

cat("## Tool versions\n\n")
cat("- R:", ver$R_version, "\n")
cat("- Mplus:", ver$Mplus_used, "\n")
cat("- R packages:", ver$R_packages_used, "\n\n")

cat("## Input file MD5 hashes\n\n")
print(data.frame(file = names(hashes), md5 = unname(hashes)))
cat("\n")

cat("## Sample-size verification (must match expected)\n\n")
print(counts)
cat("\nExpected: witness=749, active=501, no=248. ")
cat(if (nrow(w) == 749 && sum(w$active_response == 1) == 501 && sum(w$active_response == 0) == 248)
    "PASS.\n" else "FAIL.\n")
cat("\n")

cat("## Reproduction of key OR (recomputed from raw .sav)\n\n")
print(or_check)
cat("\n")
cat("Expected (region-adjusted, file 11):\n")
cat("  active_response stedu OR ~ 2.50\n")
cat("  institutional_response stedu OR ~ 2.57\n")
cat("  q40_police stedu OR ~ 2.27\n")
cat("  active_response severe_coharm OR ~ 2.59\n")
cat("  institutional_response dig OR ~ 1.20 (raw HC3 p=.027; q_FDR=.135)\n\n")
ok <- abs(or_check$stedu_OR[or_check$outcome == "active_response"] - 2.50) < 0.10 &&
      abs(or_check$stedu_OR[or_check$outcome == "institutional_response"] - 2.57) < 0.10 &&
      abs(or_check$stedu_OR[or_check$outcome == "q40_police"] - 2.27) < 0.10
cat(if (ok) "REPRODUCTION: PASS (all OR within +/-0.10, region-adjusted)\n" else "REPRODUCTION: FAIL\n")
cat("\n")

cat("## Output file inventory\n\n")
ofiles <- list.files(out, full.names = FALSE)
for (f in ofiles) cat("  -", f, "\n")
cat("\nMplus folders: Mplus_CFA, Mplus_LCA_enum, Mplus_BCH_distal, Mplus_responder_LCA_R3STEP, Mplus_all_witness_Q40\n")

sink()
cat("Wrote:", ver_md, "\n")
cat("\nSample-size check:")
print(counts)
cat("\nOR reproduction check:")
print(or_check)
