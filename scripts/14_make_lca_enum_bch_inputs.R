## ----------------------------------------------------------------------------
## 14. Build Mplus inputs for:
##   (a) Responder LCA 2-6 class with TECH11 (LMR) and TECH14 (BLRT)
##       -> formal class enumeration table
##   (b) Mplus AUXILIARY DCAT/DU3STEP for class differences on distal outcomes
##       (binary: online_withdrawal, digital_coharm, q42_police, role_police_top2)
##       (continuous: support_awareness, seoul_policy_awareness)
## ----------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({ library(dplyr); library(tidyr) })

root <- Sys.getenv("SCI_STALKING_ROOT", unset = "D:/2026/SCI/Stalking")
shared<- file.path(root, "advanced_reproducible", "_shared")
mp    <- file.path(root, "advanced_reproducible", "Mplus_LCA_enum")
mp2   <- file.path(root, "advanced_reproducible", "Mplus_BCH_distal")
dir.create(mp, recursive = TRUE, showWarnings = FALSE)
dir.create(mp2, recursive = TRUE, showWarnings = FALSE)

r <- readRDS(file.path(shared, "data_responder.rds"))

ind_q40 <- paste0("Q40_", 1:8)
ind_q41 <- paste0("Q41_", 1:6)
ind     <- c(ind_q40, ind_q41)

distal_bin  <- c("online_withdrawal", "digital_coharm", "q42_police", "role_police_top2")
distal_cont <- c("support_awareness", "seoul_policy_awareness")

short_ind  <- c(paste0("a", 1:8), paste0("b", 1:6))
short_db   <- c("owd", "dch", "q42p", "rpol2")
short_dc   <- c("supw", "spol")
short_aux  <- c(short_db, short_dc)

dat <- r[, c(ind, distal_bin, distal_cont)]
names(dat) <- c(short_ind, short_aux)
dat[is.na(dat)] <- -999
write.table(dat, file.path(mp, "lca_enum_data.dat"),
            sep = " ", row.names = FALSE, col.names = FALSE)
write.table(dat, file.path(mp2, "lca_bch_data.dat"),
            sep = " ", row.names = FALSE, col.names = FALSE)

names_str <- paste(c(short_ind, short_aux), collapse = " ")
ind_str   <- paste(short_ind, collapse = " ")

## (a) class enumeration 2..6 with TECH11 + TECH14
for (k in 2:6) {
  inp <- paste0(
'TITLE: Responder LCA k=', k, ' enumeration with TECH11 and TECH14;
DATA: FILE = "lca_enum_data.dat";
VARIABLE:
  NAMES = ', names_str, ';
  USEVARIABLES = ', ind_str, ';
  CATEGORICAL = ', ind_str, ';
  CLASSES = c(', k, ');
  MISSING = ALL(-999);
ANALYSIS:
  TYPE = MIXTURE;
  STARTS = 1000 200;
  STITERATIONS = 20;
  LRTSTARTS = 0 0 200 50;
  PROCESSORS = 4;
OUTPUT:
  TECH1 TECH8 TECH11 TECH14;
SAVEDATA:
  FILE = enum_', k, 'class.dat;
  SAVE = CPROBABILITIES;
')
  writeLines(inp, file.path(mp, paste0("enum_", k, "class.inp")))
}

## (b) BCH distal -- 5 class chosen from prior analysis
inp_bch <- paste0(
'TITLE: 5-class LCA with AUXILIARY BCH for distal outcomes (binary + continuous);
DATA: FILE = "lca_bch_data.dat";
VARIABLE:
  NAMES = ', names_str, ';
  USEVARIABLES = ', ind_str, ';
  CATEGORICAL = ', ind_str, ';
  CLASSES = c(5);
  AUXILIARY =
    owd(BCH) dch(BCH) q42p(BCH) rpol2(BCH) supw(BCH) spol(BCH);
  MISSING = ALL(-999);
ANALYSIS:
  TYPE = MIXTURE;
  STARTS = 1000 200;
  STITERATIONS = 20;
  PROCESSORS = 4;
OUTPUT:
  TECH1;
')
writeLines(inp_bch, file.path(mp2, "lca_5class_bch.inp"))

## (c) DU3STEP version as sanity comparison (often differs from BCH)
inp_du3 <- paste0(
'TITLE: 5-class LCA with AUXILIARY DU3STEP for distal outcomes;
DATA: FILE = "lca_bch_data.dat";
VARIABLE:
  NAMES = ', names_str, ';
  USEVARIABLES = ', ind_str, ';
  CATEGORICAL = ', ind_str, ';
  CLASSES = c(5);
  AUXILIARY =
    owd(DU3STEP) dch(DU3STEP) q42p(DU3STEP) rpol2(DU3STEP) supw(DU3STEP) spol(DU3STEP);
  MISSING = ALL(-999);
ANALYSIS:
  TYPE = MIXTURE;
  STARTS = 1000 200;
  STITERATIONS = 20;
  PROCESSORS = 4;
OUTPUT:
  TECH1;
')
writeLines(inp_du3, file.path(mp2, "lca_5class_du3step.inp"))

cat("Wrote enum 2..6 to:", mp, "\n")
cat("Wrote BCH/DU3STEP to:", mp2, "\n")
