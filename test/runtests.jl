using LaTeXStrings, Test

tst1 = L"an equation: $\alpha^2$"
tst1s = String(tst1)
@test tst1 == "an equation: \$\\alpha^2\$" == tst1s
@test L"\alpha^2" == "\$\\alpha^2\$"
@test repr("text/latex", tst1) == repr("application/x-latex", tst1) == tst1s
@test sprint(show, "text/latex", tst1) == tst1s
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

using Documenter
DocMeta.setdocmeta!(LaTeXStrings, :DocTestSetup, :(using LaTeXStrings); recursive=true)
doctest(LaTeXStrings; manual = false)
