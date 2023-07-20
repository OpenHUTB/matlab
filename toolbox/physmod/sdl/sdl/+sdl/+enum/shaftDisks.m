classdef shaftDisks<int32

    enumeration
        none(1)
        point(2)
        disk(3)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('none')='physmod:sdl:library:enum:None';
            map('point')='physmod:sdl:library:enum:PointMass';
            map('disk')='physmod:sdl:library:enum:Disk';
        end
    end
end



