## Title: Power analysis in R
## Author: Greg Chism
## Date: 2023-03-02
## Description: Example of how to run statistical power analyses in R

## Install and load required packages
if (!require(pacman)) install.packages('pacman')

p_load(dlookr,
       pwr,
       RCurl,
       simr,
       sjPlot,
       tidyverse)

# Read in csv from the web
data <- getURL("https://raw.githubusercontent.com/ua-data7/classical-machine-learning-workshops/main/Workshops/Spring2023/2023-Mar-29/FE_2021_Classification_mod.csv")
data <- read.csv(text = data)
data %>% 
  head()

# Effect size
model <- lm(ER ~ Treatment, data = data)
anovaMod <- anova(model)

effectsize::effectsize(anovaMod)

# Sample size
diagnose_category(data)

# Simple power analyses (ANOVA)
pwr.anova.test(k = 4, f = 0.04, sig.level = 0.05, p = 0.8)

data %>%
  ggplot(aes(x = Treatment, y = ER, fill = Treatment)) +
  geom_boxplot(width = 0.5) + 
  coord_flip() +
  theme_minimal(base_size = 14)

# Advanced power analysis (LMER)
# Create a lmer() model
# Fixed effect intercept and slopes
fixed <- c(0.52, 0.52, 0.52, 0.52, 0.52, 0.52, 0.52, 0.52, 0.52)

# Random intercept for block
rand <- list(0.5, 0.1)

# Residual variance
res <- 2

# Generate the model
m1 <- makeLmer(y ~ Treatment * NEE + Repro_culm + (1|block) + (1|Date),
               fixef = fixed,
               VarCorr = rand,
               sigma = res,
               data = data)

tab_model(m1)

# Power analysis 
set.seed(123)
sim_m1 <- powerSim(m1, nsim = 20, test = fcompare(y ~ NEE * Treatment))
sim_m1

# Detecting an interaction
sim_tn <- powerSim(m1, nsim = 20, test = fcompare(y ~ NEE + Repro_culm + Treatment))
sim_tn

# Extending the data
m1_ex <- extend(m1, 
                along = "Date",
                n = 30)

m1_ex

# Power analysis w/ extension
sim_m1_ex <- powerSim(m1_ex, nsim = 20, test = fcompare(y ~ NEE + Repro_culm + Treatment))
sim_m1_ex


