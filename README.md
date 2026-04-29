# Profiles of Bystander Responses to Stalking in Seoul

Reproducible analysis package for a study of stalking-bystander response
profiles using the **2024 Seoul Citizen Stalking Survey** (Seoul Foundation
of Women & Family).

> Bystander response to stalking is not primarily structured by digital
> exposure alone, but by risk recognition, relational context, prevention
> education, and access to institutional pathways.

## Sequential bystander response framework

| Stage | Sample | Question | Main analysis |
|---|---:|---|---|
| 1 | Witnesses, N=749 | Who acts and who uses institutional pathways? | Region-adjusted logistic regression (HC3 + Firth, FDR-BH) |
| 2 | Active responders, N=501 | How do risk recognition, relationship interpretation, and actions combine? | Q40+Q41 5-class situational-response profiles (Mplus LCA + R3STEP) |
| 3 | Non-responders N=248; non-reporting active responders N=333 | Where does response stop? | Barrier domain analysis (Q43, Q42_2) |

## Final 5-class solution

| Class | Label | n | % |
|---:|---|---:|---:|
| C1 | Network-oriented prevention responders | 73 | 14.6 |
| C2 | Escalation-aware mixed responders | 146 | 29.1 |
| C3 | Life-threat protective responders | 96 | 19.2 |
| C4 | Boundary-clarification persuaders | 110 | 22.0 |
| C5 | Multi-action institutional responders | 76 | 15.2 |

## Folder structure

```
SCI_stalking/
├── README.md
├── LICENSE
├── DATA_AVAILABILITY.md              <- how to obtain the KOSSDA data
├── docs/
│   └── METHODS_AND_RESULTS.md         <- full methods & results writeup
├── scripts/                           <- 26 R scripts (numbered execution order)
│   ├── 10_data_prep_shared.R
│   ├── 11_robust_logistic_firth.R
│   ├── 12_moderated_mediation_evalue.R
│   ├── 13~22 ...                      <- LCA, R3STEP, BCH, distal, barriers
│   ├── 23~33 ...                      <- reviewer-defense supplements
│   ├── 99_verify.R
│   └── run_all.R                      <- one-command pipeline
├── Mplus_inputs/                      <- .inp files only (no .out/.dat)
│   ├── CFA/                           <- 1F/2F/3F categorical CFA
│   ├── LCA_enum/                      <- k=2..6 enumeration with TECH11/14
│   ├── BCH_distal/                    <- 5-class with DU3STEP
│   ├── responder_R3STEP/              <- 5-class R3STEP class predictors
│   └── all_witness_Q40/               <- 749 sensitivity LCA
├── results/
│   ├── csv/                           <- 55 results tables (parsed from Mplus + R)
│   └── md/                            <- 21 analysis summaries
└── figures/                           <- 6 key PNG figures
```

## Software

- R 4.4.1 (Windows 11)
- Mplus 7.0
- Required R packages: see `scripts/run_all.R`

## How to reproduce

1. Obtain the survey data file `kor_data_20240048.sav` from KOSSDA
   (see `DATA_AVAILABILITY.md`) and place it in the project parent
   directory at the path declared in `scripts/10_data_prep_shared.R`.
2. Edit the `root` and `mplus_exe` paths at the top of `scripts/run_all.R`
   if your install paths differ.
3. Run:

```bash
cd scripts
"C:/Program Files/R/R-4.4.1/bin/Rscript.exe" run_all.R
```

The full pipeline (24 R scripts + 13 Mplus inputs) typically completes
in 2-3 minutes. `99_verify.R` prints a PASS/FAIL log against expected
key odds ratios.

## Reporting

`docs/METHODS_AND_RESULTS.md` contains the full Methods and Results
writeup with table-by-table descriptions and interpretation.

## Citation

If you use these scripts, please cite the manuscript (forthcoming).
The 2024 Seoul Citizen Stalking Survey is © Seoul Foundation of Women
& Family / KOSSDA; please cite per their distribution terms.

## License

Code: MIT (see `LICENSE`). Data are NOT included; see
`DATA_AVAILABILITY.md` for how to obtain them.

## Contact

Issues and questions: please open a GitHub issue.
