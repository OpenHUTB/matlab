classdef polynomialTLU<int32

    enumeration
        polynomial(1)
        tlu(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('polynomial')='physmod:sdl:library:enum:Polynomial';
            map('tlu')='physmod:sdl:library:enum:TableLookup';
        end
    end
end
