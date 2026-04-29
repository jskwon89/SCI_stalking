## ----------------------------------------------------------------------------
## 13. Build Mplus categorical CFA inputs (replaces broken EFA in 04_*)
##   - Indicators: Q40_1..Q40_8 (response), Q41_1..Q41_6 (trigger)
##   - Sample: responders only (N=501)
##   - 1F, 2F (response vs trigger), 3F (institutional / private / trigger)
##   - WLSMV; theta parameterization
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({ library(dplyr) })

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
shared<- file.path(root, "advanced_reproducible", "_shared")
mp    <- file.path(root, "advanced_reproducible", "Mplus_CFA")
dir.create(mp, recursive = TRUE, showWarnings = FALSE)

r <- readRDS(file.path(shared, "data_responder.rds"))

ind_q40 <- paste0("Q40_", 1:8)
ind_q41 <- paste0("Q41_", 1:6)
ind     <- c(ind_q40, ind_q41)

dat <- r[, ind]
dat[is.na(dat)] <- -999
write.table(dat, file.path(mp, "cfa_data.dat"),
            sep = " ", row.names = FALSE, col.names = FALSE)

short <- c(paste0("a", 1:8), paste0("b", 1:6))
names_str <- paste(short, collapse = " ")

build_inp <- function(label, factor_block) {
  paste0(
'TITLE: CFA ', label, ' (WLSMV, categorical)
DATA: FILE = "cfa_data.dat";
VARIABLE:
  NAMES = ', names_str, ';
  USEVARIABLES = ', names_str, ';
  CATEGORICAL = ', names_str, ';
  MISSING = ALL(-999);
ANALYSIS:
  ESTIMATOR = WLSMV;
  PARAMETERIZATION = THETA;
MODEL:
', factor_block, '
OUTPUT:
  STDYX MODINDICES(10) RESIDUAL TECH4;
SAVEDATA:
  FILE = cfa_', label, '_fs.dat;
  SAVE = FSCORES;
')
}

block_1f <- "  F BY a1* a2 a3 a4 a5 a6 a7 a8 b1 b2 b3 b4 b5 b6;\n  F@1;\n"
block_2f <- "  RESP BY a1* a2 a3 a4 a5 a6 a7 a8;
  TRIG BY b1* b2 b3 b4 b5 b6;
  RESP@1; TRIG@1;\n"
block_3f <- "  INST BY a5* a7 a8 a4;
  PRIV BY a1* a2 a6 a3;
  TRIG BY b1* b2 b3 b4 b5 b6;
  INST@1; PRIV@1; TRIG@1;\n"

writeLines(build_inp("1F", block_1f), file.path(mp, "cfa_1F.inp"))
writeLines(build_inp("2F", block_2f), file.path(mp, "cfa_2F.inp"))
writeLines(build_inp("3F", block_3f), file.path(mp, "cfa_3F.inp"))

cat("Wrote inputs to:", mp, "\n")
list.files(mp)
