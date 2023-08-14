classdef differential_orientation<int32




    enumeration
        left(1)
        right(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('left')='physmod:sdl:library:enum:LeftCenterline';
            map('right')='physmod:sdl:library:enum:RightCenterline';
        end
    end
end
