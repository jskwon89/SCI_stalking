## ----------------------------------------------------------------------------
## 16. Parse class enumeration outputs (k=2..6) for responder LCA
##   Extract: AIC/BIC/aBIC, entropy, smallest class %, LMR (TECH11), BLRT (TECH14)
##   Output: _outputs/16_class_enumeration_table.csv + 16_summary.md
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({ library(dplyr); library(tibble) })

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
mp    <- file.path(root, "advanced_reproducible", "Mplus_LCA_enum")
out   <- file.path(root, "advanced_reproducible", "_outputs")

parse_enum <- function(k) {
  f <- file.path(mp, paste0("enum_", k, "class.out"))
  if (!file.exists(f)) return(NULL)
  L <- readLines(f, warn = FALSE)
  num_after <- function(pat) {
    i <- grep(pat, L)[1]
    if (is.na(i)) return(NA_real_)
    as.numeric(regmatches(L[i], regexpr("-?[0-9]+\\.?[0-9]*\\s*$", L[i])))
  }
  ll <- num_after("^\\s+H0 Value")
  npar <- num_after("Number of Free Parameters")
  AIC <- num_after("Akaike \\(AIC\\)")
  BIC <- num_after("Bayesian \\(BIC\\)")
  aBIC<- num_after("Sample-Size Adjusted BIC")
  ent <- num_after("Entropy")
  ## class proportions (latent class prop) - take LARGEST among ".....   0.xxxxx"
  lc_idx <- grep("FINAL CLASS COUNTS AND PROPORTIONS FOR THE LATENT CLASSES", L)[1]
  if (is.na(lc_idx)) return(NULL)
  prop_lines <- L[(lc_idx+1):min(lc_idx+15, length(L))]
  props <- as.numeric(regmatches(prop_lines, regexpr("[0-9]\\.[0-9]+\\s*$", prop_lines)))
  smallest <- min(props, na.rm = TRUE)

  ## LMR (TECH11): "LO-MENDELL-RUBIN ADJUSTED LRT TEST" upper case in Mplus 7.0
  lmr_idx <- grep("LO-MENDELL-RUBIN ADJUSTED LRT TEST", L)[1]
  lmr_p <- if (!is.na(lmr_idx)) {
    pl <- L[(lmr_idx):(lmr_idx+10)]
    p_line <- pl[grep("P-Value\\s+[0-9]", pl)[1]]
    if (!is.na(p_line)) as.numeric(regmatches(p_line, regexpr("-?[0-9]+\\.?[0-9]*\\s*$", p_line)))
    else NA_real_
  } else NA_real_

  ## BLRT (TECH14): "Approximate P-Value" then "Successful Bootstrap Draws"
  blrt_idx <- grep("Approximate P-Value", L)[1]
  blrt_p <- if (!is.na(blrt_idx))
    as.numeric(regmatches(L[blrt_idx], regexpr("-?[0-9]+\\.?[0-9]*\\s*$", L[blrt_idx])))
  else NA_real_
  draws_idx <- grep("Successful Bootstrap Draws", L)[1]
  blrt_n <- if (!is.na(draws_idx))
    as.integer(regmatches(L[draws_idx], regexpr("[0-9]+\\s*$", L[draws_idx])))
  else NA_integer_

  tibble(K = k, LL = ll, npar = npar, AIC = AIC, BIC = BIC, aBIC = aBIC,
         Entropy = ent, smallest_class = round(smallest, 4),
         LMR_p = lmr_p, BLRT_p = blrt_p, BLRT_draws = blrt_n)
}

tbl <- bind_rows(lapply(2:6, parse_enum))
write.csv(tbl, file.path(out, "16_class_enumeration_table.csv"), row.names = FALSE)

sink(file.path(out, "16_summary.md"))
cat("# Class Enumeration — Responder-Only LCA\n\n")
cat("Indicators: Q40_1..Q40_8 + Q41_1..Q41_6 (14 binary).\n")
cat("Estimator: ML; STARTS = 1000 200; STITERATIONS = 20.\n\n")
cat("## Fit table\n\n")
print(tbl)
cat("\n## Decision criteria\n")
cat("- BIC (lower = better)\n")
cat("- aBIC (sample-size adjusted; lower = better)\n")
cat("- Entropy (>= .80 acceptable, >= .90 strong)\n")
cat("- Smallest class >= 5% to avoid micro-classes\n")
cat("- LMR p < .05 vs. k-1; BLRT p < .05 strongly favors k\n")
cat("- Theoretical interpretability\n\n")
sink()

cat("Wrote:\n",
    file.path(out, "16_class_enumeration_table.csv"), "\n",
    file.path(out, "16_summary.md"), "\n")
print(tbl)
