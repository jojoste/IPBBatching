using DelimitedFiles
using JuMP
using Gurobi
using Plots
using Dates
using CSV

include("CG_Batching.jl")

# CGModel -> used for column generation
# model_best -> used for IPB

# ADAPT THE FOLLOWING CONSTANTS TO YOUR NEEDS
SCP_RUNTIME_CB = 300
GAP_THRESHOLD = 0.05
# How many columns should be added in each IPB - iteration
NCOLOUMNS = 500

model_best = nothing



CG_LB_array = []
CG_AMOUNT_array = []

IPB_UB_array = []
IPB_AMOUNT_array = []

best_sol = Inf

MILP_UB_array = []

function callback_Incumbent(cb_data, cb_where)
    if cb_where == GRB_CB_MIPSOL
        obj = Ref{Cdouble}()
        runtime = Ref{Cdouble}()
        # When a new incumbent is found, get the objective and runtime
        #obj = Gurobi.cbget(cb_data, cb_where, GRB_CB_MIPSOL_OBJ)
        GRBcbget(cb_data, cb_where, GRB_CB_MIPSOL_OBJ, obj)
        #obj = GRB_CB_MIPSOL_OBJ
        #runtime = Gurobi.cbget(cb_data, cb_where, GRB_CB_RUNTIME)
        GRBcbget(cb_data, cb_where, GRB_CB_RUNTIME, runtime)
        #runtime = GRB_CB_RUNTIME
        #println("New incumbent: ", obj, ", Runtime: ", runtime)
        push!(MILP_UB_array, (obj.x, runtime.x))
    end
end




function plot_comparison_CG(CG_AMOUNT::Vector{Any}, CG_LB::Vector{Any})
    p1 = plot([x[2] for x in CG_AMOUNT], [x[1] for x in CG_AMOUNT], label = "Number of columns", line = :blue, ylabel = "Number of columns", legend = :topright)
    
    p2 = twinx()
    plot!(p2, [x[2] for x in CG_LB], [x[1] for x in CG_LB], label = "LP objective", line = :red, ylabel = "LP objective", legend = :topleft)

    plot!(title = "Comparison LP-Objective and Amount Columns")

    return p1
end

function plot_CG_LB(CG_AMOUNT_array, CG_LB_array)
    # Extract x and y values from CG_AMOUNT_array
    x_cg = [pair[1] for pair in CG_AMOUNT_array]
    y_cg = [pair[2] for pair in CG_AMOUNT_array]

    # Extract x and y values from CG_LB_array
    x_lb = [pair[1] for pair in CG_LB_array]
    y_lb = [pair[2] for pair in CG_LB_array]

    # Plot the data
    plot(x_cg, y_cg, label="CG_AMOUNT", marker=:circle)
    plot!(x_lb, y_lb, label="CG_LB", marker=:square)

    # Customize the plot
    xlabel!("CG Iteration")
    ylabel!("Value")
    title!("CG_AMOUNT vs CG_LB")

    # Generate timestamp for filename
    timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")

    # Save the plot with timestamp in the filename
    savefig("CG_$timestamp.png")

    # Display the plot
    display(plot)
end



# IPB Algorithm
function IPB(fileName::String, b::Int64)

    DEBUGGING = false

    total_start_time = time()
    first_row, N = read_data(fileName)
    n = size(N, 1)
    generateCG = true
    CG_LB = Inf


    # Step 1: reduced model, will later be used for RMP and CG
    A_prime_best = init_cols(N, b)
    A_prime = copy(A_prime_best)
    c_prime_best = compute_cikB(A_prime_best, N)
    c_prime = copy(c_prime_best)
    a_prime_best = create_a_dict(A_prime_best, N)
    a_prime = copy(a_prime_best)

    price_dict = Dict()
    
    # Initialize model for Restricted Master Problem
    x_best, flow_conservation_constraints_best, partitioning_constraints_best, u_best, v_best, obj_best, model_best = solve_optimal_partitioning_problem(A_prime_best, c_prime_best, true, N, DEBUGGING)
    # Initialize model for CG
    x, flow_conservation_constraints, partitioning_constraints, u, v, obj, CGModel = solve_optimal_partitioning_problem(A_prime, c_prime, false, N, DEBUGGING)

    
    # Step 2: Column Generation: Initial Column Pool and Integer Solution

    # Inner check exit function
    function checkExit(cb_data, cb_where::Cint)
        if cb_where == GRB_CB_MIPNODE
            # Get runtime and number of solutions from the callback data
            runtimeP = Ref{Cdouble}()
            nbSol = Ref{Cint}()
            GRBcbget(cb_data, cb_where, GRB_CB_RUNTIME, runtimeP)
            GRBcbget(cb_data, cb_where, GRB_CB_MIPNODE_SOLCNT, nbSol)
    
            #gap = abs((objbstP[] - objbndP[]) / objbstP[])
            
            #if runtimeP[] > SCP_RUNTIME_CB && nbSol[] > 0
                # Get objective bound and objective estimate from the callback data
                objbstP = Ref{Cdouble}()
                objbndP = Ref{Cdouble}()
                GRBcbget(cb_data, cb_where, GRB_CB_MIPNODE_OBJBST, objbstP)
                GRBcbget(cb_data, cb_where, GRB_CB_MIPNODE_OBJBND, objbndP)
                
                # Calculate the optimality gap
                gap = abs((objbstP[] - objbndP[]) / objbstP[])
                #GRBterminate(backend(model_best).optimizer.model.inner)
                #model_best.terminate()
            #end
                # @Joel recheck here bestCover.cost -> adapt accordingly
                #if (round(objbstP[]) < round(bestCover.cost)) || (gap < GAP_THRESHOLD)
                if (gap < GAP_THRESHOLD)
                    # If the objective estimate is lower than the bestCover cost or the gap is smaller than the threshold, terminate the optimizer
                    # Uncomment the following line if you want to print the values for debugging
                    # println("$(round(objbstP[])) < $(round(bestCover.cost)) || $gap < $GAP_THRESHOLD // $(runtimeP[]), $(nbSol[]), $(objbstP[]) , $(objbndP[])") 
                    
                    
                    #GRBterminate(backend(model_best).optimizer.model.inner)
                    #cb_data.terminate()
                    println("Model terminated")
                end
            
        end
    end

    while true
        z = objective_value(CGModel)
        u, v = get_duals(CGModel, n, flow_conservation_constraints, partitioning_constraints)
        H = new_cols(N, b, u, v)
        H = filter(x -> !(x in A_prime), H)

        if length(H) == 0

            CG_LB = objective_value(CGModel)

            #for element in values(x)
            #    set_binary(element)
            #end
            
            set_optimizer_attribute(CGModel, "Method", 2)
            optimize!(CGModel)
            if termination_status(CGModel) == MOI.OPTIMAL
                CG_UB = objective_value(CGModel)
                #x_optimal = sort(collect(keys(x)))[value.(x) .== 1]
                println("Optimal solution found: $(CG_UB)")
                #println("Optimal solution: $(x_optimal)")
            else 
                println("No optimal solution found")
            end 
            println("CG Done!")
            break
        end

        println("\nAdded $(length(H)) columns\n")
        CGModel, A_prime, x, a_prime, c_prime, flow_conservation_constraints, partitioning_constraints = update_model(CGModel, H, A_prime, x, N, a_prime, c_prime, flow_conservation_constraints, partitioning_constraints)
        set_optimizer_attribute(CGModel, "Method", 2)
        optimize!(CGModel)
        elapsed_time = time() - total_start_time
        push!(CG_LB_array, (objective_value(CGModel), elapsed_time))
        push!(CG_AMOUNT_array, (length(A_prime), elapsed_time))
    end

    start_time_IPB = time()
    # Step 3: Solve Restricted Master problem

    plot_CG_LB(CG_LB_array)

    MOI.set(model_best, Gurobi.CallbackFunction(), checkExit)

    while true
        optimize!(model_best)
        u, v = get_duals(model_best, n, flow_conservation_constraints_best, partitioning_constraints_best) 

        # Check if duals are found, if not, stop
        if(u[1] == Inf || v[1] == Inf)
            println("No duals found")
            break
        end
        
        # Step 4: pricing

        # empty price_dict
        empty!(price_dict)

        # for each column in the column pool, calculate the reduced cost
        for element in keys(x)
            (i, k, B) = element
            #price_dict[element] =  pB(B, N) * (n - i + 1) - (u[i] - u[k]) - sum(v[j] for j in B)
            price_dict[element] =  get_arc_cost(element, N) - (u[i] - u[k]) - sum(v[j] for j in B)

        end

        # Sort price_dict by value ascending and only keep columns with negative reduced cost
        sorted_price_dict = sort(collect(filter(x -> x[2] < 0, price_dict)), by = x -> x[2])

        if length(sorted_price_dict) == 0
            println("No columns with negative reduced cost found")
            break
        end

        # Step 5 Add columns
        # extract NCOLOUMNS columns with highest reduced cost from price_dict
        if NCOLOUMNS > length(sorted_price_dict)
            NCOLOUMNS_intermediate = length(sorted_price_dict)
        else
            NCOLOUMNS_intermediate = NCOLOUMNS
        end 
        x_toAdd = sorted_price_dict[1:NCOLOUMNS_intermediate]
        

        #print(x_toAdd)

        x_toAdd = [x[1] for x in x_toAdd]
        x_toAdd = filter(x -> !(x in A_prime_best), x_toAdd)

        println("\nAdded $(length(x_toAdd)) columns to the reduced model\n")

        model_best, A_prime_best, x_best , A_prime_best, c_prime_best, flow_conservation_constraints_best, partitioning_constraints_best = update_model(model_best, x_toAdd, A_prime_best, x_best, N, A_prime_best, c_prime_best, flow_conservation_constraints_best, partitioning_constraints_best)
        
        # Step 6: Solve Restricted Master problem (until exit criteria is met)
        for element in values(x_best)
            set_integer(element) 
        end
        
        
        optimize!(model_best)

        obj = objective_value(model_best)
        elapsed_time_IPB = time() - start_time_IPB
        push!(IPB_UB_array, (obj, elapsed_time_IPB))
        # Step 7: New best Solution?
        println("New best solution found: $(obj)")

        for element in values(x_best)
            unset_integer(element) 
        end

        optimize!(model_best)


        #if(time() - total_start_time > 6000 || length(x_toAdd) == 0)
        if(length(x_toAdd) == 0)
            println("Exited IPB loop ")
            break
        end



    end
    

    ## Try to access information through the callback function about incumbent solution
    MOI.set(CGModel, Gurobi.CallbackFunction(), callback_Incumbent)

    for element in values(x)
        set_integer(element) 
    end

    optimize!(CGModel)





end 

##### DEBGUGGING AREA #####

println("Starting IPB")


IPB("Data/inst_100_50_3.txt", 20)

#plot_CG_LB(CG_AMOUNT_array) 


plot_comparison_CG(CG_AMOUNT_array, CG_LB_array)

plot_CG_LB(IPB_UB_array)


plot_CG_LB(MILP_UB_array)

MILP_UB_array





arr1 = [(value, time) for (value, time) in MILP_UB_array if time < 300]
arr2 = [(value, time) for (value, time) in IPB_UB_array if time < 300]


y1 = [point[1] for point in arr1]
x1 = [point[2] for point in arr1]
y2 = [point[1] for point in arr2]
x2 = [point[2] for point in arr2]

plot(x1, y1, label = "Array 1", linewidth = 2)
plot!(x2, y2, label = "Array 2", linewidth = 2)

