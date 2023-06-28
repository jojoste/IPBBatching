using DelimitedFiles
using JuMP
using Gurobi
using Plots

#### HELPER FUNCTIONS #####

#c = Dict()


function read_data(datastring)
    data = readdlm(datastring, ' ', Int)
    first_row = data[1:1, :]
    remaining_data = data[2:end, :]

    # Add an index column to the remaining data
    index_col = collect(1:size(remaining_data, 1))
    remaining_data = hcat(index_col, remaining_data)

    # Get the values for B and sigma
    B = first_row[1]
    sigma = first_row[2]

    return first_row, remaining_data, B, sigma
end

# plot the solution
function plot_CG_LB(CG_LB_array)
    # Extract elapsed_time and cg_lb from each tuple in CG_LB_array
    elapsed_time = [t[2] for t in CG_LB_array]
    cg_lb = [t[1] for t in CG_LB_array]

    plot(elapsed_time, cg_lb, label="CG_LB", title="CG_LB over time", xlabel="Time (seconds)", ylabel="CG_LB")
end

# compute (max) processing time for one arc (==> cost)
function pB(B, N)
    max_p = -Inf
    for j in B
        # access first column of N at row j
        max_p = max(max_p, first(N[N[:, 1].==j, 2]))
    end
    return max_p
end

# compute costs for each (i, k, B) in A
function compute_cikB(A, N)
    n = size(N, 1)
    c = Dict()
    for (i, k, B) in A
        # compute p_B
        p_B = pB(B, N)
        # compute cikB (cost for arc (i, k) with B
        cikB = (n - i + 1) * p_B
        # store cikB in c
        c[i, k, B] = cikB
    end
    return c
end

# compute cost for a single arc
function get_arc_cost(arc, N)
    i, k, B = arc

    # Compute p_B
    p_B = pB(B, N)

    # Compute cikB (cost for arc (i, k) with B)
    n = size(N, 1)
    cikB = (n - i + 1) * p_B

    # Store the computed cost in the dictionary revise
    #c[arc] = cikB

    return cikB
end

#= 
# Knapsack problem functions (for the column generation)
function gr(r, b, l, sorted_N, n, gr_dict)
    # check if value is already computed
    if haskey(gr_dict, (r, b, l))
        computed_value =  gr_dict[(r, b, l)]
    end

    # boundary conditions
    if l > n - r + 1 || b < 0
        computed_value =  -Inf
    elseif l == 0
        computed_value =  0
    elseif r == n
        computed_value =  (sorted_N[r, 3] <= b && l == 1) ? sorted_N[r, 4] : 0
        # recursion
    else
        gr_with_yr_1 = gr(r + 1, b - sorted_N[r, 3], l - 1, sorted_N, n, gr_dict) + sorted_N[r, 4]
        gr_with_yr_0 = gr(r + 1, b, l, sorted_N, n, gr_dict)
        computed_value =  max(gr_with_yr_1, gr_with_yr_0)
    end
    # store computed value
    gr_dict[(r, b, l)] = computed_value
    return computed_value
end

#=
function get_B(r, b, l, sorted_N, n)
    #r= Int(r)

    #s = sorted_N[r, 3]
    #v = sorted_N[r, 4]

    if l == 0 || b < 0
        return []
    elseif r == n
        return (sorted_N[r, 3] <= b && l == 1) ? [sorted_N[r, 1]] : []
    else
        gr_with_yr_1 = gr(r + 1, b - sorted_N[r, 3], l - 1, sorted_N, n) + sorted_N[r, 4]
        gr_with_yr_0 = gr(r + 1, b, l, sorted_N, n)

        if gr_with_yr_1 >= gr_with_yr_0
            return [Int(sorted_N[r, 1]); get_B(r + 1, b - sorted_N[r, 3], l - 1, sorted_N, n)]
        else
            return get_B(r + 1, b, l, sorted_N, n)
        end
    end
end
=#

function get_B(r, b, l, sorted_N, n, gr_dict, B_dict)
    # check if value is already computed
    if haskey(B_dict, (r, b, l))
        computed_value =  B_dict[(r, b, l)]
    end

    if l > n - r + 1 || b < 0
        computed_value =  []
    elseif l == 0
        computed_value =  []
    elseif r == n
        computed_value =  (sorted_N[r, 3] <= b && l == 1) ? [sorted_N[r, 1]] : []
    else
        gr_with_yr_1 = gr(r + 1, b - sorted_N[r, 3], l - 1, sorted_N, n, gr_dict) + sorted_N[r, 4]
        gr_with_yr_0 = gr(r + 1, b, l, sorted_N, n, gr_dict)

        if gr_with_yr_1 >= gr_with_yr_0
            # The optimal set of jobs when the current job is included consists of the current job and the optimal set of jobs for the remaining jobs, total size, and cardinality.
            computed_value =  [Int(sorted_N[r, 1]); get_B(r + 1, b - sorted_N[r, 3], l - 1, sorted_N, n,gr_dict, B_dict)]
        else
            computed_value =  get_B(r + 1, b, l, sorted_N, n, gr_dict, B_dict)
        end
    end
    # store computed value
    B_dict[(r, b, l)] = computed_value
    return computed_value
end =#



function knapsack(r, b, l, sorted_N, n, GR_mem, B_mem)
    # check if value is already computed

    # @Joel, recheck this here (+1) -> limitation of Julia starting indice at 1
    #if(b>0)
        if !ismissing(GR_mem[r+1, b+11, l+1])
            return GR_mem[r+1, b+11, l+1], B_mem[r+1, b+11, l+1]
        end
    #end 

    computed_value = 0
    B_local = []

    # boundary conditions
    if l > n - r + 1 || b < 0
        computed_value = -Inf
    elseif l == 0
        computed_value = 0
    elseif r == n
        if sorted_N[r, 3] <= b && l == 1
            computed_value = sorted_N[r, 4]
            B_local = [sorted_N[r, 1]]
        else
            computed_value = 0
        end
    else
        gr_with_yr_1, B_with_yr_1 = knapsack(r + 1, b - sorted_N[r, 3], l - 1, sorted_N, n, GR_mem, B_mem)
        gr_with_yr_1 += sorted_N[r, 4]
        gr_with_yr_0, B_with_yr_0 = knapsack(r + 1, b, l, sorted_N, n, GR_mem, B_mem)

        if gr_with_yr_1 >= gr_with_yr_0
            computed_value = gr_with_yr_1
            B_local = [sorted_N[r, 1]; B_with_yr_1]
        else
            computed_value = gr_with_yr_0
            B_local = B_with_yr_0
        end
    end

    # store computed value and jobs
    #if(b>0)
        GR_mem[r+1, b+11, l+1] = computed_value
        B_mem[r+1, b+11, l+1] = B_local
    #end

    return computed_value, B_local
end 

# create incidence column vector
function create_a_dict(A, N)
    a = Dict()
    for (i, k, B) in A
        # create a new entry for each job
        if !haskey(a, B)
            a[B] = Dict()
        end
        for j in 1:size(N, 1)
            if j in B
                a[B][j] = 1
            else
                a[B][j] = 0
            end
        end
    end
    return a
end

# update existing model
function update_model(model, A_new, A, x, N, a, c, flow_conservation_constraints, partitioning_constraints)
    # Update model with new columns
    for arc in A_new
        # Check if arc is already in A
        if !haskey(x, arc)
            # Add new arc to A
            push!(A, arc)
            
            # Get cost for new arc and add to c
            c[arc] = get_arc_cost(arc, N)

            # Add new variable to model
            x[arc] = @variable(model, lower_bound = 0, upper_bound = 1, base_name = "x[$arc]")

            (i, k, B) = arc
            # Add new variable to objective function
            set_objective_coefficient(model, x[arc], c[arc])

            # Add new variable to flow conservation constraints    
            set_normalized_coefficient(flow_conservation_constraints[i], x[arc], 1)
            set_normalized_coefficient(flow_conservation_constraints[k], x[arc], -1)

            # Add new variable(s) to partitioning constraints
            for element in B
                set_normalized_coefficient(partitioning_constraints[element], x[arc], 1)
            end

        end
    end
    return model, A, x, a, c, flow_conservation_constraints, partitioning_constraints
end

# write a function that returns me the duals of the constraints
function get_duals(model, n, flow_conservation_constraints, partitioning_constraints)
    # Check if model has duals
    if has_duals(model)
        u = [dual(flow_conservation_constraints[i]) for i in 1:(n+1)]
        v = [dual(partitioning_constraints[j]) for j in 1:n]
    else
        # If not, return Inf
        u = fill(Inf, n + 1)
        v = fill(Inf, n)
    end 
    return u, v
end


# ==== Algorithms from Paper ==== #

# Algorithm 2: Generation of the set of initial arcs
function init_cols(N, b)
    # Sort jobs in N such that p1 ≤ p2 ≤ ... ≤ pn
    sorted_N = sortslices(N, dims=1, by=x -> x[2])

    # Set H ← ∅ (Set of initial arcs)
    H = Tuple{Int,Int,Vector{Int}}[]
    n = size(sorted_N, 1)

    # for all jobs check if they fit into the batch
    for j in 1:n
        # Set B = [j]
        B = [sorted_N[j, 1]]
        # added this line to make it work -> to revise
        push!(H, (j, j + length(B), sort(copy(B))))

        for h in (j+1):n
            # If ∑j∈B s_j + s_h ≤ b
            if sum([sorted_N[findfirst(sorted_N[:, 1] .== i), 3] for i in B]) + sorted_N[h, 3] <= b
                # Set B := B ∪ {h}
                append!(B, sorted_N[h, 1])
                # Set H ← H ∪ {(i, i + |B|, B) : i = 1,...,n − |B| + 1}
                for i in 1:(n-length(B)+1)
                    push!(H, (i, i + length(B), sort(copy(B))))
                end
            end
        end
    end

    return H
end



# Algorithm 1:  pricing problem
function new_cols(N, b, u, v)
    # Sort and renumber jobs in N such that p1 ≥ p2 ≥ ... ≥ pn
    s_v = hcat(N, v)
    sorted_N = sortslices(s_v, dims=1, by=x -> x[2], rev=true)
    sorted_N = round.(Int, sorted_N)
    n = size(sorted_N, 1)
    # Set H = ∅ (Set of negative-reduced cost arcs)
    H = [Tuple{Int,Int,Vector{Int}}[] for _ in 1:n]

    # Arrays for gr and B
    # For now some values, come back and change
    GR_mem = Array{Any}(missing,n+1,b+11,n+1)
    B_mem = Array{Any}(missing, n+1, b+11, n+1)
    #gr_dict = Dict{Tuple{Int,Int,Int}, Float64}()
    #B_dict = Dict{Tuple{Int,Int,Int}, Any}()
    
    #Threads.@threads for l in 1:n
    for l in 1:n
        # r should be equal to first sorted job
            r = 1
            done = false

            # Counter for iterations
            iter_count = 0

            while !done 
                gr_l_b, B_l_b  =  knapsack(r, b, l, sorted_N, n, GR_mem, B_mem )
                #gr_l_b, B_l_b = knapsack_old(r, b, l, sorted_N, n, gr_dict, B_dict)
                #position of nodes
                #Threads.@threads  for i in 1:(n-l+1)
                for i in 1:(n-l+1)
                    k = i + l
                    # Compute c_ikB = p_B(n - i + 1) - (u_i - u_k) - gr(b, l)
                    #c_ikB = pB(B_l_b, sorted_N) * (n - i + 1) - (u[i] - u[k]) - gr_l_b
                    c_ikB = get_arc_cost((i,k,B_l_b), sorted_N) - (u[i] - u[k]) - gr_l_b

                    if c_ikB < -0.001
                        # Set H := H ∪ {(i, k, B)}
                        # This was added -> need to revise
                        if (k - i) == length(B_l_b)
                            #print("adding arc: ", (i, k, copy(B_l_b)), " \t  $c_ikB")
                            push!(H[l], (i, k, sort(B_l_b)))
                        end
                    end
                end

                # Set r := min{j : p_j < p_r}
                r_values = [j for j in 1:n if sorted_N[j, 2] < sorted_N[r, 2]]
                
                if !isempty(r_values) 
                    r = minimum([Int(x) for x in r_values])
                else
                    done = true
                end 
            end
        end
    H_flat = vcat(H...)
    return H_flat 
end



### LP SOLVER ###
# Solve the LP relaxation of the restricted master problem
# A = set of arcs
# c = cost of each arc
# relaxation = true if we want to solve the LP relaxation, false if we want to solve the IP relaxation
function solve_optimal_partitioning_problem(A, c, relaxation, N, debugging)

    
    # Create a dictionary of incidence column vectors
    a = create_a_dict(A, N)

    n = size(N, 1)
    # Create new model Gurobi 
    model = Model(Gurobi.Optimizer)


    # Set Gurobi parameters
    if debugging
        # Set Gurobi output flag to 1 for more information during solving
        set_optimizer_attribute(model, "OutputFlag", 1)

        # Set Gurobi log file to see detailed solver output
        set_optimizer_attribute(model, "LogFile", "gurobi.log")
    end

    # create variable for each arc in A
    x = Dict{Tuple{Int,Int,Vector{Int}},VariableRef}()

    for arc in A
        x[arc] = @variable(model, lower_bound = 0, upper_bound = 1, base_name = "x[$arc]")
    end

    # Create objective function (13)
    @objective(model, Min, sum(c[arc] * x[arc] for arc in A))

    #Create flow conservation constraints (14)
    flow_conservation_constraints = Dict{Int,ConstraintRef}()

    for node in 1:n+1
        if node == 1  # single source
            flow_conservation_constraints[node] = @constraint(
                model,
                sum(x[arc] for arc in A if arc[1] == node) - sum(x[arc] for arc in A if arc[2] == node) == 1
            )
        elseif node == n + 1  # single sink
            flow_conservation_constraints[node] = @constraint(
                model,
                sum(x[arc] for arc in A if arc[1] == node) - sum(x[arc] for arc in A if arc[2] == node) == -1
            )
        else  # intermediate nodes
            flow_conservation_constraints[node] = @constraint(
                model,
                sum(x[arc] for arc in A if arc[1] == node) - sum(x[arc] for arc in A if arc[2] == node) == 0
            )
        end
    end

    #Create partitioning constraints (15)
    partitioning_constraints = Dict{Int,ConstraintRef}()

    for j in 1:n
        partitioning_constraints[j] = @constraint(
            model,
            sum(a[B][j] * x[(i, k, B)] for (i, k, B) in A if haskey(a[B], j)) == 1
        )
    end


    if debugging
        for j in 1:n
            #if (partitioning_constraints[j] === nothing)
            println("Constraint for j = $j: ", partitioning_constraints[j])
            #end
        end
    end


    # Solve the model
    optimize!(model)
    if debugging
        optimization_status = termination_status(model)
        println("Optimization status: ", optimization_status)
    end

    if has_duals(model)
        u = [dual(flow_conservation_constraints[i]) for i in 1:(n+1)]
        v = [dual(partitioning_constraints[j]) for j in 1:n]
    else
        u = zeros(n + 1)
        v = zeros(n)
    end

    obj = Inf

    if termination_status(model) == MOI.INFEASIBLE
        println("Model is infeasible!")
        set_optimizer_attribute(model, "InfUnbdInfo", 1)
        optimize!(model)
        #for arc in A
        #    println("Arc: ", arc, ", Reduced Cost: ", reduced_cost(x[arc]))
        #end

    else
        println("========================================")
        println("Objective Value: ", objective_value(model))
        obj = min(obj, objective_value(model))
        # Get optimal values
        # Filter out arcs with values == 0
        x_optimal = Dict(arc => value(x[arc]) for arc in A if value(x[arc]) != 0)
        println("Optimal Solution (used arcs): ", x_optimal)
    end

    return x, flow_conservation_constraints, partitioning_constraints, u, v, obj, model
end



# Algo 3: price and branch procedure

function price_and_branch(N, b, debugging, solveNonRelaxed::Bool = false)
    # Step 1: A′ ← InitCols(N , b)
    CG_LB = Inf
    CG_UB = Inf
    limit = 0
    # initialize empty array to store CG_LB
    start_time = time()
    CG_LB_array = []

    A_prime = init_cols(N, b)
    c = compute_cikB(A_prime, N)
    x, flow_conservation_constraints, partitioning_constraints, u, v, obj, myModel = solve_optimal_partitioning_problem(A_prime, c, true, N, debugging)
    elapsed_time = 0
    push!(CG_LB_array, (obj, elapsed_time))
    a = create_a_dict(A_prime, N)
    n = size(N, 1)
    # Step 2: G(V , A′) ← restricted master problem
    #G = solve_optimal_partitioning_problem(A_prime, c, relaxation, N, debugging)

    while true
        # Step 4: z ← continuous optimum of G(V , A′)


        z = objective_value(myModel)
        u, v = get_duals(myModel, n, flow_conservation_constraints, partitioning_constraints)

        # Step 5: u, v ← optimal multipliers
        #u, v = optimal_multipliers(G)

        # Step 6: H ← NewCols(N , b, u, v)
        H = new_cols(N, b, u, v)


        # maybe we should check here whether there are actually new columns in H or not
        # remove all arcs in H that are already in A_prime
        H = filter(x -> !(x in A_prime), H)


        # Step 7: if |H |=0 then
        if length(H) == 0 #|| limit > 40 #|| elapsed_time < 500
            # Step 8: CG − LB ← z — continuous optimum, lower bound
            CG_LB = objective_value(myModel)
            elapsed_time = time() - start_time
            push!(CG_LB_array, (CG_LB, elapsed_time))

            # Step 9: CG − UB ← integer solution computed over G(V , A′)
            # Add binary constraint
            if(solveNonRelaxed)
                for element in values(x)
                    set_binary(element)
                end
                set_optimizer_attribute(myModel, "Method", 2)
                optimize!(myModel)
                # check if we have an integer solution
                if termination_status(myModel) == MOI.OPTIMAL
                    CG_UB = objective_value(myModel)
                    x_optimal = sort(Dict(arc => value(x[arc]) for arc in A_prime if value(x[arc]) != 0))
                    println("Optimal Solution (used arcs): ", x_optimal)
                else
                    println("No integer solution found!")
                end
            end
            # Step 10: break
            break
        end

        # Step 12: A′ ← A′ ∪ H
        #A_prime = unique(vcat(A_prime, H))
        myModel, A_prime, x, a, c, flow_conservation_constraints, partitioning_constraints = update_model(myModel, H, A_prime, x, N, a, c, flow_conservation_constraints, partitioning_constraints)
        set_optimizer_attribute(myModel, "Method", 2)
        optimize!(myModel)
        # save CG_LB in array
        elapsed_time = time() - start_time
        push!(CG_LB_array, (objective_value(myModel), elapsed_time))

        #SparseArrays.sparse(hcat(x...))

        limit += 1
    end

    return CG_LB, CG_UB, CG_LB_array, x, c
end


##### DEBGUGGING AREA #####

#first_row, remaining_data = read_data("Data/Instances_txt/inst_20_50_1.txt")
#N = remaining_data

#CG_LB, CG_UB, CG_LB_array, x, c = price_and_branch(N, 50, false)

#length(x)





#CG("Data/Instances_txt/inst_40_50_3.txt", 10, false)



####### Uncommment HERE ########

#=

CG_LB, CG_UB, A_prime, partitioning_constraints, CG_LB_array = price_and_branch(N, 50, false)



CG_LB, CG_UB

(CG_UB / CG_LB - 1) * 100


plot_CG_LB(CG_LB_array) 

=#

#=


A_prime = init_cols(N, 10)
c = compute_cikB(A_prime, N)
a = create_a_dict(A_prime, N)
start_time = time()
x, flow_conservation_constraints, partitioning_constraints, u, v, obj, myModel = solve_optimal_partitioning_problem(A_prime, c, true, N, false)
elapsed_time = time() - start_time

start_time = time()
optimize!(myModel)
elapsed_time = time() - start_time
println("Elapsed time: ", elapsed_time)

# !!! First run the new cols Alg
H = new_cols(N, 10, u, v)
# remove all arcs in H that are already in A_prime
H = filter(x -> !(x in A_prime), H)
println( length(H), " new columns found and added to model!")
start_time = time()
myModel, A_prime, x, a, c, flow_conservation_constraints, partitioning_constraints = update_model(myModel, H, A_prime, x, N, a, c, flow_conservation_constraints, partitioning_constraints)
elapsed_time = time() - start_time
println("Elapsed time (updating model): ", elapsed_time)
start_time = time()
optimize!(myModel)
elapsed_time = time() - start_time
println("Elapsed time (solving): ", elapsed_time)
=#