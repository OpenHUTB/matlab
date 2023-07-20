classdef handedness<int32




    enumeration
        right(1)
        left(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('right')='physmod:sdl:library:enum:RightHand';
            map('left')='physmod:sdl:library:enum:LeftHand';
        end
    end
end
