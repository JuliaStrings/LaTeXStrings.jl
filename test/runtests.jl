using LaTeXStrings, Compat
using Base.Test

# write your own tests here
tst1 = L"an equation: $\alpha^2$"
tst1u = Compat.UTF8String(tst1)
@test tst1 == "an equation: \$\\alpha^2\$" == tst1u
@test L"\alpha^2" == "\$\\alpha^2\$"
@test stringmime("text/latex", tst1) == tst1u
@test sprint(show, "text/latex", tst1) == tst1u
@test latexstring(tst1u) == tst1 == LaTeXString(tst1u)

@test ccall(:strlen, Csize_t, (Cstring,), tst1) == ccall(:strlen, Csize_t, (Ptr{UInt8},), tst1) == sizeof(tst1)
