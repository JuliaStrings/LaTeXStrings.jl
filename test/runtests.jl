using LaTeXStrings
using Base.Test

# write your own tests here
tst1 = L"an equation: $\alpha^2$"
tst1u = utf8(tst1)
@test tst1 == "an equation: \$\\alpha^2\$" == tst1u
@test L"\alpha^2" == "\$\\alpha^2\$"
@test stringmime("text/latex", tst1) == tst1u
buf = IOBuffer()
writemime(buf, "text/latex", tst1)
@test takebuf_string(buf) == tst1u
