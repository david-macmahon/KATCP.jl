module KATCP

using Sockets

export listdev, regread, regwrite, estimate_fpga_clock

"""
    Client(host, port::Integer=7147)

Construct a `Client` object for communicating with a KATCP server running on
port `port` of `host`.
"""
mutable struct Client
    host::String
    port::Int
    socket::Union{TCPSocket,Nothing}
    lock::ReentrantLock
    replies::Channel{Vector{<:AbstractString}}
    notifies::Channel{String}
    reqname::String
    readtask::Union{Task,Nothing}

    function Client(host, port::Integer=7147)
        client = new(
            host,
            port,
            nothing,
            ReentrantLock(),
            Channel{Vector{<:AbstractString}}(Inf),
            Channel{String}(Inf),
            "",
            nothing
        )

        connect!(client)
    end
end

function connect!(client::Client)
    client.socket = connect(client.host, client.port)
    client.readtask = Threads.@spawn socket_read_task(client)
    client
end

function socket_read_task(client::Client)
    while isopen(client.socket)
        local line
        try
            line = readline(client.socket)
        catch
            put!(client.replies, ["!!socket-error"])
            return nothing
        end
        # Treat empty string as EOF
        if isempty(line)
            put!(client.replies, ["!!socket-eof"])
            return nothing
        end

        words = splitunescape(line)
        key = words[1][1]

        if key === '!'
            # Assume it's end of response
            put!(client.replies, words)
        elseif key === '#'
            # If words[1] matches client.reqname (except for first character)
            if words[1][2:end] == client.reqname[2:end]
                # Put words into replies channen
                put!(client.replies, words[2:end])
            else
                # Must be "asynchronous inform" (aka notifies)
                put!(client.notifies, join(words, " "))
            end
        elseif key !== '?' # Ignore requests from server
            @warn "malformed line" line
        end
    end # while isopen

    put!(client.replies, ["!!socket-eof"])
    return nothing
end

"""
    request(client, reqname, args...)

Return results of `reqname` with `args...`.

The response is a Vector corresponding to the returned lines.  Each line is
itself a Vector of words.  The last line will contain `"!\$reqname"` as the
first word (or start with `"!!"` on error) but any preceding "inform" lines will
not include the leading `"#\$reqname"`.
"""
function request(client::Client, reqname, args...)
    lock(client.lock)
    try
        client.reqname = "?" * reqname
        println(client.socket, escapejoin([client.reqname, args...]))
        timer = Timer(t->close(client.socket), 5)
        resp = [take!(client.replies)]
        while !startswith(resp[end][1], "!")
            push!(resp, take!(client.replies))
        end
        close(timer)
        resp
    finally
        client.reqname = ""
        unlock(client.lock)
    end
end

include("escape.jl")
include("listdev.jl")
include("read.jl")
include("write.jl")
include("estclock.jl")

end # module KATCP
