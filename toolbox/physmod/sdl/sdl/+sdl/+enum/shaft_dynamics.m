classdef shaft_dynamics<int32




    enumeration
        Off(0)
        On(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Off')='physmod:sdl:library:enum:ShaftDynamicsOff';
            map('On')='physmod:sdl:library:enum:ShaftDynamicsOn';
        end
    end
end
