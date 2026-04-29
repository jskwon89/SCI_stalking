# Reviewer-Defense Tables

These tables supplement the primary Q40+Q41 5-class situational-response profile model.

## Local-dependence summary

 item1 label1           item2 label2          
 Q40_2 Persuade         Q41_2 Escalation      
 Q40_3 Job/school exit  Q41_3 Others harmed   
 Q41_2 Escalation       Q41_5 Daily disruption
 Q41_3 Others harmed    Q41_5 Daily disruption
 Q40_7 Police           Q41_2 Escalation      
 Q40_1 Confront         Q41_2 Escalation      
 Q40_4 Shelter/move     Q41_3 Others harmed   
 Q40_5 School/work help Q41_3 Others harmed   
 Q40_2 Persuade         Q40_3 Job/school exit 
 Q40_4 Shelter/move     Q40_6 Network help    
 Q40_4 Shelter/move     Q41_5 Daily disruption
 pair                                             n_pair BVR    p_value 
 Q40_2 (Persuade) x Q41_2 (Escalation)            501    17.951 2.27e-05
 Q40_3 (Job/school exit) x Q41_3 (Others harmed)  501    13.364 2.56e-04
 Q41_2 (Escalation) x Q41_5 (Daily disruption)    501     9.954 1.61e-03
 Q41_3 (Others harmed) x Q41_5 (Daily disruption) 501     8.050 4.55e-03
 Q40_7 (Police) x Q41_2 (Escalation)              501     7.832 5.13e-03
 Q40_1 (Confront) x Q41_2 (Escalation)            501     7.738 5.41e-03
 Q40_4 (Shelter/move) x Q41_3 (Others harmed)     501     7.362 6.66e-03
 Q40_5 (School/work help) x Q41_3 (Others harmed) 501     7.049 7.93e-03
 Q40_2 (Persuade) x Q40_3 (Job/school exit)       501     5.247 2.20e-02
 Q40_4 (Shelter/move) x Q40_6 (Network help)      501     4.702 3.01e-02
 Q40_4 (Shelter/move) x Q41_5 (Daily disruption)  501     4.133 4.20e-02
 p_FDR   FDR_flag max_abs_std_resid
 0.00206  TRUE    2.751            
 0.01170  TRUE    2.620            
 0.04870  TRUE    2.071            
 0.08200 FALSE    1.928            
 0.08200 FALSE    2.035            
 0.08200 FALSE    1.896            
 0.08660 FALSE    2.085            
 0.09020 FALSE    2.041            
 0.22200 FALSE    1.667            
 0.27400 FALSE    1.658            
 0.34800 FALSE    1.610            
 sensitivity_response                                                     
 Addressed by pruned-trigger LCA removing Q41_2 and Q41_3                 
 Addressed by pruned-trigger LCA removing Q41_2 and Q41_3                 
 Addressed by pruned-trigger LCA removing Q41_2 and Q41_3                 
 Addressed by pruned-trigger LCA removing Q41_2 and Q41_3                 
 Addressed by pruned-trigger LCA removing Q41_2 and Q41_3                 
 Addressed by pruned-trigger LCA removing Q41_2 and Q41_3                 
 Addressed by pruned-trigger LCA removing Q41_2 and Q41_3                 
 Addressed by pruned-trigger LCA removing Q41_2 and Q41_3                 
 Reported as residual local dependence; retained for theoretical coherence
 Reported as residual local dependence; retained for theoretical coherence
 Reported as residual local dependence; retained for theoretical coherence
 manuscript_use                                                          
 Report in local-dependence supplemental table and mention in limitations
 Report in local-dependence supplemental table and mention in limitations
 Report in local-dependence supplemental table and mention in limitations
 Supplemental diagnostic only                                            
 Supplemental diagnostic only                                            
 Supplemental diagnostic only                                            
 Supplemental diagnostic only                                            
 Supplemental diagnostic only                                            
 Supplemental diagnostic only                                            
 Supplemental diagnostic only                                            
 Supplemental diagnostic only                                            

## Class-specific AvePP/OCC for selected 5-class model

 K class class_label                               modal_n modal_pct AvePP
 5 1     C1 Network-oriented prevention responders  73     14.6      0.939
 5 2     C2 Escalation-aware mixed responders      146     29.1      0.940
 5 3     C3 Life-threat protective responders       96     19.2      0.937
 5 4     C4 Boundary-clarification persuaders      110     22.0      0.947
 5 5     C5 Multi-action institutional responders   76     15.2      0.842
 OCC   classification_note OCC_note  
 90.32 Excellent AvePP     Strong OCC
 38.11 Excellent AvePP     Strong OCC
 62.76 Excellent AvePP     Strong OCC
 62.92 Excellent AvePP     Strong OCC
 29.90 Acceptable AvePP    Strong OCC

## 3/4/5/6-class interpretability comparison

 K AIC    BIC    aBIC   CAIC   AWE    entropy smallest_class_pct AvePP_min
 3 7366.2 7551.8 7412.1 7595.8 7957.3 0.886   14.8               0.888    
 4 7307.9 7556.7 7369.4 7615.7 8100.4 0.822   14.7               0.808    
 5 7274.8 7586.9 7352.0 7660.9 8268.9 0.879   14.5               0.842    
 6 7241.2 7616.5 7334.0 7705.5 8436.8 0.873   10.8               0.868    
 AvePP_mean OCC_min LMR_p 
 0.920      27.64   0.0006
 0.894      12.07   0.2760
 0.921      29.90   0.0108
 0.913      33.20   0.5150
 information_criterion_signal                                           
 Favored by BIC/CAIC; parsimonious benchmark                            
 Intermediate; no information-criterion minimum                         
 Not IC minimum; retained by classification quality and interpretability
 Favored by AIC/aBIC but not BIC/CAIC/AWE                               
 interpretability_summary                                                                                                                                       
 Coarse solution; collapses several active-response pathways and loses institutional gatekeeping detail                                                         
 Adds differentiation but does not cleanly separate the boundary-clarification and institutional-entry contrast                                                 
 Primary solution; separates network/prevention, escalation-aware mixed, life-threat protective, boundary-clarification, and multi-action institutional profiles
 Adds complexity without a clear additional policy target; LMR is non-significant                                                                               
 limitation                                                                       
 Too coarse for the manuscript's policy targeting claim                           
 LMR non-significant and lower classification clarity than K=5                    
 Requires explicit justification because ICs are split                            
 More complex and less parsimonious; smaller classes and no clear theoretical gain
 manuscript_role             
 Full reporting in supplement
 Full reporting in supplement
 Primary model               
 Full reporting in supplement

## Additional agreement metrics

 comparison                            n   cramer_V ARI   ARI_interpretation
 Primary 5-class vs Q40-only K=4       501 0.329    0.072 limited agreement 
 Primary 5-class vs pruned-trigger K=3 501 0.713    0.270 limited agreement 
 manuscript_interpretation                                                                                                 
 Behavior-only K=4 shows whether broad action axes remain visible without trigger items; not a replacement primary solution
 Pruned K=3 is a parsimonious local-dependence sensitivity; useful to show what is collapsed when trigger pairs are removed

## Narrative to use

The sensitivity checks do not aim to reproduce the exact primary class labels. Instead, they show what is lost when trigger/risk-recognition items are excluded or pruned. Q40-only and pruned-trigger alternatives support retaining the primary model as a situational-response profile model, while documenting local-dependence and information-criterion trade-offs transparently.
