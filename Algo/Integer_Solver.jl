include("IPB_Batching.jl")


function solve_Integer_Model(fileName, timeLimit=3000)
    
    parts = split(fileName, "/")
    instance_name = parts[end]
    instance_name = replace(instance_name, ".txt" => "")
    output_filename = "Output/MILP_$(instance_name)_$(timestamp).txt"

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
    for element in values(x)
        set_integer(element) 
    end

    set_optimizer_attribute(model, "TimeLimit", timeLimit)

    optimize!(model)

    output_file = open(output_filename, "a")

    write(output_file, "\n=========================\n\nOUTPUT STATISTICS\n")
    write(output_file, "Time since start: $(time() - start_time)\n")
    write(output_file, "SetUpTime: $elapsed_setup_time\n")
    write(output_file, "Objective value: $(objective_value(model))\n")
    write(output_file, "Gap: $(relative_gap(model))\n")
    write(output_file, "Number of variables: $(num_variables(model))\n")
    write(output_file, "MIP relative gap: $(relative_gap(model))\n")

    close(output_file)

end

solve_Integer_Model("Data/Instances_txt/inst_100_30_4.txt", 200)

