classdef AdvanceVelocityRange<int32





    enumeration
        Positive(1)
        PositiveAndNegative(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Positive')='physmod:sdl:library:enum:PropellerPolynomialPositiveJ';
            map('PositiveAndNegative')='physmod:sdl:library:enum:PropellerPolynomialPositiveNegativeJ';
        end
    end
end
