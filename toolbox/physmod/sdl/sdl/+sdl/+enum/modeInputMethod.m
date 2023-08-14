classdef modeInputMethod<int32

    enumeration
        SimscapeDetermined(1)
        UserDefined(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('SimscapeDetermined')='physmod:sdl:library:enum:SimscapeDetermined';
            map('UserDefined')='physmod:sdl:library:enum:UserDefined';
        end
    end
end



