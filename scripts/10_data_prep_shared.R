## ----------------------------------------------------------------------------
## 10. Shared data prep used by all downstream advanced scripts (11-19)
##   Output: <root>/advanced_reproducible/_shared/data_full.rds
##           <root>/advanced_reproducible/_shared/data_witness.rds (N=749)
##           <root>/advanced_reproducible/_shared/data_responder.rds (N=501)
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({
  library(haven); library(dplyr); library(tidyr)
})
set.seed(20260429)

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
shared <- file.path(root, "advanced_reproducible", "_shared")
dir.create(shared, recursive = TRUE, showWarnings = FALSE)

fix_skip <- function(x) { x <- as.numeric(x); x[x == -1] <- NA; x }
any_yes  <- function(df, cols) as.integer(rowSums(df[, cols, drop=FALSE] == 1, na.rm=TRUE) > 0)
count_yes<- function(df, cols) rowSums(df[, cols, drop=FALSE] == 1, na.rm=TRUE)
zscore   <- function(x) as.numeric(scale(as.numeric(x)))

d <- read_sav(file.path(root, "kor_data_20240048.sav"))
names(d) <- make.names(names(d), unique = TRUE)
cat(sprintf("Raw N = %d, p = %d\n", nrow(d), ncol(d)))

q31l <- paste0("Q31L_", 1:6); q31r <- paste0("Q31R_", 1:6)
q32l <- paste0("Q32L_", 1:3); q32r <- paste0("Q32R_", 1:3)
q7   <- c(paste0("Q7L_", 1:6), paste0("Q7R_", 1:6))
q8   <- c(paste0("Q8L_", 1:3), paste0("Q8R_", 1:3))
q37  <- paste0("Q37_", 1:8); q38 <- paste0("Q38_", 1:4)
q39  <- paste0("Q39_", c(1, 3, 4, 5, 6))

vars_to_fix <- unique(c(q31l, q31r, q32l, q32r, q7, q8,
                        paste0("Q40_", 1:9), paste0("Q41_", 1:7),
                        q37, q38, paste0("Q39_", 1:8), "Q42", "Q33", "Q35", "Q36",
                        paste0("Q48L_", 1:7), paste0("Q47L_", 1:6),
                        paste0("Q44_", 1:5), "Q45", "Q45_1"))
for (v in intersect(vars_to_fix, names(d))) d[[v]] <- fix_skip(d[[v]])

d <- d %>% mutate(
  witness_any            = any_yes(cur_data(), c(q31l, q31r, q32l, q32r)),
  own_victim             = any_yes(cur_data(), c(q7, q8)),
  active_response        = ifelse(witness_any == 1, as.integer(Q40_9 != 1), NA_integer_),
  institutional_response = ifelse(witness_any == 1, any_yes(cur_data(), c("Q40_5","Q40_7","Q40_8")), NA_integer_),
  private_network_response = ifelse(witness_any == 1, any_yes(cur_data(), c("Q40_1","Q40_2","Q40_6")), NA_integer_),
  q40_police             = ifelse(witness_any == 1, as.integer(Q40_7 == 1), NA_integer_),
  q42_police             = ifelse(witness_any == 1, as.integer(Q42 == 1), NA_integer_),
  female      = as.integer(Q1 == 1),
  age_cat     = factor(SQ2R2, levels = c(3,2,4,5,6,7), labels = c("20s","10s","30s","40s","50s","60s")),
  region      = factor(Q2R),
  college     = as.integer(Q51 >= 3),
  married     = as.integer(Q52 == 2),
  employed    = as.integer(Q55 %in% 1:10),
  one_person  = as.integer(Q53 == 1),
  disability  = as.integer(Q54 == 1),
  intimate    = as.integer(Q34 %in% 1:7),
  known_nonint= as.integer(Q34 %in% c(8, 9, 10)),
  gendered_case = as.integer(Q35 == 2 & Q36 == 1),
  stedu       = as.integer(Q45_1 %in% c(2, 3, 4)),
  any_violence_education = as.integer(Q45 %in% 1:4),
  myth        = rowMeans(select(cur_data(), paste0("Q3_", 1:9)), na.rm = TRUE),
  victim_blaming = rowMeans(select(cur_data(), Q3_1, Q3_2, Q3_3), na.rm = TRUE),
  crime_denial   = rowMeans(select(cur_data(), Q3_4, Q3_5, Q3_6), na.rm = TRUE),
  stereotype     = rowMeans(select(cur_data(), Q3_7, Q3_8), na.rm = TRUE),
  fear           = rowMeans(select(cur_data(), paste0("Q4_", 1:7)), na.rm = TRUE),
  cjs_distrust   = rowMeans(select(cur_data(), Q4_5, Q4_6), na.rm = TRUE),
  gender_awareness = rowMeans(select(cur_data(), Q6_1, Q6_2), na.rm = TRUE),
  gender_hierarchy = rowMeans(select(cur_data(), Q6_3, Q6_4, Q6_5, Q6_6), na.rm = TRUE),
  support_awareness = count_yes(cur_data(), paste0("Q48L_", 1:7)),
  seoul_policy_awareness = count_yes(cur_data(), paste0("Q47L_", 1:6)),
  dig          = count_yes(cur_data(), c(q32l, q32r)),
  offcnt       = count_yes(cur_data(), c(q31l, q31r)),
  total_type_count = dig + offcnt,
  freq_ord     = ifelse(Q33 == -1, NA, Q33),
  threat       = as.integer(Q31L_6 == 1 | Q31R_6 == 1),
  coharm_count = count_yes(cur_data(), q37),
  severe_coharm = any_yes(cur_data(), c("Q37_3","Q37_4","Q37_5","Q37_6","Q37_8")),
  negative_impact_count = count_yes(cur_data(), q38),
  prosocial_change_count = count_yes(cur_data(), q39),
  online_withdrawal = as.integer(Q38_4 == 1),
  digital_coharm    = as.integer(Q37_5 == 1),
  role_police_top2  = as.integer(Q44_1 == 2 | Q44_2 == 2)
) %>%
  mutate(across(c(myth, victim_blaming, crime_denial, stereotype, fear, cjs_distrust,
                  gender_awareness, gender_hierarchy, support_awareness, seoul_policy_awareness,
                  dig, offcnt, total_type_count, freq_ord, coharm_count,
                  negative_impact_count, prosocial_change_count),
                zscore, .names = "{.col}_z"))

w <- d %>% filter(witness_any == 1)
r <- w %>% filter(active_response == 1)

stopifnot(nrow(w) == 749, nrow(r) == 501, sum(w$active_response == 0) == 248)
cat(sprintf("witness=%d, responder=%d, non-responder=%d\n",
            nrow(w), nrow(r), sum(w$active_response == 0)))

saveRDS(d, file.path(shared, "data_full.rds"))
saveRDS(w, file.path(shared, "data_witness.rds"))
saveRDS(r, file.path(shared, "data_responder.rds"))
cat("Saved RDS to:", shared, "\n")
