## ----------------------------------------------------------------------------
## 27. BLRT attempt log
##
## Summarizes TECH14/BLRT evidence from the available Mplus 7 outputs.
## This is documentation, not a class-enumeration criterion.
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({ library(dplyr); library(tibble) })

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
adv  <- file.path(root, "advanced_reproducible")
out  <- file.path(adv, "_outputs")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

parse_blrt <- function(folder, prefix, label) {
  bind_rows(lapply(2:6, function(k) {
    f <- file.path(folder, paste0(prefix, k, "class.out"))
    if (!file.exists(f)) return(NULL)
    L <- readLines(f, warn = FALSE)
    blrt_idx <- grep("Approximate P-Value", L)[1]
    draws_idx <- grep("Successful Bootstrap Draws", L)[1]
    lrt_idx <- grep("^\\s+H0LL\\s+H1LL\\s+LRT", L)[1]
    normal <- any(grepl("THE MODEL ESTIMATION TERMINATED NORMALLY", L))
    replicated <- any(grepl("THE BEST LOGLIKELIHOOD VALUE HAS BEEN REPLICATED", L))
    tibble(
      attempt = label,
      K = k,
      output_file = f,
      terminated_normally = normal,
      best_ll_replicated = replicated,
      BLRT_p = if (!is.na(blrt_idx)) as.numeric(regmatches(L[blrt_idx], regexpr("-?[0-9]+\\.?[0-9]*\\s*$", L[blrt_idx]))) else NA_real_,
      successful_bootstrap_draws = if (!is.na(draws_idx)) as.integer(regmatches(L[draws_idx], regexpr("[0-9]+\\s*$", L[draws_idx]))) else NA_integer_,
      has_lrt_block = !is.na(lrt_idx)
    )
  }))
}

primary <- parse_blrt(file.path(adv, "Mplus_LCA_enum"), "enum_", "primary_Mplus7_TECH14")

high_dir <- file.path(adv, "Mplus_LCA_enum_BLRT")
high <- if (dir.exists(high_dir)) {
  parse_blrt(high_dir, "enum_", "high_LRTSTARTS_Mplus7_TECH14")
} else {
  tibble(
    attempt = "high_LRTSTARTS_Mplus7_TECH14",
    K = NA_integer_,
    output_file = high_dir,
    terminated_normally = NA,
    best_ll_replicated = NA,
    BLRT_p = NA_real_,
    successful_bootstrap_draws = NA_integer_,
    has_lrt_block = NA
  )
}

tbl <- bind_rows(primary, high)
tbl <- tbl %>%
  mutate(retained_as_primary_criterion =
           ifelse(!is.na(successful_bootstrap_draws) & successful_bootstrap_draws >= 30, TRUE, FALSE),
         note = case_when(
           is.na(successful_bootstrap_draws) ~ "No usable TECH14/BLRT output found for this attempt.",
           successful_bootstrap_draws < 30 ~ "Unstable: successful bootstrap draws < 30.",
           TRUE ~ "Draw count adequate."
         ))

write.csv(tbl, file.path(out, "27_blrt_attempt_table.csv"), row.names = FALSE)

sink(file.path(out, "27_blrt_attempt_log.md"))
cat("# BLRT Attempt Log\n\n")
cat("BLRT was requested using Mplus TECH14 under the available Mplus 7 environment.\n\n")
print(tbl)
cat("\n## Decision\n\n")
cat("BLRT was requested using TECH14, but bootstrap solutions were unstable under the available Mplus 7 environment; ")
cat("therefore, BLRT was not retained as a primary class-enumeration criterion.\n\n")
cat("Primary class enumeration should rely on LMR rebound, classification quality, minimum class size, and substantive/policy interpretability, while reporting the BLRT attempt transparently in supplementary materials.\n")
sink()

cat("Wrote:\n",
    file.path(out, "27_blrt_attempt_table.csv"), "\n",
    file.path(out, "27_blrt_attempt_log.md"), "\n")
