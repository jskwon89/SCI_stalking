## ----------------------------------------------------------------------------
## 32. C4 vs C5 focal contrast
##
## Purpose:
##   The manuscript's most policy-relevant contrast is C4 (boundary persuasion:
##   high willingness, little institutional entry) versus C5 (multi-action
##   institutional responders). This script produces a compact focal-contrast
##   table for Results/Supplement language.
##
## Outputs:
##   _outputs/32_C4_C5_focal_contrast.csv
##   _outputs/32_C4_C5_focal_contrast_summary.md
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({
  library(dplyr)
  library(tibble)
})

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
adv    <- file.path(root, "advanced_reproducible")
shared <- file.path(adv, "_shared")
out    <- file.path(adv, "_outputs")
mp_r3  <- file.path(adv, "Mplus_responder_LCA_R3STEP")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

class_labels <- c("Network_oriented_prevention","Escalation_aware_mixed",
                  "Life_threat_protective","Boundary_clarification",
                  "Multi_action_institutional")
display_labels <- c("C1 Network-oriented prevention responders",
                    "C2 Escalation-aware mixed responders",
                    "C3 Life-threat protective responders",
                    "C4 Boundary-clarification persuaders",
                    "C5 Multi-action institutional responders")

read_primary_class <- function() {
  cp_path <- file.path(mp_r3, "responder_lca_5class_r3step_cprob.dat")
  hdr <- c(paste0("Q40_", 1:8), paste0("Q41_", 1:6),
           "stedu","dig","offcnt","freqz","intimate","severe",
           "mythz","fearz","crimez","victimz","supportz",
           paste0("CPROB", 1:5), "Class")
  cp <- read.table(cp_path, header = FALSE)
  names(cp) <- hdr
  factor(as.integer(cp$Class), levels = 1:5, labels = class_labels)
}

binary_vars <- c("stedu", "severe_coharm", "intimate", "known_nonint",
                 "q40_police", "q42_police", "institutional_response",
                 "role_police_top2", "online_withdrawal", "digital_coharm")
continuous_vars <- c("support_awareness", "seoul_policy_awareness", "fear",
                     "crime_denial", "offcnt", "dig", "total_type_count")

r <- readRDS(file.path(shared, "data_responder.rds"))
r$Class <- read_primary_class()
r$Class_label <- factor(display_labels[as.integer(r$Class)], levels = display_labels)

d <- r %>%
  filter(Class %in% c("Boundary_clarification", "Multi_action_institutional")) %>%
  mutate(focal_class = factor(ifelse(Class == "Boundary_clarification", "C4", "C5"),
                              levels = c("C4", "C5")))

if (nrow(d) == 0) stop("No C4/C5 rows found for focal contrast.")

bin_rows <- list()
for (v in intersect(binary_vars, names(d))) {
  dd <- d[, c("focal_class", v), drop = FALSE]
  dd <- dd[!is.na(dd[[v]]), , drop = FALSE]
  dd$focal_class <- factor(as.character(dd$focal_class), levels = c("C4", "C5"))
  if (nrow(dd) == 0) next
  tab <- table(dd$focal_class, dd[[v]])
  if (length(unique(as.character(dd$focal_class))) < 2 || any(rowSums(tab) == 0)) next
  p4 <- mean(dd[[v]][dd$focal_class == "C4"] == 1, na.rm = TRUE)
  p5 <- mean(dd[[v]][dd$focal_class == "C5"] == 1, na.rm = TRUE)
  n4 <- sum(dd$focal_class == "C4")
  n5 <- sum(dd$focal_class == "C5")
  y4 <- sum(dd[[v]][dd$focal_class == "C4"] == 1, na.rm = TRUE)
  y5 <- sum(dd[[v]][dd$focal_class == "C5"] == 1, na.rm = TRUE)
  ## Haldane-Anscombe correction for stable OR when a cell is zero.
  a <- y5 + 0.5; b <- n5 - y5 + 0.5; c <- y4 + 0.5; e <- n4 - y4 + 0.5
  or <- (a / b) / (c / e)
  p <- tryCatch(fisher.test(tab)$p.value, error = function(err) NA_real_)
  bin_rows[[v]] <- tibble(
    variable = v,
    type = "binary",
    C4_n = n4,
    C4_value = p4,
    C5_n = n5,
    C5_value = p5,
    contrast = "C5 vs C4 OR",
    contrast_value = or,
    p_value = p
  )
}

cont_rows <- list()
for (v in intersect(continuous_vars, names(d))) {
  dd <- d[, c("focal_class", v), drop = FALSE]
  dd <- dd[!is.na(dd[[v]]), , drop = FALSE]
  dd$focal_class <- factor(as.character(dd$focal_class), levels = c("C4", "C5"))
  if (nrow(dd) == 0) next
  x4 <- dd[[v]][dd$focal_class == "C4"]
  x5 <- dd[[v]][dd$focal_class == "C5"]
  tt <- tryCatch(t.test(x5, x4), error = function(err) NULL)
  cont_rows[[v]] <- tibble(
    variable = v,
    type = "continuous",
    C4_n = length(x4),
    C4_value = mean(x4),
    C5_n = length(x5),
    C5_value = mean(x5),
    contrast = "C5 minus C4 mean",
    contrast_value = mean(x5) - mean(x4),
    p_value = if (is.null(tt)) NA_real_ else tt$p.value
  )
}

all_rows <- c(unname(bin_rows), unname(cont_rows))
if (length(all_rows) == 0) stop("No C4/C5 focal-contrast rows were produced.")

contrast <- bind_rows(all_rows) %>%
  mutate(
    p_FDR = p.adjust(p_value, method = "BH"),
    C4_value = round(C4_value, 3),
    C5_value = round(C5_value, 3),
    contrast_value = round(contrast_value, 3),
    p_value = signif(p_value, 3),
    p_FDR = signif(p_FDR, 3)
  ) %>%
  arrange(type, p_FDR, variable)

write.csv(contrast, file.path(out, "32_C4_C5_focal_contrast.csv"), row.names = FALSE)

sink(file.path(out, "32_C4_C5_focal_contrast_summary.md"))
cat("# C4 vs C5 Focal Contrast\n\n")
cat("C4 = Boundary-clarification persuaders; C5 = Multi-action institutional responders.\n\n")
cat("## Focal contrast table\n\n")
print(as.data.frame(contrast), row.names = FALSE)
cat("\nInterpretation: this is a policy-targeting supplement. It directly tests whether the boundary-clarification class differs from the institutional benchmark on reporting, awareness, severity, and relationship context.\n")
sink()

cat("Wrote:\n",
    file.path(out, "32_C4_C5_focal_contrast.csv"), "\n",
    file.path(out, "32_C4_C5_focal_contrast_summary.md"), "\n")
