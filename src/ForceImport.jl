__precompile__()
module ForceImport

#   This file is part of ForceImport.jl. It is licensed under the MIT license
#   Copyright (C) 2018 Michael Reed

export @force

"""

    @force using ModuleName

Forces imports of `ModuleName`'s exports, even if there are conflicts.
"""
macro force(import_module)
    import_module.head ≠ :using && throw(error("not a using statement"))
    pkgs = import_module.args
    out = []
    for pkg ∈ pkgs
        s=:(Expr(:toplevel,[Expr(:import,Symbol($(string(pkg))),j) for j∈names($pkg)]...))
        push!(out,:(import $pkg),:(eval($s)))
    end
    return Expr(:block,out...)
end

__init__() = nothing

end # module
