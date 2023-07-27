using DelimitedFiles

# Define the list of text files to process
file_list = [#=
    "Output/IPB_inst_200_10_1_RMP_RUNTIME_300_NCOLOUMNS_1600_GAP_THRESHOLD_0.2_2023-07-18_13-16-12.txt",
    "Output/IPB_inst_200_10_1_RMP_RUNTIME_300_NCOLOUMNS_3200_GAP_THRESHOLD_0.2_2023-07-18_13-16-12.txt",
    "Output/IPB_inst_200_10_1_RMP_RUNTIME_300_NCOLOUMNS_6400_GAP_THRESHOLD_0.2_2023-07-18_13-16-12.txt",
    "Output/MILP_inst_200_10_1_2023-07-18_13-16-12.txt",
    "Output/IPB_inst_200_10_2_RMP_RUNTIME_300_NCOLOUMNS_1600_GAP_THRESHOLD_0.2_2023-07-18_13-16-12.txt",
    "Output/IPB_inst_200_10_2_RMP_RUNTIME_300_NCOLOUMNS_3200_GAP_THRESHOLD_0.2_2023-07-18_13-16-12.txt",
    "Output/IPB_inst_200_10_2_RMP_RUNTIME_300_NCOLOUMNS_6400_GAP_THRESHOLD_0.2_2023-07-18_13-16-12.txt",
    "Output/MILP_inst_200_10_2_2023-07-18_13-16-12.txt",
    "Output/IPB_inst_200_10_3_RMP_RUNTIME_300_NCOLOUMNS_1600_GAP_THRESHOLD_0.2_2023-07-18_13-16-12.txt",
    "Output/IPB_inst_200_10_3_RMP_RUNTIME_300_NCOLOUMNS_3200_GAP_THRESHOLD_0.2_2023-07-18_13-16-12.txt",
    "Output/IPB_inst_200_10_3_RMP_RUNTIME_300_NCOLOUMNS_6400_GAP_THRESHOLD_0.2_2023-07-18_13-16-12.txt",
    "Output/MILP_inst_200_10_3_2023-07-18_13-16-12.txt",
    "Output/IPB_inst_200_10_4_RMP_RUNTIME_300_NCOLOUMNS_1600_GAP_THRESHOLD_0.2_2023-07-18_13-16-12.txt",
    "Output/IPB_inst_200_10_4_RMP_RUNTIME_300_NCOLOUMNS_3200_GAP_THRESHOLD_0.2_2023-07-18_13-16-12.txt",
    "Output/IPB_inst_200_10_4_RMP_RUNTIME_300_NCOLOUMNS_6400_GAP_THRESHOLD_0.2_2023-07-18_13-16-12.txt",
    "Output/MILP_inst_200_10_4_2023-07-18_13-16-12.txt",
    "Output/IPB_inst_200_30_1_RMP_RUNTIME_300_NCOLOUMNS_6400_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_30_1_RMP_RUNTIME_300_NCOLOUMNS_3200_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_30_1_RMP_RUNTIME_300_NCOLOUMNS_1600_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/MILP_inst_200_30_1_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_30_2_RMP_RUNTIME_300_NCOLOUMNS_6400_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_30_2_RMP_RUNTIME_300_NCOLOUMNS_3200_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_30_2_RMP_RUNTIME_300_NCOLOUMNS_1600_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/MILP_inst_200_30_2_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_30_3_RMP_RUNTIME_300_NCOLOUMNS_6400_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_30_3_RMP_RUNTIME_300_NCOLOUMNS_3200_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_30_3_RMP_RUNTIME_300_NCOLOUMNS_1600_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/MILP_inst_200_30_3_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_30_4_RMP_RUNTIME_300_NCOLOUMNS_6400_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_30_4_RMP_RUNTIME_300_NCOLOUMNS_3200_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_30_4_RMP_RUNTIME_300_NCOLOUMNS_1600_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/MILP_inst_200_30_4_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_50_1_RMP_RUNTIME_300_NCOLOUMNS_6400_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_50_1_RMP_RUNTIME_300_NCOLOUMNS_3200_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_50_1_RMP_RUNTIME_300_NCOLOUMNS_1600_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/MILP_inst_200_50_1_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_50_2_RMP_RUNTIME_300_NCOLOUMNS_6400_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_50_2_RMP_RUNTIME_300_NCOLOUMNS_3200_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/IPB_inst_200_50_2_RMP_RUNTIME_300_NCOLOUMNS_1600_GAP_THRESHOLD_0.2_2023-07-19_10-31-00.txt",
    "Output/MILP_inst_200_50_2_2023-07-19_10-31-00.txt"=#
    #"Output/IPB_inst_200_30_4_RMP_RUNTIME_300_NCOLOUMNS_12800_GAP_THRESHOLD_0.2_2023-07-20_10-56-19.txt",
    #"Output/IPB_inst_200_30_4_RMP_RUNTIME_300_NCOLOUMNS_25600_GAP_THRESHOLD_0.2_2023-07-20_10-56-19.txt"
    #"Output/IPB_inst_200_30_4_RMP_RUNTIME_300_NCOLOUMNS_1600_GAP_THRESHOLD_0.2_2023-07-20_13-18-11.txt",
    #"Output/IPB_inst_200_50_2_RMP_RUNTIME_300_NCOLOUMNS_1600_GAP_THRESHOLD_0.2_2023-07-20_14-51-08.txt",
    #"Output/IPB_inst_200_30_4_RMP_RUNTIME_300_NCOLOUMNS_1600_GAP_THRESHOLD_0.2_2023-07-20_13-18-11.txt",
    #"Output/IPB_inst_200_50_2_RMP_RUNTIME_300_NCOLOUMNS_12800_GAP_THRESHOLD_0.2_2023-07-20_16-37-43.txt",
    #"Output/IPB_inst_200_50_2_RMP_RUNTIME_300_NCOLOUMNS_6400_GAP_THRESHOLD_0.2_2023-07-20_16-37-43.txt",
    #"Output/IPB_inst_200_50_2_RMP_RUNTIME_300_NCOLOUMNS_3200_GAP_THRESHOLD_0.2_2023-07-20_14-51-08.txt",
    #"Output/IPB_inst_200_50_2_RMP_RUNTIME_300_NCOLOUMNS_1600_GAP_THRESHOLD_0.2_2023-07-20_14-51-08.txt",
    #"Output/IPB_inst_200_50_4_RMP_RUNTIME_300_NCOLOUMNS_12800_GAP_THRESHOLD_0.2_2023-07-21_10-19-22.txt",
    #"Output/IPB_inst_200_50_4_RMP_RUNTIME_300_NCOLOUMNS_6400_GAP_THRESHOLD_0.2_2023-07-21_10-19-22.txt",
    #"Output/MILP_inst_200_50_4_2023-07-21_15-29-12.txt",
    #"Output/IPB_inst_200_50_4_RMP_RUNTIME_300_NCOLOUMNS_6400_GAP_THRESHOLD_0.2_2023-07-21_19-07-59.txt",
    #"Output/IPB_inst_200_50_4_RMP_RUNTIME_300_NCOLOUMNS_12800_GAP_THRESHOLD_0.2_2023-07-21_19-07-59.txt",
    #"Output/IPB_inst_200_50_4_RMP_RUNTIME_300_NCOLOUMNS_200_GAP_THRESHOLD_0.2_2023-07-21_22-07-44.txt", 
    #"Output/IPB_inst_200_50_4_RMP_RUNTIME_300_NCOLOUMNS_200_GAP_THRESHOLD_0.2_2023-07-21_23-09-50.txt" ,
    #"Output/IPB_inst_200_50_4_RMP_RUNTIME_300_NCOLOUMNS_200_GAP_THRESHOLD_0.2_2023-07-22_00-22-23.txt" ,
    #"Output/IPB_inst_200_50_4_RMP_RUNTIME_300_NCOLOUMNS_200_GAP_THRESHOLD_0.2_2023-07-22_01-24-15.txt" ,
    #"Output/IPB_inst_200_50_4_RMP_RUNTIME_300_NCOLOUMNS_200_GAP_THRESHOLD_0.2_2023-07-22_02-36-53.txt" ,
    #"Output/IPB_inst_200_50_4_RMP_RUNTIME_300_NCOLOUMNS_200_GAP_THRESHOLD_0.2_2023-07-22_03-40-34.txt".

    "Output/IPB_inst_200_10_4_RMP_RUNTIME_300_NCOLOUMNS_100_GAP_THRESHOLD_0.2_2023-07-22_13-15-03.txt",
    "Output/IPB_inst_200_10_4_RMP_RUNTIME_420_NCOLOUMNS_100_GAP_THRESHOLD_0.2_2023-07-22_14-19-15.txt",
    "Output/IPB_inst_200_10_4_RMP_RUNTIME_300_NCOLOUMNS_100_GAP_THRESHOLD_0.2_2023-07-22_15-32-23.txt",
    "Output/IPB_inst_200_10_4_RMP_RUNTIME_420_NCOLOUMNS_100_GAP_THRESHOLD_0.2_2023-07-22_16-31-47.txt",
    "Output/IPB_inst_200_10_4_RMP_RUNTIME_300_NCOLOUMNS_200_GAP_THRESHOLD_0.2_2023-07-22_17-33-43.txt",
    "Output/IPB_inst_200_10_4_RMP_RUNTIME_420_NCOLOUMNS_200_GAP_THRESHOLD_0.2_2023-07-22_18-41-28.txt",
    "Output/IPB_inst_200_10_4_RMP_RUNTIME_300_NCOLOUMNS_200_GAP_THRESHOLD_0.2_2023-07-22_19-41-00.txt",
    "Output/IPB_inst_200_10_4_RMP_RUNTIME_420_NCOLOUMNS_200_GAP_THRESHOLD_0.2_2023-07-22_20-40-35.txt",
    "Output/IPB_inst_200_10_4_RMP_RUNTIME_300_NCOLOUMNS_400_GAP_THRESHOLD_0.2_2023-07-22_21-48-41.txt",
    "Output/IPB_inst_200_10_4_RMP_RUNTIME_420_NCOLOUMNS_400_GAP_THRESHOLD_0.2_2023-07-22_22-52-11.txt",
    "Output/IPB_inst_200_10_4_RMP_RUNTIME_300_NCOLOUMNS_400_GAP_THRESHOLD_0.2_2023-07-22_23-54-23.txt",
    "Output/IPB_inst_200_10_4_RMP_RUNTIME_420_NCOLOUMNS_400_GAP_THRESHOLD_0.2_2023-07-23_00-54-20.txt",
    "Output/IPB_inst_200_50_4_RMP_RUNTIME_300_NCOLOUMNS_100_GAP_THRESHOLD_0.2_2023-07-23_02-00-10.txt",
    "Output/IPB_inst_200_50_4_RMP_RUNTIME_420_NCOLOUMNS_100_GAP_THRESHOLD_0.2_2023-07-23_03-11-16.txt",
    "Output/IPB_inst_200_50_4_RMP_RUNTIME_300_NCOLOUMNS_100_GAP_THRESHOLD_0.2_2023-07-23_04-21-57.txt",
    "Output/IPB_inst_200_50_4_RMP_RUNTIME_420_NCOLOUMNS_100_GAP_THRESHOLD_0.2_2023-07-23_05-32-43.txt",
    "Output/IPB_inst_200_50_4_RMP_RUNTIME_300_NCOLOUMNS_200_GAP_THRESHOLD_0.2_2023-07-23_06-43-30.txt",
    "Output/IPB_inst_200_50_4_RMP_RUNTIME_420_NCOLOUMNS_200_GAP_THRESHOLD_0.2_2023-07-23_07-46-38.txt",
    "Output/IPB_inst_200_50_4_RMP_RUNTIME_300_NCOLOUMNS_200_GAP_THRESHOLD_0.2_2023-07-23_08-49-49.txt",
    "Output/IPB_inst_200_50_4_RMP_RUNTIME_420_NCOLOUMNS_200_GAP_THRESHOLD_0.2_2023-07-23_10-01-42.txt",
    "Output/IPB_inst_200_50_4_RMP_RUNTIME_300_NCOLOUMNS_400_GAP_THRESHOLD_0.2_2023-07-23_11-10-42.txt",
    "Output/IPB_inst_200_50_4_RMP_RUNTIME_420_NCOLOUMNS_400_GAP_THRESHOLD_0.2_2023-07-23_12-12-50.txt",
    "Output/IPB_inst_200_50_4_RMP_RUNTIME_300_NCOLOUMNS_400_GAP_THRESHOLD_0.2_2023-07-23_13-24-04.txt",
    "Output/IPB_inst_200_50_4_RMP_RUNTIME_420_NCOLOUMNS_400_GAP_THRESHOLD_0.2_2023-07-23_14-27-57.txt"






]

aggregated_data = Dict{String, Any}()

# Iterate over the files
for file_name in file_list
    # Read the lines from the file
    lines = readlines(file_name)

    # Extract the required information from the lines
    instance = ""
    time_passed = ""
    init_cols = ""
    batch_pool_columns = ""
    set_up_time_first_rmp = ""
    columns_ipb_start_solution = ""
    max_columns_in_solution = ""
    min_columns_in_solution = ""
    max_columns_in_model = ""
    ipb_iterations = ""
    cg_iterations = ""
    new_best_solution = ""
    early_cg_breaks = ""
    columns_ipb_final_solution = ""
    best_integer_solution = ""
    lb_rmp_current_best = ""
    gap_lb_ub = ""
    total_time_pricing = ""
    average_time_pricing = ""
    average_time_cg = ""
    total_time_cg = ""
    total_time_integer_solution = ""
    average_time_integer_solution = ""
    rmp_runtime = ""
    gap_threshold = ""
    ncoloumns = ""

    for line in lines
        if contains(line, "Instance:")
            instance = split(line, ":")[2]
        elseif contains(line, "TotalTimePassed:")
            time_passed = split(line, ":")[2]
        elseif contains(line, "InitCols:")
            init_cols = split(line, ":")[2]
        elseif contains(line, "BatchPoolColumns:")
            batch_pool_columns = split(line, ":")[2]
        elseif contains(line, "SetUpTimeFirstRMP:")
            set_up_time_first_rmp = split(line, ":")[2]
        elseif contains(line, "ColumnsIPBStartSolution:")
            columns_ipb_start_solution = split(line, ":")[2]
        elseif contains(line, "MaxColumnsInSolution:")
            max_columns_in_solution = split(line, ":")[2]
        elseif contains(line, "MinColumnsInSolution:")
            min_columns_in_solution = split(line, ":")[2]
        elseif contains(line, "MaxColumnsInModel:")
            max_columns_in_model = split(line, ":")[2]
        elseif contains(line, "IPBIterations:")
            ipb_iterations = split(line, ":")[2]
        elseif contains(line, "CGIterations:")
            cg_iterations = split(line, ":")[2]
        elseif contains(line, "NewBestSolution:")
            new_best_solution = split(line, ":")[2]
        elseif contains(line, "EarlyCGBreaks:")
            early_cg_breaks = split(line, ":")[2]
        elseif contains(line, "ColumnsIPBFinalSolution:")
            columns_ipb_final_solution = split(line, ":")[2]
        elseif contains(line, "BestIntegerSolution:")
            best_integer_solution = split(line, ":")[2]
        elseif contains(line, "LB_RMP_CURRENTBEST:")
            lb_rmp_current_best = split(line, ":")[2]
        elseif contains(line, "GapLBUB:")
            gap_lb_ub = split(line, ":")[2]
        elseif contains(line, "TotalTimePricing:")
            total_time_pricing = split(line, ":")[2]
        elseif contains(line, "AverageTimePricing:")
            average_time_pricing = split(line, ":")[2]
        elseif contains(line, "AverageTimeCG:")
            average_time_cg = split(line, ":")[2]
        elseif contains(line, "TotalTimeCG:")
            total_time_cg = split(line, ":")[2]
        elseif contains(line, "TotalTimeIntegerSolution:")
            total_time_integer_solution = split(line, ":")[2]
        elseif contains(line, "AverageTimeIntegerSolution:")
            average_time_integer_solution = split(line, ":")[2]
        elseif contains(line, "RMP_RUNTIME:")
            rmp_runtime = split(line, ":")[2]
        elseif contains(line, "GAP_THRESHOLD:")
            gap_threshold = split(line, ":")[2]
        elseif contains(line, "NCOLOUMNS:")
            ncoloumns = split(line, ":")[2]
        end
    end

    # Store the extracted information in the aggregated data dictionary
    aggregated_data[file_name] = Dict(
        "Instance" => instance,
        "TotalTimePassed" => time_passed,
        "InitCols" => init_cols,
        "BatchPoolColumns" => batch_pool_columns,
        "SetUpTimeFirstRMP" => set_up_time_first_rmp,
        "ColumnsIPBStartSolution" => columns_ipb_start_solution,
        "MaxColumnsInSolution" => max_columns_in_solution,
        "MinColumnsInSolution" => min_columns_in_solution,
        "MaxColumnsInModel" => max_columns_in_model,
        "IPBIterations" => ipb_iterations,
        "CGIterations" => cg_iterations,
        "NewBestSolution" => new_best_solution,
        "EarlyCGBreaks" => early_cg_breaks,
        "ColumnsIPBFinalSolution" => columns_ipb_final_solution,
        "BestIntegerSolution" => best_integer_solution,
        "LB_RMP_CURRENTBEST" => lb_rmp_current_best,
        "GapLBUB" => gap_lb_ub,
        "TotalTimePricing" => total_time_pricing,
        "AverageTimePricing" => average_time_pricing,
        "AverageTimeCG" => average_time_cg,
        "TotalTimeCG" => total_time_cg,
        "TotalTimeIntegerSolution" => total_time_integer_solution,
        "AverageTimeIntegerSolution" => average_time_integer_solution,
        "RMP_RUNTIME" => rmp_runtime,
        "GAP_THRESHOLD" => gap_threshold,
        "NCOLOUMNS" => ncoloumns
    )
end
# Define the output filename for the CSV file
output_filename = "output_table.csv"

# Open the output file
output_file = open(output_filename, "w")

# Write the CSV header
header = "File,Instance,NColoumns,Gap Threshold,RMP Runtime,Time Passed,Init Cols,Batch Pool Cols,SetUp Time First RMP,Columns IPB Start Solution,Max Columns in Solution,Min Columns in Solution,Max Columns in Model,IPB Iterations,CG Iterations,New Best Solution,Early CG Breaks,Columns IPB Final Solution,Best Integer Solution,LB RMP CURRENTBEST,Gap LBUB,Total Time Pricing,Avg Time Pricing,Avg Time CG,Total Time CG,Total Time Integer Solution,Avg Time Integer Solution"
write(output_file, header * "\n")

# Write the table rows
for (file_name, data) in aggregated_data
    row = "$file_name,"
    row *= "$(data["Instance"]),"
    row *= "$(data["NCOLOUMNS"]),"
    row *= "$(data["GAP_THRESHOLD"]),"
    row *= "$(data["RMP_RUNTIME"]),"
    row *= "$(data["TotalTimePassed"]),"
    row *= "$(data["InitCols"]),"
    row *= "$(data["BatchPoolColumns"]),"
    row *= "$(data["SetUpTimeFirstRMP"]),"
    row *= "$(data["ColumnsIPBStartSolution"]),"
    row *= "$(data["MaxColumnsInSolution"]),"
    row *= "$(data["MinColumnsInSolution"]),"
    row *= "$(data["MaxColumnsInModel"]),"
    row *= "$(data["IPBIterations"]),"
    row *= "$(data["CGIterations"]),"
    row *= "$(data["NewBestSolution"]),"
    row *= "$(data["EarlyCGBreaks"]),"
    row *= "$(data["ColumnsIPBFinalSolution"]),"
    row *= "$(data["BestIntegerSolution"]),"
    row *= "$(data["LB_RMP_CURRENTBEST"]),"
    row *= "$(data["GapLBUB"]),"
    row *= "$(data["TotalTimePricing"]),"
    row *= "$(data["AverageTimePricing"]),"
    row *= "$(data["AverageTimeCG"]),"
    row *= "$(data["TotalTimeCG"]),"
    row *= "$(data["TotalTimeIntegerSolution"]),"
    row *= "$(data["AverageTimeIntegerSolution"])"
    write(output_file, row * "\n")
end

# Close the output file
close(output_file)