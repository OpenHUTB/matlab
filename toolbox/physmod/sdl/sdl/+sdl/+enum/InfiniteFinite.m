classdef InfiniteFinite<int32




    enumeration
        Infinite(1)
        Finite(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Infinite')='physmod:sdl:library:enum:Infinite';
            map('Finite')='physmod:sdl:library:enum:Finite';
        end
    end
end
