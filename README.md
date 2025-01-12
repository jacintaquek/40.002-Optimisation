### ESD Term 4 - 40.002 Optimisation Project

### Maritime Route Optimisation of Singular Cargo Vessel leaving Singapore

## Background
Singapore exports about $638.4 billion of goods and services and imports about $567.3 billion of goods1. The total amount of imports and exports through shipping is about $1205.7 billion in Singapore 2023, this is about 11.7% increase from 2019. Exports and imports collectively contribute significantly to nation’s GDP, with goods and services accounting for approximately184.30% and imports representing 149.04% of the GDP respectively.
Singapore’s major trading partners are Taiwan, European Union, Japan, Republic of Korea, Thailand, Indonesia, Hong Kong, Malaysia, and China


## Problem Statement
A shipping company based in Singapore operates a fleet of cargo ships that needs to navigate between various ports to deliver cargo efficiently. Each port is connected by a network of maritime routes, and each route has a different travel time and cost associated with it. The company aims to optimise the routing of its ships to minimise travel time and cost. The shipping company has trading partners from Taiwan, European Union, Japan, Republic of Korea, Thailand, Indonesia, Hong Kong, Malaysia, and China. Therefore, the shipping company aims to find the most optimal route to transport the goods and services by reducing the total costs.

We consider the distance of the shipping routes and aim to find the fastest routes to deliver cargo to these countries, minimising both the travel time and cost.


## [PDF Document](40.002%20Optimisation.pdf)

## 1. Import the required functions
```
using JuMP
import GLPK
import Random
import Plots
```

## 2. Model
```
The objective of this optimisation problem is to find the shortest path for ships to navigate from Singapore to all a destination ports and ultimately back to Singapore, all while considering their distances. We define our model following a TSP formulation. The network of ports and maritime routes is represented as a weighted directed graph, where each port corresponds to a node and each route corresponds to an edge between nodes. The weight of each edge represents the distance associated with traversing the route. By finding the optimal path for the delivery of cargo, the cost and travel time will be reduced.
```
