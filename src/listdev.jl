"""
    listdev(client) -> Dict{String,Int}

Return a `Dict` mapping device names to device byte sizes.
"""
function listdev(client::Client)
    resp = request(client, "listdev", "size")
    names = first.(resp[1:end-1])
    sizes = map(resp[1:end-1]) do words
        sizeinfo = words[end]
        endswith(sizeinfo, ":0") || @warn "unknown size $sizeinfo"
        tryparse(Int, split(sizeinfo, ":")[1])
    end
    Dict(names .=> sizes)
end
