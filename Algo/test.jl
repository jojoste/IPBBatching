include("Integer_Solver.jl")
include("IPB_Batching.jl")


#function IPB(fileName::String, no_CG::Bool, RMP_RUNTIME, GAP_THRESHOLD, NCOLOUMNS, IPB_RUNTIME, CG_MAX_ITERATION, PRICING_PER_NODE, PRICING_PER_NODE_COLUMNS)#

# read all files in "Data/Instances_txt" and save them in file_names
file_names = glob("*.txt", "Data/Instances_txt")




NCOLUMNS_values = [1500000]

GAP_RMP = [0.01]

ITERATIONS_RMP = [10]

RUNTIMES_RMP = [14400]

START_SOLUTION = [4]

TOTAL_RUNTIME = 14400

for file_name in file_names
    solve_Integer_Model(fileName, 14400)
    for ncolumns in NCOLUMNS_values
        for runtime_rmp in RUNTIMES_RMP
            for iteration_rmp in ITERATIONS_RMP
                for start_solution in START_SOLUTION
                    for gap_rmp in GAP_RMP
                        IPB(file_name, true, runtime_rmp, gap_rmp, ncolumns, TOTAL_RUNTIME, iteration_rmp, false, 0, start_solution)
                    end
                end
            end
        end
    end
end



