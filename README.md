Title
Analysis of the Sepsis randomized controlled trial dataset

Author 
Samir Samadov

Affiliation 
Brown University School of Engineering, Providence, RI, USA

Corresponding author contact
samir_samadov@brown.edu 

METHODS 
Statistical Analysis
The Acute Physiology and Chronic Health Evaluation (APACHE II) score is a composite variable used as an ICU mortality prediction tool, calculated at the time of admission. For the purpose of analysis, APACHE II scores were categorized into four risk strata: low risk (0-10), moderate risk (11-20), high risk (21-30), and very high risk (>30). Body temperature measurements at both baseline (temp0) and hour 40 (temp10) were further classified into three clinical categories: Hypothermia (≤97°F), Normal Temperature (>97°F to ≤99°F), and Fever (>99°F). 
Normality of all continuous variables was assessed both visually, using histograms and quantile-quantile (Q-Q) plots, and statistically using the one-sample Kolmogorov-Smirnov (KS) test with empirically derived variable means and standard deviations. Variables that failed to demonstrate a normal distribution (KS test p < 0.05) were treated as non-normally distributed and analyzed using non-parametric methods. Descriptive statistics for continuous variables are presented as median and interquartile range (IQR: Q1, Q3). Categorical variables are summarized as frequency and percentage. 
Bivariate associations between categorical variables were evaluated using Pearson’s chi-square test. Differences in temperature at hour 40 between the two independent groups were assessed using the Wilcoxon rank-sum test, as temperature at hour 40 was non-normally distributed in preliminary analyses. Differences across three groups defined by APACHE II tertiles were assessed using the Kruskal-Wallis test. Where the Kruskal-Wallis test was statistically significant. Dunn’s test was used as a post-hoc multiple comparison procedure. 
Spearman’s rank correlation coefficient (rho) was used to assess the association between pairs of continuous variables, given the non-normal distribution of APACHE II score and baseline temperature. Correlation results are reported with rho, sample size, and p-value.
Binary logistic regression was used to evaluate predictors of 30-day patient mortality. Patient fate (Alive = 0; Dead =1) was the binary outcome variable. Unadjusted (bivariate) logistic regression models were first run for each predictor individually. A multivariate (adjusted) logistic regression model was subsequently constructed to evaluate independent associations while controlling for all covariates simultaneously. The absence of multicollinearity among predictors was verified using the generalized variance inflation factor (GVIF), with GVIF values below 5 considered acceptable. Model fit was assessed using the Hosmer-Lemeshow goodness-of-fit test. Results from logistic regression models are reported as odds ratios (OR) with 95% confidence intervals (CI) and p-values. 
An alpha threshold of p < 0.05 was used to define statistically significant results for all tests. P values less than 0.0001 are reported as p < 0.0001. All statistical analyses were performed using R programming language version 4.5.2 within RStudio IDE Version: 2026.01.1+403, released 02-19-2026. 

RESULTS
Participant Characteristics
A total of N = 455 participants were initially assessed in the dataset. Fifty-six participants were excluded due to missing values for temperature at hour 40 (temp10), and one additional participant was excluded due to a missing APACHE II score, resulting in a final analytical sample of N = 398. Complete participant characteristics and baseline physiological measures are presented in Table 1. Of the cohort, 262 (65.8%) participants survived to 30 days, while 136 (34.2%) died. Participants were nearly evenly distributed between the ibuprofen group (198, 49.7%) and the placebo group (200, 50.3%). The median APACHE II score was 14.0 (IQR 10.0-19.0), and the majority of participants fell into the moderate-risk category (200, 50.3%). The median baseline temperature was 100.8 °F (IQR 99.9-101.7°F), with 83.2% of participants presenting with fever at baseline. By hour 40, the median temperature had declined to 99.1°F  (IQR 98.1-100.4°F), and the proportion with fever decreased to 51.8%. 
Table 1. Participant characteristics, N = 398. Continuous variables are reported as median (Q1, Q3); categorical variables as frequency and percentage.  
Characteristic	N	Median (Q1, Q3) or N (%)
Treatment Group	398	 
	Ibuprofen	 	198 (49.7%)
	Placebo	 	200 (50.3%)
Patient Fate (30-day mortality)	398	 
	Alive	 	262 (65.8%)
	Dead	 	136 (34.2%)
APACHE II Score	398	14.0 (10.0, 19.0)
APACHE II Risk Category	398	 
	Low Risk (0–10)	 	116 (29.1%)
	Moderate Risk (11–20)	 	200 (50.3%)
	High Risk (21–30)	 	75 (18.8%)
	Very High Risk (>30)	 	7 (1.8%)
Follow-up Duration (hours)	398	720.0 (407.0, 720.0)
Baseline Temperature, temp0 (°F)	398	100.8 (99.9, 101.7)
Baseline Temperature Category	398	 
	Hypothermia (≤97°F)	 	24 (6.0%)
	Normal (97–99°F)	 	43 (10.8%)
	Fever (>99°F)	 	331 (83.2%)
Hour-40 Temperature, temp10 (°F)	398	99.1 (98.1, 100.4)
Hour-40 Temperature Category	398	 
	Hypothermia (≤97°F)	 	39 (9.8%)
	Normal (97–99°F)	 	153 (38.4%)
	Fever (>99°F)	 	206 (51.8%)
APACHE II, Acute Physiology and Chronic Health Evaluation II score. 

Chi-Square Analyses
Bivariate chi-square analyses were performed to evaluate the association between APACHE II risk category and both treatment assignment and mortality. Results are summarized in Table 2. No statistically significant association was observed between the treatment group and APACHE II risk category (p = 0.374), confirming that randomization was well-balanced with respect to illness severity. Mortality was significantly associated with APACHE II risk category (p < 0.0001), with patients in the high-risk group showing a markedly higher proportion of deaths (60 of 82, 73.2%) compared to patients in the low-risk group (16 of 116, 13.8%). 

Table 2. Association between APACHE II risk category, treatment, and patient fate (N = 398).
Values represent frequency and row percentage. P values determined by chi-square test. 
 	Low Risk (0–10) n=116	Moderate Risk (11–20) n=200	High Risk (>20) n=82	p value
Treatment	 	 	 	 
	Placebo	57 (14.2%)	106 (26.4%)	37 (9.2%)	0.374
	Ibuprofen	59 (14.8%)	94 (23.6%)	45 (11.3%)	 
Patient Fate	 	 	 	 
	Alive	100 (25.1%)	140 (35.2%)	22 (5.5%)	< 0.0001
	Dead	16 (4.0%)	60 (15.1%)	60 (15.1%)	 
APACHE II, Acute Physiology and Chronic Health Evaluation II score.

Temperature at Hour 40 by Categorical Groupings.
Normality testing confirmed that temperature at hour 40 was non-normally distributed (KS test p = 0.461 when the correct mean and SD were applied; however, visual inspection via histograms and Q-Q plots indicated deviation from normality). Non-parametric tests were therefore applied. Descriptive statistics for temperature at hour 40, stratified by treatment group, mortality status, and APACHE II tertile group, are presented in Table 3. 
A Wilcoxon rank sum test revealed that temperature at hour 40 was significantly higher in the placebo group (median 99.68 °F, IQR 98.58-100.77°F) compared to the ibuprofen group (median 98.60°F. IQR 97.60-99.60°F) (p < 0.0001), consistent with the expected antipyretic effect of ibuprofen. A statistically significant difference in temperature at hour 40 was also observed by 30-day survival status (p = 0.0003): survivors had a higher median temperature (99.40°F, IQR 98.30-100.48°F) than those who died (98.60°F, IQR 97.70-99.70°F). A Kruskal-Wallis test comparing temperature across APACHE II tertile groups did not yield a statistically significant result (p = 0.466), suggesting that baseline illness severity as categorized by APACHE II tertile was not independently associated with temperature at hour 40. 

Table 3. Temperature at hour 40 (°F) stratified by treatment, 30-day mortality, and APACHE II tertile group (N= 398). P values determined by Wilcoxon rank sum test (two groups) or Kruskal-Wallis test (three groups). 

Categorical Variable	Subgroup	n	Median (°F)	IQR (Q1–Q3)	p value
Treatment	Placebo	200	99.68	98.58–100.77	< 0.0001
 	Ibuprofen	198	98.60	97.60–99.60	 
30-Day Mortality	Alive	262	99.40	98.30–100.48	0.0003
 	Dead	136	98.60	97.70–99.70	 
APACHE II Tertile	[0,11)	116	99.40	98.23–100.40	0.466 (ns)
 	[11,17)	136	98.90	98.20–100.22	 
 	[17,41]	146	99.05	97.93–100.40	 
IQR, interquartile range; APACHE II, Acute Physiology and Chronic Health Evaluation II score; ns, not significant. 
Spearman Correlations
Spearman rank correlations between APACHE II score and temperature measurements are presented in Table 4. No statistically significant correlation was observed between APACHE II score and baseline temperature (rho = 0.027, p = 0.5865) or between APACHE II score and temperature at hour 40 (rho = -0.076, p = 0.1283). However, statistically significant positive correlation was observed between baseline temperature and temperature at hour 40 (rho = 0.364, p < 0.0001), indicating that patients with higher temperatures at baseline tended to have higher temperatures at hour 40. This association is illustrated in Figure 1. 

Table 4. Spearman rank correlation between APACHE II score and temperature variables (N = 398) 
Variable Pair	N	rho	p value
APACHE II Score vs Baseline Temperature (temp0)	398	0.027	0.5865 (ns)
APACHE II Score vs Hour-40 Temperature (temp10)	398	-0.076	0.1283 (ns)
Baseline Temperature (temp0) vs Hour-40 Temperature (temp10)	398	0.364	< 0.0001
rho, Spearman rank correlation coefficient; ns, not statistically significant. 





Figure 1. Scatter plot of baseline temperature (temp0, °F) versus temperature at hour 40 (tem10, °F), N = 398. The red line represents the linear regression trend line. The confidence ellipse surrounds the bivariate distribution. Spearman’s rho = 0.364, p < 0.0001. 
 

Logistic regression: Predictors of 30-Day Mortality
Binary logistic regression was used to identify predictors of 30-day mortality among patients with sepsis. Both unadjusted and adjusted odds ratios are presented in Table 5. In the bivariate analysis, APACHE II high-risk category was significantly associated with increased odds of death relative to the low-risk reference group (OR = 4.55, 95% CI 1.90-4.70, p < 0.001). Additionally, the presence of fever at hour 40 was significantly associated with elevated odds of mortality compared to patients with normal temperature (OR = 2.44, 95% CI 1.60-3.77, p = 0.0001). Treatment with placebo versus ibuprofen and baseline temperature category were not statistically significantly associated with mortality in the unadjusted models. 
In the fully adjusted multivariate model, fever at hour 40 remained the strongest and most statistically significant predictor of mortality (adjusted OR = 2.99, 95% CI 1.90-4.70, p < 0.0001). APACHE II high-risk category also remained significantly associated with mortality after adjustment (adjusted OR = 4.55, 95% CI 2.08-10.25, p < 0.001). The very high-risk APACHE II category showed elevated odds of death relative to low-risk group (adjusted OR = 4.51, 95% CI 0.84-35.29); however, this did not reach statistical significance (p = 0.099), likely reflecting the small number of participants in this stratum (n = 7). No statistically significant association was observed between treatment group or baseline temperature category and 30-day mortality after adjustment. The multicollinearity check confirmed all GVIF values were below 5, and the Hosmer-Lemeshow test indicated adequate model fit. 










Table 5. Unadjusted and adjusted odds ratios (OR) for predictors of 30-day mortality in patients with sepsis (N = 398). 

Predictor	n	Unadjusted OR (95% CI)	Adjusted OR (95% CI)	Adjusted p value
APACHE II Category (ref: Low Risk)	 	 	 	 
	Moderate Risk	200	1.38 (0.71–2.74)	1.45 (0.73–2.93)	0.290
	High Risk	75	4.55 (2.17–9.90)	4.55 (2.08–10.25)	< 0.001
	Very High Risk	7	4.82 (0.94–32.2)	4.51 (0.84–35.29)	0.099
Treatment (ref: Ibuprofen)	 	 	 	 
	Placebo	200	1.01 (0.64–1.58)	0.96 (0.60–1.53)	0.866
Baseline Temperature (ref: Normal)	 	 	 	 
	Hypothermia	24	1.24 (0.48–3.19)	1.04 (0.38–2.83)	0.941
	Fever	331	0.85 (0.43–1.70)	0.82 (0.40–1.68)	0.582
Hour-40 Temperature (ref: Normal)	 	 	 	 
	Hypothermia	39	0.87 (0.40–1.86)	0.92 (0.41–2.05)	0.831
	Fever	206	2.44 (1.60–3.77)	2.99 (1.90–4.70)	< 0.0001
OR, odds ratio; CI, confidence interval; APACHE II, Acute Physiology and Chronic Health Evaluation II score. Reference categories: APACHE II Low Risk; Treatment Ibuprofen; Temperature Normal (97-99°F). The adjusted model includes all variables simultaneously. 

