
plot.TwitterHivePlot.sampleNodes <- function(dataSetNodes = NULL, nodesUsed = NULL, dataSetg = NULL, graphSize = NULL, graphName = NULL)
{
  #graphSize <- 3
  #graphName <- "3Nodes"
  
  for (i in seq(1,3,1) ) {
  
    ############################################################################################
  
    print("---- BEGIN <TwitterHivePlot.R> -----")
  
    
    # Track start time
    print("---- BEGIN create graph data -----")
    start.time <- Sys.time()
    
    #sample list of nodes
    nodesUsedSample1 <- nodesUsed[sample(1:nrow(nodesUsed), size = graphSize, replace = FALSE, prob = NULL),] #sample edge data
    nodesUsedSample <- nodesUsedSample1[c(1)]
    rm(nodesUsedSample1)

    
    #generate edge file of sampled nodes
    dataSet3 <- merge(dataSetg, nodesUsedSample, by.x=c("V1"), by.y=c("V1"), match="all", all=FALSE, row.names=NULL) #get who sampled nodes are following
    dataSet5 <- merge(dataSetg, nodesUsedSample, by.x=c("V2"), by.y=c("V1"), match="all", all=FALSE, row.names=NULL) #get who is following them
    dataSet2 <- rbind(dataSet5, dataSet3) #all edges
    dataSet2 <- unique(dataSet2)
    myvars <- c("V1", "V2",  "V3", "V4") #columns to be included
    dataSet4 <- dataSet2[myvars]
    dataSet <- data.frame(dataSet4, row.names = NULL)
    rm(dataSet2, dataSet3, dataSet4)    

    ############################################################################################
    # Create a graph. Use simplify to ensure that there are no duplicated edges or self loops
    gD <- simplify(graph.data.frame(dataSet, directed=FALSE))
    gDNodes <- simplify(graph.data.frame(dataSet, directed=FALSE))
    
    # Print number of nodes and edges
    vcount(gD)
    ecount(gD)
    
    end.time <- Sys.time()
    time.taken <- start.time - end.time
    print(time.taken)
    print("---- END create graph data -----")
    
    print("---- BEGIN Edge degree -----")      
    start.time <- Sys.time()
    # Calculate degree for all nodes
    degAll <- degree(gD, v = V(gD), mode = "all")

    print("---- END Edge degree -----") 
    print("---- BEGIN betweeness -----")
    # Calculate betweenness for all nodes
    betAll <- betweenness(gD, v = V(gD), directed = TRUE) / (((vcount(gD) - 1) * (vcount(gD)-2)) / 2)
    betAll.norm <- (betAll - min(betAll))/(max(betAll) - min(betAll))
    print("---- END betweeness -----")

    node.list <- data.frame(name = V(gD)$name, degree = degAll, betw = betAll.norm)
    matchedData <- merge(node.list, dataSetNodes, by.x = "name", by.y = "V1", type = "left", match="all") #store node data based on which nodes have been sampled
    
    # Calculate Dice similarities between all pairs of nodes
    #dsAll <- similarity.dice(gD, vids = V(gD), mode = "all")
    
    # Calculate edge weight based on the node similarity
    #F1 <- function(x) {data.frame(V4 = dsAll[which(V(gD)$name == as.character(x$V1)), which(V(gD)$name == as.character(x$V2))])}
    #dataSet.ext <- ddply(dataSet, .variables=c("V1", "V2", "V3"), function(x) data.frame(F1(x)))
    
    rm(degAll, betAll, betAll.norm)
    
    end.time <- Sys.time()
    time.taken <- start.time - end.time
    print(time.taken)
    print("---- END Edge degree, betweeness -----")
    
    ############################################################################################
    
    print("---- BEGIN Node size calculation -----") 
    start.time <- Sys.time()
    
    # Calculate node size
    # We'll interpolate node size based on the node betweenness centrality, using the "approx" function
    # And we will assign a node size for each node based on its betweenness centrality
    approxVals <- approx(c(0.5, 1.5), n = length(unique(node.list$bet)))
    nodes_size <- sapply(node.list$bet, function(x) approxVals$y[which(sort(unique(node.list$bet)) == x)])
    node.list <- cbind(node.list, size = nodes_size)
    rm(approxVals, nodes_size)
    
    ############################################################################################
    
    # Match relevant nodes from the node list
    matchedNodeList <- merge(node.list, dataSetNodes, by.x = "name", by.y = "V1", type = "left", match="all")
    
    ############################################################################################
    #Create a hive plot
    
    source("scripts/mod.edge2HPD.R")
    source("scripts/mod.mineHPD.R")
    
    print("---- BEGIN HPD conversion -----")      
    start.time <- Sys.time()
    
    edge_color <- dataSet[c("V3")]

    hive1 <- mod.edge2HPD(edge_df = dataSet[,c("V1", "V2")], edge.color = edge_color[,1], 
                          node.size = node.list[,c("name", "size")], 
                          node.color = matchedData[,c("name", "V3")],  #node color 
                          node.radius = node.list[,c("name", "degree")],
                          axis.cols = c("white", "white"),          #make axes white
                          node.axis = matchedData[,c("name", "V4")] #turn this on or off depending if axes should be pre-defined
    )
    sumHPD(hive1)
    end.time <- Sys.time()
    time.taken <- start.time - end.time
    print(time.taken)

    print("---- BEGIN Radius assignment -----") 
    # Assign nodes to a radius based on their degree (number of edges they are touching)
    hive2 <- mineHPD(hive1, option = "rad <- tot.edge.count")
    
    # Remove orphans
    hive3 <- mineHPD(hive2, option = "remove orphans")
    
    # Removing zero edges for better visualization 
    hive3.5 <- mineHPD(hive3, option = "remove zero edge")
    
    print("---- BEGIN source manager sink assignment -----") 
    # Assign nodes to axes based on their position in the edge list 
    # (this function assumes direct graphs, so it considers the first column to be a source and second column to be a sink )
    start.time <- Sys.time()
    hive4 <- mineHPD(hive3.5, option = "axis <- source.man.sink")
    rm(hive3.5, hive3, hive2, hive1)
    
    end.time <- Sys.time()
    time.taken <- start.time - end.time
    print(time.taken)
    print("---- END HPD conversion -----")
    
    print("---- BEGIN plot hive -----")
    start.time <- Sys.time()
    file <- paste(graphName, "ALL", sep="")
    file <- paste(file, i, sep="-")
    file <- paste(file, ".pdf", sep="")
    
    pdf(file, width=8, height=8)
    
    # And finally, plotting our graph (Figure 1)
    plotHive(hive4, ch = .15, 
             method = "norm", 
             bkgnd = "white", 
             #axLabs = c("source", "sink"), 
             #axLab.pos = .5, 
             arrow = c("radius units", 0, 10, 560, 125, 140))
    
    dev.off
    
    # Display time taken
    end.time <- Sys.time()
    time.taken <- start.time - end.time
    print(time.taken)
    print("---- END plot hive -----")
  }
}
