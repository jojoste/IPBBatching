using Plots
using Printf
using DelimitedFiles
using Formatting
using LaTeXStrings

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
        if !isempty(columns) && (columns[1] == "H" || columns[1] == "*")
            push!(Incumbent, columns[4])
            push!(column_last, columns[end])
        end
    end

    column_last = replace.(column_last, r"s$" => "")
    column_last = parse.(Float64, column_last)
    Incumbent = parse.(Float64, Incumbent)

    return Incumbent, column_last
end



bestbd_input = "122377.19	-	-	13s
122377.19	-	-	14s
122377.19	-	-	14s
122377.233	-	-	15s
122377.393	-	-	15s
122377.639	-	-	15s
122377.855	-	-	16s
122378.178	-	-	16s
122378.596	-	-	16s
122378.958	-	-	16s
122379.233	-	-	17s
122804.858	-	-	50s
122805.56	-	-	51s
122806.398	-	-	51s
122807.372	-	-	52s
122815.685	-	-	53s
122816.869	-	-	54s
122818.158	-	-	55s
122819.569	-	-	55s
122820.863	-	-	56s
122821.902	-	-	57s
122822.762	-	-	58s
123029.543	-	-	87s
123030.065	-	-	87s
123030.907	-	-	87s
123031.915	-	-	88s
123034.986	-	-	89s
123044.189	-	-	92s
123044.202	-	-	92s
123044.276	-	-	92s
123047.573	-	-	94s
123048.289	-	-	95s
123291.391	-	-	124s
123388.576	-	-	142s
123418.949	-	-	149s
123424.793	-	-	154s
123425.104	-	-	155s
123528.156	-	-	178s
123592.898	-	-	208s
123613.04	-	-	218s
123613.04	-	-	218s
123613.148	-	-	219s
123613.272	-	-	219s
123613.349	-	-	220s
123613.428	-	-	220s
123613.523	-	-	220s
123613.638	-	-	221s
123613.744	-	-	221s
123613.801	-	-	222s
123613.833	-	-	222s
123616.161	-	-	226s
123616.179	-	-	226s
123616.185	-	-	226s
123616.191	-	-	226s
123616.209	-	-	226s
123616.209	-	-	227s
123616.226	-	-	227s
123616.232	-	-	227s
123616.243	-	-	227s
123675.535	-	-	243s
123694.235	-	-	257s
123699.148	-	-	265s
123699.729	-	-	267s
123744.565	-	-	288s
123744.565	-	-	288s
123744.587	-	-	288s
123744.587	-	-	289s
123744.615	-	-	289s
123744.623	-	-	290s
123744.629	-	-	290s
123744.64	-	-	290s
123744.642	-	-	290s
123744.645	-	-	291s
123750.689	-	-	298s
123750.694	-	-	298s
123764.124	-	-	310s
123764.593	-	-	331s
123778.788	-	-	344s
123778.802	-	-	344s
123778.808	-	-	344s
123778.811	-	-	345s
123778.811	-	-	345s
123780.127	-	-	349s
123786.466	-	-	356s
123786.466	-	-	359s
123786.466	-	-	651s
123786.466	-	4489	687s
123795.143	-	2179	718s
123814.555	-	1958	754s
123814.555	-	2189	823s
123823.886	-	2762	864s
123823.886	-	2624	892s
123838.094	-	2375	910s
123838.094	-	2179	959s
123846.214	-	2240	1029s
123846.214	-	2270	1065s
123852.672	-	2166	1106s
123852.672	-	2102	1151s
123852.672	-	2008	1188s
123852.672	-	1891	1232s
123852.672	-	1871	1282s
123852.672	-	1827	1317s
123852.672	-	1840	1379s
123852.672	-	1798	1424s
123852.672	-	1777	1472s
123852.672	-	1782	1501s
123852.672	-	1722	1544s
123852.672	-	1690	1605s
123852.672	-	1727	1649s
123852.672	-	1700	1696s
123852.672	-	1692	1753s
123852.672	-	1690	1806s
123852.672	-	1694	1859s
123852.672	-	1691	1913s
123852.672	-	1693	1971s
123852.672	-	1708	2026s
123852.672	-	1683	2078s
123852.672	-	1621	2130s
123852.672	-	1498	2180s
123852.672	-	1406	2230s
123852.672	-	1319	2279s
123852.672	-	1227	2334s
123852.672	-	1173	2392s
123852.672	-	1128	2445s
123852.672	-	1086	2501s
123852.672	-	1022	2557s
123852.672	-	965	2611s
123852.672	-	905	2664s
123852.672	-	840	2720s
123852.672	-	808	2777s
123852.672	-	774	2836s
123852.672	-	714	2897s
123852.672	-	666	2959s
123852.672	-	625	3023s
123852.672	-	594	3086s
123852.672	-	568	3151s
123852.672	-	549	3213s
123852.672	-	506	3275s
123852.672	-	474	3335s
123852.672	-	439	3398s
123852.672	-	410	3474s
123852.672	7.50%	404	3474s
123852.672	7.11%	397	4109s
123852.672	7.11%	396	4110s
123852.672	6.23%	397	4110s
123852.672	6.23%	397	4194s
123852.672	5.64%	393	4194s
123860.396	5.64%	389	4280s
123860.396	5.62%	397	4374s
123860.396	5.58%	399	4374s
123860.396	5.40%	402	4374s
123860.396	5.40%	405	4986s
123860.396	5.37%	405	5021s
123860.396	5.32%	405	5038s
123860.396	5.32%	405	5107s
123860.396	5.32%	405	5122s
123860.396	5.32%	404	5126s
123860.396	5.32%	404	5145s
123860.396	5.31%	404	5167s
123860.396	5.29%	404	5168s
123860.396	5.29%	404	5172s
123860.396	5.29%	404	5201s
123860.396	5.29%	403	5221s
123860.396	5.29%	403	5234s
123860.396	5.29%	403	5255s
123860.396	5.29%	403	5278s
123860.396	5.18%	403	5295s
123860.396	5.18%	402	5327s
123860.396	5.18%	402	5347s
123860.396	5.18%	402	5356s
123860.396	5.18%	402	5380s
123860.396	5.18%	401	5444s
123860.396	5.12%	401	5463s
123860.396	5.12%	401	5472s
123860.396	5.12%	401	5479s
123860.396	5.12%	401	5492s
123860.396	5.03%	401	5505s
123860.396	5.03%	400	5545s
123860.396	5.03%	400	5560s
123860.396	5.03%	400	5567s
123860.396	5.03%	400	5576s
123860.396	5.03%	400	5589s
123860.396	5.03%	399	5626s
123860.396	5.03%	399	5634s
123860.396	5.03%	399	5639s
123860.396	5.03%	399	5643s
123860.396	4.98%	399	5658s
123860.396	4.44%	399	5931s
123860.396	4.44%	398	5936s
123860.396	4.44%	398	5950s
123860.396	3.96%	398	6028s
123860.396	3.96%	398	6042s
123860.396	3.96%	398	6061s
123860.396	3.96%	397	6066s
123860.396	3.96%	397	6070s
123860.396	3.96%	397	6086s
123860.396	3.66%	397	6103s
123860.396	3.66%	396	6115s
123860.396	3.66%	396	6130s
123860.396	3.66%	396	6143s
123928.417	3.61%	396	7247s
123928.417	3.56%	461	7252s
123928.417	3.56%	462	7295s
123928.417	3.56%	464	7349s
123928.417	3.56%	470	7417s
123928.417	3.56%	475	7471s
123928.417	3.56%	480	7507s
123928.417	3.56%	488	7581s
123928.417	3.56%	492	7623s
123928.417	3.22%	495	7653s
123928.417	3.22%	499	7693s
123928.417	3.22%	503	7729s
123928.417	3.22%	506	7756s
123928.417	3.22%	510	7787s
123928.417	3.22%	512	7830s
123928.417	3.22%	516	7868s
123928.417	3.22%	520	7919s
123928.417	3.14%	520	7919s
123928.417	3.14%	526	7980s
123928.417	3.14%	533	8026s
123928.417	3.14%	538	8068s
123928.417	3.14%	542	8103s
123928.417	3.13%	544	8149s
123928.417	3.05%	545	8149s
123928.417	3.05%	548	8200s
123928.417	3.05%	553	8244s
123928.417	3.05%	556	8289s
123928.417	2.96%	559	8356s
123928.417	2.96%	562	8396s
123928.417	2.96%	566	8448s
123928.417	2.96%	570	8794s
123928.417	2.96%	571	8900s
123928.417	2.91%	572	8900s
123928.417	2.91%	572	8954s
123928.417	2.91%	576	9010s
123928.417	2.91%	580	9062s
123928.417	2.91%	582	9119s
123928.417	2.91%	584	9167s
123928.417	2.91%	583	9210s
123928.417	2.91%	579	9261s
123928.417	2.91%	575	9323s
123928.417	2.91%	572	9368s
123928.417	2.91%	569	9445s
123928.417	2.91%	574	9502s
123928.417	2.91%	578	9554s
123928.417	2.91%	582	9619s
123928.417	2.91%	586	9687s
123928.417	2.91%	592	9757s
123928.417	2.91%	598	9834s
123928.417	2.91%	604	9917s
123928.417	2.91%	611	10006s
123928.417	2.91%	620	10081s
123928.417	2.91%	626	10160s
123928.417	2.91%	633	10242s
123928.417	2.91%	641	10337s
123928.417	2.91%	649	10426s
123928.417	2.91%	654	10511s
123928.417	2.91%	661	10603s
123928.417	2.91%	670	10710s
123928.417	2.91%	675	10825s
123928.417	2.91%	683	10942s
123928.417	2.91%	693	11053s
123928.417	2.91%	702	11165s
123928.417	2.91%	708	11296s
123928.417	2.91%	711	11427s
123928.417	2.91%	714	11552s
123928.417	2.91%	707	11696s
123928.417	2.91%	713	11839s
123928.417	2.91%	725	12001s
123928.417	2.91%	732	12167s
123928.417	2.91%	738	12325s
123954.448	2.89%	746	12502s
123954.448	2.89%	754	12672s
123954.448	2.89%	763	12857s
123954.448	2.89%	774	13059s
123963.945	2.88%	778	13241s
123963.945	2.86%	778	13241s
123963.945	2.86%	778	13495s
123980.221	2.85%	788	13734s
123980.221	2.85%	801	13944s
123984.177	2.85%	800	14212s
123984.177	2.85%	810	14400s"

# transform bestbd into a vector for each column, save them separetely in arrays, only keep the first and last column
bestbd = split(bestbd_input, "\n")
bestbd = [split(row) for row in bestbd]
bestbd_values = [row[1] for row in bestbd]
bestbd_times = [row[end] for row in bestbd]
#remove "s" from the end of the time values
bestbd_times = replace.(bestbd_times, r"s$" => "")
#convert to float
bestbd_values = parse.(Float64, bestbd_values)
bestbd_times = parse.(Float64, bestbd_times)

incumbent_input = "133890	123852.672	7.50%	404	3474s
133338	123852.672	7.11%	397	4109s
133338	123852.672	7.11%	396	4110s
132078	123852.672	6.23%	397	4110s
132078	123852.672	6.23%	397	4194s
131261	123852.672	5.64%	393	4194s
131261	123860.396	5.64%	389	4280s
131238	123860.396	5.62%	397	4374s
131186	123860.396	5.58%	399	4374s
130935	123860.396	5.40%	402	4374s
130935	123860.396	5.40%	405	4986s
130892	123860.396	5.37%	405	5021s
130826	123860.396	5.32%	405	5038s
130826	123860.396	5.32%	405	5107s
130814	123860.396	5.32%	405	5122s
130814	123860.396	5.32%	404	5126s
130814	123860.396	5.32%	404	5145s
130808	123860.396	5.31%	404	5167s
130781	123860.396	5.29%	404	5168s
130781	123860.396	5.29%	404	5172s
130781	123860.396	5.29%	404	5201s
130781	123860.396	5.29%	403	5221s
130781	123860.396	5.29%	403	5234s
130781	123860.396	5.29%	403	5255s
130781	123860.396	5.29%	403	5278s
130625	123860.396	5.18%	403	5295s
130625	123860.396	5.18%	402	5327s
130625	123860.396	5.18%	402	5347s
130625	123860.396	5.18%	402	5356s
130625	123860.396	5.18%	402	5380s
130625	123860.396	5.18%	401	5444s
130538	123860.396	5.12%	401	5463s
130538	123860.396	5.12%	401	5472s
130538	123860.396	5.12%	401	5479s
130538	123860.396	5.12%	401	5492s
130427	123860.396	5.03%	401	5505s
130427	123860.396	5.03%	400	5545s
130427	123860.396	5.03%	400	5560s
130427	123860.396	5.03%	400	5567s
130427	123860.396	5.03%	400	5576s
130427	123860.396	5.03%	400	5589s
130427	123860.396	5.03%	399	5626s
130427	123860.396	5.03%	399	5634s
130427	123860.396	5.03%	399	5639s
130427	123860.396	5.03%	399	5643s
130347	123860.396	4.98%	399	5658s
129620	123860.396	4.44%	399	5931s
129620	123860.396	4.44%	398	5936s
129620	123860.396	4.44%	398	5950s
128965	123860.396	3.96%	398	6028s
128965	123860.396	3.96%	398	6042s
128965	123860.396	3.96%	398	6061s
128965	123860.396	3.96%	397	6066s
128965	123860.396	3.96%	397	6070s
128965	123860.396	3.96%	397	6086s
128565	123860.396	3.66%	397	6103s
128565	123860.396	3.66%	396	6115s
128565	123860.396	3.66%	396	6130s
128565	123860.396	3.66%	396	6143s
128565	123928.417	3.61%	396	7247s
128500	123928.417	3.56%	461	7252s
128500	123928.417	3.56%	462	7295s
128500	123928.417	3.56%	464	7349s
128500	123928.417	3.56%	470	7417s
128500	123928.417	3.56%	475	7471s
128500	123928.417	3.56%	480	7507s
128500	123928.417	3.56%	488	7581s
128500	123928.417	3.56%	492	7623s
128058	123928.417	3.22%	495	7653s
128058	123928.417	3.22%	499	7693s
128058	123928.417	3.22%	503	7729s
128058	123928.417	3.22%	506	7756s
128058	123928.417	3.22%	510	7787s
128058	123928.417	3.22%	512	7830s
128058	123928.417	3.22%	516	7868s
128052	123928.417	3.22%	520	7919s
127946	123928.417	3.14%	520	7919s
127946	123928.417	3.14%	526	7980s
127946	123928.417	3.14%	533	8026s
127946	123928.417	3.14%	538	8068s
127946	123928.417	3.14%	542	8103s
127931	123928.417	3.13%	544	8149s
127827	123928.417	3.05%	545	8149s
127827	123928.417	3.05%	548	8200s
127827	123928.417	3.05%	553	8244s
127827	123928.417	3.05%	556	8289s
127709	123928.417	2.96%	559	8356s
127709	123928.417	2.96%	562	8396s
127709	123928.417	2.96%	566	8448s
127709	123928.417	2.96%	570	8794s
127707	123928.417	2.96%	571	8900s
127642	123928.417	2.91%	572	8900s
127642	123928.417	2.91%	572	8954s
127642	123928.417	2.91%	576	9010s
127642	123928.417	2.91%	580	9062s
127642	123928.417	2.91%	582	9119s
127642	123928.417	2.91%	584	9167s
127642	123928.417	2.91%	583	9210s
127642	123928.417	2.91%	579	9261s
127642	123928.417	2.91%	575	9323s
127642	123928.417	2.91%	572	9368s
127642	123928.417	2.91%	569	9445s
127642	123928.417	2.91%	574	9502s
127642	123928.417	2.91%	578	9554s
127642	123928.417	2.91%	582	9619s
127642	123928.417	2.91%	586	9687s
127642	123928.417	2.91%	592	9757s
127642	123928.417	2.91%	598	9834s
127642	123928.417	2.91%	604	9917s
127642	123928.417	2.91%	611	10006s
127642	123928.417	2.91%	620	10081s
127642	123928.417	2.91%	626	10160s
127642	123928.417	2.91%	633	10242s
127642	123928.417	2.91%	641	10337s
127642	123928.417	2.91%	649	10426s
127642	123928.417	2.91%	654	10511s
127642	123928.417	2.91%	661	10603s
127642	123928.417	2.91%	670	10710s
127642	123928.417	2.91%	675	10825s
127642	123928.417	2.91%	683	10942s
127642	123928.417	2.91%	693	11053s
127642	123928.417	2.91%	702	11165s
127642	123928.417	2.91%	708	11296s
127642	123928.417	2.91%	711	11427s
127642	123928.417	2.91%	714	11552s
127642	123928.417	2.91%	707	11696s
127642	123928.417	2.91%	713	11839s
127642	123928.417	2.91%	725	12001s
127642	123928.417	2.91%	732	12167s
127642	123928.417	2.91%	738	12325s
127642	123954.448	2.89%	746	12502s
127638	123954.448	2.89%	754	12672s
127638	123954.448	2.89%	763	12857s
127638	123954.448	2.89%	774	13059s
127638	123963.945	2.88%	778	13241s
127619	123963.945	2.86%	778	13241s
127619	123963.945	2.86%	778	13495s
127619	123980.221	2.85%	788	13734s
127619	123980.221	2.85%	801	13944s
127619	123984.177	2.85%	800	14212s
127619	123984.177	2.85%	810	14400s"

# transform incumbent into a vector for each column, save them separetely in arrays, only keep the first and last column
incumbent = split(incumbent_input, "\n")
incumbent = [split(row) for row in incumbent]
incumbent_values = [row[1] for row in incumbent]
incumbent_times = [row[end] for row in incumbent]
#remove "s" from the end of the time values
incumbent_times = replace.(incumbent_times, r"s$" => "")
#convert to float
incumbent_values = parse.(Float64, incumbent_values)
incumbent_times = parse.(Float64, incumbent_times)








function extract_MILP_information_full(file_path::String)
    # Arrays to store the extracted values
    incumbents = []
    bestbds = []
    times = []

    # Open the file
    open(file_path, "r") do file
        # Flag to indicate if the target line has been found
        found_line = false

        # Iterate through the lines in the file
        for line in eachline(file)
            # Check if the line contains the target string
            if occursin("Expl Unexpl |  Obj  Depth IntInf | Incumbent    BestBd   Gap | It/Node Time", line)
                found_line = true
                continue
            end

            # If the line contains "Cutting", stop extracting
            if occursin("Cutting", line)
                break
            end

            # If the target line has been found, extract the columns
            if found_line && !isempty(line)
                # Split the line into columns
                columns = split(line)

                # Extract the Incumbent, BestBd, and Time columns and convert to Float64
                 push!(incumbents, columns[7])
                push!(bestbds, columns[8])
                push!(times, columns[length(columns)])

            end
        end
    end

    # replace all non-numerical characters with empty string¨
    incumbents = replace.(incumbents, r"[^0-9.]" => "")
    bestbds = replace.(bestbds, r"[^0-9.]" => "")
    times = replace.(times, r"[^0-9.]" => "")

    # convert the arrays to Float64
    #incumbents = parse.(Float64, incumbents)
    #bestbds = parse.(Float64, bestbds)
    #times = parse.(Float64, times)


    # Return the arrays
    return incumbents, bestbds, times
end



Incumbent, LB, MILP_time = extract_MILP_information_full("Output/MILP_RELAXED_inst_200_30_3_2023-08-07_16-17-50.txt")

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

function extract_info_from_string(str::String)
    parts = split(str, "/")  # Split the string by '/'
    filename = last(parts)   # Get the last part of the split string, which is the filename
    info = split(filename, "_")  # Split the filename by '_'

    
    # Extract the desired information from the filename
    jobsize = parse(Int, info[3])
    batch_size = parse(Int, info[4])
    distribution = parse(Int, info[5])
    date_time = info[6]
    return [jobsize, batch_size, distribution, date_time]
end

function extend_to_time(solutions, times, final_time)
    if times[end] < final_time
        push!(times, final_time)
        push!(solutions, solutions[end])
    end
    return solutions, times
end
# initialize IPB_new_integer_solutions_3, IPB_total_time_passed_3 as 8-element Vector{Float64}:


IPB_new_integer_solutions_3 = Vector{Float64}(undef, 8)
IPB_total_time_passed_3 = Vector{Float64}(undef, 8)


IPB_log_file_path = "Output/IPB_inst_200_30_3_RMP_RUNTIME_300_NCOLOUMNS_3200_GAP_THRESHOLD_0.05_STARTSOLUTION_4_2023-08-08_20-38-10.txt"
IPB_new_integer_solutions, IPB_total_time_passed = extract_info_from_log(IPB_log_file_path, ["New best integer solution:", "Total time passed for best solution:"])
IPB_total_time_passed = IPB_total_time_passed / 60
#prepend!(IPB_new_integer_solutions, 729828.0)
#prepend!(IPB_total_time_passed, 44.79885697364807)


IPB_log_file_path_2 = "Output/IPB_inst_200_30_3_RMP_RUNTIME_300_NCOLOUMNS_1500000_GAP_THRESHOLD_0.05_STARTSOLUTION_4_2023-08-10_11-16-13.txt"
IPB_new_integer_solutions_2, IPB_total_time_passed_2 = extract_info_from_log(IPB_log_file_path_2, ["New best integer solution:", "Total time passed for best solution:"])
IPB_total_time_passed_2 = IPB_total_time_passed_2 / 60
#prepend!(IPB_new_integer_solutions_2, 729828.0)
#prepend!(IPB_total_time_passed_2, 44.79885697364807)


IPB_log_file_path_3 = "Output/IPB_inst_200_30_3_RMP_RUNTIME_300_NCOLOUMNS_9600_GAP_THRESHOLD_0.05_STARTSOLUTION_4_2023-08-08_21-26-28.txt"
IPB_new_integer_solutions_3, IPB_total_time_passed_3 = extract_info_from_log(IPB_log_file_path_3, ["New best integer solution:", "Total time passed for best solution:"])
IPB_total_time_passed_3 = IPB_total_time_passed_3 / 60
#prepend!(IPB_new_integer_solutions_3, 729828.0)
#prepend!(IPB_total_time_passed_3, 44.79885697364807)


IPB_log_file_path_4 = "Output/IPB_inst_200_30_3_RMP_RUNTIME_300_NCOLOUMNS_1500000_GAP_THRESHOLD_0.05_STARTSOLUTION_4_2023-08-08_22-13-12.txt"
IPB_new_integer_solutions_4, IPB_total_time_passed_4 = extract_info_from_log(IPB_log_file_path_4, ["New best integer solution:", "Total time passed for best solution:"])
IPB_total_time_passed_4 = IPB_total_time_passed_4 / 60
#prepend!(IPB_new_integer_solutions_4, 729828.0)
#prepend!(IPB_total_time_passed_4, 44.79885697364807)
#=
IPB_log_file_path_5 = "Output/IPB_inst_200_30_4_RMP_RUNTIME_300_NCOLOUMNS_25600_GAP_THRESHOLD_0.2_2023-07-20_10-56-19.txt"
IPB_new_integer_solutions_5, IPB_total_time_passed_5 = extract_info_from_log(IPB_log_file_path_5, ["New best integer solution:", "Total time passed for best solution:"])
#prepend!(IPB_new_integer_solutions_5, 729828.0)
#prepend!(IPB_total_time_passed_5, 44.79885697364807)


IPB_log_file_path_6 = "Output/IPB_inst_200_30_4_RMP_RUNTIME_300_NCOLOUMNS_1600_GAP_THRESHOLD_0.2_2023-07-20_13-18-11.txt"
IPB_new_integer_solutions_6, IPB_total_time_passed_6 = extract_info_from_log(IPB_log_file_path_6, ["New best integer solution:", "Total time passed for best solution:"])
prepend!(IPB_new_integer_solutions_6, 689164.0000)
prepend!(IPB_total_time_passed_6, 16+71.40541505813599)

IPB_log_file_path_7 = "Output/IPB_inst_200_10_4.txt_RMP_RUNTIME_300_NCOLOUMNS_3200_GAP_THRESHOLD_0.1_2023-07-17_12-43-09.txt"
IPB_new_integer_solutions_7, IPB_total_time_passed_7 = extract_info_from_log(IPB_log_file_path_7, ["New best integer solution:", "Total time passed for best solution:"])
prepend!(IPB_new_integer_solutions_7, 729828.0)
prepend!(IPB_total_time_passed_7, 44.79885697364807)

IPB_log_file_path_8 = "Output/IPB_inst_200_10_4.txt_RMP_RUNTIME_300_NCOLOUMNS_6400_GAP_THRESHOLD_0.1_2023-07-17_13-45-07.txt"
IPB_new_integer_solutions_8, IPB_total_time_passed_8 = extract_info_from_log(IPB_log_file_path_8, ["New best integer solution:", "Total time passed for best solution:"])
prepend!(IPB_new_integer_solutions_8, 729828.0)
prepend!(IPB_total_time_passed_8, 44.79885697364807)

=#
## OVERVIEW DIFFERNT VARIANTS ##

#=


final_time = 45
LB = 122377.19
IPB_new_integer_solutions, IPB_total_time_passed = extend_to_time(IPB_new_integer_solutions, IPB_total_time_passed, final_time)
IPB_new_integer_solutions_2, IPB_total_time_passed_2 = extend_to_time(IPB_new_integer_solutions_2, IPB_total_time_passed_2, final_time)
IPB_new_integer_solutions_3, IPB_total_time_passed_3 = extend_to_time(IPB_new_integer_solutions_3, IPB_total_time_passed_3, final_time)
IPB_new_integer_solutions_4, IPB_total_time_passed_4 = extend_to_time(IPB_new_integer_solutions_4, IPB_total_time_passed_4, final_time)


MILP_log_file_path = "Output/MILP_inst_200_50_1_2023-08-02_21-36-03.txt"
MILP_new_integer_solutions, MILP_total_time_passed =  extract_MILP_information(MILP_log_file_path)
#prepend!(MILP_new_integer_solutions, 689662.000)
#prepend!(MILP_total_time_passed, 175)
MILP_total_time_passed = [x + 394.97 for x in MILP_total_time_passed]
MILP_total_time_passed = MILP_total_time_passed / 60

default(fontfamily = "Times New Roman")

bestbd_times = bestbd_times / 60 / 60
incumbent_times = incumbent_times / 60 / 60

plot(#bestbd_times, bestbd_values,
    seriestype = :steppost,
     xlabel = "Time (h)",
     ylabel = "Objectvie Function",
     title = "IPB - Different Variants\nn = 200, b = 30, σ = 3",
     #legend = true,
     #legend=:outertopright,
     label="MILP LB",
     xaxis = (formatter = x -> @sprintf("%.0f", x)),
     yaxis = (formatter = y -> @sprintf("%.0f", y)),
     ylims = (LB*0.997, LB*1.11),
     #size = (800   ,400),
     bottommargin=5Plots.mm,
     leftmargin=5Plots.mm,
     topmargin=5Plots.mm,
     line = (:dash, :black),

       
)
#=
plot!(IPB_total_time_passed, IPB_new_integer_solutions,
      label="IPB (10*100 Columns)"
)
=#

IPB_total_time_passed_2 = IPB_total_time_passed_2 / 60 
plot!(IPB_total_time_passed_2, IPB_new_integer_solutions_2,
    seriestype = :steppost,
      label="IPB (Iteratively add all columns)",
      line = :springgreen4,
      #line = (:dash, :black),
)

IPB_new_integer_solutions_4, IPB_total_time_passed_4 = extract_MILP_information("Output/IPB_inst_200_30_3_RMP_RUNTIME_14400_NCOLOUMNS_1500000_GAP_THRESHOLD_0.01_STARTSOLUTION_4_2023-08-10_15-26-02.txt")
IPB_total_time_passed_4 = IPB_total_time_passed_4 / 60 / 60
plot!(IPB_total_time_passed_4, IPB_new_integer_solutions_4,
    seriestype = :steppost,
      label="IPB (Stay in first column pool)",
)

plot!(incumbent_times, incumbent_values,
      label="MILP UB",
      #line = (:dash, :black),
    seriestype = :steppost,
    line = :deepskyblue3

)

plot!(bestbd_times, bestbd_values,
seriestype = :steppost,
line = (:dash, :black),
label="MILP LB",
)

=#

# adding a dotted horizontal line for the lower bound
#hline!([LB], linestyle=:dash, color=:black, label="LB")


#=

plot!(IPB_total_time_passed_5, IPB_new_integer_solutions_5,
      label="IPB (10*25600 Columns)"
)

plot!(IPB_total_time_passed_6, IPB_new_integer_solutions_6,
      label="IPB (10*1600 Columns /\n300s in initial cols)"
)

plot!(IPB_total_time_passed_7, IPB_new_integer_solutions_7,
      label="IPB (10*3200 Columns)"
)

plot!(IPB_total_time_passed_8, IPB_new_integer_solutions_8,
      label="IPB (10*6400 Columns)"
)

=#

#=
plot!(MILP_total_time_passed, MILP_new_integer_solutions,
      label="MILP",
      line = (:dot, :black)
)


=#


#=

##  Columns and LP Objective plot


default(fontfamily = "Times New Roman")

# Function to read the output data from a text file
function read_output_data(file_path::AbstractString)
    return readdlm(file_path, String; skipstart=1)
end

# Sample output data file path
output_file_path = "Output/CG_inst_200_50_4_2023-08-03_09-36-57.txt"

# Read the output data from the file
output_data = read_output_data(output_file_path)

# Extract columns, time, and objective from the output data
columns, time_values = extract_info_from_log(output_file_path, ["Columns:", "Time"])

objective, time_values = extract_info_from_log(output_file_path, ["Objective:", "Time"])

time_values = time_values/60/60


# Create the plot with dual y-axes
p = plot(time_values, columns,
         xlabel = "Time (h)",
         ylabel = "Columns",
         title = "Columns and LP Objective over Time\nn = 200, b = 50, σ = 4",
         legend = :topright,  # Position the legend at the top right corner
         label="Columns",
         xaxis = (formatter = x -> sprintf1("'%d", x, )),
         yaxis = (formatter = y -> sprintf1("'%d", y))
)

# Add the second series (LP Objective) to the same plot
plot!(twinx(), time_values, objective, legend=:topleft,   label="LP Objective", color=:red, ylabel="LP Objective",  yformatter = y -> sprintf1("'%d", y))


=#



#=
aggregated_data = Dict{String, Any}()

empty!(aggregated_data)

filenames = [
    "CG_inst_200_50_4_2023-07-28_18-22-36.txt",
    "CG_inst_200_50_3_2023-07-28_18-02-18.txt",
    "CG_inst_200_50_2_2023-07-28_17-05-37.txt",
    "CG_inst_200_50_1_2023-07-28_16-28-05.txt",
    "CG_inst_200_30_4_2023-07-28_15-28-56.txt",
    "CG_inst_200_30_3_2023-07-28_15-21-10.txt",
    "CG_inst_200_30_2_2023-07-28_15-07-48.txt",
    "CG_inst_200_30_1_2023-07-28_14-42-24.txt",
    "CG_inst_200_10_4_2023-07-28_14-36-45.txt",
    "CG_inst_200_10_3_2023-07-28_14-36-23.txt",
    "CG_inst_200_10_2_2023-07-28_14-35-38.txt",
    "CG_inst_200_10_1_2023-07-28_14-34-24.txt",
    "CG_inst_20_50_4_2023-07-28_14-14-15.txt",
    "CG_inst_20_50_3_2023-07-28_14-14-14.txt",
    "CG_inst_20_50_2_2023-07-28_14-14-13.txt",
    "CG_inst_20_50_1_2023-07-28_14-14-11.txt",
    "CG_inst_20_30_4_2023-07-28_14-14-11.txt",
    "CG_inst_20_30_3_2023-07-28_14-14-10.txt",
    "CG_inst_20_30_2_2023-07-28_14-14-10.txt",
    "CG_inst_20_30_1_2023-07-28_14-14-09.txt",
    "CG_inst_20_10_4_2023-07-28_14-14-09.txt",
    "CG_inst_20_10_3_2023-07-28_14-14-09.txt",
    "CG_inst_20_10_2_2023-07-28_14-14-09.txt",
    "CG_inst_20_10_1_2023-07-28_14-14-09.txt",
    "CG_inst_100_50_4_2023-07-28_14-00-05.txt",
    "CG_inst_100_50_3_2023-07-28_13-58-29.txt",
    "CG_inst_100_50_2_2023-07-28_13-54-42.txt",
    "CG_inst_100_50_1_2023-07-28_13-48-34.txt",
    "CG_inst_100_30_4_2023-07-28_13-44-23.txt",
    "CG_inst_100_30_3_2023-07-28_13-43-53.txt",
    "CG_inst_100_30_2_2023-07-28_13-43-08.txt",
    "CG_inst_100_30_1_2023-07-28_13-41-55.txt",
    "CG_inst_100_10_4_2023-07-28_13-41-38.txt",
    "CG_inst_100_10_3_2023-07-28_13-41-34.txt",
    "CG_inst_100_10_2_2023-07-28_13-41-28.txt",
    "CG_inst_100_10_1_2023-07-28_13-41-19.txt",
    "CG_inst_60_50_4_2023-08-01_12-31-30.txt",
    "CG_inst_60_50_3_2023-08-01_12-31-17.txt",
    "CG_inst_60_50_2_2023-08-01_12-30-44.txt",
    "CG_inst_60_50_1_2023-08-01_12-30-26.txt",
    "CG_inst_60_30_4_2023-08-01_12-30-10.txt",
    "CG_inst_60_30_3_2023-08-01_12-30-02.txt",
    "CG_inst_60_30_2_2023-08-01_12-29-53.txt",
    "CG_inst_60_30_1_2023-08-01_12-29-43.txt",
    "CG_inst_60_10_4_2023-08-01_12-29-34.txt",
    "CG_inst_60_10_3_2023-08-01_12-29-33.txt",
    "CG_inst_60_10_2_2023-08-01_12-29-31.txt",
    "CG_inst_60_10_1_2023-08-01_12-29-10.txt"
]

filenames = sort(filenames)


for output_file_path in filenames

    output_file_path = "Output/$output_file_path"

    columns, time_values = extract_info_from_log(output_file_path, ["Columns:", "Time"])

    objective, time_values = extract_info_from_log(output_file_path, ["Objective:", "Time"])

    iterations = extract_info_from_log(output_file_path, ["Iteration"])

    differences_columns = diff(columns)
    total_columns_added = sum(differences_columns)
    # give me the maximum value of all iterations  
    amount_iterations = iterations[end][end]

    #instance name, init_cols, end_cols, amount iterations, average time per iteration, average amount columns added (MILP?)

    jobsize, batch_size, distribution, date_time = extract_info_from_string(output_file_path)

    name_inst = String("n = $(jobsize) b = $(batch_size) σ = $(distribution)")

    total_time = time_values[end][end]

    aggregated_data[output_file_path] = Dict(
        "name" => name_inst,
        "n" => jobsize,
        "b" => batch_size,
        "distribution" => distribution,
        #="init_cols" => sprintf1("'%d", Int(columns[1])),
        "end_cols" => sprintf1("'%d", columns[end][end]),
        "amount_iterations" => sprintf1("'%d", Int(amount_iterations)),
        "average_time_per_iteration" => sprintf1("'%.2f", time_values[end] / amount_iterations),
        "average_amount_columns_added" => sprintf1("'%.2f", sum(differences_columns) / amount_iterations))=#
        "init_cols" => columns[1],
        "end_cols" =>  columns[end][end],
        "total_columns_added" => total_columns_added,
        "average_amount_columns_added" =>  sum(differences_columns) / amount_iterations,
        "amount_iterations" => Int(amount_iterations),
        "total_time" => total_time,
        "average_time_per_iteration" => time_values[end] / amount_iterations,
    )


end


# sort aggregated_data by n then b then distribution
#aggregated_data = sort(collect(aggregated_data), by = x -> (x[2]["n"], x[2]["b"], x[2]["distribution"]))



# Define the output filename for the CSV file
output_filename = "CG_output_table.csv"

# Open the output file
output_file = open(output_filename, "w")

# Write the CSV header
header = "Instance,name,n,b,σ,Init. Columns,Final Columns,Total Columns added,Avg. Amount Columns added,Iterations,Total Time,Average Time p. Iteration"
write(output_file, header * "\n")

# Write the table rows
for (file_name, data) in aggregated_data
    row = "$file_name,"
    row *= "$(data["name"]),"
    row *= "$(data["n"]),"
    row *= "$(data["b"]),"
    row *= "$(data["distribution"]),"
    row *= "$(data["init_cols"]),"
    row *= "$(data["end_cols"]),"
    row *= "$(data["total_columns_added"]),"
    row *= "$(data["average_amount_columns_added"]),"
    row *= "$(data["amount_iterations"]),"
    row *= "$(data["total_time"]),"
    row *= "$(data["average_time_per_iteration"]),"


    write(output_file, row * "\n")
end



close(output_file)
=#


## Table for price and branch data


aggregated_data = Dict{String, Any}()

#listOfFiles = "Output/MILP_RELAXED_inst_20_10_1_2023-08-01_16-28-50.txt Output/MILP_inst_200_10_4_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_200_10_4_2023-08-01_16-28-50.txt Output/MILP_inst_200_10_3_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_200_10_3_2023-08-01_16-28-50.txt Output/MILP_inst_200_10_2_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_200_10_2_2023-08-01_16-28-50.txt Output/MILP_inst_200_10_1_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_200_10_1_2023-08-01_16-28-50.txt Output/MILP_inst_100_50_4_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_100_50_4_2023-08-01_16-28-50.txt Output/MILP_inst_100_50_3_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_100_50_3_2023-08-01_16-28-50.txt Output/MILP_inst_100_50_2_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_100_50_2_2023-08-01_16-28-50.txt Output/MILP_inst_100_50_1_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_100_50_1_2023-08-01_16-28-50.txt Output/MILP_inst_100_30_4_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_100_30_4_2023-08-01_16-28-50.txt Output/MILP_inst_100_30_3_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_100_30_3_2023-08-01_16-28-50.txt Output/MILP_inst_100_30_2_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_100_30_2_2023-08-01_16-28-50.txt Output/MILP_inst_100_30_1_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_100_30_1_2023-08-01_16-28-50.txt Output/MILP_inst_100_10_4_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_100_10_4_2023-08-01_16-28-50.txt Output/MILP_inst_100_10_3_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_100_10_3_2023-08-01_16-28-50.txt Output/MILP_inst_100_10_2_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_100_10_2_2023-08-01_16-28-50.txt Output/MILP_inst_100_10_1_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_100_10_1_2023-08-01_16-28-50.txt Output/MILP_inst_60_50_4_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_60_50_4_2023-08-01_16-28-50.txt Output/MILP_inst_60_50_3_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_60_50_3_2023-08-01_16-28-50.txt Output/MILP_inst_60_50_2_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_60_50_2_2023-08-01_16-28-50.txt Output/MILP_inst_60_50_1_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_60_50_1_2023-08-01_16-28-50.txt Output/MILP_inst_60_30_4_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_60_30_4_2023-08-01_16-28-50.txt Output/MILP_inst_60_30_3_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_60_30_3_2023-08-01_16-28-50.txt Output/MILP_inst_60_30_2_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_60_30_2_2023-08-01_16-28-50.txt Output/MILP_inst_60_30_1_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_60_30_1_2023-08-01_16-28-50.txt Output/MILP_inst_60_10_4_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_60_10_4_2023-08-01_16-28-50.txt Output/MILP_inst_60_10_3_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_60_10_3_2023-08-01_16-28-50.txt Output/MILP_inst_60_10_2_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_60_10_2_2023-08-01_16-28-50.txt Output/MILP_inst_60_10_1_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_60_10_1_2023-08-01_16-28-50.txt Output/MILP_inst_20_50_4_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_20_50_4_2023-08-01_16-28-50.txt Output/MILP_inst_20_50_3_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_20_50_3_2023-08-01_16-28-50.txt Output/MILP_inst_20_50_2_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_20_50_2_2023-08-01_16-28-50.txt Output/MILP_inst_20_50_1_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_20_50_1_2023-08-01_16-28-50.txt Output/MILP_inst_20_30_4_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_20_30_4_2023-08-01_16-28-50.txt Output/MILP_inst_20_30_3_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_20_30_3_2023-08-01_16-28-50.txt Output/MILP_inst_20_30_2_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_20_30_2_2023-08-01_16-28-50.txt Output/MILP_inst_20_30_1_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_20_30_1_2023-08-01_16-28-50.txt Output/MILP_inst_20_10_4_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_20_10_4_2023-08-01_16-28-50.txt Output/MILP_inst_20_10_3_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_20_10_3_2023-08-01_16-28-50.txt Output/MILP_inst_20_10_2_2023-08-01_16-28-50.txt Output/MILP_RELAXED_inst_20_10_2_2023-08-01_16-28-50.txt Output/MILP_inst_20_10_1_2023-08-01_16-28-50.txt"
listOfFiles = "Output/MILP_RELAXED_inst_100_10_1_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_60_50_4_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_60_50_3_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_60_50_2_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_60_50_1_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_60_30_4_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_60_30_3_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_60_30_2_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_60_30_1_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_60_10_4_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_60_10_3_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_60_10_2_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_60_10_1_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_20_50_4_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_20_50_3_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_20_50_2_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_20_50_1_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_20_30_4_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_20_30_3_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_20_30_2_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_20_30_1_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_20_10_4_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_20_10_3_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_20_10_2_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_20_10_1_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_200_50_4_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_200_50_3_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_200_50_2_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_200_50_1_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_200_30_4_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_200_30_3_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_200_30_2_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_200_30_1_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_200_10_4_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_200_10_3_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_200_10_2_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_200_10_1_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_100_50_4_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_100_50_3_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_100_50_2_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_100_50_1_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_100_30_4_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_100_30_3_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_100_30_2_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_100_30_1_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_100_10_4_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_100_10_3_2023-08-14_09-45-28.txt Output/MILP_RELAXED_inst_100_10_2_2023-08-14_09-45-28.txt"
listOfFiles = split(listOfFiles, " ")
# make sure the array is of type string
listOfFiles = String.(listOfFiles)
# sort the array
listOfFiles = sort(listOfFiles)


for file in listOfFiles
    println(file)
    #replace the RELAXED with nothing
    filename = replace(file, "RELAXED_" =>  "")

    println(filename)



    jobsize, batch_size, distribution, date_time = extract_info_from_string(filename)

    instance_name = String("n_$(jobsize)_b_$(batch_size)_s_$(distribution)")

    #check if file contains Relaxed
    if contains(file, "RELAXED")
        CG_LB = extract_info_from_log(file, ["Objective value LB:"])[end][end]
        CG_UB = extract_info_from_log(file, ["Objective value UB:"])[end][end]
        CG_LB_solving_time = extract_info_from_log(file, ["Solving time LB:"])[end][end]
        CG_UB_solving_time = extract_info_from_log(file, ["Solving time UB:"])[end][end]
        CG_LB_setUp_time = extract_info_from_log(file, ["SetUpTime:"])[end][end]
        Gap = extract_info_from_log(file, ["Gap:"])[end][end]
        aggregated_data[instance_name] = Dict(
            "name" => instance_name,
            "n" => jobsize,
            "b" => batch_size,
            "distribution" => distribution,
            "CG_LB" => CG_LB,
            "CG_LB_solving_time" => CG_LB_solving_time,
            "CG_LB_setUp_time" => CG_LB_setUp_time,
            "CG_UB" => CG_UB,
            "CG_UB_solving_time" => CG_UB_solving_time,
            "Gap" => Gap,
        )

    #=else
        CG_UB = extract_info_from_log(file, ["Objective value:"])[end][end]
        CG_UB_solving_time = extract_info_from_log(file, ["Solving time:"])[end][end]
        CG_UB_setUp_time = extract_info_from_log(file, ["SetUpTime:"])[end][end]
        #if the instance name is missing, add it
        if !haskey(aggregated_data, instance_name)
            aggregated_data[instance_name] = Dict(
            )
        end
        
        aggregated_data[instance_name]["CG_UB"] = CG_UB
        aggregated_data[instance_name]["CG_UB_solving_time"] = CG_UB_solving_time
        aggregated_data[instance_name]["CG_UB_setUp_time"] = CG_UB_setUp_time
=#
    end
    
end

# return all entries which do not have a CG_UB


output_filename = "PB_output_table.csv"

# Open the output file
output_file = open(output_filename, "w")

# Write the CSV header
header = "Instance,name,n,b,σ,CG_LB,CG_LB_solving_time,CG_LB_setUp_time,CG_UB,CG_UB_solving_time,CG_UB_solving_time,Gap"
write(output_file, header * "\n")

# Write the table rows
for (instance_name, data) in aggregated_data
    row = "$instance_name,"
    row *= "$(data["name"]),"
    row *= "$(data["n"]),"
    row *= "$(data["b"]),"
    row *= "$(data["distribution"]),"
    row *= "$(data["CG_LB"]),"
    row *= "$(data["CG_LB_solving_time"]),"
    row *= "$(data["CG_LB_setUp_time"]),"
    row *= "$(data["CG_UB"]),"
    row *= "$(data["CG_UB_solving_time"]),"
    row *= "$(data["CG_UB_solving_time"]),"
    row *= "$(data["Gap"])"

    write(output_file, row * "\n")
end

close(output_file)





