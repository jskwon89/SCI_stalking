## ----------------------------------------------------------------------------
## 20. Approximate local-dependence diagnostics for the selected 5-class LCA
##
## This script computes binary item-pair bivariate residuals (BVRs) from:
##   - observed Q40/Q41 item responses saved by Mplus CPROBABILITIES
##   - 5-class item-response probabilities parsed in script 19
##   - posterior class proportions from enum_5class.dat
##
## It is not a replacement for a full Mplus TECH10 review, but it gives a
## reproducible screening table for likely local dependence.
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({ library(dplyr); library(tidyr) })

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
adv  <- file.path(root, "advanced_reproducible")
mp   <- file.path(adv, "Mplus_LCA_enum")
out  <- file.path(adv, "_outputs")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

ind_short <- c(paste0("a", 1:8), paste0("b", 1:6))
ind_full  <- c(paste0("Q40_", 1:8), paste0("Q41_", 1:6))
ind_label <- c("Confront","Persuade","Job/school exit","Shelter/move",
               "School/work help","Network help","Police","Agency counseling",
               "Not romance","Escalation","Others harmed","Life threat",
               "Daily disruption","Prevent another harm")

cprob_file <- file.path(mp, "enum_5class.dat")
icc_file   <- file.path(out, "19_item_response_probabilities.csv")
stopifnot(file.exists(cprob_file), file.exists(icc_file))

cprob <- read.table(cprob_file, header = FALSE)
items <- as.matrix(cprob[, seq_along(ind_short)])
post  <- as.matrix(cprob[, (length(ind_short) + 1):(length(ind_short) + 5)])
pi_hat <- colMeans(post, na.rm = TRUE)
pi_hat <- pi_hat / sum(pi_hat)

icc <- read.csv(icc_file)
icc5 <- icc %>%
  filter(K == 5) %>%
  arrange(match(item, toupper(ind_short)), class)

p_mat <- matrix(NA_real_, nrow = 5, ncol = length(ind_short),
                dimnames = list(paste0("C", 1:5), toupper(ind_short)))
for (j in seq_along(ind_short)) {
  sub <- icc5 %>% filter(item == toupper(ind_short[j])) %>% arrange(class)
  p_mat[, j] <- sub$prob_yes
}

pair_bvr <- function(j, k) {
  x <- items[, j]
  y <- items[, k]
  keep <- !is.na(x) & !is.na(y) & x %in% c(0, 1) & y %in% c(0, 1)
  x <- x[keep]
  y <- y[keep]
  n <- length(x)

  obs <- matrix(0, nrow = 2, ncol = 2, dimnames = list(x = c("0","1"), y = c("0","1")))
  tab <- table(factor(x, levels = c(0, 1)), factor(y, levels = c(0, 1)))
  obs[,] <- as.numeric(tab)

  pj <- p_mat[, j]
  pk <- p_mat[, k]
  exp_prob <- matrix(0, nrow = 2, ncol = 2)
  exp_prob[1, 1] <- sum(pi_hat * (1 - pj) * (1 - pk))
  exp_prob[1, 2] <- sum(pi_hat * (1 - pj) * pk)
  exp_prob[2, 1] <- sum(pi_hat * pj * (1 - pk))
  exp_prob[2, 2] <- sum(pi_hat * pj * pk)
  exp <- n * exp_prob

  bvr <- sum((obs - exp)^2 / pmax(exp, 1e-8))
  std_resid <- (obs - exp) / sqrt(pmax(exp, 1e-8))
  data.frame(
    item1 = ind_full[j],
    item2 = ind_full[k],
    label1 = ind_label[j],
    label2 = ind_label[k],
    n_pair = n,
    bvr_chisq = bvr,
    p_value = pchisq(bvr, df = 1, lower.tail = FALSE),
    max_abs_std_resid = max(abs(std_resid)),
    stringsAsFactors = FALSE
  )
}

res <- bind_rows(lapply(seq_len(length(ind_short) - 1), function(j) {
  bind_rows(lapply((j + 1):length(ind_short), function(k) pair_bvr(j, k)))
})) %>%
  mutate(p_fdr_BH = p.adjust(p_value, method = "BH"),
         flag_bvr_gt_3_84 = bvr_chisq > 3.84) %>%
  arrange(desc(bvr_chisq))

write.csv(res, file.path(out, "20_local_dependence_bvr.csv"), row.names = FALSE)

sink(file.path(out, "20_summary.md"))
cat("# Approximate Local-Dependence Diagnostics\n\n")
cat("Selected model: 5-class responder LCA. Diagnostic: binary item-pair BVR from observed vs model-implied two-way tables.\n\n")
cat("Pairs checked:", nrow(res), "\n\n")
cat("Pairs with BVR > 3.84:", sum(res$flag_bvr_gt_3_84), "\n\n")
cat("Pairs with FDR q < .05:", sum(res$p_fdr_BH < .05), "\n\n")
cat("## Top 15 item pairs\n\n")
print(head(res, 15))
cat("\nInterpretation: large BVRs identify item pairs that may retain residual association after conditioning on class membership. ")
cat("Use this as a screening sensitivity check; if the same pairs are theoretically redundant, combine or discuss them.\n")
sink()

cat("Wrote:", file.path(out, "20_local_dependence_bvr.csv"), "\n")
cat("Wrote:", file.path(out, "20_summary.md"), "\n")
