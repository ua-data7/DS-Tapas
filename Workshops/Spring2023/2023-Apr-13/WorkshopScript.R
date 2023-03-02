# Title: K-means clustering with tidy data principles
# Author: Greg Chism
# Date: 2023-04-13
# Description: Summarize clustering characteristics and estimate the best number of clusters for a data set.

# Install required packages
install.packages("tidymodels")

library(tidymodels)

# Setup and data
set.seed(27)

theme_set(theme_minimal(base_size = 14))
theme_update(legend.position = "top")

centers <- tibble(
  cluster = factor(1:3), 
  num_points = c(100, 150, 50),  # number points in each cluster
  x1 = c(5, 0, -3),              # x1 coordinate of cluster center
  x2 = c(-1, 1, -2)              # x2 coordinate of cluster center
)

labelled_points <- 
  centers %>%
  mutate(
    x1 = map2(num_points, x1, rnorm),
    x2 = map2(num_points, x2, rnorm)
  ) %>% 
  select(-num_points) %>% 
  unnest(cols = c(x1, x2))

ggplot(labelled_points, aes(x1, x2, color = cluster)) +
  geom_point(alpha = 0.5) 

# Clustering in R
# Points for clustering
points <- 
  labelled_points %>% 
  select(-cluster)

# K-means algorithm
kclust <- kmeans(points, centers = 3)
kclust

# Summary of algorithm output
summary(kclust)

# Add classifications to original dataset
augment(kclust, points)

# Per-cluster level summary
tidy(kclust)

# Single row summary
glance(kclust)

# Exploring clustering
kclusts <- 
  tibble(k = 1:9) %>%
  mutate(
    kclust = map(k, ~kmeans(points, .x)),
    tidied = map(kclust, tidy),
    glanced = map(kclust, glance),
    augmented = map(kclust, augment, points)
  )

kclusts

# Dataset for each type of summary
clusters <- 
  kclusts %>%
  unnest(cols = c(tidied))

assignments <- 
  kclusts %>% 
  unnest(cols = c(augmented))

clusterings <- 
  kclusts %>%
  unnest(cols = c(glanced))

# Plot different number of clusters
p1 <- 
  ggplot(assignments, aes(x = x1, y = x2)) +
  geom_point(aes(color = .cluster), alpha = 0.8) + 
  facet_wrap(~ k)
p1

# Add cluster centroid
p2 <- p1 + geom_point(data = clusters, size = 7, shape = "x")
p2

# Elbow method for clusters*
ggplot(clusterings, aes(k, tot.withinss)) +
  geom_line() +
  geom_point()

# Better methods to assess clusters
criteria <- CHCriterion(data = points, kmax = 9, 
                        clustermethod = "hclust", method = "ward.D")

# Compare CH Index and WSS (elbow-method)
criteria$plot

