classdef shaftOutputDirection<int32




    enumeration
        same(1)
        opposite(-1)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('same')='physmod:sdl:library:enum:OutputSame';
            map('opposite')='physmod:sdl:library:enum:OutputOpposite';
        end
    end
end
