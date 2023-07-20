classdef linearTLU<int32

    enumeration
        linear(1)
        TLU(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('linear')='physmod:sdl:library:enum:Linear';
            map('TLU')='physmod:sdl:library:enum:TableLookup';
        end
    end
end



