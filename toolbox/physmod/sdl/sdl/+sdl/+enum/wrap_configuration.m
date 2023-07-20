classdef wrap_configuration<int32




    enumeration
        open(1)
        crossed(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('open')='physmod:sdl:library:enum:OpenBelt';
            map('crossed')='physmod:sdl:library:enum:CrossedBelt';
        end
    end
end
