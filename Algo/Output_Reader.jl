log_file_path = "Output/try_inst_200_10_4.txt_IPB_2023-07-06_13-24-43.txt"
log_output = read(log_file_path, String)

extracted_info = []


lines = split(log_output, "\n")


for line in lines
     # Extract the solution value
    if contains(line, "New best integer solution:")
        value = parse(Float64, split(line, ":")[2])
        push!(extracted_info, value)
    # Extract the column amount
    elseif contains(line, "Amount columns in solution:")
        amount = parse(Float64, split(line, ":")[2])
        push!(extracted_info, amount)
    elseif contains(line, "Time elapsed:")
        time = parse(Float64, split(line, ":")[2])
        push!(extracted_info, time)
    end
end

# Print the extracted information
println(extracted_info)
