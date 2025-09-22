"""
    Base.write(client::Client, name, data, offset=0)

Use `client` to write data to device `name` starting at `offset`.

`offset` is a byte counts and must be a multiple of 4.
"""
function Base.write(client::Client, name, data::AbstractArray{<:UInt32}, offset=0)
    offset % 4 == 0 || error("byte offset must be a multiple of 4")
    strdata = transcode(String, reinterpret(UInt8, vec(data)))
    resp = request(client, "write", name, offset, strdata, length(strdata))
    resp[end][1] == "!write" || error("got KATCP error ($(resp[end][2]))")
    resp[end][2] == "ok" || error("got KATCP error ($(resp[end][2]))")
    nothing
end

Base.write(client::Client, name, data::Integer, offset=0) = write(client, name, [data%UInt32], offset)
Base.write(client::Client, name, data, offset=0) = write(client, name, convert(Vector{UInt32}, data), offset)

"""
    regwrite(client::Client, name, data)
    
Writes `data` to 32-bit regsiter named `name` using `client`.
"""
regwrite(client::Client, name, data::UInt32) = write(client, name, [data], 0)
regwrite(client::Client, name, data::Integer) = regwrite(client, name, data%UInt32)
