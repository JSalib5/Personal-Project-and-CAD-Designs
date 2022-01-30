import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt
from pyvis.network import Network

df = pd.read_csv("ActorNetwork.csv")

G = nx.from_pandas_edgelist(df, 
                            source='Source', 
                            target='Target',
                            edge_attr=['label', 'color'])

#nx.draw_networkx_edge_labels(G,1, font_color='red')
print("No of unique actors:", len(G.nodes)) 
print("No of connections:", len(G.edges))



net = Network('1080', 'full', heading="John's Surveillance Actor Network")
# load the networkx graph
net.from_nx(G)
node_list = df["Source"].tolist()
size_list = df["size"].tolist()
color_list = df["Node_Color"].tolist()
for i in range(len(node_list)):
  net.get_node(node_list[i])['color'] = color_list[i]
  net.get_node(node_list[i])['size'] = size_list[i]


net.get_node(node_list[0]).update({'physics':False})

phy = '''{
  "physics": {
    "barnesHut": {
      "gravitationalConstant": -25000,
      "centralGravity": 0.005,
      "springLength": 650,
      "overlap": 1,
      "damping": 0.5
    },
    "minVelocity": 0.75
  }
}'''


net.set_options(phy)

# show
net.show("John's Actor Network.html")
