"""
The LaTeXStrings module exists mainly to make LaTeX equations easier to type as
literal strings, and so that the resulting strings display as formatted equations
in supporting environments like IJulia.

See in particular the `LaTeXString` type and the `L"..."` constructor macro.
"""
module LaTeXStrings
export LaTeXString, latexstring, @L_str

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

# the only point of using LaTeXString to represent equations, since
# IJulia doesn't support LaTeX output other than equations, so add $'s
# around the string if they aren't there (ignoring \$ and %$)
_maybe_wrap_equation(s) = occursin(r"[^\\%]\$|^\$", s) ? s : string('\$', s, '\$')

"""
    latexstring(args...)

Similar to `string(args...)`, but generates a `LaTeXString` instead of a `String`.
"""
latexstring(args...) = latexstring(string(args...))
function latexstring(s::String)
    return LaTeXString(_maybe_wrap_equation(s))
end
latexstring(s::AbstractString) = latexstring(String(s))

if isdefined(Meta, :parseatom)
    const parseatom = Meta.parseatom
else
    parseatom(s, i; filename=nothing) = Meta.parse(s, i; greedy=false)
end

@doc raw"""
    L"..."

Creates a `LaTeXString` and is equivalent to `latexstring(raw"...")`, except that
`%$` can be used for interpolation.

```jldoctest
julia> L"x = \sqrt{2}"
L"$x = \sqrt{2}$"

julia> L"x = %$(sqrt(2))"
L"$x = 1.4142135623730951$"
```
"""
macro L_str(s::String)
    i = firstindex(s)
    buf = IOBuffer(maxsize=ncodeunits(s))
    ex = Expr(:call, GlobalRef(LaTeXStrings, :latexstring))
    while i <= ncodeunits(s)
        c = @inbounds s[i]
        i = nextind(s, i)
        if c === '%' && i <= ncodeunits(s)
            c = @inbounds s[i]
            if c === '$'
                position(buf) > 0 && push!(ex.args, String(take!(buf)))
                atom, i = parseatom(s, nextind(s, i), filename=string(__source__.file))
                Meta.isexpr(atom, :incomplete) && error(atom.args[1])
                atom !== nothing && push!(ex.args, atom)
                continue
            else
                print(buf, '%')
            end
        else
            print(buf, c)
        end
    end
    position(buf) > 0 && push!(ex.args, String(take!(buf)))
    return esc(ex)
end

Base.write(io::IO, s::LaTeXString) = write(io, s.s)
Base.show(io::IO, ::MIME"application/x-latex", s::LaTeXString) = print(io, s.s)
Base.show(io::IO, ::MIME"text/latex", s::LaTeXString) = print(io, s.s)
function Base.show(io::IO, s::LaTeXString)
    @static if isdefined(Base, :escape_raw_string)  # Julia ≥ 1.4
        print(io,"L\"")
        Base.escape_raw_string(io, s.s)
        print(io,'"')
    else
        print(io, 'L')
        Base.print_quoted_literal(io, s.s)   # Julia < 1.6
    end
end

Base.firstindex(s::LaTeXString) = firstindex(s.s)
Base.lastindex(s::LaTeXString) = lastindex(s.s)
Base.iterate(s::LaTeXString, i::Int) = iterate(s.s, i)
Base.iterate(s::LaTeXString) = iterate(s.s)
Base.nextind(s::LaTeXString, i::Int) = nextind(s.s, i)
Base.prevind(s::LaTeXString, i::Int) = prevind(s.s, i)
Base.eachindex(s::LaTeXString) = eachindex(s.s)
Base.length(s::LaTeXString) = length(s.s)
Base.getindex(s::LaTeXString, i::Integer) = getindex(s.s, i)
Base.getindex(s::LaTeXString, i::Int) = getindex(s.s, i) # for method ambig in Julia 0.6
Base.getindex(s::LaTeXString, i::UnitRange{Int}) = getindex(s.s, i)
Base.getindex(s::LaTeXString, i::UnitRange{<:Integer}) = getindex(s.s, i)
Base.getindex(s::LaTeXString, i::AbstractUnitRange{<:Integer}) = getindex(s.s, i) # for method ambiguity
Base.getindex(s::LaTeXString, i::AbstractVector{<:Integer}) = getindex(s.s, i)
Base.getindex(s::LaTeXString, i::AbstractVector{Bool}) = getindex(s.s, i) # for method ambiguity
Base.codeunit(s::LaTeXString, i::Integer) = codeunit(s.s, i)
Base.codeunit(s::LaTeXString) = codeunit(s.s)
Base.ncodeunits(s::LaTeXString) = ncodeunits(s.s)
Base.codeunits(s::LaTeXString) = codeunits(s.s)
Base.sizeof(s::LaTeXString) = sizeof(s.s)
Base.isvalid(s::LaTeXString, i::Integer) = isvalid(s.s, i)
Base.pointer(s::LaTeXString) = pointer(s.s)
Base.IOBuffer(s::LaTeXString) = IOBuffer(s.s)
Base.unsafe_convert(T::Union{Type{Ptr{UInt8}},Type{Ptr{Int8}},Cstring}, s::LaTeXString) = Base.unsafe_convert(T, s.s)
Base.match(re::Regex, s::LaTeXString, idx::Integer, add_opts::UInt32=UInt32(0)) = match(re, s.s, idx, add_opts)
Base.findnext(re::Regex, s::LaTeXString, idx::Integer) = findnext(re, s.s, idx)
Base.eachmatch(re::Regex, s::LaTeXString; overlap = false) = eachmatch(re, s.s; overlap=overlap)

end # module
