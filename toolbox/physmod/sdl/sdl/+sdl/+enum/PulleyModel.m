classdef PulleyModel<int32




    enumeration
        Continuous(1)
        Modal(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Continuous')='physmod:sdl:library:enum:Continuous';
            map('Modal')='physmod:sdl:library:enum:Modal';
        end
    end
end
