using LaTeXStrings, Test
import Aqua
using Base: OneTo

Aqua.test_all(LaTeXStrings)

tst1 = L"an equation: $\alpha^2$"
tst1s = String(tst1)
@test tst1 == "an equation: \$\\alpha^2\$" == tst1s
@test L"\alpha^2" == "\$\\alpha^2\$"
@test repr("text/latex", tst1) == repr("application/x-latex", tst1) == tst1s
@test sprint(show, "text/latex", tst1) == tst1s
@test sprint(show, "text/plain", tst1) == "L\"an equation: \$\\alpha^2\$\""
@test latexstring(tst1s) == tst1 == LaTeXString(tst1s)

@test ccall(:strlen, Csize_t, (Cstring,), tst1) == ccall(:strlen, Csize_t, (Ptr{UInt8},), tst1) == sizeof(tst1)

for f in (length, eachindex, pointer, collect, ncodeunits, codeunits)
    @test f(tst1) == f(tst1.s)
end
@test nextind(tst1, 1) == prevind(tst1, 3) == 2
@test isvalid(tst1, 1)
@test findnext(isequal('o'), L"foo", 1) == 3
@test tst1[1] == 'a'
@test codeunit(tst1, 1) == UInt8('a')
@test L"foo"[1] == '$'
@test tst1[1:2] == tst1[0x01:0x02] == tst1[[1,2]] == "an"

@test match(r"[a-z]+", tst1, 3).match == match(r"[a-z]+", tst1.s, 3).match
@test findnext(r"[a-z]+", tst1, 3) == findnext(r"[a-z]+", tst1.s, 3)
@test [m.match for m in eachmatch(r"[a-z]+", tst1)] == [m.match for m in eachmatch(r"[a-z]+", tst1.s)]

# issue #23 — will change if #17 is addressed
@test L"x" * L"y" == "\$x\$\$y\$"

# show should return nothing
@test show(IOBuffer(), "application/x-latex", tst1) === nothing
@test show(IOBuffer(), "text/latex", tst1) === nothing

@testset "interpolation" begin
    @test L"" == latexstring("")
    @test L"%" == latexstring("%")
    @test L"$" == latexstring("\$")
    @test L"%$" == latexstring("")

    for x in ["foo", 'c', 7, 3.1]
        @test L"%$x" == latexstring(x)
        @test L"%%$(x)foo" == latexstring("%", x, "foo")
        @test L"%$(x)%$x" == latexstring(x, x)
    end
    @test L"%$(1+2)" == latexstring(3)
    @test L"%$(raw\"$$\")" == latexstring(raw"$$")

    if VERSION >= v"1.6.0-DEV.22"
        @test L"%$(@__FILE__)" == latexstring(@__FILE__)
    end

    @test_throws ErrorException getproperty(LaTeXStrings, Symbol("@L_str"))(
        LineNumberNode(@__LINE__, @__FILE__), @__MODULE__,
        "%\$(",
    )
end

@testset "indexing" begin
    tst1 = L"an equation: $\alpha^2$"
    tst1s = String(tst1)

    @test firstindex(tst1) == 1
    @test lastindex(tst1) == length(tst1)

    @test tst1[5] == tst1s[5]
    @test tst1[15] == tst1s[15]

    idx = [5, 10, 15]
    @test tst1[idx] == tst1s[idx]

    # to test for ambiguities (#61, #65)
    bool_idx = rand(Bool, length(tst1))
    @test_throws ArgumentError tst1[bool_idx]

    @test tst1[UInt(5)] == tst1[5]
    @test tst1[UInt.(idx)] == tst1[idx]

    @test tst1[OneTo(5)] == tst1[1:5]
end

using Documenter
DocMeta.setdocmeta!(LaTeXStrings, :DocTestSetup, :(using LaTeXStrings); recursive=true)
doctest(LaTeXStrings; manual = false)
