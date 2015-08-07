VERSION >= v"0.4.0-dev+6521" && __precompile__()

module LaTeXStrings
export LaTeXString, latexstring, @L_str, @L_mstr

using Compat

# IJulia supports LaTeX output for any object with a text/latex
# writemime method, but these are annoying to type as string literals
# in Julia because of all the escaping required, e.g. "\$\\alpha +
# \\beta\$".  To simplify this, we add a new string type with a macro
# constructor, so that one can simply do L"$\alpha + \beta$".

immutable LaTeXString <: AbstractString
    s::ByteString
end

# coercing constructor:
function latexstring(s::ByteString)
    # the only point of using LaTeXString to represent equations, since
    # IJulia doesn't support LaTeX output other than equations, so add $'s
    # around the string if they aren't there (ignoring \$)
    return ismatch(r"[^\\]\$|^\$", s) ?
        LaTeXString(s) :  LaTeXString(string("\$", s, "\$"))
end
latexstring(s::AbstractString) = latexstring(bytestring(s))
latexstring(args...) = latexstring(string(args...))

macro L_str(s, flags...) latexstring(s) end
macro L_mstr(s, flags...) latexstring(s) end

import Base: writemime, show, write, endof, getindex, sizeof, search, rsearch, isvalid, next, length, bytestring, convert, IOBuffer, pointer

write(io::IO, s::LaTeXString) = write(io, s.s)
writemime(io::IO, ::MIME"application/x-latex", s::LaTeXString) = write(io, s)
writemime(io::IO, ::MIME"text/latex", s::LaTeXString) = write(io, s)

function show(io::IO, s::LaTeXString)
    print(io, "L")
    Base.print_quoted_literal(io, s.s)
end

bytestring(s::LaTeXString) = bytestring(s.s)
endof(s::LaTeXString) = endof(s.s)
next(s::LaTeXString, i::Int) = next(s.s, i)
length(s::LaTeXString) = length(s.s)
getindex(s::LaTeXString, i::Int) = getindex(s.s, i)
getindex(s::LaTeXString, i::Integer) = getindex(s.s, i)
getindex(s::LaTeXString, i::Real) = getindex(s.s, i)
getindex(s::LaTeXString, i::UnitRange{Int}) = getindex(s.s, i)
getindex{T<:Integer}(s::LaTeXString, i::UnitRange{T}) = getindex(s.s, i)
getindex(s::LaTeXString, i::AbstractVector) = getindex(s.s, i)
sizeof(s::LaTeXString) = sizeof(s.s)
search(s::LaTeXString, c::Char, i::Integer) = search(s.s, c, i)
rsearch(s::LaTeXString, c::Char, i::Integer) = rsearch(s.s, c, i)
isvalid(s::LaTeXString, i::Integer) = isvalid(s.s, i)
convert(T::Union(Type{Ptr{Uint8}},Type{Ptr{Int8}}), s::LaTeXString) = convert(T, s.s)
pointer(s::LaTeXString) = pointer(s.s)
IOBuffer(s::LaTeXString) = IOBuffer(s.s)

end # module
