using Random

function generate_data(n::Int, size_dist::Vector{Int}, time_dist::Vector{Int}, filename::AbstractString)
    data = []
    push!(data, [n, minimum(size_dist), maximum(size_dist)])
    for i in 1:n
        size = rand(size_dist)
        time = rand(time_dist)
        push!(data, [size, time])
    end
    open(filename, "w") do f
        for row in data
            write(f, join(row, " ") * "\n")
        end
    end
end

# example usage
n = 10
size_dist = 1:100
time_dist = 1:10
filename = "data.txt"
generate_data(n, size_dist, time_dist, filename)

