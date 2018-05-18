__precompile__()
module ForceImport

#   This file is part of ForceImport.jl. It is licensed under the MIT license
#   Copyright (C) 2018 Michael Reed

export @force, @merge

"""

        @force using Module

Forces imports of exported methods from `Module`, even if there are conflicts.
"""
macro force(use)
    use.head ∉ [:using,:toplevel] && throw(error("$use not a using statement"))
    pkgs = use.head ≠ :using ? use.args : [use]
    out = []
    for p ∈ pkgs
        m = p.args[end]
        s = :([Expr(:import,Symbol($(string(m))),j) for j ∈ names($(esc(m)))])
        push!(out,Expr(:import,p.args...),:($(esc(:eval))(Expr(:toplevel,$s...))))
    end
    return Expr(:block,out...)
end

"""

        ForceImport.@port using Module

Force exports methods from `Module` in current module.
"""
macro port(use)
    use.head ∉ [:using,:toplevel] && throw(error("$use not a using statement"))
    pkgs = use.head ≠ :using ? use.args : [use]
    out = []
    for p ∈ pkgs
        m = p.args[end]
        s = :([Expr(:export,Symbol($(string(m))),j) for j ∈ names($(esc(m)))])
        push!(out,Expr(:export,p.args...),:($(esc(:eval))(Expr(:toplevel,$s...))))
    end
    return Expr(:block,out...)
end

"""

        @merge fun(x) = x

Automatically imports `fun` from its module if necessary for function definition.
"""
macro merge(expr)
    if !( (expr.head == :function) | ( (expr.head == :(=)) &&
            (typeof(expr.args[1]) == Expr) && (expr.args[1].head == :call) ) )
        throw(error("ForceImport: $expr is not a function definition"))
    end
    fun = expr.args[1].args[1]
    return Expr(:quote,quote
        for name in names(current_module())
            try
                eval(ForceImport.imp($(string(fun)),name))
            end
        end
        eval($(Expr(:quote,expr)))
    end)
end

function imp(fun::String,name::Symbol)
    :(Symbol($fun) ∈ names($name) && (import $name.$(Symbol(fun))))
end

__init__() = nothing

end # module
