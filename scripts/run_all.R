## ============================================================================
## run_all.R  --  one-command reproduction of every analysis in this folder
##
## Usage:
##   "C:/Program Files/R/R-4.4.1/bin/Rscript.exe" run_all.R
##
## What it does (in order):
##   STEP 0  — package check (auto-install missing CRAN packages)
##   STEP 1  — 10_data_prep_shared.R         (raw .sav -> _shared/*.rds)
##   STEP 2  — 13_make_cfa_inputs.R          (write Mplus CFA .inp + data)
##   STEP 3  — Mplus run cfa_1F.inp .. cfa_3F.inp
##   STEP 4  — 14_make_lca_enum_bch_inputs.R (write LCA enum + BCH .inp + data)
##   STEP 5  — Mplus run enum_2..6class.inp + DU3STEP
##   STEP 6  — 11_robust_logistic_firth.R    (HC3 + Firth + DIG x stedu)
##   STEP 7  — 12_moderated_mediation_evalue.R (lavaan + E-value)
##   STEP 8  — 15_manual_bch_distal.R        (manual BCH on distals)
##   STEP 9  — 16_parse_enum_summary.R       (parse enum table)
##   STEP 10 — 17_class_profile_descriptive.R (class profile, BCH-weighted)
##   STEP 11 — 18_class_anova_chisq_posthoc.R (modal-class ANOVA / chi2)
##   STEP 12 — 99_verify.R                   (re-derive key OR + MD5 + PASS/FAIL)
##   STEP 13     20_lca_local_dependence.R
##   STEP 14     21_policy_distal_outcomes.R
##   STEP 15     22_nonresponse_barriers.R
##   STEP 16     23_lca_extended_fit_reporting.R
##   STEP 17     24_q40_only_response_lca.R
##   STEP 18     25_pruned_trigger_lca.R
##   STEP 19     26_sensitivity_agreement.R
##   STEP 20     27_blrt_attempt_log.R
##   STEP 21     28_review_defense_tables.R
##   STEP 22     30_make_author_tables.R
##
## Inputs:
##   D:/2026/SCI/Stalking/kor_data_20240048.sav  (must exist)
##
## Outputs:
##   _shared/*.rds                  (749 + 501 prepared data)
##   Mplus_CFA/*.out                (1F/2F/3F categorical CFA)
##   Mplus_LCA_enum/*.out           (k=2..6 enumeration with TECH11/14)
##   Mplus_BCH_distal/*.out         (5-class with DU3STEP distal)
##   _outputs/11_*..28_*            (all R-side tables and md summaries)
##   VERIFICATION.md                (reproduction PASS/FAIL log)
##   PUBLICATION_READY_SUMMARY.md   (top-level results)
## ============================================================================

options(stringsAsFactors = FALSE)
t_start <- Sys.time()

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
adv  <- file.path(root, "advanced_reproducible")
mplus_exe <- "C:/Program Files/Mplus/Mplus.exe"

setwd(adv)

stopifnot("raw .sav not found" = file.exists(file.path(root, "kor_data_20240048.sav")))
stopifnot("Mplus.exe not found" = file.exists(mplus_exe))

## ---------------------------------------------------------------------------
## STEP 0. CRAN package check (auto-install if missing)
## ---------------------------------------------------------------------------
required <- c("haven","dplyr","tidyr","tibble","broom","sandwich","lmtest",
              "logistf","lavaan","glmnet","ranger","pROC","igraph","psych",
              "nnet","purrr","ggplot2","readr","openxlsx")
ip <- installed.packages()[,"Package"]
miss <- setdiff(required, ip)
if (length(miss) > 0) {
  cat("Installing missing packages:", paste(miss, collapse=", "), "\n")
  install.packages(miss, repos = "https://cloud.r-project.org", type = "binary")
}

run_R <- function(script) {
  cat(sprintf("\n[%s] %s ...\n", format(Sys.time(), "%H:%M:%S"), script))
  source(file.path(adv, script), echo = FALSE)
}

## Skip rerun if a valid .out already exists (>= 50KB). Override with
## FORCE_MPLUS=TRUE env var.
force_mplus <- as.logical(Sys.getenv("FORCE_MPLUS", "FALSE"))
run_Mplus <- function(folder, inp_files) {
  for (f in inp_files) {
    out_alt  <- file.path(adv, folder, sub("\\.inp$", ".out", f))
    out_low  <- file.path(adv, folder, sub("\\.inp$", ".out", tolower(f)))
    out_path <- if (file.exists(out_alt)) out_alt else out_low
    if (!force_mplus && file.exists(out_path) && file.size(out_path) >= 50000) {
      cat(sprintf("\n[%s] Mplus skip (existing .out %.0f KB): %s/%s\n",
                  format(Sys.time(), "%H:%M:%S"), file.size(out_path)/1024,
                  folder, f))
      next
    }
    cat(sprintf("\n[%s] Mplus run: %s/%s ...\n",
                format(Sys.time(), "%H:%M:%S"), folder, f))
    setwd(file.path(adv, folder))
    rc <- system2(mplus_exe, args = shQuote(f), stdout = TRUE, stderr = TRUE)
    setwd(adv)
  }
}

## ---------------------------------------------------------------------------
## STEPS
## ---------------------------------------------------------------------------
run_R("10_data_prep_shared.R")
run_R("13_make_cfa_inputs.R")
run_Mplus("Mplus_CFA", c("cfa_1F.inp","cfa_2F.inp","cfa_3F.inp"))
run_R("14_make_lca_enum_bch_inputs.R")
run_Mplus("Mplus_LCA_enum",
          c("enum_2class.inp","enum_3class.inp","enum_4class.inp",
            "enum_5class.inp","enum_6class.inp"))
run_Mplus("Mplus_BCH_distal", c("lca_5class_du3step.inp"))
run_R("11_robust_logistic_firth.R")
run_R("12_moderated_mediation_evalue.R")
run_R("15_manual_bch_distal.R")
run_R("16_parse_enum_summary.R")
run_R("17_class_profile_descriptive.R")
run_R("18_class_anova_chisq_posthoc.R")
run_R("19_lca_item_response_and_3v5class.R")
run_R("20_lca_local_dependence.R")
run_R("21_policy_distal_outcomes.R")
run_R("22_nonresponse_barriers.R")
run_R("23_lca_extended_fit_reporting.R")
run_R("24_q40_only_response_lca.R")
run_R("25_pruned_trigger_lca.R")
run_R("26_sensitivity_agreement.R")
run_R("27_blrt_attempt_log.R")
run_R("28_review_defense_tables.R")
run_R("29_missing_data_audit.R")
run_R("31_class_specific_barriers.R")
run_R("32_C4_C5_focal_contrast.R")
run_R("33_barrier_overlap_difference.R")
run_R("30_make_author_tables.R")
run_R("99_verify.R")

t_end <- Sys.time()
cat(sprintf("\nDONE. Elapsed: %.1f min\n", as.numeric(difftime(t_end, t_start, units="mins"))))
cat("Read VERIFICATION.md and PUBLICATION_READY_SUMMARY.md for results.\n")
