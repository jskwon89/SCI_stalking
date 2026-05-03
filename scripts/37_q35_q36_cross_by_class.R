## ----------------------------------------------------------------------------
## 37. Q35 (피해자 성별) × Q36 (가해자 성별) cross-tabulation by latent class
##
## Reviewer ask (narrative 정교화):
##   - 행 5 categories: 여성-남성 / 남성-여성 / 여성-여성 / 남성-남성 / 미상
##   - 열 5 classes: C1..C5 (5-class LCA, n=501 responder)
##   - 셀: n (column %)
##   - column total row 추가
##   - row totals (across classes) 추가
##
## Coding (kor_que_20240048.pdf):
##   Q35/Q36: 1=남성, 2=여성, 3=모르겠음, 4=기타, -1=비해당
##   미상 = (Q35==3) | (Q36==3) | (Q35==4) | (Q36==4) | NA in either
##
## Class assignment: modal class from Mplus 5-class R3STEP cprob (same source
## as script 36; avepp .921, entropy .879).
##
## Output:
##   _outputs/37_q35q36_by_class_count.csv     (5 rows × C1..C5 + Total + RowTotal)
##   _outputs/37_q35q36_by_class_pct.csv       (column %, 1 decimal)
##   _outputs/37_q35q36_by_class_combined.csv  (n (col%) display, 1 decimal)
##   _outputs/37_q35q36_chisq.csv              (omnibus χ²; pairwise drop later if needed)
##   _outputs/37_summary.md                    (note + footer)
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

## --- Responder data + class assignment (same chain as script 36) ----------
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

## Q35/Q36 raw (before fix_skip): -1=비해당; convert to NA so 미상 captures it
q35 <- as.numeric(raw_resp$Q35); q35[q35 == -1] <- NA
q36 <- as.numeric(raw_resp$Q36); q36[q36 == -1] <- NA

## --- Class assignment from Mplus cprob ------------------------------------
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

## --- Build dyad category --------------------------------------------------
## Definition:
##   여성-남성 : Q35==2 & Q36==1 (여성 피해자, 남성 가해자) -- gendered_case
##   남성-여성 : Q35==1 & Q36==2
##   여성-여성 : Q35==2 & Q36==2
##   남성-남성 : Q35==1 & Q36==1
##   미상      : 그 밖의 모든 경우 (모르겠음/기타/NA 한쪽이라도 포함)
dyad <- rep(NA_character_, length(q35))
dyad[q35 == 2 & q36 == 1] <- "여성-남성"
dyad[q35 == 1 & q36 == 2] <- "남성-여성"
dyad[q35 == 2 & q36 == 2] <- "여성-여성"
dyad[q35 == 1 & q36 == 1] <- "남성-남성"
dyad[is.na(dyad)]         <- "미상"

dyad_lvls <- c("여성-남성","남성-여성","여성-여성","남성-남성","미상")
dyad <- factor(dyad, levels = dyad_lvls)

stopifnot(length(dyad) == 501, sum(is.na(dyad)) == 0)

## --- Cross-tab (count) ----------------------------------------------------
ct <- table(dyad, cls)
ct_df <- as.data.frame.matrix(ct)
ct_df$Total <- rowSums(ct_df)
ct_df <- ct_df %>% rownames_to_column("dyad_Q35_Q36")

## column totals row
col_tot <- c(dyad_Q35_Q36 = "Total",
             as.list(c(colSums(as.matrix(ct_df[, class_labels])),
                       Total = sum(as.matrix(ct_df[, class_labels])))))
ct_out <- bind_rows(ct_df, as_tibble(col_tot)) %>%
  mutate(across(all_of(c(class_labels,"Total")), as.integer))

write.csv(ct_out, file.path(out, "37_q35q36_by_class_count.csv"), row.names = FALSE)

## --- Cross-tab (column %) -------------------------------------------------
col_n <- as.numeric(table(cls))   # 73 146 96 110 76
pct <- sweep(as.matrix(ct), 2, col_n, FUN = "/") * 100
pct_df <- as.data.frame.matrix(pct) %>%
  rownames_to_column("dyad_Q35_Q36") %>%
  mutate(across(all_of(class_labels), ~ round(.x, 1)))
## RowTotal = % of full N=501 (overall column)
pct_df$Overall <- round(rowSums(as.matrix(ct)) / 501 * 100, 1)
## column totals row (100, 100, 100, ..., 100)
pct_tot <- tibble(dyad_Q35_Q36 = "Total",
                  C1 = 100.0, C2 = 100.0, C3 = 100.0, C4 = 100.0, C5 = 100.0,
                  Overall = 100.0)
pct_out <- bind_rows(pct_df, pct_tot)

write.csv(pct_out, file.path(out, "37_q35q36_by_class_pct.csv"), row.names = FALSE)

## --- Combined "n (col%)" display table ------------------------------------
fmt_cell <- function(n, p) sprintf("%d (%.1f%%)", n, p)
combined <- tibble(dyad_Q35_Q36 = dyad_lvls)
for (k in class_labels) {
  combined[[k]] <- fmt_cell(as.integer(ct_df[[k]][match(dyad_lvls, ct_df$dyad_Q35_Q36)]),
                            pct_df[[k]][match(dyad_lvls, pct_df$dyad_Q35_Q36)])
}
combined$Total_n_pctOfN <- fmt_cell(as.integer(ct_df$Total[match(dyad_lvls, ct_df$dyad_Q35_Q36)]),
                                    pct_df$Overall[match(dyad_lvls, pct_df$dyad_Q35_Q36)])
## footer row: column N
combined <- bind_rows(
  combined,
  tibble(dyad_Q35_Q36 = "Column N",
         C1 = as.character(col_n[1]), C2 = as.character(col_n[2]),
         C3 = as.character(col_n[3]), C4 = as.character(col_n[4]),
         C5 = as.character(col_n[5]),
         Total_n_pctOfN = as.character(sum(col_n)))
)
write.csv(combined, file.path(out, "37_q35q36_by_class_combined.csv"), row.names = FALSE)

## --- Omnibus χ² (5×5) -----------------------------------------------------
## Some cells will have small expected counts → also report Fisher (simulated p)
chi <- suppressWarnings(chisq.test(ct))
fis <- tryCatch(fisher.test(ct, simulate.p.value = TRUE, B = 20000),
                error = function(e) NULL)

cell_min_exp <- min(chi$expected)
cell_pct_lt5 <- mean(chi$expected < 5) * 100

chi_out <- tibble(
  test = c("Pearson chi-square", "Fisher exact (Monte Carlo, B=20000)"),
  statistic = c(round(unname(chi$statistic), 4),
                NA_real_),
  df = c(unname(chi$parameter), NA_integer_),
  p_value = c(signif(chi$p.value, 4),
              if (!is.null(fis)) signif(fis$p.value, 4) else NA_real_),
  note = c(sprintf("min expected = %.2f; %.1f%% of cells have expected < 5",
                   cell_min_exp, cell_pct_lt5),
           "Fisher used because some expected cell counts < 5")
)
write.csv(chi_out, file.path(out, "37_q35q36_chisq.csv"), row.names = FALSE)

## --- Summary md -----------------------------------------------------------
md <- c(
  "# 37. Q35 × Q36 dyad cross-tabulation by latent class",
  "",
  sprintf("- Date: %s", format(Sys.Date(), "%Y-%m-%d")),
  "- Source: 5-class LCA, modal-class assignment (Mplus R3STEP run; avepp .921, entropy .879)",
  sprintf("- N = %d (responder)", 501),
  "",
  "## Definition",
  "- Dyad row = (Q35 피해자 성별) - (Q36 가해자 성별)",
  "- 미상 absorbs Q35/Q36 ∈ {3=모르겠음, 4=기타, NA} on either side",
  "- Column % computed within each class (denominator = column N)",
  "",
  "## Class column N",
  paste0("- ", paste(class_labels, "=", col_n, collapse = ", ")),
  "",
  "## Files",
  "- `37_q35q36_by_class_count.csv`  — 5 dyad rows × C1..C5 + Total + Total row",
  "- `37_q35q36_by_class_pct.csv`    — column % (within class) + Overall % (within N=501)",
  "- `37_q35q36_by_class_combined.csv` — display table (`n (col%)`) for paste-in",
  "- `37_q35q36_chisq.csv`           — omnibus 5×5 association test (Pearson + Fisher MC)",
  "",
  "## Note",
  sprintf("- Pearson χ²(df=%d) = %.3f, p = %s",
          unname(chi$parameter), unname(chi$statistic), signif(chi$p.value, 4)),
  if (!is.null(fis)) sprintf("- Fisher exact (B=20000): p = %s", signif(fis$p.value, 4)) else "- Fisher exact: not computed",
  sprintf("- Cell sparsity: min expected = %.2f, %.1f%% of cells < 5",
          cell_min_exp, cell_pct_lt5),
  "",
  "## Footer to copy into manuscript",
  "> Among the 501 active responders, dyadic gender composition (Q35 victim ×",
  "> Q36 perpetrator) was cross-tabulated against the 5-class latent profile",
  "> using modal-class assignment (entropy .879). Cells report n (column %).",
  "> Categories with Q35 or Q36 reported as 모르겠음/기타/missing were collapsed",
  "> into 미상."
)
writeLines(md, file.path(out, "37_summary.md"))

cat("\n--- Done. Outputs in:", out, "---\n")
print(ct_out)
cat("\nColumn percent:\n"); print(pct_out)
cat("\nCombined display:\n"); print(combined)
cat("\nχ² test:\n"); print(chi_out)
