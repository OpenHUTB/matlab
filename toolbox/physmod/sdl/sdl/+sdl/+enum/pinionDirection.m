classdef pinionDirection<int32

    enumeration
        negative(-1)
        positive(1)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('negative')='physmod:sdl:library:enum:NegativePinion';
            map('positive')='physmod:sdl:library:enum:PositivePinion';
        end
    end
end
