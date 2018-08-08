using ForceImport
VERSION > v"0.7-" ? (using Test) : (using Base.Test)

module Foo
    export +
    +() = 7
end

module Bar
    using ForceImport
    @force using Main.Foo
end

# write your own tests here
@test Bar.:+() == 7
@test 1+1 == 2
