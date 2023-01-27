## Title: Network Visualization in R
## Author: Greg Chism
## Date: 2023-02-02
## Description: Example of how to visualize network data in R with the ggraph package

pacman::p_load(igraph,      # for making graph objects in R
               ggraph,      # for plotting graphs with ggplot2 syntax
               RCurl,       # for reading in text files from a URL
               wesanderson) # for creating the color palette below

data <- getURL("https://raw.githubusercontent.com/Gchism94/AntColonyPerformance/main/analysis/data/raw_data/Colony18CircleAggnNRMatrix.csv")
data <- read.csv(text = data, row.names = 1, header = TRUE)

## Examine the data
head(data)

# Data type
class(data)

# Change to matrix
data_mat <- as.matrix(data)

# Recheck data type
class(data_mat)

# Number of rows
nrow(data)

# Number of columns
ncol(data)

# Build a network
network <- graph_from_adjacency_matrix(data_mat, weighted = TRUE, mode = "directed")

# Check data type
class(network)

## Network analyses
# Number of edges in the matrix
m <- gorder(network)

# Number of nodes in the matrix
n <- gsize(network)

# Network degree
d <- degree(network)
range(d)

# Shortest paths between node pairs
distances(network, v = V(network), to = V(network), mode = "all",  algorithm = "dijkstra")

# Diameter of the network
net_diam <- diameter(network, directed = TRUE, unconnected = TRUE)

# Reciprocity
r <- reciprocity(network)

# Transitivity
c <- transitivity(network, type = "global") # Clustering for undirected

# Harmonic Centrality
HC <- harmonic_centrality(network, mode = c("all")) 

# Plot network
# Palette for networks
pal <- wes_palette("Zissou1", 100, type = "continuous")

# Assign a weight value
weight = E(network)$weight

# Plot the graph
p <- ggraph(network, layout = "stress") +
  geom_edge_link(aes(alpha = weight)) +
  geom_node_point(aes(fill = d, size = d), shape = 21) + 
  scale_size("Degree") +
  scale_fill_gradientn("Degree", colours = pal) +
  theme_graph() +
  theme(legend.position = "bottom")

p

ggsave(plot = p, "network.png", width = 10, height = 10, units = "in", dpi = 400)
