classdef DisabledEnabled<int32




    enumeration
        Disabled(1)
        Enabled(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Disabled')='physmod:sdl:library:enum:Disabled';
            map('Enabled')='physmod:sdl:library:enum:Enabled';
        end
    end
end
