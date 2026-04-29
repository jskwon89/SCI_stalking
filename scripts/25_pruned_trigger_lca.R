## ----------------------------------------------------------------------------
## 25. Pruned-trigger LCA sensitivity
##
## Purpose:
##   Check whether the primary Q40+Q41 5-class structure remains interpretable
##   after removing trigger items involved in the strongest local-dependence
##   pairs: Q41_2 (escalation) and Q41_3 (others harmed).
##
## Sample:
##   Active responders only (N = 501), from _shared/data_responder.rds
##
## Indicators:
##   Q40_1..Q40_8 + Q41_1, Q41_4, Q41_5, Q41_6.
##
## Outputs:
##   Mplus_pruned_trigger_LCA/pruned_2..6class.*
##   _outputs/25_pruned_fit.csv
##   _outputs/25_pruned_item_response.csv
##   _outputs/25_pruned_class_sizes.csv
##   _outputs/25_pruned_summary.md
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({ library(dplyr); library(tibble) })

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
adv  <- file.path(root, "advanced_reproducible")
shared <- file.path(adv, "_shared")
mp   <- file.path(adv, "Mplus_pruned_trigger_LCA")
out  <- file.path(adv, "_outputs")
mplus_exe <- "C:/Program Files/Mplus/Mplus.exe"
dir.create(mp, recursive = TRUE, showWarnings = FALSE)
dir.create(out, recursive = TRUE, showWarnings = FALSE)

r <- readRDS(file.path(shared, "data_responder.rds"))
stopifnot(nrow(r) == 501)

q40_full <- paste0("Q40_", 1:8)
q41_full <- c("Q41_1", "Q41_4", "Q41_5", "Q41_6")
ind_full <- c(q40_full, q41_full)
ind_short <- c(paste0("a", 1:8), "b1", "b4", "b5", "b6")
ind_label <- c("Confront", "Persuade", "Job/school exit", "Shelter/move",
               "School/work help", "Network help", "Police", "Agency counseling",
               "Not romance", "Life threat", "Daily disruption", "Prevent another harm")

dat <- r[, ind_full]
names(dat) <- ind_short
dat[is.na(dat)] <- -999
write.table(dat, file.path(mp, "pruned_trigger_data.dat"),
            sep = " ", row.names = FALSE, col.names = FALSE, quote = FALSE)

write_inputs <- function(k) {
  names_str <- paste(ind_short, collapse = " ")
  inp <- paste0(
'TITLE: Pruned-trigger LCA k=', k, ';
DATA: FILE = "pruned_trigger_data.dat";
VARIABLE:
  NAMES = ', names_str, ';
  USEVARIABLES = ', names_str, ';
  CATEGORICAL = ', names_str, ';
  CLASSES = c(', k, ');
  MISSING = ALL(-999);
ANALYSIS:
  TYPE = MIXTURE;
  STARTS = 1000 250;
  STITERATIONS = 20;
  LRTSTARTS = 0 0 200 50;
  PROCESSORS = 4;
OUTPUT:
  SAMPSTAT TECH1 TECH10 TECH11 TECH14;
SAVEDATA:
  FILE = pruned_', k, 'class.dat;
  SAVE = CPROBABILITIES;
')
  writeLines(inp, file.path(mp, paste0("pruned_", k, "class.inp")))
}
invisible(lapply(2:6, write_inputs))

force_mplus <- as.logical(Sys.getenv("FORCE_MPLUS", "FALSE"))
run_mplus_one <- function(k) {
  inp <- paste0("pruned_", k, "class.inp")
  out_file <- file.path(mp, paste0("pruned_", k, "class.out"))
  cprob_file <- file.path(mp, paste0("pruned_", k, "class.dat"))
  if (!force_mplus && file.exists(out_file) && file.info(out_file)$size > 50000 &&
      file.exists(cprob_file) && file.info(cprob_file)$size > 0) {
    cat("Mplus skip:", inp, "\n")
    return(invisible(TRUE))
  }
  old <- getwd()
  on.exit(setwd(old), add = TRUE)
  setwd(mp)
  cat("Mplus run:", inp, "\n")
  system2(mplus_exe, args = shQuote(inp), stdout = TRUE, stderr = TRUE)
  if (!file.exists(out_file)) stop("Mplus output missing: ", out_file)
  L <- readLines(out_file, warn = FALSE)
  if (!any(grepl("THE MODEL ESTIMATION TERMINATED NORMALLY", L))) {
    stop("Mplus did not terminate normally for ", inp)
  }
  invisible(TRUE)
}
invisible(lapply(2:6, run_mplus_one))

num_after <- function(L, pat) {
  i <- grep(pat, L)[1]
  if (is.na(i)) return(NA_real_)
  as.numeric(regmatches(L[i], regexpr("-?[0-9]+\\.?[0-9]*\\s*$", L[i])))
}

parse_enum <- function(k) {
  f <- file.path(mp, paste0("pruned_", k, "class.out"))
  if (!file.exists(f)) return(NULL)
  L <- readLines(f, warn = FALSE)
  lc_idx <- grep("FINAL CLASS COUNTS AND PROPORTIONS FOR THE LATENT CLASSES", L)[1]
  props <- NA_real_
  if (!is.na(lc_idx)) {
    prop_lines <- L[(lc_idx + 1):min(lc_idx + 15, length(L))]
    props <- as.numeric(regmatches(prop_lines, regexpr("[0-9]\\.[0-9]+\\s*$", prop_lines)))
  }
  lmr_idx <- grep("LO-MENDELL-RUBIN ADJUSTED LRT TEST", L)[1]
  lmr_p <- if (!is.na(lmr_idx)) {
    pl <- L[lmr_idx:min(lmr_idx + 10, length(L))]
    p_line <- pl[grep("P-Value\\s+[0-9]", pl)[1]]
    if (!is.na(p_line)) as.numeric(regmatches(p_line, regexpr("-?[0-9]+\\.?[0-9]*\\s*$", p_line))) else NA_real_
  } else NA_real_
  blrt_idx <- grep("Approximate P-Value", L)[1]
  draws_idx <- grep("Successful Bootstrap Draws", L)[1]
  tibble(
    K = k,
    LL = num_after(L, "^\\s+H0 Value"),
    npar = num_after(L, "Number of Free Parameters"),
    AIC = num_after(L, "Akaike \\(AIC\\)"),
    BIC = num_after(L, "Bayesian \\(BIC\\)"),
    aBIC = num_after(L, "Sample-Size Adjusted BIC"),
    Entropy = num_after(L, "Entropy"),
    smallest_class = round(min(props, na.rm = TRUE), 4),
    LMR_p = lmr_p,
    BLRT_p = if (!is.na(blrt_idx)) as.numeric(regmatches(L[blrt_idx], regexpr("-?[0-9]+\\.?[0-9]*\\s*$", L[blrt_idx]))) else NA_real_,
    BLRT_draws = if (!is.na(draws_idx)) as.integer(regmatches(L[draws_idx], regexpr("[0-9]+\\s*$", L[draws_idx]))) else NA_integer_
  )
}

parse_icp <- function(k) {
  f <- file.path(mp, paste0("pruned_", k, "class.out"))
  if (!file.exists(f)) return(NULL)
  L <- readLines(f, warn = FALSE)
  start <- grep("RESULTS IN PROBABILITY SCALE", L)[1]
  if (is.na(start)) return(NULL)
  end_candidates <- grep("QUALITY OF NUMERICAL|TECHNICAL [0-9]+ OUTPUT|LATENT CLASS REGRESSION", L)
  end_candidates <- end_candidates[end_candidates > start]
  end <- if (length(end_candidates) > 0) end_candidates[1] else length(L)
  block <- L[start:end]
  cls_idx <- grep("^\\s*Latent Class\\s+[0-9]+", block)
  cls_num <- as.integer(regmatches(block[cls_idx], regexpr("[0-9]+", block[cls_idx])))
  recs <- list()
  for (i in seq_along(cls_idx)) {
    s <- cls_idx[i]
    e <- if (i < length(cls_idx)) cls_idx[i + 1] - 1 else length(block)
    sub <- block[s:e]
    item_idx <- grep("^\\s+[AB][0-9]+\\s*$|^\\s+[A-Z][0-9]+\\s*$", sub)
    for (j in item_idx) {
      item_name <- tolower(trimws(sub[j]))
      if (!item_name %in% ind_short) next
      cat2 <- grep("Category 2", sub[(j + 1):min(j + 8, length(sub))])
      if (length(cat2) == 0) next
      val_line <- sub[j + cat2[1]]
      val <- as.numeric(regmatches(val_line, regexpr("0\\.[0-9]+|1\\.0+|1$", val_line))[1])
      recs[[length(recs) + 1]] <- data.frame(
        K = k, class = cls_num[i], item = item_name, prob_yes = val
      )
    }
  }
  bind_rows(recs)
}

fit <- bind_rows(lapply(2:6, parse_enum))
fit <- fit %>%
  mutate(CAIC = -2 * LL + npar * (log(nrow(r)) + 1),
         AWE = -2 * LL + 2 * npar * (log(nrow(r)) + 1.5))
write.csv(fit, file.path(out, "25_pruned_fit.csv"), row.names = FALSE)

icp <- bind_rows(lapply(2:6, parse_icp)) %>%
  mutate(item_full = ind_full[match(item, ind_short)],
         item_label = ind_label[match(item, ind_short)]) %>%
  arrange(K, class, match(item, ind_short))
write.csv(icp, file.path(out, "25_pruned_item_response.csv"), row.names = FALSE)

class_sizes <- bind_rows(lapply(2:6, function(k) {
  f <- file.path(mp, paste0("pruned_", k, "class.dat"))
  if (!file.exists(f) || file.info(f)$size == 0) return(NULL)
  d <- read.table(f, header = FALSE)
  modal <- d[, ncol(d)]
  as.data.frame(table(factor(modal, levels = 1:k))) %>%
    transmute(K = k, class = as.integer(as.character(Var1)), n = Freq,
              proportion = n / sum(n))
}))
write.csv(class_sizes, file.path(out, "25_pruned_class_sizes.csv"), row.names = FALSE)

sink(file.path(out, "25_pruned_summary.md"))
cat("# Pruned-Trigger LCA Sensitivity\n\n")
cat("Sample: active responders only, N =", nrow(r), "\n\n")
cat("Indicators: Q40_1..Q40_8 + Q41_1, Q41_4, Q41_5, Q41_6.\n\n")
cat("Removed trigger items: Q41_2 (Escalation), Q41_3 (Others harmed), because they were involved in top local-dependence BVR pairs.\n\n")
cat("## Fit table\n\n")
print(fit)
cat("\n## 5-class item-response probabilities\n\n")
print(icp %>% filter(K == 5))
cat("\n## 5-class class sizes\n\n")
print(class_sizes %>% filter(K == 5))
sink()

cat("Wrote:\n",
    file.path(out, "25_pruned_fit.csv"), "\n",
    file.path(out, "25_pruned_item_response.csv"), "\n",
    file.path(out, "25_pruned_class_sizes.csv"), "\n",
    file.path(out, "25_pruned_summary.md"), "\n")
