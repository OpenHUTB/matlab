classdef directionality<int32




    enumeration
        bidirectional(0)
        unidirectional(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('bidirectional')='physmod:sdl:library:enum:Bidirectional';
            map('unidirectional')='physmod:sdl:library:enum:Unidirectional';
        end
    end
end