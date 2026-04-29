## ----------------------------------------------------------------------------
## 17. Descriptive class profile — "Who is in each class?"
##   For each of the 5 responder LCA classes, compute:
##     - Demographic: female, age, college, married, employed, one_person, disability
##     - Relational: intimate, known_nonint, gendered_case, own_victim
##     - Situational: severe_coharm, threat, freq_ord, dig, offcnt, total_type_count,
##                    coharm_count, negative_impact_count
##     - Attitudinal (mean): victim_blaming, crime_denial, stereotype, fear,
##                           cjs_distrust, gender_awareness, gender_hierarchy
##     - Education/exposure: stedu, any_violence_education
##     - Awareness: support_awareness, seoul_policy_awareness, role_police_top2
##
##   Methods:
##     - Categorical/binary -> BCH-weighted proportion + chi-square style Wald
##     - Continuous          -> BCH-weighted mean + Wald (already in 15_*)
##     - All p-values FDR(BH) corrected within block
##
##   Output:
##     _outputs/17_class_profile_table.csv  (publication Table 1 candidate)
##     _outputs/17_class_profile_pairwise.csv
##     _outputs/17_summary.md
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({ library(dplyr); library(tidyr); library(tibble) })

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
shared<- file.path(root, "advanced_reproducible", "_shared")
out   <- file.path(root, "advanced_reproducible", "_outputs")
mp_r3 <- file.path(root, "advanced_reproducible", "Mplus_responder_LCA_R3STEP")

## ---------- Load CPROB and recover BCH weights ----------
cp_path <- file.path(mp_r3, "responder_lca_5class_r3step_cprob.dat")
hdr <- c(paste0("Q40_", 1:8), paste0("Q41_", 1:6),
         "stedu","dig","offcnt","freqz","intimate","severe",
         "mythz","fearz","crimez","victimz","supportz",
         paste0("CPROB", 1:5), "Class")
cp <- read.table(cp_path, header = FALSE)
names(cp) <- hdr

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
bch_wt <- W[modal, , drop = FALSE]   # 501 x 5

## ---------- Bring in profile variables ----------
r <- readRDS(file.path(shared, "data_responder.rds"))
stopifnot(nrow(r) == nrow(cp))

cont_vars <- c("dig","offcnt","total_type_count","coharm_count",
               "negative_impact_count","prosocial_change_count","freq_ord",
               "victim_blaming","crime_denial","stereotype","fear",
               "cjs_distrust","gender_awareness","gender_hierarchy",
               "support_awareness","seoul_policy_awareness")
bin_vars  <- c("female","college","married","employed","one_person","disability",
               "intimate","known_nonint","gendered_case","own_victim",
               "severe_coharm","threat","stedu","any_violence_education",
               "online_withdrawal","digital_coharm","q40_police","q42_police",
               "role_police_top2")

## numeric age (we have age_cat as factor; create numeric midpoint)
age_mid <- c("10s"=15, "20s"=25, "30s"=35, "40s"=45, "50s"=55, "60s"=65)
r$age_num <- unname(age_mid[as.character(r$age_cat)])
cont_vars <- c("age_num", cont_vars)

## ---------- BCH-weighted summaries with Wald test ----------
bch_summarize <- function(y, wt, K, type = c("cont","bin")) {
  type <- match.arg(type)
  ok <- !is.na(y); ys <- y[ok]; ws <- wt[ok, , drop = FALSE]
  mu <- numeric(K); var_mu <- numeric(K); n_eff <- numeric(K)
  for (k in 1:K) {
    nk <- sum(ws[, k]); n_eff[k] <- nk
    mu[k]     <- sum(ws[, k] * ys) / nk
    var_mu[k] <- max(sum(ws[, k] * (ys - mu[k])^2) / (nk^2), 1e-12)
  }
  C <- matrix(0, K - 1, K)
  for (j in 1:(K - 1)) { C[j, j] <- 1; C[j, K] <- -1 }
  delta <- C %*% mu
  Sigma <- C %*% diag(var_mu) %*% t(C)
  W_overall <- as.numeric(t(delta) %*% solve(Sigma) %*% delta)
  p_overall <- 1 - pchisq(W_overall, K - 1)
  pair <- expand.grid(i = 1:K, j = 1:K) %>% filter(i < j)
  pair$diff   <- mu[pair$i] - mu[pair$j]
  pair$se     <- sqrt(var_mu[pair$i] + var_mu[pair$j])
  pair$z      <- pair$diff / pair$se
  pair$p_pair <- 2 * (1 - pnorm(abs(pair$z)))
  list(mu = mu, se = sqrt(var_mu), n_eff = n_eff,
       W = W_overall, df = K - 1, p = p_overall, pair = pair, type = type)
}

profile_rows <- list(); pairwise_rows <- list()

for (v in cont_vars) {
  if (!v %in% names(r)) next
  res <- bch_summarize(r[[v]], bch_wt, K, "cont")
  row <- data.frame(
    variable = v, type = "continuous",
    overall_mean = round(weighted.mean(r[[v]], rep(1, nrow(r)), na.rm = TRUE), 3),
    Wald = round(res$W, 2), df = res$df, p_overall = signif(res$p, 3))
  for (k in 1:K) {
    row[[paste0(class_labels[k], "_mean")]] <- round(res$mu[k], 3)
    row[[paste0(class_labels[k], "_se")]]   <- round(res$se[k], 3)
  }
  profile_rows[[v]] <- row
  pairwise_rows[[v]] <- res$pair %>%
    mutate(variable = v, type = "continuous",
           class_i = class_labels[i], class_j = class_labels[j]) %>%
    select(variable, type, class_i, class_j, diff, se, z, p_pair)
}

for (v in bin_vars) {
  if (!v %in% names(r)) next
  yv <- as.numeric(r[[v]])
  res <- bch_summarize(yv, bch_wt, K, "bin")
  ## Clip BCH-weighted proportions to [0,1] (manual BCH can produce out-of-range
  ## values when D matrix is ill-conditioned for very small classes); flag them.
  raw_mu <- res$mu
  out_of_range <- (raw_mu < 0) | (raw_mu > 1)
  res$mu <- pmin(pmax(raw_mu, 0), 1)
  row <- data.frame(
    variable = v, type = "binary",
    overall_mean = round(mean(yv, na.rm = TRUE), 3),
    Wald = round(res$W, 2), df = res$df, p_overall = signif(res$p, 3),
    n_classes_clipped = sum(out_of_range))
  for (k in 1:K) {
    row[[paste0(class_labels[k], "_mean")]] <- round(res$mu[k], 3)
    row[[paste0(class_labels[k], "_se")]]   <- round(res$se[k], 3)
  }
  profile_rows[[v]] <- row
  pairwise_rows[[v]] <- res$pair %>%
    mutate(variable = v, type = "binary",
           class_i = class_labels[i], class_j = class_labels[j]) %>%
    select(variable, type, class_i, class_j, diff, se, z, p_pair)
}

profile_df <- bind_rows(profile_rows) %>%
  mutate(p_fdr = p.adjust(p_overall, method = "BH"),
         sig   = ifelse(p_fdr < 0.001, "***",
                  ifelse(p_fdr < 0.01,  "**",
                  ifelse(p_fdr < 0.05,  "*",
                  ifelse(p_fdr < 0.10,  "†", ""))))) %>%
  arrange(type, variable)

pair_df <- bind_rows(pairwise_rows) %>%
  group_by(variable) %>%
  mutate(p_fdr = p.adjust(p_pair, method = "BH")) %>%
  ungroup()

write.csv(profile_df, file.path(out, "17_class_profile_table.csv"), row.names = FALSE)
write.csv(pair_df,    file.path(out, "17_class_profile_pairwise.csv"), row.names = FALSE)

## ---------- Markdown narrative summary ----------
sink(file.path(out, "17_summary.md"))
cat("# Descriptive Class Profile (Responder LCA, K = 5)\n\n")
cat("Method: BCH-weighted means/proportions; overall Wald with K-1 df; FDR(BH) within table.\n\n")

cat("## Class sizes (modal)\n\n")
sizes <- table(modal)
for (k in 1:K) cat(sprintf("- %s: n = %d (%.1f%%)\n", class_labels[k],
                           sizes[k], 100 * sizes[k] / sum(sizes)))
cat("\n")

cat("## Significant variables (q < .05) — what makes each class distinct\n\n")
sig_tbl <- profile_df %>% filter(p_fdr < 0.05) %>%
  select(variable, type, overall_mean, Wald, df, p_overall, p_fdr, sig,
         all_of(paste0(class_labels, "_mean")))
sig_df <- as.data.frame(sig_tbl)
sig_df[] <- lapply(sig_df, function(x) { if (is.numeric(x)) ifelse(is.nan(x), NA, x) else x })
print(sig_df, row.names = FALSE)

cat("\n\n## Class-by-class narrative (top distinguishing features)\n\n")
for (k in 1:K) {
  cat(sprintf("### %s (n = %d, %.1f%%)\n\n", class_labels[k],
              sizes[k], 100 * sizes[k] / sum(sizes)))
  cls_col <- paste0(class_labels[k], "_mean")
  se_col  <- paste0(class_labels[k], "_se")
  pf <- profile_df %>%
    filter(p_fdr < 0.05) %>%
    mutate(class_val = .[[cls_col]],
           class_se  = .[[se_col]],
           dev_z     = (class_val - overall_mean) / pmax(class_se, 1e-6)) %>%
    arrange(desc(abs(dev_z))) %>%
    head(8) %>%
    select(variable, type, overall_mean, class_val, dev_z)
  pf_df <- as.data.frame(pf)
  pf_df[] <- lapply(pf_df, function(x) { if (is.numeric(x)) ifelse(is.nan(x), NA, x) else x })
  print(pf_df, row.names = FALSE)
  cat("\n")
}

sink()

cat("Wrote:\n",
    file.path(out, "17_class_profile_table.csv"), "\n",
    file.path(out, "17_class_profile_pairwise.csv"), "\n",
    file.path(out, "17_summary.md"), "\n\n")

## quick console preview
cat("=== Variables with FDR-significant class differences ===\n")
preview <- as.data.frame(profile_df %>% filter(p_fdr < 0.05) %>%
  select(variable, type, overall_mean, p_fdr, sig))
preview[] <- lapply(preview, function(x) { if (is.numeric(x)) ifelse(is.nan(x), NA, x) else x })
print(preview, row.names = FALSE)
