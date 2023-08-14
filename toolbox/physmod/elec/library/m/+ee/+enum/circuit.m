classdef circuit<int32
    enumeration
        open(1)
        short(2)
    end
    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('open')='physmod:ee:library:comments:enum:circuit:map_OpenCircuit';
            map('short')='physmod:ee:library:comments:enum:circuit:map_ShortCircuit';
        end
    end
end
