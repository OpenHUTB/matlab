classdef hubRingDirection<int32

    enumeration
        positive(1)
        negative(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('positive')='physmod:sdl:library:enum:HubRingPositive';
            map('negative')='physmod:sdl:library:enum:HubRingNegative';
        end
    end
end