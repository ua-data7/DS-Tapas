## Title: Simulating data for study design in R
## Author: Greg Chism
## Date: 2023-02-23
## Description: Example of how to simulate study data in R for statistical design
## Objectives
## 1. Defining data variables
## 2. Generating the data 
## 3. Assigning treatments/exposures
## 4. Multiple variables from the same definition
## 5. Adding to existing data


## Install and load required packages
if (!require(pacman)) install.packages('pacman')

p_load(devtools,
       dlookr,
       GGally,
       remotes,
       tidyverse)


## Defining the data
# An age normal distributed column
def <- defData(varname = "age", dist = "normal", formula = 10, variance = 2)

# Female binary distributed column
def <- defData(def, varname = "female", dist = "binary", formula = "-2 + age*0.1", link = "logit")

# Visits poison distributed column
def <- defData(def, varname = "visits", dist = "poisson", formula = "1.5 - 0.2*age + 0.5*female", link = "log")

## Generating the data
set.seed(123)

genData(100)

dd <- genData(100, def)

head(dd)

## Assigning treatment/exposure
study1 <- trtAssign(dd, n = 3, balanced = TRUE, strata = c("female"), grpName = "rx")

head(study1)

# Visualize the data
study1 %>%
  select(-id, -rx) %>%
  mutate(female = as.factor(female)) %>%
  ggpairs(aes(color = female, alpha = 0.5)) +
  theme(axis.text = element_blank(),
        axis.ticks = element_blank(),
        strip.background = element_blank()) +
  theme_minimal(base_size = 14)


## Formulas
# Previously...
def <- defData(varname = "age", dist = "normal", formula = 10, variance = 2)
def <- defData(def, varname = "female", dist = "binary",
               formula = "-2 + age*0.1", link = "logit")
def <- defData(def, varname = "visits", dist = "poisson",
               formula = "1.5 - 0.2*age + 0.5*female", link = "log")

# Formula to take the inverse of data
myinv <- function(x) {
  1/x
}

# New simulated data taking the log inverse of age
def <- defData(varname = "age", formula = 10, variance = 2,
               dist = "normal")
def <- defData(def, varname = "loginvage", formula = "log(myinv(age))",
               variance = 0.1, dist = "normal")

genData(5, def)

# New simulated data taking the log10 inverse of age
def10 <- updateDef(def, changevar = "loginvage", newformula = "log10(myinv(age))")
def10

genData(5, def10)

# Externally defined variables
age_effect <- 3

def <- defData(varname = "age", formula = 10, variance = 2,
               dist = "normal")
def <- defData(def, varname = "agemult", formula = "age*..age_effect",
               dist = "nonrandom")

def

genData(2, def)

# Dynamic definition iterated over multiple values:
age_effects <- c(0, 5, 10)
list_of_data <- list()

for(i in seq_along(age_effects)) {
  age_effect <- age_effects[i]
  list_of_data[[i]] <- genData(2, def)
}

list_of_data

# Multiple variables with a single definition
def <- defRepeat(nVars = 4, prefix = "g", formula = "1/3;1/3;1/3",
                 variance = 0, dist = "categorical")
def <- defData(def, varname = "a", formula = "1;1", dist = "trtAssign")
def <- defRepeat(def, 3, "b", formula = "5 + a", variance = 3,
                 dist = "normal")
def <- defData(def, "y", formula = "0.10", dist = "binary")

def

# Add data to existing data table
d1 <- defData(varname = "x1", formula = 0, variance = 1,
              dist = "normal")
d1 <- defData(d1, varname = "x2", formula = 0.5, dist = "binary")

d2 <- defRepeatAdd(nVars = 2, prefix = "q", formula = "5 + 3*rx",
                   variance = 4, dist = "normal")
d2 <- defDataAdd(d2, varname = "y", formula = "-2 + 0.5*x1 + 0.5*x2 + 1*rx",
                 dist = "binary", link = "logit")

dd <- genData(5, d1)
dd <- trtAssign(dd, nTrt = 2, grpName = "rx")
dd

dd <- addColumns(d2, dd)
dd

# defCondition and addCondition
d <- defData(varname = "x", formula = 0, variance = 9, dist = "normal")

dc <- defCondition(condition = "x <= -2", formula = "4 + 3*x",
                   variance = 2, dist = "normal")
dc <- defCondition(dc, condition = "x > -2 & x <= 2", formula = "0 + 1*x",
                   variance = 4, dist = "normal")
dc <- defCondition(dc, condition = "x > 2", formula = "-5 + 4*x",
                   variance = 3, dist = "normal")

dd <- genData(1000, d)
dd <- addCondition(dc, dd, newvar = "y")

# Visualizing the data
ggplot(dd, aes(x, y)) +
  geom_point(size = 2, alpha = 0.5) +
  geom_smooth() +
  theme_minimal(base_size = 14)
