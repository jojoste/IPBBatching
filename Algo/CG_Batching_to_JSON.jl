using CSV
using Dates
using DelimitedFiles
using Glob
using Gurobi
using JSON
using JuMP
using Plots

include("CG_Batching.jl")



function generate_JSON()

    x = missing
    
    # Read the data in the directory
    directoryInstances = "Data/Instances_txt/"
    filenamesInstances = glob("*.txt", directoryInstances)
    filenamesInstances = [replace(filename, ".txt" => "") for filename in filenamesInstances]
    filenamesInstances = [replace(filename, "Data/Instances_txt/" => "") for filename in filenamesInstances]

    directoryJSON = "Data/CG_JSON/"
    filenamesJSON = glob("*.json", directoryJSON)
    filenamesJSON = [replace(filename, ".json" => "") for filename in filenamesJSON]
    filenamesJSON = [replace(filename, "Data/CG_JSON/" => "") for filename in filenamesJSON]

    for fileNameInstance in filenamesInstances

        # Check if the instance has already been solved and written to JSON
        if(fileNameInstance in filenamesJSON)
            println("Instance ", fileNameInstance, " has already been solved and written to JSON")
            continue
        end
        # 
        first_row, N = read_data(directoryInstances * fileNameInstance*".txt")
        fileNameInstance = replace(fileNameInstance, ".txt" => "")
        n, b = first_row[1], first_row[2]
        println("n = ", n, " b = ", b)
        CG_LB, CG_UB, CG_LB_array, x, c = price_and_branch(N, b, false)
        keysX = collect(keys(x))

        outputFileName = joinpath(directoryJSON, basename(fileNameInstance) * ".json")

        lengthx = length(keysX)

        println("Writing $lengthx generated columns to $outputFileName")

        open(outputFileName, "w") do file
            JSON.print(file, keysX)
        end
    end
end

generate_JSON()






