# 0. Install and Load Packages

# install.packages('expss')
# install.packages('tidyverse')
# install.packages('readxl')
# install.packages('ggplot2')
# install.packages('gtools')    # quantcut function
# install.packages('DescTools') # Levene's test
# install.packages('rstatix')   # Dunn's multiple comparison test
# install.packages('car')       # Variance inflation factor (VIF)
# install.packages('glmtoolbox') # Hosmer-Lemeshow goodness-of-fit test

library(expss)
library(tidyverse)
library(readxl)
library(ggplot2)
library(gtools)
library(DescTools)
library(rstatix)
# 1. Import Dataset and Initial Data Analysis
# Set working directory and import raw dataset
setwd("C:\\Users\\samir\\Desktop\\BIO2025_STATS\\Statistical_Analysis_Methods_and_Findings_Report")
df_sepsis <- read_excel("Dataset_sepsis_01.xlsx")

# Explore the raw dataset
view(df_sepsis)   # 455 rows, 7 columns
str(df_sepsis)
glimpse(df_sepsis)
summary(df_sepsis)  # 56 missing values in temp10; 1 missing in apache

# Remove participants with missing values for temp10 or apache
# These are required variables for the primary analyses
df_sepsis_clean <- drop_na(df_sepsis, c(temp10, apache))
View(df_sepsis_clean)  # 398 rows remain after exclusions
summary(df_sepsis_clean)

# 2. Create New Variables
# Create derived variables using mutate/case_when (tidyverse approach)
df_sepsis_clean <- df_sepsis_clean %>%
  mutate(
    
    # APACHE II categories: low (0-10), moderate (11-20), high (21-30), very high (>30)
    apache_cat = case_when(
      apache >= 0  & apache <= 10 ~ 1,   # Low risk
      apache > 10  & apache <= 20 ~ 2,   # Moderate risk
      apache > 20  & apache <= 30 ~ 3,   # High risk
      apache > 30                 ~ 4    # Very high risk
    ),
    
    # Follow-up fate: alive = reached 720 hours; dead = died before 720 hours
    followup_fate = case_when(
      followup < 720 & fate == 1 ~ 1,   # Dead
      followup == 720            ~ 0,   # Alive
      TRUE                       ~ NA_real_
    ),
    
    # Baseline temperature categories (Hypothermia / Normal / Fever)
    temp0_cat = case_when(
      temp0 <= 97              ~ "Hypothermia",
      temp0 > 97 & temp0 <= 99 ~ "Normal Temperature",
      temp0 > 99               ~ "Fever"
    ),
    
    # 10-hour temperature categories
    temp10_cat = case_when(
      temp10 <= 97               ~ "Hypothermia",
      temp10 > 97 & temp10 <= 99 ~ "Normal Temperature",
      temp10 > 99                ~ "Fever"
    )
  )

view(df_sepsis_clean)
table(df_sepsis_clean$apache_cat)      # Check distribution of APACHE categories
table(df_sepsis_clean$followup_fate)   # ~262 alive, ~136 dead
table(df_sepsis_clean$temp0_cat)
table(df_sepsis_clean$temp10_cat)

# 3. Apply Variable Labels and Factor Levels
# Assign variable labels
attr(df_sepsis_clean$treat, "label") <- "Treatment"
attr(df_sepsis_clean$apache, "label") <- "Acute Physiology and Chronic Health Evaluation (APACHE II) Score"
attr(df_sepsis_clean$apache_cat, "label") <- "APACHE II Mortality Risk Category"
attr(df_sepsis_clean$fate, "label") <- "Mortality (0=Survival, 1=Death)"
attr(df_sepsis_clean$followup, "label") <- "Follow-up Duration (hours)"
attr(df_sepsis_clean$followup_fate, "label") <- "30-Day Mortality Status"
attr(df_sepsis_clean$temp0, "label") <- "Temperature at Baseline (°F)"
attr(df_sepsis_clean$temp10, "label") <- "Temperature at Hour 40 (°F)"
attr(df_sepsis_clean$temp0_cat, "label") <- "Baseline Temperature Category"
attr(df_sepsis_clean$temp10_cat, "label") <- "10-Hour Temperature Category"
view(df_sepsis_clean)

# Convert categorical variables to factors with labelled levels
df_sepsis_clean$fate <- factor(df_sepsis_clean$fate,
                               levels = c(0, 1),
                               labels = c("Alive", "Dead"))

df_sepsis_clean$treat <- factor(df_sepsis_clean$treat,
                                levels = c(0, 1),
                                labels = c("Placebo", "Ibuprofen"))

df_sepsis_clean$apache_cat <- factor(df_sepsis_clean$apache_cat,
                                     levels = c(1, 2, 3, 4),
                                     labels = c("Low risk", "Moderate risk", "High risk", "Very high risk"))

df_sepsis_clean$temp0_cat  <- factor(df_sepsis_clean$temp0_cat)
df_sepsis_clean$temp10_cat <- factor(df_sepsis_clean$temp10_cat)
view(df_sepsis_clean)

# Set reference categories for regression models
df_sepsis_clean$treat <- relevel(df_sepsis_clean$treat, ref = "Ibuprofen")
df_sepsis_clean$fate  <- relevel(df_sepsis_clean$fate, ref = "Alive")
df_sepsis_clean$apache_cat<- relevel(df_sepsis_clean$apache_cat,ref = "Low risk")
df_sepsis_clean$temp0_cat <- relevel(df_sepsis_clean$temp0_cat, ref = "Normal Temperature")
df_sepsis_clean$temp10_cat<- relevel(df_sepsis_clean$temp10_cat,ref = "Normal Temperature")
view(df_sepsis_clean)

# Turn off scientific notation globally
options(scipen = 999)

view(df_sepsis_clean)

# 4. Normality Assessment for Continuous Variables
# Histograms ---
hist(df_sepsis_clean$apache, main = "APACHE II Score", xlab = "Score")
hist(df_sepsis_clean$followup, main = "Follow-up Duration", xlab = "Hours")
hist(df_sepsis_clean$temp0, main = "Baseline Temperature (°F)", xlab = "°F")
hist(df_sepsis_clean$temp10, main = "Hour-40 Temperature (°F)", xlab = "°F")

# Q-Q Plots
qqnorm(df_sepsis_clean$apache)   
qqline(df_sepsis_clean$apache)

qqnorm(df_sepsis_clean$followup)
qqline(df_sepsis_clean$followup)  # Skewed

qqnorm(df_sepsis_clean$temp0)
qqline(df_sepsis_clean$temp0)

qqnorm(df_sepsis_clean$temp10)
qqline(df_sepsis_clean$temp10)    # Near-normal

# Kolmogorov-Smirnov normality tests (with empirical mean and SD)
mean(df_sepsis_clean$apache);  sd(df_sepsis_clean$apache)   # Mean=14.8, SD=6.8
mean(df_sepsis_clean$followup); sd(df_sepsis_clean$followup)# Mean=572.9, SD=233.0
mean(df_sepsis_clean$temp0);   sd(df_sepsis_clean$temp0)    # Mean=100.5, SD=1.9
mean(df_sepsis_clean$temp10);  sd(df_sepsis_clean$temp10)   # Mean=99.2, SD=1.7

ks.test(df_sepsis_clean$apache, 'pnorm', mean=14.8, sd=6.8)    # p=0.006789, non-normal
ks.test(df_sepsis_clean$followup,'pnorm', mean=572.9, sd=233.0)# p<0.0001, non-normal
ks.test(df_sepsis_clean$temp0, 'pnorm', mean=100.5, sd=1.9)    # p<0.0001, non-normal
ks.test(df_sepsis_clean$temp10, 'pnorm', mean=99.2, sd=1.7)    # p=0.461, NORMAL

# 5. Descriptive Statistics
# Continuous variables: median and IQR
summary(df_sepsis_clean[c("apache", "followup", "temp0", "temp10")])
summary(df_sepsis_clean) # All the variable descriptives 
sapply(df_sepsis_clean[c("apache", "followup", "temp0", "temp10")], sd) # SD

# Categorical variables: frequency and proportion 
table(df_sepsis_clean$treat) # Ibuprofen   Placebo 
#                                    198       200
proportions(table(df_sepsis_clean$treat)) # About 50% placebo, 50% ibuprofen

table(df_sepsis_clean$fate) # Alive  Dead 
#                               262   136 
proportions(table(df_sepsis_clean$fate)) # 65.8% alive, 34.2% dead

table(df_sepsis_clean$apache_cat) # Low risk  Moderate risk      High risk Very high risk 
#                                        116            200             75              7 

proportions(table(df_sepsis_clean$apache_cat)) # Low risk  Moderate risk      High risk     Very high risk 
#                                                   29.1%          50.3%          18.8%               1.8% 

table(df_sepsis_clean$temp0_cat) # Normal Temperature              Fever        Hypothermia 
#                                                  43                331                 24 

proportions(table(df_sepsis_clean$temp0_cat)) # Normal Temperature              Fever        Hypothermia 
#                                                            10.8%              83.2%               6.0%

table(df_sepsis_clean$temp10_cat) # Normal Temperature              Fever        Hypothermia 
#                                                  153                206                 39 

proportions(table(df_sepsis_clean$temp10_cat)) # Normal Temperature              Fever        Hypothermia 
#                                                             38.4%              51.8%               9.8% 

# Box plots for continuous variables
boxplot(df_sepsis_clean$apache, ylab = "APACHE II Score")
boxplot(df_sepsis_clean$followup, ylab = "Follow-up Duration (hours)")
boxplot(df_sepsis_clean$temp0, ylab = "Baseline Temperature (°F)")
boxplot(df_sepsis_clean$temp10, ylab = "Temperature at Hour 40 (°F)")

# Bar chart for APACHE II risk categories
par(mar = c(4, 11, 4, 4))
barplot(table(df_sepsis_clean$apache_cat) / nrow(df_sepsis_clean) * 100,
        xlim = c(0, 100), xlab = "Percentage (%)", horiz = TRUE, las = 2,
        main = "APACHE II Risk Category Distribution")

# 6. Chi-Square Tests 
# Association between 30-day mortality and APACHE II risk category
table(df_sepsis_clean$fate, df_sepsis_clean$apache_cat) # Low risk Moderate risk High risk Very high risk          
                                                  # Alive       93           137        31              1
                                                  # Dead        23            63        44              6
100 * proportions(table(df_sepsis_clean$fate, df_sepsis_clean$apache_cat)) # Low risk     Moderate risk     High risk      Very high risk  
                                                                    # Alive 23.3668342    34.4221106        7.7889447      0.2512563
                                                                    # Dead   5.7788945    15.8291457        11.0552764     1.5075377
chisq.test(df_sepsis_clean$fate, df_sepsis_clean$apache_cat) # Chi-square test 
#                                                              X-squared = 39.517, df = 3, p-value = 0.00000001349

# Association between treatment and APACHE II risk category 
table(df_sepsis_clean$treat, df_sepsis_clean$apache_cat) # Low risk Moderate risk High risk Very high risk
                                               # Ibuprofen       62            91        43              2
                                               # Placebo         54           109        32              5

100 * proportions(table(df_sepsis_clean$treat, df_sepsis_clean$apache_cat)) # Low risk      Moderate risk    High risk       Very high risk
                                                                  # Ibuprofen 15.5778894    22.8643216       10.8040201      0.5025126
                                                                  # Placebo   13.5678392    27.3869347       8.0402010       1.2562814

chisq.test(df_sepsis_clean$treat, df_sepsis_clean$apache_cat) # Chi-square test
#                                                               X-squared = 5.0608, df = 3, p-value = 0.1674

# Association between fate and treatment
table(df_sepsis_clean$fate, df_sepsis_clean$treat) # Ibuprofen Placebo
                                             # Alive       130     132
                                             # Dead         68      68

100 * proportions(table(df_sepsis_clean$fate, df_sepsis_clean$treat)) # Ibuprofen  Placebo
                                                                # Alive  32.66332  33.16583
                                                                # Dead   17.08543  17.08543
chisq.test(df_sepsis_clean$fate, df_sepsis_clean$treat)           # Chi-square dummy test

# 7. Wilcoxon Rank Sum and Kruskal-Wallis Tests
# Check variance equality before two-group tests 
var.test(temp10 ~ treat, data = df_sepsis_clean) # F test for equal variance
var.test(temp10 ~ fate, data = df_sepsis_clean)

# Wilcoxon rank sum test: temp10 by treatment group 
# Descriptive stats (median and IQR) stratified by treatment
aggregate(df_sepsis_clean$temp10, by = list(df_sepsis_clean$treat),
          FUN = function(x) c(Median = median(x),
                              Q1 = quantile(x, 0.25),
                              Q3 = quantile(x, 0.75)))

wilcox.test(temp10 ~ treat, data = df_sepsis_clean)  # p < 0.0001

# Wilcoxon rank sum test: temp10 by 30-day mortality 
aggregate(df_sepsis_clean$temp10, by = list(df_sepsis_clean$fate),
          FUN = function(x) c(Median = median(x),
                              Q1 = quantile(x, 0.25),
                              Q3 = quantile(x, 0.75)))

wilcox.test(temp10 ~ fate, data = df_sepsis_clean)   # p = 0.0003

# Create APACHE tertile variable for ANOVA/Kruskal-Wallis
# Uses quantcut() from gtools package to create equal-sized tertiles
df_sepsis_clean$apache_cat3 <- quantcut(df_sepsis_clean$apache, 3, right = FALSE)
table(df_sepsis_clean$apache_cat3)  #  [0,11) [11,17) [17,41] 
                                        # 116     136     146 

# Kruskal-Wallis test: temp10 across three APACHE tertile groups
aggregate(df_sepsis_clean$temp10, by = list(df_sepsis_clean$apache_cat3),
          FUN = function(x) c(Median = median(x, na.rm = TRUE),
                              Q1 = quantile(x, 0.25, na.rm = TRUE),
                              Q3 = quantile(x, 0.75, na.rm = TRUE))) #  Group.1 x.Median x.Q1.25% x.Q3.75%
                                                                    # 1  [0,11)   99.400   98.230  100.400
                                                                    # 2 [11,17)   98.900   98.200  100.220
                                                                    # 3 [17,41]   99.050   97.925  100.400

kruskal.test(temp10 ~ apache_cat3, data = df_sepsis_clean)  # p = 0.466, ns

# Post-hoc Dunn's test (example; Kruskal-Wallis was not significant) 
dunn_test(temp10 ~ apache_cat3, data = df_sepsis_clean)

# Figure: Box plot of temp10 stratified by APACHE tertile group 
ggplot(df_sepsis_clean, aes(x = apache_cat3, y = temp10)) +
  geom_boxplot() +
  xlab("APACHE II Risk Group (Tertiles)") +
  ylab("Temperature at Hour 40 (°F)") +
  ggtitle("Temperature at Hour 40 by APACHE II Risk Group (N=398)")

# 8. Spearman Correlation 
# Spearman correlation used because APACHE and temp0 are non-normally distributed

# APACHE II vs Baseline Temperature (temp0) 
cor(df_sepsis_clean$apache, df_sepsis_clean$temp0,
    method = "spearman", use = "complete.obs")# rho = 0.027
cor.test(df_sepsis_clean$apache, df_sepsis_clean$temp0,
         method = "spearman", use = "complete.obs") # p = 0.5865 (ns)

# APACHE II vs Hour-40 Temperature (temp10) 
cor(df_sepsis_clean$apache, df_sepsis_clean$temp10,
    method = "spearman", use = "complete.obs") # rho = -0.076
cor.test(df_sepsis_clean$apache, df_sepsis_clean$temp10,
         method = "spearman", use = "complete.obs") # p = 0.1283 (ns)

# Baseline Temperature (temp0) vs Hour-40 Temperature (temp10) 
cor(df_sepsis_clean$temp0, df_sepsis_clean$temp10,
    method = "spearman", use = "complete.obs")            # rho = 0.364
cor.test(df_sepsis_clean$temp0, df_sepsis_clean$temp10,
         method = "spearman", use = "complete.obs")            # p < 0.0001

# Scatter plots with linear trend lines
# Figure: APACHE II vs temp0
ggplot(df_sepsis_clean, aes(x = apache, y = temp0)) +
  geom_point() +
  stat_smooth(method = "lm", col = "#C42126", se = FALSE, size = 1) +
  stat_ellipse() +
  xlab("APACHE II Score") + ylab("Baseline Temperature (°F)") +
  annotate("text", label = "rho = 0.027\np = 0.5865 (ns)", x = 5, y = 93)

# Figure: APACHE II vs temp10
ggplot(df_sepsis_clean, aes(x = apache, y = temp10)) +
  geom_point() +
  stat_smooth(method = "lm", col = "#C42126", se = FALSE, size = 1) +
  stat_ellipse() +
  xlab("APACHE II Score") + ylab("Temperature at Hour 40 (°F)") +
  annotate("text", label = "rho = -0.076\np = 0.1283 (ns)", x = 5, y = 95)

# Figure: temp0 vs temp10
ggplot(df_sepsis_clean, aes(x = temp0, y = temp10)) +
  geom_point() +
  # stat_smooth(method = "lm", col = "#C42126", se = FALSE, size = 1) +
  stat_ellipse() +
  xlab("Baseline Temperature (°F)") + ylab("Temperature at Hour 40 (°F)") +
  annotate("text", label = "rho = 0.364\np < 0.0001****", x = 105, y = 93)

# 9. Simple Linear Regression 
# Evaluate linear relationship between baseline temperature and Temperature after 40 hours

# Scatter plot to visualize potential linear relationship
ggplot(df_sepsis_clean, aes(x = temp0, y = temp10)) + # apache
  geom_point() +
  stat_ellipse()

# Examine diagnostic plots for the linear model
plot(lm(temp0 ~ temp10, data = df_sepsis_clean))

# Run simple linear regression: baseline temperature ~ Temperature after 40 hours
lm(temp0 ~ temp10, data = df_sepsis_clean)                         # Beta coefficient and intercept
summary(lm(temp0 ~ temp10, data = df_sepsis_clean))                # Beta, SE, t-statistic, p value
confint(lm(temp0 ~ temp10, data = df_sepsis_clean), level = 0.95)  # 95% CI

# Scatter plot with regression line and 95% CI
ggplot(df_sepsis_clean, aes(x = temp0, y = temp10)) +
  geom_point() +
  geom_smooth(method = lm, se = TRUE, level = 0.95) +
  xlab("Baseline Temperature (°F)") + ylab("Temperature after 40 hours (°F)")

# 10. Binary and Multivariate Logistic Regression (Element 9)
# Model 1: Bivariate (unadjusted) logistic regression models

# Predictor: APACHE II category
exp(coef(glm(fate ~ apache_cat, data = df_sepsis_clean, family = binomial)))   # OR
exp(confint(glm(fate ~ apache_cat, data = df_sepsis_clean, family = binomial))) # 95% CI
summary(glm(fate ~ apache_cat, data = df_sepsis_clean, family = binomial))    # p value

# Predictor: Treatment group
exp(coef(glm(fate ~ treat, data = df_sepsis_clean, family = binomial))) # OR
exp(confint(glm(fate ~ treat, data = df_sepsis_clean, family = binomial))) # 95% CI
summary(glm(fate ~ treat, data = df_sepsis_clean, family = binomial)) # p value

# Predictor: Baseline temperature category
exp(coef(glm(fate ~ temp0_cat, data = df_sepsis_clean, family = binomial)))   # OR
exp(confint(glm(fate ~ temp0_cat,data = df_sepsis_clean, family = binomial)))   # 95% CI
summary(glm(fate ~ temp0_cat, data = df_sepsis_clean, family = binomial))    # p value

# Predictor: 10-hour temperature category
exp(coef(glm(fate ~ temp10_cat,  data = df_sepsis_clean, family = binomial)))   # OR
exp(confint(glm(fate ~ temp10_cat,data=df_sepsis_clean,  family = binomial)))   # 95% CI
summary(glm(fate ~ temp10_cat,   data = df_sepsis_clean, family = binomial))    # p value

#Model 2: Multivariate (adjusted) logistic regression

# Check for multicollinearity using the variance inflation factor (VIF)
library(car)
vif(glm(fate ~ apache_cat + treat + temp0_cat + temp10_cat,
        data = df_sepsis_clean, family = binomial))
# All GVIF values < 5; no multicollinearity detected

# Check model fit using the Hosmer-Lemeshow goodness-of-fit test
library(glmtoolbox)
hltest(glm(fate ~ apache_cat + treat + temp0_cat + temp10_cat,
           data = df_sepsis_clean, family = binomial))

# Run multivariate logistic regression
exp(coef(glm(fate ~ apache_cat + treat + temp0_cat + temp10_cat,
             data = df_sepsis_clean, family = binomial)))    # Adjusted ORs
exp(confint(glm(fate ~ apache_cat + treat + temp0_cat + temp10_cat,
                data = df_sepsis_clean, family = binomial))) # 95% CI
summary(glm(fate ~ apache_cat + treat + temp0_cat + temp10_cat,
            data = df_sepsis_clean, family = binomial))      # p values






