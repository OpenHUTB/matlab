classdef rope_model<int32




    enumeration
        ideal(1)
        slack(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('ideal')='physmod:sdl:library:enum:RopeIdeal';
            map('slack')='physmod:sdl:library:enum:RopeSlack';
        end
    end
end
