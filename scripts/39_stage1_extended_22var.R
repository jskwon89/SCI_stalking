## ----------------------------------------------------------------------------
## 39. Stage 1 logistic regression — extended 22-variable specification
##
##   Reviewer concern: Table 2 (Stage 1, 11 predictors) does not include the
##   external profile variables of Table 4 (28 rows total). To address this,
##   refit the Stage 1 logit using all 22 external predictors of Table 4
##   (Table 4's 28 rows minus 6 response-repertoire indicators which are
##   synonymous with the outcome).
##
##   Multicollinearity rule: offline (Q31, 0–6) + digital (Q32, 0–3) sums to
##   total_type_count (0–9). The three are deterministically dependent. Per
##   reviewer note we use total_type_count_z only and drop offcnt+dig.
##   Net regression coefficients = 21 (variable pool = 22).
##
##   Outcome  : active_response = (Q40_9 != 1)   n = 501 / 749
##   Sample   : witnesses (witness_any == 1)
##   Adjust   : 자치구 (district) dummies — Q2, 25 levels
##   SE       : HC3 sandwich (manual; sandwich pkg unavailable for R 4.5.x bin)
##   FDR      : BH within model
##   Diag     : car::vif (GVIF), LR test baseline ⊂ extended (same complete-case)
##
##   Outputs (under <root>/advanced_reproducible/_outputs/):
##     39_stage1_baseline_11var.csv
##     39_stage1_extended_22var.csv
##     39_stage1_VIF.csv
##     39_stage1_summary.md
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({ library(car); library(tibble); library(dplyr) })

root  <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
shared<- file.path(root, "advanced_reproducible", "_shared")
out   <- file.path(root, "advanced_reproducible", "_outputs")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

w <- readRDS(file.path(shared, "data_witness.rds"))   # 749
stopifnot(nrow(w) == 749)
## Build coharm_count_z, negative_impact_count_z, gender_hierarchy_z if missing
w$age_num <- if ("age_num" %in% names(w)) w$age_num else
  unname(c("10s"=15,"20s"=25,"30s"=35,"40s"=45,"50s"=55,"60s"=65)[as.character(w$age_cat)])
w$district <- factor(w$Q2)
w$total_type_count_z       <- as.numeric(scale(w$total_type_count))
w$coharm_count_z           <- as.numeric(scale(w$coharm_count))
w$negative_impact_count_z  <- as.numeric(scale(w$negative_impact_count))
w$gender_hierarchy_z       <- as.numeric(scale(w$gender_hierarchy))
## Original Table 2 used the raw 0–9 total
if (!"total_type_count" %in% names(w)) w$total_type_count <- w$dig + w$offcnt

## ---- HC3 (manual; same algebra as sandwich::vcovHC type="HC3") --------------
vcovHC3_glm <- function(fit) {
  X  <- model.matrix(fit); mu <- fitted(fit); y <- model.response(model.frame(fit))
  W  <- mu * (1 - mu)
  bread <- solve(crossprod(X * sqrt(W)))
  H_diag <- rowSums((X %*% bread) * (X * W))
  H_diag <- pmin(pmax(H_diag, 0), 1 - 1e-8)
  meat <- crossprod(X * ((y - mu) / (1 - H_diag)))
  V <- bread %*% meat %*% bread
  dimnames(V) <- list(colnames(X), colnames(X)); V
}
coeftest_HC3 <- function(fit) {
  V <- vcovHC3_glm(fit); est <- coef(fit); se <- sqrt(diag(V))
  z <- est/se; p <- 2 * pnorm(-abs(z))
  cbind(Estimate = est, `Std. Error` = se, `z value` = z, `Pr(>|z|)` = p)
}

## ---- Predictor sets ---------------------------------------------------------
preds_baseline_11 <- c(
  "female","college","own_victim",
  "total_type_count","threat","freq_ord_z",
  "severe_coharm","intimate",
  "stedu","support_awareness_z","seoul_policy_awareness_z"
)
preds_extended_22 <- c(
  "female","age_num","college","married","one_person","own_victim",
  "total_type_count_z","freq_ord_z","threat",
  "intimate","known_nonint","gendered_case",
  "severe_coharm","coharm_count_z","negative_impact_count_z","online_withdrawal",
  "stedu","any_violence_education",
  "support_awareness_z","seoul_policy_awareness_z","gender_hierarchy_z"
)

fit_dist <- function(df, y, preds) {
  cols <- unique(c(y, preds, "district"))
  dat <- df[, cols]; dat <- dat[complete.cases(dat), ]
  fml <- as.formula(paste(y, "~", paste(c(preds, "district"), collapse = " + ")))
  list(fit = glm(fml, data = dat, family = binomial()), dat = dat, fml = fml)
}
tidy_hc3 <- function(res, predictor_set, label) {
  ct <- coeftest_HC3(res$fit); rn <- rownames(ct); k <- rn %in% predictor_set
  est <- ct[k,"Estimate"]; se <- ct[k,"Std. Error"]
  z <- ct[k,"z value"];    p  <- ct[k,"Pr(>|z|)"]
  q <- p.adjust(p, method = "BH")
  tibble(model=label, term=rn[k], aOR=exp(est),
         CI_lo=exp(est-1.96*se), CI_hi=exp(est+1.96*se),
         p=p, q_BH=q, B=est, SE_HC3=se, z=z)
}

res_b <- fit_dist(w, "active_response", preds_baseline_11)
res_e <- fit_dist(w, "active_response", preds_extended_22)
tab_b <- tidy_hc3(res_b, preds_baseline_11, "baseline_11")
tab_e <- tidy_hc3(res_e, preds_extended_22, "extended_22")

vif_e <- car::vif(res_e$fit)
vif_e_df <- if (is.matrix(vif_e)) {
  data.frame(term=rownames(vif_e), GVIF=vif_e[,1], df=vif_e[,2],
             GVIF_adj=vif_e[,1]^(1/(2*vif_e[,2])))
} else {
  data.frame(term=names(vif_e), GVIF=unname(vif_e),
             df=1, GVIF_adj=sqrt(unname(vif_e)))
}
vif_e_df <- vif_e_df[vif_e_df$term != "district", ]

common_cols <- unique(c("active_response", preds_baseline_11, preds_extended_22, "district"))
common_dat  <- w[, common_cols]; common_dat <- common_dat[complete.cases(common_dat), ]
fit_b_c <- glm(reformulate(c(preds_baseline_11,"district"),"active_response"),
               data=common_dat, family=binomial())
fit_e_c <- glm(reformulate(c(preds_extended_22,"district"),"active_response"),
               data=common_dat, family=binomial())
lr <- anova(fit_b_c, fit_e_c, test="Chisq")

write.csv(tab_b, file.path(out, "39_stage1_baseline_11var.csv"), row.names=FALSE)
write.csv(tab_e, file.path(out, "39_stage1_extended_22var.csv"), row.names=FALSE)
write.csv(vif_e_df, file.path(out, "39_stage1_VIF.csv"), row.names=FALSE)

sink(file.path(out, "39_stage1_summary.md"))
cat("# Stage 1 Logistic — Baseline (11) vs Extended (22-pool / 21 coef.)\n\n")
cat(sprintf("N(witnesses) = %d, active = %d\n", nrow(w), sum(w$active_response==1)))
cat("Adjustment: 자치구 더미 (Q2, 25 levels). SE = HC3 (manual). q = BH-FDR within model.\n\n")
fmt <- function(r) sprintf("%-28s aOR=%5.2f [%4.2f, %4.2f]   p=%7.4f   q=%7.4f",
                           r$term, r$aOR, r$CI_lo, r$CI_hi, r$p, r$q_BH)
cat("## Baseline (11)\n\n```\n"); for (i in seq_len(nrow(tab_b))) cat(fmt(tab_b[i,]),"\n"); cat("```\n\n")
cat("## Extended (22-pool, 21 coef.)\n\n```\n"); for (i in seq_len(nrow(tab_e))) cat(fmt(tab_e[i,]),"\n"); cat("```\n\n")
cat("## VIF\n\n```\n")
for (i in seq_len(nrow(vif_e_df))) cat(sprintf("%-28s GVIF=%5.2f df=%d adj=%5.2f\n",
  vif_e_df$term[i], vif_e_df$GVIF[i], vif_e_df$df[i], vif_e_df$GVIF_adj[i]))
cat("```\n\n## LR test (same complete-case sample)\n\n```\n"); print(lr); cat("```\n\n")
cat("## Δ aOR — focal four\n\n```\n")
cat(sprintf("%-22s %12s %12s %12s %12s\n","term","baseline_aOR","q","extended_aOR","q"))
for (v in c("stedu","severe_coharm","freq_ord_z","intimate")) {
  rb <- tab_b[tab_b$term==v,]; re <- tab_e[tab_e$term==v,]
  if (nrow(rb)&&nrow(re)) cat(sprintf("%-22s %12.3f %12.4f %12.3f %12.4f\n",
                                       v, rb$aOR, rb$q_BH, re$aOR, re$q_BH))
}
cat("```\n")
sink()
cat("Wrote:", file.path(out,"39_stage1_*.csv|md"), "\n")
