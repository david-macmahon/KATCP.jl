"""
    Base.read(client::Client, name, offset, length)
    Base.read(client::Client, name; offset=0, length=4)

Use `client` to read `length` bytes from device `name` starting at `offset`.

Both `offset` and `length` are byte counts and must be a multiple of 4.
"""
function Base.read(client::Client, name, offset, length)::Vector{UInt32}
    offset % 4 == 0 || error("byte offset must be a multiple of 4")
    length % 4 == 0 || error("byte length must be a multiple of 4")

    resp = request(client, "read", name, offset, length)
    resp[end][1] == "!read" || error("got KATCP error ($(resp[end][2]))")
    resp[end][2] == "ok" || error("got KATCP error ($(resp[end][2]))")
    reinterpret(UInt32, transcode(UInt8, resp[end][end]))|>collect
end

function Base.read(client::Client, name; offset=0, length=4)
    Base.read(client, name, offset, length)
end

"""
    regread(client::Client, name)
    
Read 32-bit regsiter named `name` from `client`.
"""
regread(client::Client, name) = read(client, name, 0, 4)[1]
