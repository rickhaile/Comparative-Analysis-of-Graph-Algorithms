
if (!require("igraph")) install.packages("igraph")
if (!require("dplyr")) install.packages("dplyr")
if (!require("ggplot2")) install.packages("ggplot2")

library(igraph)
library(dplyr)
library(ggplot2)

# Load data using relative paths (Works on any machine)
path_edge <- file.path("data", "addhealth_edgelist.txt")
path_attr <- file.path("data", "addhealth_attributes.txt")

# Check if files exist
if (!file.exists(path_edge) || !file.exists(path_attr)) {
  stop("Error: Data files not found. Please ensure they are in the 'data/' folder.")
}

print("Loading Network Data...")
node_attr <- read.table(path_attr, header = TRUE)
node_attr <- select(node_attr, -toa) # Remove unnecessary column
edges <- read.table(path_edge, header = TRUE)

# Create Directed Graph Object
net_graph <- graph_from_data_frame(edges, directed = TRUE, vertices = node_attr)
print(paste("Nodes:", gorder(net_graph), "| Edges:", gsize(net_graph)))

# Initial Visualization
plot(net_graph, vertex.label = NA, vertex.size = 4, edge.arrow.size = 0.2, 
     edge.arrow.width = 0.5, vertex.color = 'black', main = "Raw Network Structure")

# 2. NETWORK METRICS ----------------------------------------------------------

# Calculate Density (Connectedness)
net_density <- edge_density(net_graph)
print(paste("Network Density:", round(net_density * 100, 4), "%"))
# Interpretation: Low density implies a sparse network with distinct clusters.

# Convert to Undirected for Community Detection algorithms
net_und <- as.undirected(net_graph, mode = "collapse")

# 3. COMMUNITY DETECTION ALGORITHMS -------------------------------------------

print("Running Community Detection Algorithms...")

# A. Walktrap Algorithm (Based on random walks)
# Comparing 3 steps vs 4 steps to find optimal modularity
comm_wt4 <- cluster_walktrap(graph = net_und, steps = 4)
comm_wt3 <- cluster_walktrap(graph = net_und, steps = 3)

print(paste("Walktrap (4 steps) Modularity:", round(modularity(comm_wt4), 4)))
print(paste("Walktrap (3 steps) Modularity:", round(modularity(comm_wt3), 4)))

# B. Louvain Algorithm (Optimization of modularity)
# Usually faster and finds high modularity for large networks
comm_louvain <- cluster_louvain(graph = net_und, resolution = 1)
print(paste("Louvain Modularity:", round(modularity(comm_louvain), 4)))

# C. Edge Betweenness (Hierarchical decomposition)
comm_edge_bet <- cluster_edge_betweenness(graph = net_und)
print(paste("Edge Betweenness Modularity:", round(modularity(comm_edge_bet), 4)))

# VISUALIZATION: Comparing Community Structures
par(mfrow = c(1, 2)) # Side-by-side plots
layout <- layout.fruchterman.reingold(net_und)

plot(net_und, layout = layout, vertex.color = membership(comm_wt4), 
     vertex.size = 5, vertex.label = NA, main = "Walktrap Communities (4 Steps)")

plot(net_und, layout = layout, vertex.color = membership(comm_louvain), 
     vertex.size = 5, vertex.label = NA, main = "Louvain Communities")
par(mfrow = c(1, 1)) # Reset plot window

# 4. MODULARITY OPTIMIZATION ANALYSIS -----------------------------------------

# Function to extract modularity at every merge step (Hierarchical Analysis)
extract_modularity_data <- function(communities, graph){    
  num_merges <- 0:nrow(communities$merges)    
  results <- data.frame(num_communities = numeric(), modularity = numeric())
  
  # Loop through cuts (Simplified for performance)
  for (i in seq(1, length(num_merges), by = 5)) { 
    mems <- cut_at(communities, steps = num_merges[i])          
    mod <- modularity(graph, mems)
    results <- rbind(results, data.frame(num_communities = length(unique(mems)), modularity = mod))
  }
  return(results) 
}

print("Analyzing Modularity Optimization (This may take a moment)...")
mod_data <- extract_modularity_data(communities = comm_edge_bet, graph = net_und)

# Plot using ggplot2
p <- ggplot(mod_data, aes(num_communities, modularity)) +
  geom_line(color = "steelblue", linewidth = 1) +    
  geom_point(size = 1.5) +   
  labs(title = "Optimal Number of Communities (Modularity Maximization)",
       subtitle = "Edge Betweenness Method",
       x = "Number of Communities", y = "Modularity Score") +
  theme_minimal()
print(p)

# 5. INFLUENCER ANALYSIS (CENTRALITY) -----------------------------------------

print("Calculating Centrality Measures (Identifying Influencers)...")

# Calculate raw metrics
degree_sc <- igraph::degree(net_graph, mode = "all")
eigen_sc  <- igraph::eigen_centrality(net_graph)$vector
between_sc <- igraph::betweenness(net_graph)
close_sc   <- igraph::closeness(net_graph) 

# Normalize metrics (0 to 1 scale) for comparison
normalize <- function(x) { return (x / max(x, na.rm = TRUE)) }

centrality_df <- data.frame(
  node_id = V(net_graph)$name,
  degree_norm = normalize(degree_sc),
  eigen_norm = normalize(eigen_sc),
  betweenness_norm = normalize(between_sc),
  closeness_norm = normalize(close_sc)
)

# Identify Top 5 Influencers based on Eigenvector Centrality
top_influencers <- centrality_df %>% 
  arrange(desc(eigen_norm)) %>% 
  head(5)

print("--- TOP 5 NETWORK INFLUENCERS ---")
print(top_influencers)

print("✅ Analysis Complete.")