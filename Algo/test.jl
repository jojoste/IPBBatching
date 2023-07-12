include("IPB_Batching.jl")


fileName = "Data/Instances_txt/inst_100_10_4.txt"

println("Read data from file: ", fileName)
first_row, N = read_data(fileName)

A =  []       
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

parts = split(fileName, "/")
instance_name = parts[end]
output_filename = "Output/MILP_$(instance_name)_$(timestamp).txt"
configure_gurobi_logging(output_filename, model)

println("Solve model")
for element in values(x)
    set_integer(element) 
end

optimize!(model)
