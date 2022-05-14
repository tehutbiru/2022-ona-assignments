---
title: "Exercise 1"
output:
  md_document: default
  github_document: default
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
#install.packages('tidyverse')
library('tidyverse')
```

## GitHub Documents

This is an R Markdown format used for publishing markdown documents to GitHub. When you click the **Knit** button all R code chunks are run and a markdown file (.md) suitable for publishing to GitHub is generated.

## Including Code

```{r}
Connections <- read_csv('Connections.csv')
attach(Connections)
```

## Get count of contacts by employer
using 'dplyr' functions ("verbs") to do the counts
pipe operator '%>%' that passes the data from one step to the next

```{r}
Connections %>% count(Company) %>% arrange(-n)
```

## Create networks where edges are based on your contacts being affiliated with the same organization
# node and edges tables
## node table
#id and name
## edge table
#from to and weight

```{r}
# load libraries
library(igraph)
```

# create first and last name column

```{r}
# create first name and last name initial column
first_l = c()
for (i in 1:nrow(Connections)) {
  # get first name
  f_name <- Connections[i,1]
  # get last name
  l_name <- Connections[i,2]
  # get last names first character
  l_initial <- substr(l_name,1,1)
  # join into one string
  f_l_name <- paste(f_name, l_initial, sep=" ")
  # add to list
  first_l[i] = f_l_name
}

# add as a column to dataset
Connections$Names <- first_l
```

```{r}
# get unique names
#nodes <- Connections %>%
  #distinct(Names)
nodes <- Connections[,7, drop=FALSE]
nodes
```
## create edge table
# From name -> to name + weight of connection


```{r}
first_person <- c()
connected_to <- c()
Connections$Company = as.factor(Connections$Company)
Connections$Names = as.factor(Connections$Names)
# get data to create edge table 
for (i in 1:nrow(Connections)) {
  # get the current name
  curr_name <- Connections[i,7][1]
  print(curr_name)
  # get the company of the person
  curr_company <- Connections[i,4][1]
  vec <- c(str(curr_company))
  same_company <- Connections[Connections$Company %in% vec,]
  # get all the names that also have the same company, without the current name
  #same_company <- Connections[Connections$Company == curr_company]
  #same_company <- subset(Connections, Company == curr_company) 
  #& Connections$Names != as.character(curr_name), ]
  if (nrow(same_company)==0){
    next # go to next person if no common people with the same company
  }
  curr_first_person <- c()
  curr_connected_to <- c()
  # add the name and connection to vectors created
  for (j in 1:nrow(same_company)){ 
    curr_first_person[[j]] = curr_name[1]
    curr_connected_to[[j]] = same_company[j, 7][1]
  }
  # append to vector
  first_person <- append(first_person, curr_first_person)
  connected_to <- append(connected_to, curr_connected_to)

}

```

# save data

```{r}
mat = matrix(ncol = 2, nrow = 30002)
  
# converting the matrix to data 
# frame
edges=data.frame(mat)
edges$Node1 = first_person
edges$Node2 = connected_to
#edges <- data.frame(first_person,connected_to)
edges %>% distinct() # remove duplicates
edges
```

```{r}
#install.packages('tidygraph')
#install.packages('ggraph')
library("tidygraph")
library("ggraph")
```

# create network objects
```{r}
linkedIn_network <- tbl_graph(nodes=nodes, edges=edges, directed=FALSE)

```