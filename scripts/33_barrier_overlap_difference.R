## ----------------------------------------------------------------------------
## 33. Barrier overlap and non-response vs non-reporting difference tests
##
## Purpose:
##   Strengthen the sequential framework by showing that barriers to doing
##   nothing (Stage 1/decision-to-act) and barriers to reporting (Stage 3/
##   institutional entry) have different structures.
##
## Outputs:
##   _outputs/33_barrier_domain_difference.csv
##   _outputs/33_barrier_overlap_pairs.csv
##   _outputs/33_barrier_heatmap_data.csv
##   _outputs/33_barrier_overlap_difference_summary.md
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(tibble)
})

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
adv    <- file.path(root, "advanced_reproducible")
shared <- file.path(adv, "_shared")
out    <- file.path(adv, "_outputs")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

num <- function(x) suppressWarnings(as.numeric(as.vector(x)))
yes <- function(x) ifelse(num(x) == 1, 1, ifelse(num(x) == 0, 0, NA_real_))
any_domain <- function(df, vars) as.numeric(rowSums(sapply(vars, function(v) yes(df[[v]]) == 1), na.rm = TRUE) > 0)

w <- readRDS(file.path(shared, "data_witness.rds"))
r <- readRDS(file.path(shared, "data_responder.rds"))

nonresp <- w %>% filter(num(active_response) == 0)
nonreport <- r %>% filter(num(q42_police) == 0)

## Non-response domains (Q43)
nr <- nonresp %>%
  mutate(
    group = "Non-response",
    privacy_retaliation = any_domain(nonresp, c("Q43_1", "Q43_2", "Q43_4")),
    minimization = any_domain(nonresp, c("Q43_3", "Q43_6", "Q43_12")),
    evidence_legal = yes(Q43_5),
    burden_distrust = yes(Q43_7),
    relationship_victim_wish = any_domain(nonresp, c("Q43_9", "Q43_11")),
    social_norm_blame = any_domain(nonresp, c("Q43_8", "Q43_10"))
  ) %>%
  select(group, privacy_retaliation, minimization, evidence_legal,
         burden_distrust, relationship_victim_wish, social_norm_blame)

## Non-reporting domains (Q42_2)
rp <- nonreport %>%
  mutate(
    group = "Non-reporting",
    privacy_retaliation = any_domain(nonreport, c("Q42_2_2", "Q42_2_3")),
    minimization = yes(Q42_2_6),
    evidence_legal = yes(Q42_2_4),
    burden_distrust = yes(Q42_2_5),
    relationship_victim_wish = any_domain(nonreport, c("Q42_2_1", "Q42_2_7")),
    social_norm_blame = NA_real_
  ) %>%
  select(group, privacy_retaliation, minimization, evidence_legal,
         burden_distrust, relationship_victim_wish, social_norm_blame)

domain_vars <- c("privacy_retaliation", "minimization", "evidence_legal",
                 "burden_distrust", "relationship_victim_wish",
                 "social_norm_blame")

heatmap <- bind_rows(nr, rp) %>%
  pivot_longer(all_of(domain_vars), names_to = "domain", values_to = "endorsed") %>%
  group_by(group, domain) %>%
  summarise(
    N_valid = sum(!is.na(endorsed)),
    n_yes = sum(endorsed == 1, na.rm = TRUE),
    prop_yes = mean(endorsed, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(prop_yes = ifelse(N_valid == 0, NA_real_, round(prop_yes, 3)))

compare_domains <- setdiff(domain_vars, "social_norm_blame")
diff_tests <- bind_rows(lapply(compare_domains, function(v) {
  dd <- bind_rows(nr, rp) %>% select(group, all_of(v)) %>% drop_na()
  names(dd)[2] <- "endorsed"
  tab <- table(dd$group, dd$endorsed)
  chi <- suppressWarnings(chisq.test(tab))
  p <- if (any(chi$expected < 5)) fisher.test(tab)$p.value else chi$p.value
  props <- dd %>%
    group_by(group) %>%
    summarise(N = n(), prop = mean(endorsed), .groups = "drop")
  tibble(
    domain = v,
    nonresponse_N = props$N[props$group == "Non-response"],
    nonresponse_prop = props$prop[props$group == "Non-response"],
    nonreporting_N = props$N[props$group == "Non-reporting"],
    nonreporting_prop = props$prop[props$group == "Non-reporting"],
    difference_nonreporting_minus_nonresponse =
      props$prop[props$group == "Non-reporting"] - props$prop[props$group == "Non-response"],
    p_value = p,
    cramer_V = as.numeric(sqrt(chi$statistic / (sum(tab) * (min(dim(tab)) - 1))))
  )
})) %>%
  mutate(p_FDR = p.adjust(p_value, method = "BH"),
         across(c(nonresponse_prop, nonreporting_prop,
                  difference_nonreporting_minus_nonresponse, p_value, p_FDR, cramer_V),
                ~ round(.x, 4)))

pair_overlap <- function(df, group_name) {
  pairs <- combn(domain_vars, 2, simplify = FALSE)
  bind_rows(lapply(pairs, function(pp) {
    if (all(is.na(df[[pp[1]]])) || all(is.na(df[[pp[2]]]))) return(NULL)
    ok <- !is.na(df[[pp[1]]]) & !is.na(df[[pp[2]]])
    tibble(
      group = group_name,
      domain_a = pp[1],
      domain_b = pp[2],
      N_valid = sum(ok),
      overlap_n = sum(df[[pp[1]]][ok] == 1 & df[[pp[2]]][ok] == 1),
      overlap_prop = ifelse(sum(ok) == 0, NA_real_,
                            mean(df[[pp[1]]][ok] == 1 & df[[pp[2]]][ok] == 1))
    )
  }))
}

overlap <- bind_rows(
  pair_overlap(nr, "Non-response"),
  pair_overlap(rp, "Non-reporting")
) %>%
  mutate(overlap_prop = round(overlap_prop, 3)) %>%
  arrange(group, desc(overlap_prop))

domain_counts <- bind_rows(nr, rp) %>%
  rowwise() %>%
  mutate(domain_count = sum(c_across(all_of(domain_vars)) == 1, na.rm = TRUE)) %>%
  ungroup() %>%
  group_by(group) %>%
  summarise(
    N = n(),
    mean_domain_count = mean(domain_count),
    median_domain_count = median(domain_count),
    pct_two_or_more = mean(domain_count >= 2),
    .groups = "drop"
  ) %>%
  mutate(across(c(mean_domain_count, median_domain_count, pct_two_or_more), ~ round(.x, 3)))

write.csv(diff_tests, file.path(out, "33_barrier_domain_difference.csv"), row.names = FALSE)
write.csv(overlap, file.path(out, "33_barrier_overlap_pairs.csv"), row.names = FALSE)
write.csv(heatmap, file.path(out, "33_barrier_heatmap_data.csv"), row.names = FALSE)
write.csv(domain_counts, file.path(out, "33_barrier_domain_counts.csv"), row.names = FALSE)

sink(file.path(out, "33_barrier_overlap_difference_summary.md"))
cat("# Barrier Overlap and Difference Tests\n\n")
cat("## Domain counts\n\n")
print(as.data.frame(domain_counts), row.names = FALSE)
cat("\n## Non-response vs non-reporting domain differences\n\n")
print(as.data.frame(diff_tests), row.names = FALSE)
cat("\n## Heatmap data\n\n")
print(as.data.frame(heatmap), row.names = FALSE)
cat("\n## Top overlap pairs\n\n")
print(as.data.frame(overlap %>% group_by(group) %>% slice_head(n = 10) %>% ungroup()),
      row.names = FALSE)
cat("\nInterpretation: these tables test whether decision-to-act barriers and institutional-entry barriers are structurally different. ")
cat("They should be used to support the sequential framework rather than expand the LCA model.\n")
sink()

cat("Wrote:\n",
    file.path(out, "33_barrier_domain_difference.csv"), "\n",
    file.path(out, "33_barrier_overlap_pairs.csv"), "\n",
    file.path(out, "33_barrier_heatmap_data.csv"), "\n",
    file.path(out, "33_barrier_overlap_difference_summary.md"), "\n")
