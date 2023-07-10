using PyPlot
import Pkg; Pkg.add("PyPlot")
log_file_path = "Output/try_inst_200_10_4.txt_IPB_2023-07-10_13-57-10.txt"

function plot_MILP_IPB(MILP_UB_array, IPB_UB_array, Timelimit)
    arr1 = [(value, time) for (value, time) in MILP_UB_array if time < Timelimit]
    arr2 = [(value, time) for (value, time) in IPB_UB_array if time < Timelimit]

    y1 = [point[1] for point in arr1]
    x1 = [point[2] for point in arr1]
    y2 = [point[1] for point in arr2]
    x2 = [point[2] for point in arr2]

    # Format y-axis values without scientific notation
    y1_formatted = y1#[string(format(point, ",.3f")) for point in y1]
    y2_formatted = y2#[string(format(point, ",.3f")) for point in y2]

    plot(x1, y1_formatted, label="MILP", linewidth=2, xlabel="seconds", ylabel="objective value")
    plot!(x2, y2_formatted, label="IPB", linewidth=2)
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



function extract_info_from_log(log_file_path::String, patterns::Array{String, 1})
    log_output = read(log_file_path, String)
    extracted_info = Dict{String, Array{String, 1}}()
    lines = split(log_output, "\n")
    for line in lines
        for pattern in patterns
            if contains(line, pattern)
                value = split(line, ":")[2]
                if !(pattern in keys(extracted_info))
                    extracted_info[pattern] = [value]
                else
                    push!(extracted_info[pattern], value)
                end
            end
        end
    end
    return extracted_info
end

solution_dictionary = extract_info_from_log(log_file_path, ["New integer solution", "Total time passed"])


new_integer_solutions = solution_dictionary["New integer solution"]
total_time_passed = solution_dictionary["Total time passed"]


total_time_passed = [replace(time, " seconds" => "") for time in total_time_passed]


new_integer_solutions

total_time_passed


function convert_to_float(array::Vector{String})
    return parse.(Float64, array)
end
new_integer_solutions = convert_to_float(new_integer_solutions)
total_time_passed = convert_to_float(total_time_passed)



(total_time_passed, new_integer_solutions, marker = :circle, legend = false, xlabel = "seconds", ylabel = "objective value", title = "IPB")


plot(total_time_passed, new_integer_solutions,
     xlabel = "Total Time Passed",
     ylabel = "New Integer Solutions",
     title = "Integer Solutions over Time",
     legend = false)

ax = gca()
ax.ticklabel_format(useMathText=false)


plot_data(total_time_passed, new_integer_solutions)



#=
#IPB("Data/inst_200_50_3.txt", 20)

plot_CG_LB(CG_AMOUNT_array) 


plot_comparison_CG(CG_AMOUNT_array, CG_LB_array)

plot_CG_LB(IPB_UB_array)


plot_CG_LB(MILP_UB_array)

MILP_UB_array




plot_MILP_IPB(MILP_UB_array, IPB_UB_array, 30)

=#
