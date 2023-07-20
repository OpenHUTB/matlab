classdef rodParameterization<int32

    enumeration
        stiffnessInertia(1)
        materialProperties(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('stiffnessInertia')='physmod:sdl:library:enum:ShaftStiffness';
            map('materialProperties')='physmod:sdl:library:enum:ShaftMaterial';
        end
    end
end