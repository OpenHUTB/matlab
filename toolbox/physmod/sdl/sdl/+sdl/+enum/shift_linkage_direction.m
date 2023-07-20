classdef shift_linkage_direction<int32




    enumeration
        positive(1)
        negative(-1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('positive')='physmod:sdl:library:enum:PositiveShiftLinkage';
            map('negative')='physmod:sdl:library:enum:NegativeShiftLinkage';
        end
    end
end
