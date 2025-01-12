#TSP
using JuMP
import GLPK
import Random
import Plots

# Define the distances between ports
distances = [
    0 3252.48 5311 2674 2671 5066 1089 11.3 1044
    3252.48 0 4624 2373 2560 4215 1697 3243 3311
    5311 4624 0 2469 2975 1245 3849 5324 3745
    2674 2373 2469 0 886 2969 2404 2582 2061
    2671 2560 2975 886 0 2100 1807 2665 2207
    5066 4215 1245 2969 2100 0 4248 5071 3263
    1089 1697 3849 2404 1807 4248 0 1099 1452
    11.3 3243 5324 2582 2665 5071 1099 0 1033
    1044 3311 3745 2061 2207 3263 1452 1033 0
]

# Build the TSP model using the provided distances
function build_tsp_model(distances)
    n = size(distances, 1)
    model = Model(GLPK.Optimizer)  # Create a model using the GLPK optimizer
    @variable(model, x[1:n, 1:n], Bin, Symmetric)  # Define binary variables for the edges
    @objective(model, Min, sum(distances[i, j] * x[i, j] for i in 1:n, j in 1:n) / 2)  # Define objective function
    @constraint(model, [i in 1:n], sum(x[i, :]) == 2)  # Constraint: Each port is visited exactly twice
    @constraint(model, [i in 1:n], x[i, i] == 0)  # Constraint: No self-loops
    return model
end

# Function to find the subtour
function subtour(edges::Vector{Tuple{Int,Int}}, n)
    shortest_subtour, unvisited = collect(1:n), Set(collect(1:n))
    while !isempty(unvisited)
        this_cycle, neighbors = Int[], unvisited
        while !isempty(neighbors)
            current = pop!(neighbors)
            push!(this_cycle, current)
            if length(this_cycle) > 1
                pop!(unvisited, current)
            end
            neighbors = [j for (i, j) in edges if i == current && j in unvisited]
        end
        if length(this_cycle) < length(shortest_subtour)
            shortest_subtour = this_cycle
        end
    end
    return shortest_subtour
end

# Function to extract selected edges
function selected_edges(x::Matrix{Float64}, n)
    return Tuple{Int,Int}[(i, j) for i in 1:n, j in 1:n if x[i, j] > 0.5]
end

# Define a function to plot the tour
function plot_tour(X, Y, x)
    plot = Plots.plot()
    println("Nodes visited:")
    visited_nodes = Set{Int}()
    for (i, j) in selected_edges(x, size(x, 1))
        println("From node $i to node $j")
        push!(visited_nodes, i)
        push!(visited_nodes, j)
        Plots.plot!([X[i], X[j]], [Y[i], Y[j]]; legend=false)
    end
    println("All nodes visited: ", sort(collect(visited_nodes)))
    return plot
end


# Build the TSP model
tsp_model = build_tsp_model(distances)

# Solve the TSP model
optimize!(tsp_model)

# Check the status of the optimization
status = termination_status(tsp_model)

if status == MOI.OPTIMAL
    # Retrieve the optimized objective value
    optimized_value = objective_value(tsp_model)
    println("Optimized value: ", optimized_value)

    # Retrieve the solution
    solution = value.(tsp_model[:x])

    # Define X, Y as the coordinates of the ports (rough position on the world map)
    X = [120, 140, 140, 120, 110, 110, 100, 100, 140, 130]
    Y = [25, 45, 35, 25, 40, 10, 20, 35, 20, 30]

    # Plot the tour
    plot = plot_tour(X, Y, value.(tsp_model[:x]))  # Plot the tour
    display(plot)  # Display the plot
else
    println("Optimization was not successful.")
end

#MTZ
using JuMP
import GLPK
import Random
import Plots

# Define the distances between ports
distances = [
    0 3252.48 5311 2674 2671 5066 1089 11.3 1044
    3252.48 0 4624 2373 2560 4215 1697 3243 3311
    5311 4624 0 2469 2975 1245 3849 5324 3745
    2674 2373 2469 0 886 2969 2404 2582 2061
    2671 2560 2975 886 0 2100 1807 2665 2207
    5066 4215 1245 2969 2100 0 4248 5071 3263
    1089 1697 3849 2404 1807 4248 0 1099 1452
    11.3 3243 5324 2582 2665 5071 1099 0 1033
    1044 3311 3745 2061 2207 3263 1452 1033 0
]

# Print out the distances matrix
println("Distances matrix:")
println(distances)

# Define X, Y as the coordinates of the ports (rough position on the world map)
X = [120, 140, 140, 120, 110, 110, 100, 100, 140, 130]
Y = [25, 45, 35, 25, 40, 10, 20, 35, 20, 30]

# Build the TSP model using the provided distances
function build_tsp_model(distances)
    n = size(distances, 1)
    model = Model(GLPK.Optimizer)  # Create a model using the GLPK optimizer
    @variable(model, x[1:n, 1:n], Bin)  # Define binary variables for the edges
    @variable(model, u[1:n] >= 1, Int)  # Define auxiliary variables for the order of visiting ports
    @objective(model, Min, sum(distances[i, j] * x[i, j] for i in 1:n, j in 1:n))  # Define objective function
    @constraint(model, [i in 1:n], sum(x[i, j] for j in 1:n) == 1)  # Constraint: Each port is visited exactly once
    @constraint(model, [j in 1:n], sum(x[i, j] for i in 1:n) == 1)  # Constraint: Each port is left exactly once
    @constraint(model, [i in 2:n, j in 2:n], u[i] - u[j] + n * x[i, j] <= n - 1) # MTZ constraint
    return model
end


# Define a function to plot the tour
function plot_tour(X, Y, x)
    plot = Plots.plot()
    n = size(x, 1)
    for i in 1:n
        for j in 1:n
            if x[i, j] > 0.5
                Plots.plot!([X[i], X[j]], [Y[i], Y[j]]; legend=false)
            end
        end
    end
    return plot
end

# Define the TSP model
tsp_model = build_tsp_model(distances)

# Solve the TSP model
optimize!(tsp_model)

# Check the status of the optimization
status = termination_status(tsp_model)
println("Optimization status: ", status)

if status == MOI.OPTIMAL
    # Retrieve the optimized objective value
    optimized_value = objective_value(tsp_model)
    println("Optimized value: ", optimized_value)

    # Retrieve the solution
    solution = value.(tsp_model[:x])

    # Check if the solution is correct
    println("Solution:")
    println(solution)

    # Plot the tour
    plot = plot_tour(X, Y, solution)
    display(plot)  # Plot the tour using the solution
else
    println("Optimization was not successful.")
end
