## ----------------------------------------------------------------------------
## 40. Stage 1 logistic regression — composite 18-variable specification (Model D)
##
##   Reviewer concern: in script 39 (Extended 22-var), stedu and severe_coharm
##   attenuate to non-significance because they share concept-space with
##   any_violence_education and coharm_count respectively (GVIF 3.34 / 3.41).
##
##   Composite definition (each component z-standardized then averaged):
##     1) any_violence_edu       : single (stedu dropped)
##     2) harm_breadth_z         = mean( z(severe_coharm), z(coharm_count) )
##     3) impact_severity_z      = mean( z(negative_impact_count), z(online_withdrawal) )
##
##   Total predictors = 18 (other variables identical to script 39).
##
##   Outcome  : active_response (Q40_9 != 1)   n = 501 / 749
##   Adjust   : 자치구 (district) dummies — Q2, 25 levels
##   SE       : HC3 sandwich (manual; sandwich pkg not on CRAN binary for R 4.5.x)
##   FDR      : BH within model (18 cells)
##   Diag     : car::vif (GVIF), composite internal consistency
##              (Pearson r, Spearman rho, ICC(2,k)),
##              LR test A (11) vs B (22) vs D (18) on common complete-case sample
##
##   Outputs (under <root>/advanced_reproducible/_outputs/):
##     40_stage1_composite_18var.csv
##     40_stage1_VIF.csv
##     40_stage1_internal_consistency.csv
##     40_stage1_LR_A_B_D.csv
##     40_stage1_summary.md
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({ library(car); library(tibble); library(dplyr) })

root  <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
shared<- file.path(root, "advanced_reproducible", "_shared")
out   <- file.path(root, "advanced_reproducible", "_outputs")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

w <- readRDS(file.path(shared, "data_witness.rds"))
stopifnot(nrow(w) == 749)

w$age_num <- if ("age_num" %in% names(w)) w$age_num else
  unname(c("10s"=15,"20s"=25,"30s"=35,"40s"=45,"50s"=55,"60s"=65)[as.character(w$age_cat)])
w$district <- factor(w$Q2)
w$total_type_count_z       <- as.numeric(scale(w$total_type_count))
w$coharm_count_z           <- as.numeric(scale(w$coharm_count))
w$negative_impact_count_z  <- as.numeric(scale(w$negative_impact_count))
w$gender_hierarchy_z       <- as.numeric(scale(w$gender_hierarchy))
w$severe_coharm_z          <- as.numeric(scale(w$severe_coharm))
w$online_withdrawal_z      <- as.numeric(scale(w$online_withdrawal))

## ---- Composites -------------------------------------------------------------
w$harm_breadth_z    <- rowMeans(cbind(w$severe_coharm_z,         w$coharm_count_z))
w$impact_severity_z <- rowMeans(cbind(w$negative_impact_count_z, w$online_withdrawal_z))

## ---- HC3 (manual) -----------------------------------------------------------
vcovHC3_glm <- function(fit) {
  X <- model.matrix(fit); mu <- fitted(fit); y <- model.response(model.frame(fit))
  W <- mu * (1 - mu)
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
preds_composite_18 <- c(
  "female","age_num","college","married","one_person","own_victim",
  "total_type_count_z","freq_ord_z","threat",
  "intimate","known_nonint","gendered_case",
  "harm_breadth_z","impact_severity_z",
  "any_violence_education",
  "support_awareness_z","seoul_policy_awareness_z","gender_hierarchy_z"
)
stopifnot(length(preds_composite_18) == 18)

## ---- Internal consistency for composites -----------------------------------
internal_cons <- function(name, x, y) {
  cc <- complete.cases(x, y); m <- cbind(x,y)[cc,]
  pr <- cor(m[,1], m[,2])
  sr <- cor(m[,1], m[,2], method="spearman")
  mb <- rowMeans(m); gm <- mean(mb)
  msb <- 2 * sum((mb - gm)^2) / (nrow(m) - 1)
  mse <- sum((m - mb)^2) / (nrow(m) - 1)
  icc2k <- (msb - mse) / (msb + mse)
  data.frame(composite=name, n=sum(cc),
             pearson_r=round(pr,3), spearman_rho=round(sr,3),
             ICC2k_consistency=round(icc2k,3))
}
ic_tab <- rbind(
  internal_cons("harm_breadth_z = z(severe_coharm) + z(coharm_count)",
                w$severe_coharm_z, w$coharm_count_z),
  internal_cons("impact_severity_z = z(neg_impact) + z(online_withdrawal)",
                w$negative_impact_count_z, w$online_withdrawal_z)
)

## ---- Fit helpers ------------------------------------------------------------
fit_dist <- function(df, y, preds) {
  cols <- unique(c(y, preds, "district"))
  dat <- df[, cols]; dat <- dat[complete.cases(dat), ]
  fml <- as.formula(paste(y, "~", paste(c(preds,"district"), collapse=" + ")))
  list(fit=glm(fml, data=dat, family=binomial()), dat=dat, fml=fml)
}
tidy_hc3 <- function(res, predictor_set, label) {
  ct <- coeftest_HC3(res$fit); rn <- rownames(ct); k <- rn %in% predictor_set
  est <- ct[k,"Estimate"]; se <- ct[k,"Std. Error"]
  z <- ct[k,"z value"];    p  <- ct[k,"Pr(>|z|)"]
  q <- p.adjust(p, method="BH")
  tibble(model=label, term=rn[k], aOR=exp(est),
         CI_lo=exp(est-1.96*se), CI_hi=exp(est+1.96*se),
         p=p, q_BH=q, B=est, SE_HC3=se, z=z)
}

if (!"total_type_count" %in% names(w)) w$total_type_count <- w$dig + w$offcnt

res_A <- fit_dist(w, "active_response", preds_baseline_11)
res_B <- fit_dist(w, "active_response", preds_extended_22)
res_D <- fit_dist(w, "active_response", preds_composite_18)
tab_A <- tidy_hc3(res_A, preds_baseline_11, "A_baseline_11")
tab_B <- tidy_hc3(res_B, preds_extended_22, "B_extended_22")
tab_D <- tidy_hc3(res_D, preds_composite_18, "D_composite_18")

## ---- VIF (Model D) ---------------------------------------------------------
vif_D <- car::vif(res_D$fit)
vif_D_df <- if (is.matrix(vif_D)) {
  data.frame(term=rownames(vif_D), GVIF=vif_D[,1], df=vif_D[,2],
             GVIF_adj=vif_D[,1]^(1/(2*vif_D[,2])))
} else {
  data.frame(term=names(vif_D), GVIF=unname(vif_D), df=1, GVIF_adj=sqrt(unname(vif_D)))
}
vif_D_df <- vif_D_df[vif_D_df$term != "district", ]

## ---- LR test A / B / D on common complete-case ----------------------------
common_cols <- unique(c("active_response", preds_baseline_11, preds_extended_22,
                        preds_composite_18, "district"))
common_dat  <- w[, common_cols]; common_dat <- common_dat[complete.cases(common_dat), ]
fit_A <- glm(reformulate(c(preds_baseline_11,"district"),"active_response"),
             data=common_dat, family=binomial())
fit_B <- glm(reformulate(c(preds_extended_22,"district"),"active_response"),
             data=common_dat, family=binomial())
fit_D <- glm(reformulate(c(preds_composite_18,"district"),"active_response"),
             data=common_dat, family=binomial())
lr_AB <- anova(fit_A, fit_B, test="Chisq")
lr_AD <- anova(fit_A, fit_D, test="Chisq")
lr_BD <- anova(fit_B, fit_D, test="Chisq")
fit_summary <- data.frame(
  model = c("A_baseline_11","B_extended_22","D_composite_18"),
  df    = c(length(coef(fit_A)), length(coef(fit_B)), length(coef(fit_D))),
  resid_dev = c(deviance(fit_A), deviance(fit_B), deviance(fit_D)),
  AIC   = c(AIC(fit_A), AIC(fit_B), AIC(fit_D)),
  BIC   = c(BIC(fit_A), BIC(fit_B), BIC(fit_D))
)

## ---- Write outputs ---------------------------------------------------------
write.csv(tab_D,       file.path(out, "40_stage1_composite_18var.csv"),     row.names=FALSE)
write.csv(vif_D_df,    file.path(out, "40_stage1_VIF.csv"),                  row.names=FALSE)
write.csv(ic_tab,      file.path(out, "40_stage1_internal_consistency.csv"), row.names=FALSE)
write.csv(fit_summary, file.path(out, "40_stage1_LR_A_B_D.csv"),             row.names=FALSE)

sink(file.path(out, "40_stage1_summary.md"))
cat("# Stage 1 — Model D : 18-variable composite\n\n")
cat(sprintf("N(witnesses) = %d, active = %d\n", nrow(w), sum(w$active_response==1)))
cat("Adjustment: 자치구 (Q2, 25 levels). SE = HC3. q = BH-FDR within model.\n\n")
cat("## 1. Composite internal consistency\n\n```\n"); print(ic_tab, row.names=FALSE); cat("```\n\n")

fmt <- function(r) sprintf("%-26s aOR=%5.2f [%4.2f, %4.2f]   p=%7.4f   q=%7.4f",
                           r$term, r$aOR, r$CI_lo, r$CI_hi, r$p, r$q_BH)
cat("## 2. Model D — 18-var composite\n\n```\n")
for (i in seq_len(nrow(tab_D))) cat(fmt(tab_D[i,]),"\n")
cat("```\n\n## 3. VIF (Model D)\n\n```\n")
for (i in seq_len(nrow(vif_D_df))) cat(sprintf("%-26s GVIF=%5.2f df=%d adj=%5.2f\n",
  vif_D_df$term[i], vif_D_df$GVIF[i], vif_D_df$df[i], vif_D_df$GVIF_adj[i]))
cat("```\n\n## 4. Model fit comparison\n\n```\n"); print(fit_summary, row.names=FALSE)
cat("\n--- LR A vs B ---\n"); print(lr_AB)
cat("\n--- LR A vs D (non-nested) ---\n"); print(lr_AD)
cat("\n--- LR B vs D (non-nested) ---\n"); print(lr_BD)
cat("```\n\n## 5. Focal four — A / B / D\n\n```\n")
cat(sprintf("%-22s %12s %10s %12s %10s %12s %10s\n",
            "term","A_aOR","A_q","B_aOR","B_q","D_aOR","D_q"))
focal_map <- list(
  "any_violence_edu" = list(A=NA,           B="any_violence_education", D="any_violence_education"),
  "harm_breadth_z"   = list(A=NA,           B=NA,                       D="harm_breadth_z"),
  "freq_ord_z"       = list(A="freq_ord_z", B="freq_ord_z",             D="freq_ord_z"),
  "intimate"         = list(A="intimate",   B="intimate",               D="intimate")
)
ftxt <- function(r) {
  if (is.null(r) || !nrow(r)) c("        — ","        — ")
  else c(sprintf("%12.3f", r$aOR), sprintf("%10.4f", r$q_BH))
}
get1 <- function(tab, term) if (is.na(term)) NULL else tab[tab$term==term,]
for (label in names(focal_map)) {
  m <- focal_map[[label]]
  vA <- ftxt(get1(tab_A, m$A)); vB <- ftxt(get1(tab_B, m$B)); vD <- ftxt(get1(tab_D, m$D))
  cat(sprintf("%-22s %s %s %s %s %s %s\n",
              label, vA[1], vA[2], vB[1], vB[2], vD[1], vD[2]))
}
cat("```\n")
sink()
cat("Wrote 40_stage1_*.csv|md\n")
