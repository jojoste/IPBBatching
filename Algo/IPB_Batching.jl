using CSV
using Dates
using DelimitedFiles
using Glob
using Gurobi
using JSON
using JuMP
using Plots

include("CG_Batching.jl")

# model_CG -> used for column generation, full model
# model_RMP -> used for IPB, reduced model only with inital columns, will be reassigned in each iteration

# ADAPT THE FOLLOWING CONSTANTS TO YOUR NEEDS
RMP_RUNTIME = 120
GAP_THRESHOLD = 0.01
CG_MAX_ITERATION = 10
NCOLOUMNS = 1000

PRICING_PER_NODE = false
PRICING_PER_NODE_COLUMNS = 5

# Maximum number of iterations for IPB (removed later)
IPB_MAX_ITERATION  = 1000

best_sol = Inf

CG_LB_array = []
CG_AMOUNT_array = []
IPB_UB_array = []
IPB_AMOUNT_array = []
MILP_UB_array = []
Integer_Iteration = 1

directoryInstances = "Data/Instances_txt/"
filenamesInstances = glob("*.txt", directoryInstances)
filenamesInstances = [replace(filename, ".txt" => "") for filename in filenamesInstances]
filenamesInstances = [replace(filename, "Data/Instances_txt/" => "") for filename in filenamesInstances]

directoryJSON = "Data/CG_JSON/"
filenamesJSON = glob("*.json", directoryJSON)
filenamesJSON = [replace(filename, ".json" => "") for filename in filenamesJSON]
filenamesJSON = [replace(filename, "Data/CG_JSON/" => "") for filename in filenamesJSON]

# Callback Function for full MILP model
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

function configure_gurobi_logging(log_filename::AbstractString, model::Model)
    # Set Gurobi output flag to 1 for more information during solving
    set_optimizer_attribute(model, "OutputFlag", 1)

    # Set Gurobi log file to see detailed solver output
    set_optimizer_attribute(model, "LogFile", log_filename)
end



# IPB Algorithm
function IPB(fileName::String, no_CG::Bool)
    CG_iteration = 0
    IPB_iteration = 0
    currentBest = Inf

    parts = split(fileName, "/")  # Split the string at each "/"
    instance_name = parts[end]  # Get the last part of the split string
    output_filename = "Output/try_$(instance_name)_IPB_$(timestamp).txt"
    output_file = open(output_filename, "w")
    write(output_file, "$fileName start IPB\n")
    
    println("Starting IPB")

    if(no_CG)
        fileName_compare = replace(fileName, ".txt" => "")
        fileName_compare = replace(fileName_compare, "Data/Instances_txt/" => "")
        if !(fileName_compare in filenamesJSON)
        println("File not found, no IPB performed, CG will be performed!")
        no_CG = false
        end
    end

    write(output_file, "RMP_RUNTIME: $RMP_RUNTIME\n")
    write(output_file, "GAP_THRESHOLD: $GAP_THRESHOLD\n")
    write(output_file, "NCOLOUMNS: $NCOLOUMNS\n\n")


    DEBUGGING = false

    total_start_time = time()
    first_row, N = read_data(fileName)
    # Retrieve size and maximum batch size
    n, b = first_row[1], first_row[2]
    CG_LB = Inf

    # Step 1: reduced model, will later be used for RMP and CG
    if(!no_CG)
        write(output_file, "\nStart IPB with CG\n")
        A_prime_RMP = init_cols(N, b)
        A_prime_CG = copy(A_prime_RMP)
        c_prime_CG = compute_cikB(A_prime_CG, N)
        a_prime_CG = create_a_dict(A_prime_CG, N)
        write(output_file, "\nInitialize CG model\n")
        # Initialize model for CG 
        x_CG, flow_conservation_constraints_CG, partitioning_constraints_CG, u_CG, v_CG, obj_CG, model_CG = solve_optimal_partitioning_problem(A_prime_CG, c_prime_CG, false, N, DEBUGGING)
        write(output_file, "CG model initialized in $(time() - start_time) seconds\n")
    
    else
        write(output_file, "\nStart IPB without CG\n")
        A_prime_CG = Tuple{Int,Int,Vector{Int}}[]
        data = JSON.parsefile("Data/CG_JSON/$(fileName_compare).json")
        for (k, i, B) in data
            push!(A_prime_CG, (k, i, B))
        end
        A_prime_RMP = init_cols(N, b)
        batchPool = A_prime_CG
    end


    c_prime_RMP = compute_cikB(A_prime_RMP, N)
    a_prime_RMP = create_a_dict(A_prime_RMP, N)

    price_dict = Dict()
    sorted_price_dict = Dict()
    grouped_price_dict = Dict()
    start_time = time()
    write(output_file, "\nInitialize RMP model\n")
    # Initialize model for RMP (used in IPB)
    x_RMP, flow_conservation_constraints_RMP, partitioning_constraints_RMP, u_RMP, v_RMP, obj_RMP, model_RMP = solve_optimal_partitioning_problem(A_prime_RMP, c_prime_RMP, true, N, DEBUGGING)
    write(output_file, "RMP model initialized in $(time() - start_time) seconds\n")
    
    
    # Step 2: Column Generation: Initial Column Pool and Integer Solution

    # Get amount of starting columns 
    elapsed_time = time() - total_start_time
    push!(CG_AMOUNT_array, (length(A_prime_CG), elapsed_time))
    write(output_file, "\nStart CG\n")
    write(output_file, "CG_AMOUNT: $(length(A_prime_CG)) at iteration $CG_iteration\n")
    close(output_file)
    while (true & !no_CG)
        CG_iteration += 1
        z = objective_value(model_CG)
        u, v = get_duals(model_CG, n, flow_conservation_constraints_CG, partitioning_constraints_CG)
        H = new_cols(N, b, u, v)
        H = filter(x_CG -> !(x_CG in A_prime_CG), H)

        if length(H) == 0

            CG_LB = objective_value(model_CG)

            #for element in values(x)
            #    set_binary(element)
            #end
            
            set_optimizer_attribute(model_CG, "Method", 2)
            optimize!(model_CG)
            if termination_status(model_CG) == MOI.OPTIMAL
                CG_UB = objective_value(model_CG)
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
        model_CG, A_prime_CG, x_CG, a_prime_CG, c_prime_CG, flow_conservation_constraints_CG, partitioning_constraints_CG = update_model(model_CG, H, A_prime_CG, x_CG, N, a_prime_CG, c_prime_CG, flow_conservation_constraints_CG, partitioning_constraints_CG)
        set_optimizer_attribute(model_CG, "Method", 2)
        optimize!(model_CG)
        elapsed_time = time() - total_start_time
        push!(CG_LB_array, (objective_value(model_CG), elapsed_time))
        push!(CG_AMOUNT_array, (length(A_prime), elapsed_time))
        batchPool = keys(x_CG)
    end
    CG_iteration = 0

    start_time_IPB = time()
    # Step 3: Solve Restricted Master problem

    # callback function for IPB
    # Edit callback function!! revise
    # https://discourse.julialang.org/t/easier-solver-callback-for-jump-lj-gurobi/84889/2
    function callback_checkExit(cb_data, cb_where::Cint)
        if cb_where == GRB_CB_MIPNODE
            runtimeP = Ref{Cdouble}()
            nbSol = Ref{Cint}()
            GRBcbget(cb_data, cb_where, GRB_CB_RUNTIME, runtimeP)
            GRBcbget(cb_data, cb_where, GRB_CB_MIPNODE_SOLCNT, nbSol)
                
        
            if runtimeP[] > RMP_RUNTIME && nbSol[] > 0
                objbstP = Ref{Cdouble}()
                objbndP = Ref{Cdouble}()
                GRBcbget(cb_data, cb_where, GRB_CB_MIPNODE_OBJBST, objbstP)
                GRBcbget(cb_data, cb_where, GRB_CB_MIPNODE_OBJBND, objbndP)
                gap = abs((objbstP[] - objbndP[]) / objbstP[])
                if (round(objbstP[]) < round(best_sol)) || (gap < GAP_THRESHOLD)
                    # println("$(round(objbstP[])) < $(round(bestCover.cost)) || $gap < $GAP_THRESHOLD // $(runtimeP[]), $(nbSol[]), $(objbstP[]) , $(objbndP[])") 
                    println("Terminate RMP")
                    GRBterminate(JuMP.backend(model_RMP).optimizer.model.inner)
                end
            end
        end
    end

    MOI.set(model_RMP, Gurobi.CallbackFunction(), callback_checkExit)
    
    elapsed_time = time() - total_start_time
    #push!(IPB_UB_array, (objective_value(model_RMP), elapsed_time))
    output_file = open(output_filename, "a") 
    write(output_file, "\nStart IPB\n")
    close(output_file)

    # Initial column pool -> A_prime_CG (this variable contains all columns (previously computed by CG))
    # Integer solution (solve RMP until feasible solution is found)
    

    # Callback function for a first feasible solution
    function callback_feasibleSolution(cb_data, cb_where::Cint)
        if cb_where == GRB_CB_MIPSOL
            GRBterminate(JuMP.backend(model_RMP).optimizer.model.inner)
        end 
    end

    MOI.set(model_RMP, Gurobi.CallbackFunction(), callback_feasibleSolution)

    # Solve RMP with initial column pool
    for element in values(x_RMP)
        set_binary(element)
    end
    configure_gurobi_logging(output_filename, model_RMP)

    optimize!(model_RMP)

    # Check if feasible solution is found
    x_RMP_feasibleSolution = Dict(arc => value(x_RMP[arc]) for arc in A_prime_RMP if value(x_RMP[arc]) != 0)

    A_prime_RMP_feasibleSolution = keys(x_RMP_feasibleSolution)
    c_prime_RMP_feasibleSolution = compute_cikB(A_prime_RMP_feasibleSolution, N)

    # Solve RMP with feasible solution
    x_RMP, flow_conservation_constraints_RMP, partitioning_constraints_RMP, model_RMP = create_model(A_prime_RMP_feasibleSolution, c_prime_RMP_feasibleSolution, N)
    configure_gurobi_logging(output_filename, model_RMP)
    optimize!(model_RMP)
    currentBest = objective_value(model_RMP)
    

    while IPB_iteration < IPB_MAX_ITERATION
        IPB_iteration += 1
        CG_iteration = 0
        output_file = open(output_filename, "a")
        write(output_file, "\nIPB Iteration: $IPB_iteration\n")
        close(output_file)

        # Column Generation
        #for _ in 1:CG_MAX_ITERATION
        while CG_iteration < CG_MAX_ITERATION
            optimize!(model_RMP)
            CG_iteration += 1
            CG_iteration_start_time = time()

            output_file = open(output_filename, "a") 
            write(output_file, "\nCG Iteration $CG_iteration\n")
            
            u_RMP, v_RMP = get_duals(model_RMP, n, flow_conservation_constraints_RMP, partitioning_constraints_RMP) 

            # Check if duals are found, if not, stop
            if(u_RMP[1] == Inf || v_RMP[1] == Inf)
                println("No duals found")
                break
            end
            

            # Step 4: pricing 
            # empty price_dict and sorted_price_dict
            empty!(price_dict)
            empty!(sorted_price_dict)
            empty!(grouped_price_dict)

            # for each column in the column pool, calculate the reduced cost
            for element in batchPool
                (i, k, B) = element
                price_dict[element] =  get_arc_cost(element, N) - (u_RMP[i] - u_RMP[k]) - sum(v_RMP[j] for j in B)

            end

            if(!PRICING_PER_NODE)
                # Sort price_dict by value ascending and only keep columns with negative reduced cost
                sorted_price_dict = sort(collect(filter(x -> x[2] < 0, price_dict)), by = x -> x[2])
                if length(sorted_price_dict) == 0
                    println("No columns with negative reduced cost found")
                    break
                end
            else
                grouped_price_dict = Dict()
                for (element, cost) in price_dict
                    (i, k, B) = element
                    if haskey(grouped_price_dict, i)
                        push!(grouped_price_dict[i], (element, cost))
                    else
                        grouped_price_dict[i] = [(element, cost)]
                    end
                end

                # Sort the tuples in each group by cost
                for (node, tuples) in grouped_price_dict
                    sort!(tuples, by = x -> x[2])
                end

                # Now, for each node, keep only the three tuples with the lowest cost
                for (node, tuples) in grouped_price_dict
                    grouped_price_dict[node] = tuples[1:min(PRICING_PER_NODE_COLUMNS, length(tuples))]
                end

                # Flatten the grouped_price_dict to have a list of all tuples
                sorted_price_dict = [tup for (node, tuples) in grouped_price_dict for tup in tuples]

                if isempty(sorted_price_dict)
                    println("No columns with negative reduced cost found")
                    break
                end
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
            x_toAdd = filter(x -> !(x in A_prime_RMP), x_toAdd)


            model_RMP, A_prime_RMP, x_RMP , A_prime_RMP, c_prime_RMP, flow_conservation_constraints_RMP, partitioning_constraints_RMP = update_model(model_RMP, x_toAdd, A_prime_RMP, x_RMP, N, A_prime_RMP, c_prime_RMP, flow_conservation_constraints_RMP, partitioning_constraints_RMP)
            optimize!(model_RMP)

            elapsed_time_CG = time() - CG_iteration_start_time
            println("\nAdded $(length(x_toAdd)) columns to the reduced model\n")
            write(output_file, "Obj Relaxed: $(objective_value(model_RMP))\n")
            write(output_file, "Columns added to RMP: $(length(x_toAdd)) in $elapsed_time_CG\n")
            close(output_file)
            
            if(CG_iteration == CG_MAX_ITERATION)
                println("CG reached maximum number of iterations")
            end
        end 
        
        # Step 6: Solve Restricted Master problem (until exit criteria is met)
        MOI.set(model_RMP, Gurobi.CallbackFunction(), callback_checkExit)
        for element in values(x_RMP)
            set_integer(element) 
        end
        
        optimize!(model_RMP)

        obj = objective_value(model_RMP)
        Integer_Iteration = +1
        elapsed_time_IPB = time() - start_time_IPB
        push!(IPB_UB_array, (obj, elapsed_time_IPB))
        output_file = open(output_filename, "a")
        write(output_file, "\n\nNew integer solution found: $(obj) \n")
        write(output_file, "Time for iteration $(Integer_Iteration): $(elapsed_time_IPB) seconds\n")
        current_total_time = time() - start_time
        write(output_file, "Total time passed: $(current_total_time) seconds\n")
        close(output_file)


    
        # Step 7: New best Solution?
        # If yes, set solution to initial columns of RMP and go to step 4
        if(obj < currentBest)
            output_file = open(output_filename, "a")
            currentBest = obj
                
            # Generate new model with only feasible solution
            x_RMP_feasibleSolution = Dict(arc => value(x_RMP[arc]) for arc in keys(x_RMP) if value(x_RMP[arc]) != 0)
            length_x = length(x_RMP_feasibleSolution)
            A_prime_RMP = collect(keys(x_RMP_feasibleSolution))
            c_prime_RMP = compute_cikB(A_prime_RMP, N) 
            write(output_file, "\n\nNew best integer solution found!\n")
            write(output_file, "New best integer solution: $(obj)\n")
            write(output_file, "Amount columns in solution: $length_x\n")       

            x_RMP, flow_conservation_constraints_RMP, partitioning_constraints_RMP, model_RMP = create_model(A_prime_RMP, c_prime_RMP, N)
            configure_gurobi_logging(output_filename, model_RMP)

            close(output_file)
        else
            # Add more columns to RMP
            for element in values(x_RMP)
                unset_integer(element) 
            end
        end
    end
    #=
    if(model_CG)
    
        ## Try to access information through the callback function about incumbent solution, revise!!
        MOI.set(model_CG, Gurobi.CallbackFunction(), callback_Incumbent)

        # Solve full model with integer variables
        for element in values(x_CG)
            set_integer(element) 
        end 
        optimize!(model_CG)

    end
    =#
end 

##### DEBGUGGING AREA #####

#IPB("Data/Instances_txt/inst_200_10_4.txt", true)





