"""
    escape(str) -> escaped_str

Return a KATCP escaped version of `str`.
"""
function escape(s::AbstractString)
    isempty(s) ? "\\@" : replace(s,
        "\\" => "\\\\",
        " "  => "\\_",
        "\0" => "\\0",
        "\n" => "\\n",
        "\r" => "\\r",
        "\e" => "\\e",
        "\t" => "\\t",
    )
end

escape(x) = escape(string(x))

"""
    unescape(escaped_str) -> str

Return an unescaped version of KATCP escaped string `str`.
"""
function unescape(s::AbstractString)
    replace(s,
        "\\\\" => "\\",
        "\\_"  => " ",
        "\\0"  => "\0",
        "\\n"  => "\n",
        "\\r"  => "\r",
        "\\e"  => "\e",
        "\\t"  => "\t",
        "\\@"  => ""
    )
end

"""
    escapejoin(words) -> escaped_str

Escape `words` and join with space delimiter.
"""
escapejoin(words::AbstractVector, delim=" ") = join(escape.(words), delim)
#escapejoin(words::AbstractVector{<:AbstractString}, delim=" ") = join(escape.(words), delim)

"""
    splitunescape(escapedwords) -> [word1, ...]

Split `escapedwords` on whitespace and unescape each word.
"""
splitunescape(escapedwords::AbstractString) = unescape.(split(escapedwords))
