# Missing-Data Audit

This audit documents analysis-specific Ns for the sequential bystander response framework.

## Analysis sample Ns

                                               analysis    N
                                             Raw sample 2500
                                 Stage 1 witness sample  749
        Stage 1 active-response logistic complete cases  749
 Stage 1 institutional-response logistic complete cases  749
                    Stage 2 active-responder LCA sample  501
                    Stage 2 LCA complete indicator rows  501
                 Stage 2 R3STEP complete covariate rows  501
                    Stage 3 non-response barrier sample  248
                   Stage 3 non-reporting barrier sample  333
                                                                                      note
                                                                      Original survey file
                                                Any witnessed stalking behavior in Q31/Q32
                                              Complete cases for HC3 region-adjusted logit
                                              Complete cases for HC3 region-adjusted logit
                                            Active responders used for primary Q40+Q41 LCA
 Mplus uses all rows with missing coded as -999; this row reports complete indicators only
                                     Covariate completeness for R3STEP auxiliary variables
                                                 Witnesses who reported no active response
                                            Active responders with no police report in Q42

## Variables with any missingness

            sample                                block   variable   N
 Witnesses (N=749) Stage 1 logistic outcomes/covariates q42_police 749
 missing_n missing_pct nonmissing_n
       248       33.11          501

## Interpretation

Prevalence estimates are unweighted sample proportions because the source file did not provide a weighting variable. The audit supports transparent reporting of Stage 1, Stage 2, and Stage 3 analysis Ns.
