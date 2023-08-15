include("IPB_Batching.jl")


function solve_Integer_Model(fileName, timeLimit=3000, relaxed::Bool=true)
    
    parts = split(fileName, "/")
    instance_name = parts[end]
    instance_name = replace(instance_name, ".txt" => "")

    parts_instance_name = split(instance_name, "_")
    b = parse(Int64, parts_instance_name[3])


    if(relaxed)
        output_filename = "Output/MILP_RELAXED_$(instance_name)_$(timestamp).txt"
    else
        output_filename = "Output/MILP_$(instance_name)_$(timestamp).txt"
    end

    start_time = time()

    println("Read data from file: ", fileName)
    first_row, N = read_data(fileName)

    A = []
    fileName_compare = replace(fileName, ".txt" => "")
    fileName_compare = replace(fileName_compare, "Data/Instances_txt/" => "")

    println("Read data from file: ", fileName_compare)
    data = JSON.parsefile("Data/CG_JSON/$(fileName_compare).json")
    for (k, i, B) in data
        push!(A, (k, i, B))
    end

    println("Compute cikB")
    c = compute_cikB(A, N)

    println("Create model")
    x, flow_conservation_constraints, partitioning_constraints, model = create_model(A,c, N)

    output_file = open(output_filename, "w")
    write(output_file, "Instance: $fileName\n")
    elapsed_setup_time = time() - start_time
    write(output_file, "SetUpTime: $(time() - start_time)\n")
    close(output_file)

    configure_gurobi_logging(output_filename, model)

    println("Solve model")

    start_solving_time = time() 
    optimize!(model)
    elapsed_solving_time = time() - start_solving_time

    cg_lb = objective_value(model)
    cg_lb_time = elapsed_solving_time

    #=
    if (!relaxed)
        for element in values(x)
            set_integer(element)
        end
    end
    =#

    # init_cols non-relaxed
    A = init_cols(N,b)
    c = compute_cikB(A, N)
    x, flow_conservation_constraints, partitioning_constraints, model = create_model(A,c, N)

    for element in values(x)
        set_integer(element)
    end

    set_optimizer_attribute(model, "TimeLimit", timeLimit)

    start_solving_time = time() 
    optimize!(model)
    elapsed_solving_time = time() - start_solving_time

    output_file = open(output_filename, "a")


    gap = ((objective_value(model) - cg_lb) / objective_value(model)) 
    write(output_file, "\n=========================\n\nOUTPUT STATISTICS\n")
    write(output_file, "Relaxed: $relaxed\n")
    write(output_file, "Time since start: $(time() - start_time)\n")
    write(output_file, "SetUpTime: $elapsed_setup_time\n")
    write(output_file, "Objective value LB: $cg_lb\n")
    if (!has_values(model))
        write(output_file, "Objective value: 0\n")
    else
        write(output_file, "Objective value UB: $(objective_value(model))\n")
    end
    write(output_file, "Solving time LB: $cg_lb_time\n")
    write(output_file, "Solving time UB: $elapsed_solving_time\n")
    write(output_file, "Gap: $gap\n")

    close(output_file)

end

#solve_Integer_Model("Data/Instances_txt/inst_100_30_4.txt", 200)

