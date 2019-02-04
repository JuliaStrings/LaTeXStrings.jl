VERSION < v"0.7.0-beta2.199" && __precompile__()

"""
The LaTeXStrings module exists mainly to make LaTeX equations easier to type as
literal strings, and so that the resulting strings display as formatted equations
in supporting environments like IJulia.

See in particular the `LaTeXString` type and the `L"..."` constructor macro.
"""
module LaTeXStrings
export LaTeXString, latexstring, @L_str, @L_mstr
using Compat

# IJulia supports LaTeX output for any object with a text/latex
# writemime method, but these are annoying to type as string literals
# in Julia because of all the escaping required, e.g. "\$\\alpha +
# \\beta\$".  To simplify this, we add a new string type with a macro
# constructor, so that one can simply do L"$\alpha + \beta$".

@doc raw"""
A `LaTeXString` is a string type whose contents represent a fragment of LaTeX code,
typically containing an equation (`$...$`).   In certain environments (e.g. IJulia)
this will display with LaTeX-like formatting.   For the most part, you can use
a `LaTeXString` object in any context that expects an `AbstractString` object.

The `L"..."` macro is convenient for constructing `LaTeXString` objects, because
it eliminates the need to escape backslashes and dollar signs, and implicitly inserts
dollar signs around the string if none are present.  For example, `L"$\alpha$"`, `L"\alpha"`,
and `LaTeXString("\$\\alpha\$")` are all equivalent.
"""
struct LaTeXString <: AbstractString
    s::String
end

"""
    latexstring(args...)

Similar to `string(args...)`, but generates a `LaTeXString` instead of a `String`.
"""
latexstring(args...) = latexstring(string(args...))
function latexstring(s::String)
    # the only point of using LaTeXString to represent equations, since
    # IJulia doesn't support LaTeX output other than equations, so add $'s
    # around the string if they aren't there (ignoring \$)
    return occursin(r"[^\\]\$|^\$", s) ? LaTeXString(s) :  LaTeXString(string('\$', s, '\$'))
end
latexstring(s::AbstractString) = latexstring(String(s))

macro L_str(s, flags...) latexstring(s) end
macro L_mstr(s, flags...) latexstring(s) end

Base.write(io::IO, s::LaTeXString) = write(io, s.s)
Base.show(io::IO, ::MIME"application/x-latex", s::LaTeXString) = print(io, s.s)
Base.show(io::IO, ::MIME"text/latex", s::LaTeXString) = print(io, s.s)
function Base.show(io::IO, s::LaTeXString)
    print(io, "L")
    Base.print_quoted_literal(io, s.s)
end

Compat.firstindex(s::LaTeXString) = Compat.firstindex(s.s)
Compat.lastindex(s::LaTeXString) = Compat.lastindex(s.s)
@static if isdefined(Base, :iterate)
    Base.iterate(s::LaTeXString, i::Int) = iterate(s.s, i)
    Base.iterate(s::LaTeXString) = iterate(s.s)
else
    Base.start(s::LaTeXString) = start(s.s)
    Base.next(s::LaTeXString, i) = next(s.s, i)
    Base.done(s::LaTeXString, i) = done(s.s, i)
end
Base.nextind(s::LaTeXString, i::Int) = nextind(s.s, i)
Base.prevind(s::LaTeXString, i::Int) = prevind(s.s, i)
Base.eachindex(s::LaTeXString) = eachindex(s.s)
Base.length(s::LaTeXString) = length(s.s)
Base.getindex(s::LaTeXString, i::Integer) = getindex(s.s, i)
Base.getindex(s::LaTeXString, i::Int) = getindex(s.s, i) # for method ambig in Julia 0.6
Base.getindex(s::LaTeXString, i::UnitRange{Int}) = getindex(s.s, i)
Base.getindex(s::LaTeXString, i::UnitRange{<:Integer}) = getindex(s.s, i)
Base.getindex(s::LaTeXString, i::AbstractVector{<:Integer}) = getindex(s.s, i)
Compat.codeunit(s::LaTeXString, i::Integer) = codeunit(s.s, i)
Compat.codeunit(s::LaTeXString) = codeunit(s.s)
Compat.ncodeunits(s::LaTeXString) = ncodeunits(s.s)
Compat.codeunits(s::LaTeXString) = codeunits(s.s)
Base.sizeof(s::LaTeXString) = sizeof(s.s)
Base.isvalid(s::LaTeXString, i::Integer) = isvalid(s.s, i)
Base.pointer(s::LaTeXString) = pointer(s.s)
Base.IOBuffer(s::LaTeXString) = IOBuffer(s.s)
Base.unsafe_convert(T::Union{Type{Ptr{UInt8}},Type{Ptr{Int8}},Cstring}, s::LaTeXString) = Base.unsafe_convert(T, s.s)

end # module
