# Data Availability

## Source

The analyses use the **2024 Seoul Citizen Stalking Awareness and
Victimization Survey** (서울시민 스토킹 인식 및 피해 실태조사, 2024).

- Producer: Seoul Foundation of Women & Family
- Distributor: KOSSDA (Korea Social Science Data Archive),
  Seoul National University
- KOSSDA permanent ID: <https://kossda.snu.ac.kr/handle/20.500.12236/31166>
- File used: `kor_data_20240048.sav` (SPSS format, N = 2,500)

## Why the data file is NOT in this repository

KOSSDA distributes survey microdata under user-registration and access
terms that **do not permit redistribution** of the raw data file. To
respect this license, the .sav file is excluded from this repository.

All RDS data caches and Mplus .out / .dat files derived from the survey
data are also excluded for the same reason. The repository contains only
analysis code, Mplus input files, and aggregate result tables.

## How to obtain the data

1. Visit <https://kossda.snu.ac.kr> and create a free researcher account.
2. Search for **서울시민 스토킹 인식 및 피해 실태조사, 2024** or use the
   permanent ID above.
3. Submit the data-use application form. Approval is typically granted
   within a few business days for academic research.
4. Download the `.sav` file (the file used here is named
   `kor_data_20240048.sav`).

## How to plug the data into this repository

Place the downloaded `.sav` file at the path expected by the scripts
(default: `<project_root>/kor_data_20240048.sav`). Edit `scripts/run_all.R`
and `scripts/10_data_prep_shared.R` if your install path differs.

After that, the full pipeline runs end to end:

```bash
cd scripts
"C:/Program Files/R/R-4.4.1/bin/Rscript.exe" run_all.R
```

`99_verify.R` will check the key odds ratios against the expected values
documented in the script and write a PASS/FAIL line to `VERIFICATION.md`.

## Aggregate results in this repository

`results/csv/` and `results/md/` contain only:

- Class-level aggregate proportions and means
- Logistic regression coefficients and odds ratios
- Mplus-derived class enumeration and item-response probabilities
- Multiple-comparison corrected p-values and effect sizes
- Diagnostic statistics (BVR, AvePP, OCC)

These tables are **not microdata** and contain no row-level individual
information. They are released under the MIT license that covers this
repository.

## Citation

If you use this analysis package, please cite both:

- The forthcoming manuscript (citation to be added).
- The 2024 Seoul Citizen Stalking Awareness and Victimization Survey
  via KOSSDA, following KOSSDA's recommended citation format.
