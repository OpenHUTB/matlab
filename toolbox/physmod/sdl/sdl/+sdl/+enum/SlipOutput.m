classdef SlipOutput<int32




    enumeration
        Relative(1)
        Absolute(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Relative')='physmod:sdl:library:enum:Relative';
            map('Absolute')='physmod:sdl:library:enum:Absolute';
        end
    end
end
