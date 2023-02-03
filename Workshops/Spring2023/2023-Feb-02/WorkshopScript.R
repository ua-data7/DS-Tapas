# Title: DS Tapas - Network viz in R
# Author: Greg Chism
# Date: 2023-02-02
# Description: Example of Network viz in R using igraph and ggraph

# Install packages
install.packages("pacman")

pacman::p_load(igraph, 
               ggraph, 
               RCurl,
               wesanderson)

# Load and examine data
data <- getURL("https://raw.githubusercontent.com/Gchism94/AntColonyPerformance/main/analysis/data/raw_data/Colony18CircleAggnNRMatrix.csv")
data <- read.csv(text = data, row.names = 1, header = TRUE)

# First 6 rows
head(data)

# Class of the data object
class(data)

# Change to matrix
data_mat <- as.matrix(data)

# Recheck class
class(data_mat)

# Number of rows
nrow(data_mat)

# Number of columns
ncol(data_mat)

# Make a network
network <- graph_from_adjacency_matrix(data_mat, weighted = TRUE, mode = "directed")

class(network)

## Network analyses

# Number of nodes in network
m <- gorder(network)

# Number of edges in network
n <- gsize(network)

# Network degree
d <- degree(network)
range(d)

# Shortest distances between node pairs
dist <- distances(network, v = V(network), to = V(network), mode = "all", algorithm = "dijkstra")

# Diameter of the network
net_diam <- diameter(network, directed = TRUE, unconnected = TRUE)
net_diam

# Reciprocity 
r <- reciprocity(network)

# Transitivity / clustering
c <- transitivity(network, type = "global")

## Plot network
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
  theme_graph(base_size = 14) + 
  theme(legend.position = "bottom")

p

# Save your network
ggsave(plot = p, "network.png", width = 10, height = 10, units = "in", dpi = 400)

# Network with ID labels as nodes
p <- ggraph(network, layout = "stress") +
  geom_edge_link(aes(alpha = weight)) +
  geom_node_label(aes(label = name)) +
  scale_size("Degree") +
  scale_fill_gradientn("Degree", colours = pal) +
  theme_graph(base_size = 14) + 
  theme(legend.position = "bottom")



