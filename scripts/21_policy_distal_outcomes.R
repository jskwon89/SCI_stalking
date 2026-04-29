## ----------------------------------------------------------------------------
## 21. Policy distal outcomes by 5-class responder LCA membership
##
## Uses modal class assignment from the selected 5-class LCA to summarize:
##   - perceived bystander roles (Q44, top 2)
##   - prevention education emphasis (Q46, top 2)
##   - intention to use Seoul/support services (Q47R, Q48R)
##   - policy needs (Q50, top 3)
##
## This is a manuscript-facing policy translation table. Because modal class
## assignment ignores classification error, treat it as a sensitivity/descriptive
## distal analysis alongside Mplus DU3STEP/manual BCH outputs.
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({ library(dplyr); library(tidyr); library(tibble) })

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
adv    <- file.path(root, "advanced_reproducible")
shared <- file.path(adv, "_shared")
mp     <- file.path(adv, "Mplus_LCA_enum")
out    <- file.path(adv, "_outputs")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

r <- readRDS(file.path(shared, "data_responder.rds"))
cprob <- read.table(file.path(mp, "enum_5class.dat"), header = FALSE)
stopifnot(nrow(r) == nrow(cprob))
r$class5 <- factor(cprob[, ncol(cprob)], levels = 1:5, labels = paste0("C", 1:5))
r$class5_label <- factor(r$class5, levels = paste0("C", 1:5),
                         labels = c("Network-oriented prevention responders",
                                    "Escalation-aware mixed responders",
                                    "Life-threat protective responders",
                                    "Boundary-clarification persuaders",
                                    "Multi-action institutional responders"))

num <- function(x) suppressWarnings(as.numeric(as.vector(x)))
yes1 <- function(x) ifelse(num(x) == 1, 1, ifelse(num(x) == 2, 0, NA_real_))
selected <- function(dat, vars, code) {
  m <- sapply(vars, function(v) num(dat[[v]]) == code)
  as.numeric(rowSums(m, na.rm = TRUE) > 0)
}

## Q44: expected bystander roles, top 2.
q44 <- paste0("Q44_", 1:2)
r$role_confront_top2       <- selected(r, q44, 1)
r$role_police_top2         <- selected(r, q44, 2)
r$role_schoolwork_top2     <- selected(r, q44, 3)
r$role_network_top2        <- selected(r, q44, 4)
r$role_agency_info_top2    <- selected(r, q44, 5)
r$role_punishment_top2     <- selected(r, q44, 6)
r$role_victim_support_top2 <- selected(r, q44, 7)

## Q46: future education emphasis, top 2.
q46 <- paste0("Q46_", 1:2)
r$edu_legal_top2          <- selected(r, q46, 1)
r$edu_schoolwork_top2     <- selected(r, q46, 2)
r$edu_help_info_top2      <- selected(r, q46, 3)
r$edu_humanrights_top2    <- selected(r, q46, 4)
r$edu_bystander_role_top2 <- selected(r, q46, 5)

## Q47R/Q48R: intention to use services.
q47 <- paste0("Q47R_", 1:6)
q48 <- paste0("Q48R_", 1:7)
for (v in q47) r[[paste0(tolower(v), "_yes")]] <- yes1(r[[v]])
for (v in q48) r[[paste0(tolower(v), "_yes")]] <- yes1(r[[v]])
r$seoul_service_use_count <- rowSums(r[paste0(tolower(q47), "_yes")], na.rm = TRUE)
r$seoul_service_use_any   <- as.numeric(r$seoul_service_use_count > 0)
r$seoul_digital_center_yes <- r$q47r_5_yes
r$support_service_use_count <- rowSums(r[paste0(tolower(q48), "_yes")], na.rm = TRUE)
r$support_service_use_any   <- as.numeric(r$support_service_use_count > 0)
r$support_digital_center_yes <- r$q48r_5_yes

## Q50: policy needs, top 3.
q50 <- paste0("Q50_", 1:3)
r$policy_police_protection_top3 <- selected(r, q50, 1)
r$policy_punishment_top3        <- selected(r, q50, 2)
r$policy_perp_treatment_top3    <- selected(r, q50, 3)
r$policy_secondary_harm_top3    <- selected(r, q50, 4)
r$policy_victim_support_top3    <- selected(r, q50, 5)
r$policy_online_delete_top3     <- selected(r, q50, 6)
r$policy_school_education_top3  <- selected(r, q50, 7)
r$policy_workplace_protocol_top3<- selected(r, q50, 8)
r$policy_safe_environment_top3  <- selected(r, q50, 9)
r$policy_public_campaign_top3   <- selected(r, q50, 10)

distal_vars <- c(
  "role_confront_top2","role_police_top2","role_schoolwork_top2",
  "role_network_top2","role_agency_info_top2","role_punishment_top2",
  "role_victim_support_top2",
  "edu_legal_top2","edu_schoolwork_top2","edu_help_info_top2",
  "edu_humanrights_top2","edu_bystander_role_top2",
  "seoul_service_use_count","seoul_service_use_any","seoul_digital_center_yes",
  "support_service_use_count","support_service_use_any","support_digital_center_yes",
  "policy_police_protection_top3","policy_punishment_top3",
  "policy_perp_treatment_top3","policy_secondary_harm_top3",
  "policy_victim_support_top3","policy_online_delete_top3",
  "policy_school_education_top3","policy_workplace_protocol_top3",
  "policy_safe_environment_top3","policy_public_campaign_top3"
)

summary_wide <- r %>%
  group_by(class5, class5_label) %>%
  summarise(n = n(),
            across(all_of(distal_vars), \(x) mean(x, na.rm = TRUE)),
            .groups = "drop")
write.csv(summary_wide, file.path(out, "21_policy_distal_class_summary.csv"), row.names = FALSE)

summary_long <- summary_wide %>%
  pivot_longer(cols = all_of(distal_vars), names_to = "distal", values_to = "mean_or_prop")
write.csv(summary_long, file.path(out, "21_policy_distal_class_summary_long.csv"), row.names = FALSE)

test_one <- function(v) {
  x <- r[[v]]
  ok <- !is.na(x) & !is.na(r$class5)
  x <- x[ok]
  g <- droplevels(r$class5[ok])
  if (length(unique(x)) <= 2) {
    tab <- table(g, x)
    p <- tryCatch(chisq.test(tab)$p.value, error = function(e) NA_real_)
    stat <- tryCatch(unname(chisq.test(tab)$statistic), error = function(e) NA_real_)
    method <- "chi-square"
  } else {
    fit <- lm(x ~ g)
    a <- anova(fit)
    p <- a$`Pr(>F)`[1]
    stat <- a$`F value`[1]
    method <- "ANOVA"
  }
  data.frame(distal = v, method = method, statistic = stat, p_value = p)
}

tests <- bind_rows(lapply(distal_vars, test_one)) %>%
  mutate(p_fdr_BH = p.adjust(p_value, method = "BH")) %>%
  arrange(p_value)
write.csv(tests, file.path(out, "21_policy_distal_omnibus.csv"), row.names = FALSE)

sink(file.path(out, "21_summary.md"))
cat("# Policy Distal Outcomes by 5-Class LCA\n\n")
cat("Sample: active responders, N =", nrow(r), "\n\n")
cat("Class labels are provisional and based on the item-response profile from script 19.\n\n")
cat("## Omnibus tests with FDR q < .10\n\n")
print(tests %>% filter(p_fdr_BH < .10))
cat("\n## Class summary\n\n")
print(summary_wide)
cat("\nInterpretation: these modal-class distal comparisons translate the LCA into policy-relevant needs. ")
cat("Use as descriptive/sensitivity evidence, with DU3STEP/manual BCH retained for classification-error-aware checks.\n")
sink()

cat("Wrote:", file.path(out, "21_policy_distal_class_summary.csv"), "\n")
cat("Wrote:", file.path(out, "21_policy_distal_omnibus.csv"), "\n")
cat("Wrote:", file.path(out, "21_summary.md"), "\n")
