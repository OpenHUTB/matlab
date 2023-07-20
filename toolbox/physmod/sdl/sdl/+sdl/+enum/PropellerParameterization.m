classdef PropellerParameterization<int32




    enumeration
        Constant(1)
        PolynomialFit(2)
        Tabulated(3)
        TabulatedBeta(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Constant')='physmod:sdl:library:enum:PropellerConstant';
            map('PolynomialFit')='physmod:sdl:library:enum:PropellerPolynomial';
            map('Tabulated')='physmod:sdl:library:enum:PropellerTabulated';
            map('TabulatedBeta')='physmod:sdl:library:enum:PropellerTabulatedBeta';
        end
    end
end
