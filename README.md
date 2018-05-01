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
