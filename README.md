# ForceImport.jl

*Macro that force imports conflicting methods in Julia modules*

[![Build Status](https://travis-ci.org/chakravala/ForceImport.jl.svg?branch=master)](https://travis-ci.org/chakravala/ForceImport.jl)
[![Coverage Status](https://coveralls.io/repos/chakravala/ForceImport.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/chakravala/ForceImport.jl?branch=master)
[![codecov.io](http://codecov.io/github/chakravala/ForceImport.jl/coverage.svg?branch=master)](http://codecov.io/github/chakravala/ForceImport.jl?branch=master)

## Usage

```Julia
@force using ModuleName
```

Forces imports of `ModuleName`'s exported methods, even if there are conflicts.
