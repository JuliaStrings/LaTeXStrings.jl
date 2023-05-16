[![Build Status](https://github.com/JuliaStrings/LaTeXStrings.jl/workflows/CI/badge.svg)](https://github.com/JuliaStrings/LaTeXStrings.jl/actions)

# LaTeXStrings

This is a small package to make it easier to type LaTeX equations in
string literals in the [Julia language](http://julialang.org/),
written by [Steven G. Johnson](http://math.mit.edu/~stevenj).

With ordinary strings in Julia, to enter a string literal with
embedded LaTeX equations you need to manually escape all backslashes
and dollar signs: for example, `$\alpha^2$` is written
`\$\\alpha^2\$`.  Also, even though
[IJulia](https://github.com/JuliaLang/IJulia.jl) is capable of
displaying formatted LaTeX equations (via
[MathJax](http://www.mathjax.org/)), an ordinary string will not
exploit this.  Therefore, the LaTeXStrings package defines:

* A `LaTeXString` class (a subtype of `String`), which works like
  a string (for indexing, conversion, etcetera), but automatically displays
  as `text/latex` in IJulia.

* `L"..."` and `L"""..."""` string macros which allow you to enter
  LaTeX equations without escaping backslashes and dollar signs
  (and which add the dollar signs for you if you omit them).
  
## FAQ: Not a LaTeX renderer

LaTeXStrings does **not do any rendering** — its sole purpose is to make it easier to *enter* LaTeX-rendered strings without typing a lot of [backslash escapes](https://xkcd.com/1638), as well as providing a type to tell [display backends](https://docs.julialang.org/en/v1/base/io-network/#Multimedia-I/O) to use LaTeX rendering if possible.

Other packages like plotting software, [Jupyter notebooks](https://github.com/JuliaLang/IJulia.jl), [Pluto](https://github.com/fonsp/Pluto.jl), etcetera, are responsible for the LaTeX rendering (if any).  For example, they might use [MathJax](https://www.mathjax.org/), [MathTeXEngine.jl](https://github.com/Kolaru/MathTeXEngine.jl), or [other renderers](https://matplotlib.org/2.0.2/users/mathtext.html).   LaTeXStrings only provides the LaTeX text to these backend, and has no influence on what LaTeX features (if any) are supported.

## Usage

After installing LaTeXStrings with `Pkg.add("LaTeXStrings")` in Julia, run

```
using LaTeXStrings
```

to load the package.  At this point, you can construct `LaTeXString`
literals with the constructor `L"..."` (and `L"""..."""` for multi-line
strings); for example `L"1 + \alpha^2"` or `L"an equation: $1 +
\alpha^2$"`.  (Note that `$` is added automatically around your
string, i.e. the string is interpreted as an equation, if you do not
include `$` yourself.)

If you want to perform [string
interpolation](https://docs.julialang.org/en/v1/manual/strings/#string-interpolation)
(inserting the values of other variables into your string), use `%$` instead of
the plain `$` that you would use for interpolation in ordinary Julia strings.
For example, if `x=3` is a Julia variable, then `L"y = %$x"` will produce `L"y = 3"`.

You can also use the lower-level constructor `latexstring(args...)`,
which works much like `string(args...)` except that it produces a
`LaTeXString` result and automatically puts `$` at the beginning and
end of the string if an unescaped `$` is not already present.  Note
that with `latexstring(...)` you *do* have to escape `$` and `\`: for
example, `latexstring("an equation: \$1 + \\alpha^2\$")`.
Note that you can supply multiple arguments (of any types) to `latexstring`, which are converted to
strings and concatenated as in the `string(...)` function.

Finally, you can use the lowest-level constructor
`LaTeXString(s)`.  The only advantage of this is that it
does *not* automatically put `$` at the beginning and end of the
string.  So, if for some reason you want to use `text/latex` display
of ordinary text (with no equations or formatting), you can use this
constructor.  (Note that IJulia *only* formats LaTeX equations; other
LaTeX text-formatting commands like `\emph` are ignored.)

## Author

This package was written by [Steven
G. Johnson](http://math.mit.edu/~stevenj/), and is distributed under
the MIT/expat license (see the [LICENSE.md](LICENSE.md) file).
