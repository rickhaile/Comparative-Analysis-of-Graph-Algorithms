🕸️ Social Network Analysis (SNA) & Community Detection

### 📊 Project Overview
This project utilizes **Graph Theory** and **Statistical Analysis (R)** to uncover structural patterns within the *AddHealth* adolescent friendship network.

The goal was to identify **social communities** (cliques) and **key influencers** using various clustering algorithms. This type of analysis is critical in fields ranging from Epidemiology (virus spread) to Marketing (influencer identification).

### ⚙️ Technical Approach

#### 1. Network Topology
*   **Graph Construction:** Directed graph creation using `igraph` with attribute integration.
*   **Density Analysis:** Calculated a network density of **0.66%**, indicating a sparse network with high clustering potential.

#### 2. Community Detection (Algorithm Comparison)
We benchmarked three distinct algorithms to maximize the **Modularity Score** ($Q$):
*   **Walktrap Algorithm:** Uses random walks to find densely connected subgraphs.
*   **Louvain Method:** Heuristic optimization; proved most effective for this dataset.
*   **Edge Betweenness:** Hierarchical decomposition to identify "bridge" edges.

#### 3. Influencer Identification (Centrality)
To identify key nodes, we computed and normalized four centrality measures:
*   **Degree Centrality:** Immediate popularity.
*   **Eigenvector Centrality:** "Who you know" (Connection to other high-value nodes).
*   **Betweenness Centrality:** Gatekeeping potential (Control of information flow).

### 🛠️ Tech Stack
*   **Language:** R (4.0+)
*   **Libraries:** `igraph` (Network objects), `ggplot2` (Visualization), `dplyr` (Data Manipulation).

### 🚀 How to Run
1.  Place your data (`addhealth_edgelist.txt`, `addhealth_attributes.txt`) in the `data/` folder.
2.  Run the script:
    ```r
    source("main_analysis.R")
    ```
