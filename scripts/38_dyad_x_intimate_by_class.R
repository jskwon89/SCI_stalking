## ----------------------------------------------------------------------------
## 38. Dyad (Q35×Q36) × Intimate (Q34∈1..7) cross-tab WITHIN each latent class
##
## Reviewer ask:
##   - 클래스별 5(dyad rows) × 2(intimate yes/no) cross-tab
##   - 각 클래스 안에서 dyad × intimate 독립성 검정 (Fisher MC, p값)
##   - 각 클래스의 "친밀관계 사건 안 동성 사건 비율"
##     (= P(동성 dyad | intimate=1, class=Ck))
##
## Definitions (script 37과 동일):
##   dyad ∈ {여성-남성, 남성-여성, 여성-여성, 남성-남성, 미상}
##   intimate = (Q34 ∈ 1..7)        # script 10의 정의 그대로
##   동성 사건 = (남성-남성) ∪ (여성-여성)
##
## Output:
##   _outputs/38_dyad_intimate_by_class_count.csv      (long: class, dyad, intimate=0/1, n)
##   _outputs/38_dyad_intimate_by_class_combined.csv   (display: rows=dyad×intimate, cols=C1..C5)
##   _outputs/38_intimate_share_by_class.csv           (intimate %, same-sex within intimate %)
##   _outputs/38_within_class_independence.csv         (per class: chi2, df, p; Fisher MC p)
##   _outputs/38_summary.md
## ----------------------------------------------------------------------------

options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({
  library(haven); library(dplyr); library(tidyr); library(tibble)
})

root   <- "D:/2026/SCI/Stalking"
adv    <- file.path(root, "advanced_reproducible")
shared <- file.path(adv, "_shared")
mp_r3  <- file.path(adv, "Mplus_responder_LCA_R3STEP")
out    <- file.path(adv, "_outputs")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

## --- Load responder + class assignment + raw Q34/Q35/Q36 ------------------
r <- readRDS(file.path(shared, "data_responder.rds"))
stopifnot(nrow(r) == 501)

raw_full <- read_sav(file.path(root, "kor_data_20240048.sav"))
names(raw_full) <- make.names(names(raw_full), unique = TRUE)
raw_full$witness_any <- as.integer(rowSums(
  sapply(c(paste0("Q31L_", 1:6), paste0("Q31R_", 1:6),
           paste0("Q32L_", 1:3), paste0("Q32R_", 1:3)),
         function(v) replace(as.numeric(raw_full[[v]]), as.numeric(raw_full[[v]]) == -1, NA) == 1),
  na.rm = TRUE) > 0)
raw_full$active_response <- ifelse(
  raw_full$witness_any == 1,
  as.integer(replace(as.numeric(raw_full$Q40_9), as.numeric(raw_full$Q40_9) == -1, NA) != 1),
  NA_integer_)
raw_resp <- raw_full[which(raw_full$witness_any == 1 & raw_full$active_response == 1), ]
stopifnot(nrow(raw_resp) == 501)

## raw Q34/Q35/Q36 (-1 → NA)
fix <- function(x) { x <- as.numeric(x); x[x == -1] <- NA; x }
q34 <- fix(raw_resp$Q34)
q35 <- fix(raw_resp$Q35)
q36 <- fix(raw_resp$Q36)

## sanity: r$intimate (from script 10) should equal (q34 ∈ 1..7)
intimate_check <- as.integer(q34 %in% 1:7)
stopifnot(identical(as.integer(r$intimate), intimate_check))

## --- Class assignment from Mplus cprob -----------------------------------
hdr <- c(paste0("q40_", 1:8), paste0("q41_", 1:6),
         "stedu_m","dig_m","offcnt_m","freqz_m","intimate_m","severe_m",
         "mythz_m","fearz_m","crimez_m","victimz_m","supportz_m",
         paste0("CPROB", 1:5), "Class")
cp <- read.table(file.path(mp_r3, "responder_lca_5class_r3step_cprob.dat"),
                 header = FALSE)
names(cp) <- hdr
stopifnot(nrow(cp) == 501)

class_labels <- c("C1","C2","C3","C4","C5")
cls <- factor(class_labels[as.integer(cp$Class)], levels = class_labels)
stopifnot(all(as.numeric(table(cls)) == c(73, 146, 96, 110, 76)))

## --- Build dyad (5-level) and intimate (binary) ---------------------------
dyad_lvls <- c("여성-남성","남성-여성","여성-여성","남성-남성","미상")
dyad <- rep(NA_character_, length(q35))
dyad[q35 == 2 & q36 == 1] <- "여성-남성"
dyad[q35 == 1 & q36 == 2] <- "남성-여성"
dyad[q35 == 2 & q36 == 2] <- "여성-여성"
dyad[q35 == 1 & q36 == 1] <- "남성-남성"
dyad[is.na(dyad)]         <- "미상"
dyad <- factor(dyad, levels = dyad_lvls)

intim <- factor(intimate_check, levels = c(0,1), labels = c("non-intimate","intimate"))
samesex <- factor(ifelse(dyad %in% c("남성-남성","여성-여성"), 1, 0),
                  levels = c(0,1), labels = c("other","same-sex"))

dat <- tibble(class = cls, dyad = dyad, intimate = intim, samesex = samesex)

## --- (1) Per-class 5x2 cross-tab (long format) ---------------------------
long <- dat %>%
  count(class, dyad, intimate, .drop = FALSE) %>%
  arrange(class, dyad, intimate)
write.csv(long, file.path(out, "38_dyad_intimate_by_class_count.csv"), row.names = FALSE)

## --- (2) Display table: rows = dyad × intimate, cols = C1..C5 ------------
display <- dat %>%
  count(class, dyad, intimate, .drop = FALSE) %>%
  unite("row", dyad, intimate, sep = " | ") %>%
  pivot_wider(names_from = class, values_from = n, values_fill = 0L) %>%
  mutate(across(all_of(class_labels), as.integer))

## add row totals + col total row
display$Total <- rowSums(display[, class_labels])
col_tot_row <- tibble(row = "Column N",
                      C1 = 73L, C2 = 146L, C3 = 96L, C4 = 110L, C5 = 76L,
                      Total = 501L)
display_out <- bind_rows(display, col_tot_row)
write.csv(display_out, file.path(out, "38_dyad_intimate_by_class_combined.csv"), row.names = FALSE)

## --- (3) Per-class summary metrics --------------------------------------
share_rows <- list()
for (k in class_labels) {
  sub <- dat %>% filter(class == k)
  n_k <- nrow(sub)
  n_intim <- sum(sub$intimate == "intimate")
  n_intim_same <- sum(sub$intimate == "intimate" & sub$samesex == "same-sex")
  n_intim_other<- sum(sub$intimate == "intimate" & sub$samesex == "other")
  n_nonintim_same  <- sum(sub$intimate == "non-intimate" & sub$samesex == "same-sex")
  n_nonintim_other <- sum(sub$intimate == "non-intimate" & sub$samesex == "other")
  n_same <- sum(sub$samesex == "same-sex")

  share_rows[[k]] <- tibble(
    class = k,
    N = n_k,
    intimate_n = n_intim,
    intimate_pct_within_class = round(n_intim / n_k * 100, 1),
    samesex_n_overall = n_same,
    samesex_pct_within_class = round(n_same / n_k * 100, 1),
    intimate_samesex_n = n_intim_same,
    intimate_samesex_pct_within_intimate = if (n_intim > 0) round(n_intim_same / n_intim * 100, 1) else NA_real_,
    nonintimate_samesex_n = n_nonintim_same,
    nonintimate_samesex_pct_within_nonintimate =
      if ((n_k - n_intim) > 0) round(n_nonintim_same / (n_k - n_intim) * 100, 1) else NA_real_,
    intimate_other_n = n_intim_other,
    nonintimate_other_n = n_nonintim_other
  )
}
share <- bind_rows(share_rows)
write.csv(share, file.path(out, "38_intimate_share_by_class.csv"), row.names = FALSE)

## --- (4) Per-class independence tests -----------------------------------
##  (a) 5x2 table (dyad × intimate) -- main reviewer ask
##  (b) 2x2 table (samesex × intimate) -- 동성×친밀관계 직접 대비
indep_rows <- list()
for (k in class_labels) {
  sub <- dat %>% filter(class == k)
  ## (a) 5x2 dyad × intimate
  t52 <- table(sub$dyad, sub$intimate)
  chi52 <- suppressWarnings(chisq.test(t52))
  fis52 <- tryCatch(fisher.test(t52, simulate.p.value = TRUE, B = 20000),
                    error = function(e) NULL)
  min_exp52 <- min(chi52$expected)
  pct_lt5_52 <- mean(chi52$expected < 5) * 100

  ## (b) 2x2 samesex × intimate
  t22 <- table(sub$samesex, sub$intimate)
  fis22 <- tryCatch(fisher.test(t22), error = function(e) NULL)
  ## OR for samesex=1 vs samesex=0 within intimate (vs non-intimate)
  if (all(dim(t22) == c(2,2))) {
    a <- t22["same-sex","intimate"]; b <- t22["same-sex","non-intimate"]
    c_ <- t22["other","intimate"];   d <- t22["other","non-intimate"]
    or22 <- (a * d) / (b * c_)
    se_lor <- sqrt(1/max(a,0.5) + 1/max(b,0.5) + 1/max(c_,0.5) + 1/max(d,0.5))
    or_lo <- exp(log(or22) - 1.96 * se_lor)
    or_hi <- exp(log(or22) + 1.96 * se_lor)
  } else {
    or22 <- NA_real_; or_lo <- NA_real_; or_hi <- NA_real_
  }

  indep_rows[[k]] <- tibble(
    class = k,
    N = nrow(sub),
    dyad_intimate_pearson_chi2 = round(unname(chi52$statistic), 4),
    dyad_intimate_df = unname(chi52$parameter),
    dyad_intimate_p = signif(chi52$p.value, 4),
    dyad_intimate_fisher_MC_p = if (!is.null(fis52)) signif(fis52$p.value, 4) else NA_real_,
    dyad_intimate_min_expected = round(min_exp52, 2),
    dyad_intimate_pct_cells_exp_lt5 = round(pct_lt5_52, 1),
    samesex_intimate_OR = round(or22, 3),
    samesex_intimate_OR_CI95 = sprintf("[%.3f, %.3f]", or_lo, or_hi),
    samesex_intimate_fisher_p = if (!is.null(fis22)) signif(fis22$p.value, 4) else NA_real_
  )
}
indep <- bind_rows(indep_rows)
write.csv(indep, file.path(out, "38_within_class_independence.csv"), row.names = FALSE)

## --- (5) Summary md -----------------------------------------------------
md <- c(
  "# 38. Dyad × Intimate cross-tab WITHIN each latent class",
  "",
  sprintf("- Date: %s", format(Sys.Date(), "%Y-%m-%d")),
  "- Source: 5-class LCA, modal-class assignment (Mplus R3STEP; entropy .879, avepp .921)",
  sprintf("- N = %d (responder)", 501),
  "",
  "## Definitions",
  "- dyad: Q35 victim × Q36 perpetrator (5 categories incl. 미상; same as script 37)",
  "- intimate: Q34 ∈ {1..7} (current/former intimate partner; same as script 10)",
  "- same-sex: dyad ∈ {남성-남성, 여성-여성}",
  "",
  "## Question this answers",
  "How much do the 'intimate-relationship' cases and the 'same-sex' cases overlap *within* a class?",
  "Specifically: among intimate cases in C3, what share are same-sex?",
  "",
  "## Files",
  "- `38_dyad_intimate_by_class_count.csv`     — long: class, dyad(5), intimate(0/1), n",
  "- `38_dyad_intimate_by_class_combined.csv`  — display: rows = dyad×intimate (10), cols = C1..C5",
  "- `38_intimate_share_by_class.csv`          — per-class % intimate, % same-sex, P(same-sex | intimate)",
  "- `38_within_class_independence.csv`        — per class: 5×2 χ²+Fisher MC, 2×2 OR(95% CI)+Fisher",
  "",
  "## Test choice",
  "- Pearson χ² reported but several cells have expected < 5 in some classes → primary inference uses Fisher exact (Monte Carlo, B=20000) for 5×2; exact Fisher for 2×2.",
  "",
  "## Manuscript footer",
  "> Within each latent class, dyadic gender composition (Q35×Q36) was cross-tabulated against intimate-partner status (Q34 ∈ 1..7). Independence within class was tested with Pearson χ² (5×2) and Fisher exact (Monte Carlo, B=20000) given cell sparsity; the same-sex/other × intimate/non-intimate 2×2 also reports an odds ratio with 95% CI. The proportion of same-sex cases within intimate cases is reported per class to characterize the overlap of relational context and gender composition."
)
writeLines(md, file.path(out, "38_summary.md"))

cat("\n--- Done. Outputs in:", out, "---\n")
cat("\n[Display table]\n");          print(display_out, n = 20)
cat("\n[Per-class shares]\n");       print(share)
cat("\n[Within-class independence]\n"); print(indep)
