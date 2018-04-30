__precompile__()
module ForceImport

#   This file is part of ForceImport.jl. It is licensed under the MIT license
#   Copyright (C) 2018 Michael Reed

export @force

# adds exported items to import list
function extend_list!(list,expr)
    if typeof(expr) == Expr
        for erg ∈ (expr.head == :block ? expr.args : [expr])
            if typeof(erg) == Expr && erg.head == :export
                push!(list,erg.args...)
            end
        end
    end
end

# searches Julia module for exports
function extend_find!(list,args,pkg)
    for arg ∈ args
        if typeof(arg) == Expr
            if arg.head == :export
                push!(list,arg.args...)
            elseif (arg.head == :call && (arg.args[1] == :eval ||
                    (arg.args[1] == :|> && arg.args[3] == :eval))) ||
                    (arg.head == :macrocall && arg.args[1] == Symbol("@eval"))
                extend_list!(list,arg.args[2])
            elseif (arg.head == :call && arg.args[1] == :include)
                nargs = nothing
                open(joinpath(Pkg.dir(pkg),"src",arg.args[2])) do f
                    nargs = "module foo\n"*readstring(f)*"\nend"
                end
                extend_find!(list,parse(nargs).args[3].args,pkg)
            end
        end
    end
end

"""

    @force using ModuleName

Forces imports of `ModuleName`'s exports, even if there are conflicts.
"""
macro force(import_module)
    import_module.head ≠ :using && throw(error("not a using statement"))
    pkg = string(import_module.args[1])
    args = nothing
    open(joinpath(Pkg.dir(pkg),"src","$pkg.jl")) do f
        args = readstring(f)
    end
    list = []
    extend_find!(list,parse(args).args[3].args,pkg)
    return Expr(:toplevel,[Expr(:import,import_module.args[1],j) for j ∈ list]...)
end

__init__() = nothing

end # module
