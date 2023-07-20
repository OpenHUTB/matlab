classdef inductancesparam<int32
    enumeration
        constant(1)
        tabulated(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('constant')='physmod:ee:library:comments:enum:sm:inductancesparam:map_ConstantLdLqLmfAndLf';
            map('tabulated')='physmod:ee:library:comments:enum:sm:inductancesparam:map_TabulatedLdLqLmfAndLf';
        end
    end
end
