include("Integer_Solver.jl")
include("IPB_Batching.jl")

#solve_Integer_Model("Data/Instances_txt/inst_100_50_4.txt", 700)


#function IPB(fileName::String, no_CG::Bool, RMP_RUNTIME, GAP_THRESHOLD, NCOLOUMNS, IPB_RUNTIME, CG_MAX_ITERATION, PRICING_PER_NODE, PRICING_PER_NODE_COLUMNS)#


#IPB("Data/Instances_txt/inst_100_50_4.txt", true, 300 , 0.2, 1600, 700, 10, false, 0)
#IPB("Data/Instances_txt/inst_100_50_4.txt", true, 300 , 0.2, 3200, 700, 10, false, 0)
#IPB("Data/Instances_txt/inst_100_50_4.txt", true, 300 , 0.2, 6400, 700, 10, false, 0)
#IPB("Data/Instances_txt/inst_100_50_4.txt", true, 300 , 0.2, 12800, 700, 10, false, 0)


file_names = [
    #"Data/Instances_txt/inst_200_10_1.txt",
    #"Data/Instances_txt/inst_200_10_2.txt",
    #"Data/Instances_txt/inst_200_10_3.txt",
    #"Data/Instances_txt/inst_200_10_4.txt",
    #"Data/Instances_txt/inst_200_30_1.txt",
    #"Data/Instances_txt/inst_200_30_2.txt",
    #"Data/Instances_txt/inst_200_30_3.txt",
    #"Data/Instances_txt/inst_200_30_4.txt",
    #"Data/Instances_txt/inst_200_50_1.txt",
    #"Data/Instances_txt/inst_200_50_2.txt",
    #"Data/Instances_txt/inst_200_50_3.txt",
    #"Data/Instances_txt/inst_200_50_4.txt"
    #"Data/Instances_txt/inst_200_50_4.txt"
]

NCOLUMNS_values = [100, 200, 400]

ITERATIONS_RMP = [20, 30]

RUNTIMES_RMP = [300, 420]

for file_name in file_names
    for NCOLUMNS in NCOLUMNS_values
        for ITERATION_RMP in ITERATIONS_RMP
            for RUNTIME_RMP in RUNTIMES_RMP
                IPB(file_name, true, RUNTIME_RMP, 0.2, NCOLUMNS, 3500, ITERATION_RMP, false, 0)
            end
        end
    end
    #solve_Integer_Model(file_name, 2700)
end



#IPB("Data/Instances_txt/inst_40_50_3.txt", true, 10, 0.05, 300, 60, 10, false, 0)

#solve_Integer_Model("Data/Instances_txt/inst_40_50_3.txt")