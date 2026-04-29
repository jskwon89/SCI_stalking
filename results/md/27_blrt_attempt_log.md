# BLRT Attempt Log

BLRT was requested using Mplus TECH14 under the available Mplus 7 environment.

# A tibble: 6 × 10
  attempt            K output_file terminated_normally best_ll_replicated BLRT_p
  <chr>          <int> <chr>       <lgl>               <lgl>               <dbl>
1 primary_Mplus…     2 D:/2026/SC… TRUE                TRUE                    0
2 primary_Mplus…     3 D:/2026/SC… TRUE                TRUE                    0
3 primary_Mplus…     4 D:/2026/SC… TRUE                TRUE                    0
4 primary_Mplus…     5 D:/2026/SC… TRUE                TRUE                    0
5 primary_Mplus…     6 D:/2026/SC… TRUE                TRUE                    0
6 high_LRTSTART…    NA D:/2026/SC… NA                  NA                     NA
# ℹ 4 more variables: successful_bootstrap_draws <int>, has_lrt_block <lgl>,
#   retained_as_primary_criterion <lgl>, note <chr>

## Decision

BLRT was requested using TECH14, but bootstrap solutions were unstable under the available Mplus 7 environment; therefore, BLRT was not retained as a primary class-enumeration criterion.

Primary class enumeration should rely on LMR rebound, classification quality, minimum class size, and substantive/policy interpretability, while reporting the BLRT attempt transparently in supplementary materials.
