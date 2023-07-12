using Plots
using Printf

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

function extract_MILP_information(output_file::String)
    log_output = read(output_file, String)
    rows = filter(row -> startswith(row, "H"), split(log_output, "\n"))

    Incumbent = []
    column_last = []
    for row in rows
        columns = split(row)
        if !isempty(columns) && columns[1] == "H"
            push!(Incumbent, columns[4])
            push!(column_last, columns[end])
        end
    end

    column_last = replace.(column_last, r"s$" => "")
    column_last = parse.(Float64, column_last)
    Incumbent = parse.(Float64, Incumbent)

    return Incumbent, column_last
end


function convert_to_float(array::Vector{String})
    return parse.(Float64, array)
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
    converted_arrays = [extracted_info[pattern] for pattern in patterns]
    #converted_arrays = [replace.(convert_to_float(array), r"[^0-9.]" => "") for array in extracted_arrays]
    
    converted_arrays = [parse.(Float64, array) for array in converted_arrays]
    
    return converted_arrays
end



IPB_log_file_path = "Output/IPB_inst_100_10_4.txt_RMP_RUNTIME_30_NCOLOUMNS_200_GAP_THRESHOLD_0.1_2023-07-12_11-25-35.txt"
IPB_new_integer_solutions, IPB_total_time_passed = extract_info_from_log(IPB_log_file_path, ["New best integer solution:", "Total time passed for best solution:"])

MILP_log_file_path = "Output/MILP_inst_100_10_4.txt_2023-07-12_11-44-18.txt"
MILP_new_integer_solutions, MILP_total_time_passed =  extract_MILP_information(MILP_log_file_path)

default(fontfamily = "Times New Roman")

plot(IPB_total_time_passed, IPB_new_integer_solutions,
     xlabel = "Total Time Passed",
     ylabel = "New Integer Solutions",
     title = "Integer Solutions over Time",
     legend = true,
     label="IPB",
     xaxis = (formatter = x -> @sprintf("%.0f", x)),
     yaxis = (formatter = y -> @sprintf("%.0f", y))
)

plot!(MILP_total_time_passed, MILP_new_integer_solutions,
      label="MILP"
)









