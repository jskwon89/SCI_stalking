## ----------------------------------------------------------------------------
## 19. LCA item-response probability table + 3-class vs 5-class sensitivity
##
##   (a) Parse item-response probabilities from each k=2..6 enum_*.out into a
##       single CSV (ICC × items × classes). This is the standard "Table 2"
##       in LCA papers showing the conditional probability profile.
##
##   (b) For 3-class and 5-class, compare:
##       - class sizes
##       - class composition on key descriptive vars (intimate, severe_coharm,
##         dig, stedu, q42_police, online_withdrawal)
##       - interpretive correspondence (which 3-class merges which 5-class?)
##
##   Outputs:
##     _outputs/19_item_response_probabilities.csv  (long-format ICC profile)
##     _outputs/19_item_response_5class_wide.csv     (5-class profile, wide)
##     _outputs/19_3class_vs_5class_crosstab.csv
##     _outputs/19_3class_vs_5class_means.csv
##     _outputs/19_summary.md
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({ library(dplyr); library(tidyr); library(tibble) })

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
shared<- file.path(root, "advanced_reproducible", "_shared")
mp    <- file.path(root, "advanced_reproducible", "Mplus_LCA_enum")
out   <- file.path(root, "advanced_reproducible", "_outputs")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

ind_short <- c(paste0("a", 1:8), paste0("b", 1:6))
ind_full  <- c(paste0("Q40_", 1:8), paste0("Q41_", 1:6))
ind_label <- c("Confront","Persuade","Job/school exit","Shelter/move",
               "School/work help","Network help","Police","Agency counseling",
               "Not romance","Escalation","Others harmed","Life threat",
               "Daily disruption","Prevent another harm")

## ---------- (a) parse item-response probabilities from each enum_*.out ----------
parse_icp <- function(k) {
  f <- file.path(mp, paste0("enum_", k, "class.out"))
  if (!file.exists(f)) return(NULL)
  L <- readLines(f, warn = FALSE)
  start <- grep("RESULTS IN PROBABILITY SCALE", L)[1]
  if (is.na(start)) return(NULL)
  ## ICP block continues until "QUALITY OF NUMERICAL RESULTS" or
  ## "TECHNICAL" or empty area
  end_candidates <- grep("QUALITY OF NUMERICAL|TECHNICAL [0-9]+ OUTPUT|LATENT CLASS REGRESSION", L)
  end_candidates <- end_candidates[end_candidates > start]
  end <- if (length(end_candidates) > 0) end_candidates[1] else length(L)
  block <- L[start:end]
  ## For each item, find "Category 2 X.XXX" lines under each Class header.
  ## Easier path: extract by class blocks "Latent Class N"
  cls_idx <- grep("^\\s*Latent Class\\s+[0-9]+", block)
  cls_num <- as.integer(regmatches(block[cls_idx],
                                    regexpr("[0-9]+", block[cls_idx])))
  recs <- list()
  for (i in seq_along(cls_idx)) {
    s <- cls_idx[i]
    e <- if (i < length(cls_idx)) cls_idx[i+1]-1 else length(block)
    sub <- block[s:e]
    ## item name lines like "    A1" then below "Category 2  X.XXX"
    item_idx <- grep("^\\s+[AB][0-9]+\\s*$|^\\s+[A-Z][0-9]+\\s*$", sub)
    for (j in item_idx) {
      item_name <- toupper(trimws(sub[j]))
      if (!item_name %in% toupper(ind_short)) next
      ## Look for next "Category 2"
      cat2 <- grep("Category 2", sub[(j+1):min(j+8, length(sub))])
      if (length(cat2) == 0) next
      cat2_line <- sub[j + cat2[1]]
      val <- as.numeric(regmatches(cat2_line,
                                    regexpr("0\\.[0-9]+|1\\.0+", cat2_line))[1])
      recs[[length(recs)+1]] <- data.frame(
        K = k, class = cls_num[i],
        item = item_name,
        prob_yes = val
      )
    }
  }
  bind_rows(recs)
}

icp_long <- bind_rows(lapply(2:6, parse_icp))
## map a1..a8,b1..b6 -> Q40_*/Q41_*/label
short_to_full  <- setNames(ind_full,  toupper(ind_short))
short_to_label <- setNames(ind_label, toupper(ind_short))
icp_long <- icp_long %>%
  mutate(item_full  = short_to_full[item],
         item_label = short_to_label[item])
write.csv(icp_long, file.path(out, "19_item_response_probabilities.csv"), row.names = FALSE)

## 5-class profile, wide
icp5 <- icp_long %>% filter(K == 5) %>%
  select(item_full, item_label, class, prob_yes) %>%
  arrange(class, item_full) %>%
  pivot_wider(names_from = class, values_from = prob_yes,
              names_prefix = "C")
write.csv(icp5, file.path(out, "19_item_response_5class_wide.csv"), row.names = FALSE)

cat("Wrote item-response probabilities (5-class):\n")
print(icp5)

## ---------- (b) 3-class vs 5-class composition crosstab ----------
## Need modal class assignment from each enum file's CPROBABILITIES file.
read_modal <- function(k) {
  f <- file.path(mp, paste0("enum_", k, "class.dat"))
  if (!file.exists(f)) return(NULL)
  d <- read.table(f, header = FALSE)
  ## Last column = modal class
  d[, ncol(d)]
}
modal_3 <- read_modal(3)
modal_5 <- read_modal(5)

if (!is.null(modal_3) && !is.null(modal_5) && length(modal_3) == length(modal_5)) {
  cross <- as.data.frame.matrix(table(`5class` = modal_5, `3class` = modal_3))
  cross$total_5class <- rowSums(cross)
  write.csv(cross, file.path(out, "19_3class_vs_5class_crosstab.csv"), row.names = TRUE)
  cat("\n3-class vs 5-class crosstab (rows=5-class):\n"); print(cross)

  ## Composition by 3-class on key vars
  r <- readRDS(file.path(shared, "data_responder.rds"))
  if (nrow(r) == length(modal_3)) {
    r$class3 <- factor(modal_3, levels = sort(unique(modal_3)),
                       labels = paste0("3C_", sort(unique(modal_3))))
    r$class5 <- factor(modal_5, levels = sort(unique(modal_5)),
                       labels = paste0("5C_", sort(unique(modal_5))))
    key_vars <- c("dig","offcnt","total_type_count","severe_coharm","intimate",
                  "stedu","q42_police","online_withdrawal","crime_denial")
    by3 <- r %>% group_by(class3) %>%
      summarise(across(all_of(key_vars), \(x) mean(x, na.rm = TRUE)), n = n())
    by5 <- r %>% group_by(class5) %>%
      summarise(across(all_of(key_vars), \(x) mean(x, na.rm = TRUE)), n = n())
    write.csv(by3, file.path(out, "19_3class_vs_5class_means_3class.csv"), row.names = FALSE)
    write.csv(by5, file.path(out, "19_3class_vs_5class_means_5class.csv"), row.names = FALSE)
    cat("\n3-class means on key vars:\n"); print(by3)
    cat("\n5-class means on key vars:\n"); print(by5)
  }
} else {
  cat("WARNING: modal_3 and modal_5 not aligned; skipping crosstab.\n")
}

## ---------- summary md ----------
sink(file.path(out, "19_summary.md"))
cat("# LCA item-response probabilities + 3-class vs 5-class sensitivity\n\n")
cat("## (a) Item-response probabilities (5-class, wide format)\n\n")
print(icp5)
cat("\n## (b) Cross-tabulation: 3-class x 5-class modal assignment\n\n")
if (exists("cross")) print(cross)
cat("\n\nInterpretation: each row shows how a 5-class member is distributed across the 3-class solution. ")
cat("Diagonal-like patterns mean the 3-class is a coarsening of the 5-class.\n")
sink()
cat("\nWrote:",
    file.path(out, "19_item_response_probabilities.csv"), "\n",
    file.path(out, "19_item_response_5class_wide.csv"), "\n",
    file.path(out, "19_3class_vs_5class_crosstab.csv"), "\n",
    file.path(out, "19_summary.md"), "\n")
