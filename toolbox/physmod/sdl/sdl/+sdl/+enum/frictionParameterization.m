classdef frictionParameterization<int32




    enumeration
        geometry(1)
        efficiencies(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('geometry')='physmod:sdl:library:enum:FrictionGeometry';
            map('efficiencies')='physmod:sdl:library:enum:Efficiencies';
        end
    end
end
