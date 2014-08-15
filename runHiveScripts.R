library("igraph")
library("plyr")
library("HiveR")
library("RColorBrewer")

rm(list = ls())

#import edge files
dataSeta <- read.table("data/followings_mal2.txt", header = FALSE, sep = "\t") #read in edge data
dataSetb <- read.table("data/followings_norm2.txt", header = FALSE, sep = "\t")
dataSetc <- read.table("data/followers_mal2.txt", header = FALSE, sep = "\t") #read in edge data
dataSetd <- read.table("data/followers_norm2.txt", header = FALSE, sep = "\t")

#Merge edge files together
dataSete <- rbind(dataSeta, dataSetc) #mal followings/followers
dataSetf <- rbind(dataSetb, dataSetd) #norm followings/followers
dataSetR <- rbind(dataSete, dataSetf) #all
rm(dataSeta, dataSetb, dataSetc, dataSetd, dataSete, dataSetf)

#import node files
dataSetNodes1 <- read.table("data/known_ids.txt", header = FALSE, sep = "\t") #read in user data
dataSetNodes2 <- read.table("data/unknown_ids.txt", header = FALSE, sep = "\t") #read in user data
dataSetNodes2 <- unique(dataSetNodes2)
dataSetNodes3 <- rbind(dataSetNodes1, dataSetNodes2) #all

#generate list of nodes used in edge files
nodesUsed0 <- merge(dataSetNodes3, dataSetR, by.x=c("V1"), by.y=c("V1"), all=FALSE)
myvars <- c("V1", "V2.x",  "V3.x",  "V4.x") #columns to be included
nodesUsed1 <- nodesUsed0[myvars]
nodesUseda <- unique(nodesUsed1) #nodes to be sampled from
rm(nodesUsed1, nodesUsed0, myvars)

source("plot.TwitterHivePlot.sampleNodes.R")

plot.TwitterHivePlot.sampleNodes(dataSetNodes = dataSetNodes3, nodesUsed = nodesUseda, dataSetg = dataSetR, graphSize = 150 , graphName = "150a_ALL")
