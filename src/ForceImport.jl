__precompile__()
module ForceImport

#   This file is part of ForceImport.jl. It is licensed under the MIT license
#   Copyright (C) 2018 Michael Reed

export @force

"""

    @force using ModuleName

Forces imports of `ModuleName`'s exports, even if there are conflicts.
"""
macro force(mod)
    mod.head ∉ [:using,:toplevel] && throw(error("$mod not a using statement"))
    pkgs = mod.head ≠ :using ? mod.args : [mod]
    out = []
    for p ∈ pkgs
	m = p.args[end]
	s = :([Expr(:import,Symbol($(string(m))),j) for j ∈ names($(esc(m)))])
	push!(out,Expr(:import,p.args...),:($(esc(:eval))(Expr(:toplevel,$s...))))
    end
    return Expr(:block,out...)
end

__init__() = nothing

end # module
