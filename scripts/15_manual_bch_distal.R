## ----------------------------------------------------------------------------
## 15. Manual BCH for distal outcomes (Mplus 7.0 lacks BCH/DCAT)
##
##   STATUS (per reviewer audit): SENSITIVITY analysis only.
##   Primary external-validation analyses are now:
##     - Modal-class ANOVA/Welch/KW + Tukey HSD (file 18, continuous)
##     - Modal-class chi-square + Fisher + Bonferroni (file 18, binary)
##   Reason: BCH-style weighting can produce binary proportions outside [0,1]
##   when D matrix is moderately ill-conditioned (esp. small classes), and the
##   manual SE does not propagate uncertainty in the D matrix itself. We
##   therefore CLIP binary proportions to [0,1] and explicitly flag any
##   clipping in the output.
## ----------------------------------------------------------------------------
##   Steps:
##     1. Read CPROB from responder_lca_5class_r3step_cprob.dat
##     2. Compute D = E[CPROB | modal class] (5x5 classification accuracy)
##     3. W = solve(D); BCH weight w_ik for person i, class k = W[modal_i, k]
##     4. For each distal Y, compute weighted class mean (binary -> proportion)
##     5. Wald test of equality across classes
##   Outputs:
##     _outputs/15_bch_class_means.csv
##     _outputs/15_bch_wald_overall.csv
##     _outputs/15_bch_pairwise.csv
##     _outputs/15_summary.md
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({ library(dplyr); library(tidyr); library(tibble) })

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
shared<- file.path(root, "advanced_reproducible", "_shared")
out   <- file.path(root, "advanced_reproducible", "_outputs")
mp_r3 <- file.path(root, "advanced_reproducible", "Mplus_responder_LCA_R3STEP")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

cp_path <- file.path(mp_r3, "responder_lca_5class_r3step_cprob.dat")
hdr <- c(paste0("Q40_", 1:8), paste0("Q41_", 1:6),
         "stedu","dig","offcnt","freqz","intimate","severe",
         "mythz","fearz","crimez","victimz","supportz",
         paste0("CPROB", 1:5), "Class")
cp <- read.table(cp_path, header = FALSE)
stopifnot(ncol(cp) == length(hdr))
names(cp) <- hdr
cat("R3STEP CPROB rows = ", nrow(cp), "\n", sep = "")

K <- 5
class_labels <- c("Network_oriented_prevention","Escalation_aware_mixed",
                  "Life_threat_protective","Boundary_clarification",
                  "Multi_action_institutional")

cprob_mat <- as.matrix(cp[, paste0("CPROB", 1:K)])
modal     <- as.integer(cp$Class)

D <- matrix(0, K, K)
for (s in 1:K) {
  rows <- which(modal == s)
  D[s, ] <- if (length(rows) == 0) rep(0, K) else colMeans(cprob_mat[rows, , drop = FALSE])
}
W <- solve(D)
diag_D <- diag(D)
cat("Classification diagonal accuracy:", paste(round(diag_D, 3), collapse = ", "), "\n")

bch_wt <- W[modal, , drop = FALSE]   # n x K

## Bring in distals from witness data (responder subset must match cp rows)
r <- readRDS(file.path(shared, "data_responder.rds"))
stopifnot(nrow(r) == nrow(cp))

distals <- list(
  online_withdrawal     = r$online_withdrawal,
  digital_coharm        = r$digital_coharm,
  q42_police            = r$q42_police,
  role_police_top2      = r$role_police_top2,
  support_awareness     = r$support_awareness,
  seoul_policy_awareness= r$seoul_policy_awareness,
  freq_ord              = r$freq_ord,
  severe_coharm         = r$severe_coharm,
  intimate              = r$intimate,
  fear                  = r$fear,
  crime_denial          = r$crime_denial
)

bch_test <- function(y, wt, K) {
  ok <- !is.na(y); ys <- y[ok]; ws <- wt[ok, , drop = FALSE]
  mu <- numeric(K); var_mu <- numeric(K)
  for (k in 1:K) {
    nk <- sum(ws[, k])
    mu[k]     <- sum(ws[, k] * ys) / nk
    var_mu[k] <- sum(ws[, k] * (ys - mu[k])^2) / (nk^2)
  }
  ## Overall Wald with K-1 contrasts (k vs K)
  C <- matrix(0, K - 1, K)
  for (j in 1:(K - 1)) { C[j, j] <- 1; C[j, K] <- -1 }
  delta <- C %*% mu
  Sigma <- C %*% diag(var_mu) %*% t(C)
  W_overall <- as.numeric(t(delta) %*% solve(Sigma) %*% delta)
  p_overall <- 1 - pchisq(W_overall, K - 1)
  ## Pairwise Wald
  pair <- expand.grid(i = 1:K, j = 1:K) %>% filter(i < j)
  pair$diff   <- mu[pair$i] - mu[pair$j]
  pair$se     <- sqrt(var_mu[pair$i] + var_mu[pair$j])
  pair$z      <- pair$diff / pair$se
  pair$p_pair <- 2 * (1 - pnorm(abs(pair$z)))
  list(mu = mu, se = sqrt(var_mu), W = W_overall, df = K - 1, p = p_overall, pair = pair)
}

## Variables that are binary -> clip mean to [0,1] and flag
binary_distals <- c("online_withdrawal","digital_coharm","q42_police",
                    "role_police_top2","severe_coharm","intimate")

class_means <- list(); wald_tab <- list(); pair_tab <- list()
for (nm in names(distals)) {
  res <- bch_test(distals[[nm]], bch_wt, K)
  ## Clip binary proportions to [0,1] and note out-of-range cases
  is_bin <- nm %in% binary_distals
  raw_mu <- res$mu
  if (is_bin) {
    out_of_range <- (raw_mu < 0) | (raw_mu > 1)
    res$mu <- pmin(pmax(raw_mu, 0), 1)
  } else {
    out_of_range <- rep(FALSE, K)
  }
  class_means[[nm]] <- tibble(
    distal = nm,
    class  = 1:K,
    label  = class_labels,
    mean   = res$mu,
    raw_mean = raw_mu,
    clipped = is_bin & out_of_range,
    se     = res$se
  )
  wald_tab[[nm]] <- tibble(
    distal = nm, Wald = res$W, df = res$df, p_overall = res$p
  )
  pair_tab[[nm]] <- res$pair %>%
    mutate(distal = nm,
           class_i = class_labels[i], class_j = class_labels[j]) %>%
    select(distal, class_i, class_j, diff, se, z, p_pair)
}

class_means_df <- bind_rows(class_means)
wald_df        <- bind_rows(wald_tab) %>%
  mutate(p_fdr = p.adjust(p_overall, method = "BH"),
         sig   = ifelse(p_fdr < 0.001, "***", ifelse(p_fdr < 0.01, "**", ifelse(p_fdr < 0.05, "*", ""))))
pair_df        <- bind_rows(pair_tab) %>%
  group_by(distal) %>% mutate(p_fdr = p.adjust(p_pair, method = "BH")) %>% ungroup()

write.csv(class_means_df, file.path(out, "15_bch_class_means.csv"), row.names = FALSE)
write.csv(wald_df,        file.path(out, "15_bch_wald_overall.csv"), row.names = FALSE)
write.csv(pair_df,        file.path(out, "15_bch_pairwise.csv"), row.names = FALSE)

## summary md
sink(file.path(out, "15_summary.md"))
cat("# BCH-style class differences on distal outcomes (manual implementation)\n\n")
cat("Mplus 7.0 lacks AUXILIARY = ...(BCH); manual BCH using R3STEP CPROB.\n\n")
cat("Classification diagonal D:", paste(round(diag_D, 3), collapse = ", "), "\n\n")
cat("## Overall Wald test of class equality (with FDR-BH correction across distals)\n\n")
print(wald_df %>% select(distal, Wald, df, p_overall, p_fdr, sig), n = Inf)
cat("\n## Class means (binary -> proportion; continuous -> mean) by distal\n\n")
print(class_means_df, n = Inf)
sink()

cat("Wrote:\n",
    file.path(out, "15_bch_class_means.csv"), "\n",
    file.path(out, "15_bch_wald_overall.csv"), "\n",
    file.path(out, "15_bch_pairwise.csv"), "\n",
    file.path(out, "15_summary.md"), "\n")
