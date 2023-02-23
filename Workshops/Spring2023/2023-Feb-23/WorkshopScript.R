# Title: Sim data for study design in R
# Author: Greg Chism
# Date: 2023-02-23
# Description: Simulating a study in R

# Installing packages
if (!require(pacman)) install.packages("pacman")

p_load(GGally,
       simstudy,
       tidyverse)

# Define the data
def <- defData(varname = "age", dist = "normal", formula = 10, variance = 2)

def <- defData(def, varname = "female", dist = "binary", formula = "-2 + age*0.2", link = "logit")

def <- defData(def, varname = "visits", dist = "poisson", formula = "1.5 - 0.2*age + 0.5*female", link = "log")

def

# Generate
set.seed(123)

dd <- genData(100, def)

head(dd)

# Assign treatment/exposure
study1 <- trtAssign(dd, n = 3, balanced = TRUE, strata = c("female"), grpName = "rx")

head(study1)

# Visualizing data
study1 %>%
  select(-id, -rx) %>%
  mutate(female = as.factor(female)) %>%
  ggpairs(aes(color = female, alpha = 0.5)) +
  theme_minimal(base_size = 14)

# Formulas
myinv <- function(x) {
  1/x
} 

# New simulated data log inverse of age
def <- defData(varname = "age", formula = 10, variance = 2, dist = "normal")

def <- defData(def, varname = "loginvage", formula = "log10(myinv(age))", variance = 0.1, dist = "normal")

genData(5, def)

# Externally defined variables
age_effect <- 3

def <- defData(varname = "age", formula = 10, variance = 2, dist = "normal")

def <- defData(def, varname = "agemult", formula = "age*..age_effect", dist = "nonrandom")

def

genData(2, def)

# Multiple variables with a single definition
def <- defRepeat(nVars = 4, prefix = "g", formula = "1/3;1/3;1/3", variance = 0, dist = "categorical")
def <- defData(def, varname = "a", formula = "1;1", dist = "trtAssign")
def <- defRepeat(def, 3, "b", formula = "5 + a", variance = 3, dist = "normal") 
def <- defData(def, "y", formula = "0.10", dist = "binary")

def

genData(5, def)

# Add data to existing data table
d1 <- defData(varname = "x1", formula = 0, variance = 1, dist = "normal")

d1 <- defData(d1, varname = "x2", formula = 0.5, dist = "binary")

d2 <- defRepeatAdd(nVars = 2, prefix = "q", formula = "5 + 3*rx", variance = 4, dist = "normal")

dd <- genData(5, d1)
dd <- trtAssign(dd, nTrt = 2, grpName = "rx")
dd

dd <- addColumns(d2, dd)
dd

