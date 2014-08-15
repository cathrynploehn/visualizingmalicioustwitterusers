###########################################################
###########################################################

########## R Scripts for Creating Hive Plots ##############
##########  plot.TwitterHivePlot.R function  ##############

###########################################################
###########################################################


Outputs 3 hive plot PDFs:

Node size is determined based on betweeness centrality. Bigger nodes have larger relative betweeness centrality.

Axis 1 (12 o'clock): Source nodes
Axis 2 (8 o'clock): Sink nodes
Axis 3 (4 o'clock): Manager nodes


Package requirements ######################################

Be sure to include these libraries:
library("igraph")
library("plyr")
library("HiveR")
library("RColorBrewer")

Usage #####################################################

Note: "runHiveScripts.R" provides an example of how to use the file

parameters ####

edgeFile: path (string) to source file for edges. (See below for formatting)

graphSize: (integer) number of nodes to sample. Must be > than number of edges in edgeFile

graphName: filename for plotHive pdf (string)


uses ####

user_ids.txt: gives the ids, node color, and node type of each node (See below for formatting)



formatting #################################################

edgeFile ####

Path should point to a .txt file, formatted like the following, without a heading
(columns separated by tabs, each node is a line):

souce	sink	edge-color	interaction-type(optional)


example file:

7248952	19555957	orange	maltonormal
7248952	206256154	orange	maltonormal
7248952	17814451	orange	maltonormal
7248952	160437491	orange	maltonormal
7248952	47912943	orange	maltonormal
7248952	201330435	orange	maltonormal
7248952	67374418	orange	maltonormal
7248952	17867513	orange	maltonormal


user_ids.txt ####

Formatted like the following, without a heading 
(columns separated by tabs, each node is a line):

id	node-type	node-color	axis-assignment(optional)

example file:

67847720	malicious	red	1
82388225	malicious	red	1
47023408	malicious	red	1
63074400	malicious	red	1
69510341	malicious	red	1
100607808	malicious	red	1
72904415	malicious	red	1
69504535	malicious	red	1
53780486	malicious	red	1
65231459	malicious	red	1
108526831	malicious	red	1