## ----------------------------------------------------------------------------
## 22. Barriers among non-responding and non-reporting witnesses
##
## Q43: reasons for no response among witnesses who did not respond.
## Q42_2: reasons for no police report among active responders who did not report.
##
## These tables support the bystander-intervention framing by showing practical
## barriers to action and reporting.
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({ library(dplyr); library(tibble) })

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
adv    <- file.path(root, "advanced_reproducible")
shared <- file.path(adv, "_shared")
out    <- file.path(adv, "_outputs")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

w <- readRDS(file.path(shared, "data_witness.rds"))
num <- function(x) suppressWarnings(as.numeric(as.vector(x)))
yes <- function(x) ifelse(num(x) == 1, 1, ifelse(num(x) == 0, 0, NA_real_))

## Q43 non-response barriers among passive witnesses.
q43_vars <- paste0("Q43_", 1:13)
q43_labels <- c(
  "Retaliation/further harm",
  "Identity exposure/privacy",
  "Thought no response was better",
  "Threat to leak private/sexual material",
  "No evidence/witness",
  "Did not know how/where to respond",
  "Time/psychological/economic burden",
  "Victim partly at fault",
  "Avoid worsening relationship with perpetrator",
  "Not appropriate to intervene in others' affairs",
  "Victim did not want intervention",
  "Did not think it was serious enough",
  "Other"
)

nonresp <- w %>% filter(num(active_response) == 0)
q43 <- bind_rows(lapply(seq_along(q43_vars), function(i) {
  v <- q43_vars[i]
  x <- yes(nonresp[[v]])
  data.frame(item = v, barrier = q43_labels[i],
             n_valid = sum(!is.na(x)),
             n_yes = sum(x == 1, na.rm = TRUE),
             prop_yes = mean(x, na.rm = TRUE))
})) %>% arrange(desc(prop_yes))
write.csv(q43, file.path(out, "22_nonresponse_barriers.csv"), row.names = FALSE)

nonresp$barrier_retaliation_privacy <- as.numeric(rowSums(sapply(q43_vars[c(1,2,4)], function(v) yes(nonresp[[v]]) == 1), na.rm = TRUE) > 0)
nonresp$barrier_uncertainty_minimize <- as.numeric(rowSums(sapply(q43_vars[c(3,6,12)], function(v) yes(nonresp[[v]]) == 1), na.rm = TRUE) > 0)
nonresp$barrier_evidence <- yes(nonresp$Q43_5)
nonresp$barrier_burden <- yes(nonresp$Q43_7)
nonresp$barrier_victim_blame_social <- as.numeric(rowSums(sapply(q43_vars[c(8,10)], function(v) yes(nonresp[[v]]) == 1), na.rm = TRUE) > 0)
nonresp$barrier_relationship_victim_wish <- as.numeric(rowSums(sapply(q43_vars[c(9,11)], function(v) yes(nonresp[[v]]) == 1), na.rm = TRUE) > 0)

q43_groups <- tibble(
  domain = c("retaliation/privacy", "uncertainty/minimization", "evidence",
             "burden", "victim-blame/social norm", "relationship/victim wish"),
  n = nrow(nonresp),
  prop = c(mean(nonresp$barrier_retaliation_privacy, na.rm = TRUE),
           mean(nonresp$barrier_uncertainty_minimize, na.rm = TRUE),
           mean(nonresp$barrier_evidence, na.rm = TRUE),
           mean(nonresp$barrier_burden, na.rm = TRUE),
           mean(nonresp$barrier_victim_blame_social, na.rm = TRUE),
           mean(nonresp$barrier_relationship_victim_wish, na.rm = TRUE))
) %>% arrange(desc(prop))

## Q42_2 non-reporting barriers among responders who did not report to police.
q422_vars <- paste0("Q42_2_", 1:8)
q422_labels <- c(
  "Others discouraged reporting",
  "Identity exposure/privacy",
  "Perpetrator threat/retaliation fear",
  "No evidence or fear of false-accusation countersuit",
  "Low expectation of police protection/punishment",
  "Did not think police report was warranted",
  "Victim did not want legal punishment",
  "Other"
)

nonreport <- w %>% filter(num(active_response) == 1, num(q42_police) == 0)
q422 <- bind_rows(lapply(seq_along(q422_vars), function(i) {
  v <- q422_vars[i]
  x <- yes(nonreport[[v]])
  data.frame(item = v, barrier = q422_labels[i],
             n_valid = sum(!is.na(x)),
             n_yes = sum(x == 1, na.rm = TRUE),
             prop_yes = mean(x, na.rm = TRUE))
})) %>% arrange(desc(prop_yes))
write.csv(q422, file.path(out, "22_nonreporting_barriers.csv"), row.names = FALSE)

nonreport$report_barrier_discouraged_victimwish <- as.numeric(rowSums(sapply(q422_vars[c(1,7)], function(v) yes(nonreport[[v]]) == 1), na.rm = TRUE) > 0)
nonreport$report_barrier_privacy_retaliation <- as.numeric(rowSums(sapply(q422_vars[c(2,3)], function(v) yes(nonreport[[v]]) == 1), na.rm = TRUE) > 0)
nonreport$report_barrier_evidence_legalrisk <- yes(nonreport$Q42_2_4)
nonreport$report_barrier_institutional_distrust <- yes(nonreport$Q42_2_5)
nonreport$report_barrier_minimization <- yes(nonreport$Q42_2_6)

q422_groups <- tibble(
  domain = c("discouraged/victim wish", "privacy/retaliation", "evidence/legal risk",
             "institutional distrust", "minimization"),
  n = nrow(nonreport),
  prop = c(mean(nonreport$report_barrier_discouraged_victimwish, na.rm = TRUE),
           mean(nonreport$report_barrier_privacy_retaliation, na.rm = TRUE),
           mean(nonreport$report_barrier_evidence_legalrisk, na.rm = TRUE),
           mean(nonreport$report_barrier_institutional_distrust, na.rm = TRUE),
           mean(nonreport$report_barrier_minimization, na.rm = TRUE))
) %>% arrange(desc(prop))

write.csv(q43_groups, file.path(out, "22_nonresponse_barrier_domains.csv"), row.names = FALSE)
write.csv(q422_groups, file.path(out, "22_nonreporting_barrier_domains.csv"), row.names = FALSE)

sink(file.path(out, "22_summary.md"))
cat("# Non-response and Non-reporting Barriers\n\n")
cat("Passive/non-responding witnesses: N =", nrow(nonresp), "\n\n")
cat("## Top Q43 non-response barriers\n\n")
print(q43)
cat("\n## Q43 barrier domains\n\n")
print(q43_groups)
cat("\nActive responders who did not report to police: N =", nrow(nonreport), "\n\n")
cat("## Top Q42_2 non-reporting barriers\n\n")
print(q422)
cat("\n## Q42_2 reporting-barrier domains\n\n")
print(q422_groups)
cat("\nInterpretation: these barriers help explain passive witnessing and non-reporting pathways, and can be used to tailor policy recommendations.\n")
sink()

cat("Wrote:", file.path(out, "22_nonresponse_barriers.csv"), "\n")
cat("Wrote:", file.path(out, "22_nonreporting_barriers.csv"), "\n")
cat("Wrote:", file.path(out, "22_summary.md"), "\n")
