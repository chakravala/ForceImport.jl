<p align="center">
  <img src="./docs/src/assets/logo.png" alt="ForceImport.jl"/>
</p>

# ForceImport.jl

*Macro that force imports conflicting methods in Julia modules*

[![Build Status](https://travis-ci.org/chakravala/ForceImport.jl.svg?branch=master)](https://travis-ci.org/chakravala/ForceImport.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/x2jruseyqtw72ktw?svg=true)](https://ci.appveyor.com/project/chakravala/forceimport-jl)

## Usage

Forces imports of exported methods from `Module`, even if there are conflicts.

```Julia
@force using Module
```

If you are using this package, then the `@force` is strong in you and the Module!

## Example

Allows using packages that export conflicting definitions of methods and imports them into the module.

```Julia
module Foo
    export +
    +() = 7
end

module Bar
    using ForceImport
    @force using Foo
end

julia> Bar.:+()
7
```

Note that if the conflicting definition of the method is used before the import, then `@force` will not be effective.

```Julia
julia> 1+1
2

julia> @force using Foo
WARNING: ignoring conflicting import of Foo.+ into Main
```

Hence the macro has to be called before the relevant methods have been called.

## Local method extension technique

The principle which all `@force` users must keep in mind is this: the goal is to extend `Base` methods locally without affecting the global method table by type piracy, and to be able to import them into another package to have the same local effect. In order to avoid the type piracy, one must define a new local complementary 
`n`-ary method that will fall back on the base method with `Any` arguments. Then there will be a tiered alternative dispatch layer within the local package scope that redirects to the default `Base` dispatch generically. This has many advantages, including a 
`2x`-improvement in precompile time (since the precompilation is now tiered), which actually makes a big difference if this technique is applied to a large number of operations (on the order of 50-100 in `Reduce`).
```Julia
module ExtendedPackage
+(x...) = Base.:+(x...)
+(x::Symbol,y::Number...) = Expr(:call,:+,x,y...)
end
```
Then you can use it locally with the `@force` macro, which automatically forces imports of all exported methods one by one;
```Julia
module NewScope
using ForceImport
@force using ExtendedPackage
end
```
You will now have the property
```Julia
julia> Base.:+ == NewScope.:+
false
```
where the `+` in the `NewScope` is now the extended plus that falls back on `Base`, which is also different from the `+` in `Main`. All it takes is the application of this principle, which has been pioneered with the development of the [Reduce.Algebra](https://github.com/chakravala/Reduce.jl/blob/382b5ff84bb66067f2f087156c6bd930c297318a/src/Reduce.jl#L105-L123) module (defined in [src/args.jl](https://github.com/chakravala/Reduce.jl/blob/master/src/args.jl) and [src/unary.jl](https://github.com/chakravala/Reduce.jl/blob/master/src/unary.jl)).

The main difficulty lies in properly designing the redirection from the tiered method dispatch so that the infix operations work naturally with a variety of syntax.
