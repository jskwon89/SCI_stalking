## ----------------------------------------------------------------------------
## 23. Extended LCA model-selection reporting
##
## Adds manuscript-friendly model selection diagnostics:
##   - CAIC and AWE, in addition to AIC/BIC/aBIC
##   - average posterior probabilities (AvePP) by assigned modal class
##   - model-selection elbow plot for AIC/BIC/aBIC/CAIC/AWE
##
## The selected model is still a substantive decision; these diagnostics make
## the trade-off between 3-class parsimony and 5-class interpretability explicit.
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({ library(dplyr) })

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
adv  <- file.path(root, "advanced_reproducible")
mp   <- file.path(adv, "Mplus_LCA_enum")
out  <- file.path(adv, "_outputs")
dir.create(out, recursive = TRUE, showWarnings = FALSE)

fit_file <- file.path(out, "16_class_enumeration_table.csv")
stopifnot(file.exists(fit_file))
fit <- read.csv(fit_file)

N <- 501

read_cprob_diag <- function(k) {
  f <- file.path(mp, paste0("enum_", k, "class.dat"))
  if (!file.exists(f)) return(NULL)
  if (file.info(f)$size == 0) return(NULL)
  d <- read.table(f, header = FALSE)
  item_cols <- 14
  post <- as.matrix(d[, (item_cols + 1):(item_cols + k)])
  modal <- as.integer(d[, ncol(d)])
  avepp <- sapply(1:k, function(c) {
    idx <- which(modal == c)
    if (length(idx) == 0) return(NA_real_)
    mean(post[idx, c], na.rm = TRUE)
  })
  prop <- as.numeric(table(factor(modal, levels = 1:k))) / length(modal)
  occ <- (avepp / (1 - avepp)) / (prop / (1 - prop))
  data.frame(
    K = k,
    class = 1:k,
    modal_prop = prop,
    AvePP = avepp,
    OCC = occ
  )
}

avepp_by_class <- bind_rows(lapply(fit$K, read_cprob_diag))
write.csv(avepp_by_class, file.path(out, "23_avepp_by_class.csv"), row.names = FALSE)

avepp_summary <- avepp_by_class %>%
  group_by(K) %>%
  summarise(AvePP_min = min(AvePP, na.rm = TRUE),
            AvePP_mean = mean(AvePP, na.rm = TRUE),
            OCC_min = min(OCC, na.rm = TRUE),
            .groups = "drop")

fit_ext <- fit %>%
  mutate(CAIC = -2 * LL + npar * (log(N) + 1),
         AWE  = -2 * LL + 2 * npar * (log(N) + 1.5)) %>%
  left_join(avepp_summary, by = "K") %>%
  mutate(best_AIC = AIC == min(AIC, na.rm = TRUE),
         best_BIC = BIC == min(BIC, na.rm = TRUE),
         best_aBIC = aBIC == min(aBIC, na.rm = TRUE),
         best_CAIC = CAIC == min(CAIC, na.rm = TRUE),
         best_AWE = AWE == min(AWE, na.rm = TRUE))

write.csv(fit_ext, file.path(out, "23_lca_extended_fit_table.csv"), row.names = FALSE)

plot_file <- file.path(out, "23_lca_fit_elbow_plot.png")
crit <- c("AIC", "BIC", "aBIC", "CAIC", "AWE")
png(plot_file, width = 2100, height = 1350, res = 300)
matplot(fit_ext$K, as.matrix(fit_ext[, crit]), type = "b", pch = 16,
        lty = 1, lwd = 2, col = c("#1b9e77", "#d95f02", "#7570b3", "#e7298a", "#66a61e"),
        xlab = "Number of classes", ylab = "Fit statistic",
        main = "LCA model-selection elbow plot", xaxt = "n")
axis(1, at = fit_ext$K)
legend("topright", legend = crit, col = c("#1b9e77", "#d95f02", "#7570b3", "#e7298a", "#66a61e"),
       lty = 1, pch = 16, bty = "n", cex = 0.8)
dev.off()

sink(file.path(out, "23_summary.md"))
cat("# Extended LCA Fit Reporting\n\n")
cat("N =", N, "\n\n")
cat("## Extended fit table\n\n")
print(fit_ext)
cat("\n## AvePP by class\n\n")
print(avepp_by_class)
cat("\nInterpretation: information criteria favor the most parsimonious defensible solution, ")
cat("while AvePP and entropy describe classification quality. Entropy should not be used as the primary class-number criterion. ")
cat("If a 5-class model is retained, justify it by theoretical and policy differentiation, not by BIC alone.\n")
sink()

cat("Wrote:", file.path(out, "23_lca_extended_fit_table.csv"), "\n")
cat("Wrote:", file.path(out, "23_avepp_by_class.csv"), "\n")
cat("Wrote:", plot_file, "\n")
cat("Wrote:", file.path(out, "23_summary.md"), "\n")
