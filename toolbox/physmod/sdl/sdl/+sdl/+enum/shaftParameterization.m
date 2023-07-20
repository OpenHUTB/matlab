classdef shaftParameterization<int32

    enumeration
        StiffnessInertia(1)
        MaterialProperties(2)
        StiffnessInertiaVaried(3)
        MaterialPropertiesVaried(4)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('StiffnessInertia')='physmod:sdl:library:enum:ShaftStiffness';
            map('MaterialProperties')='physmod:sdl:library:enum:ShaftMaterial';
            map('StiffnessInertiaVaried')='physmod:sdl:library:enum:ShaftStiffnessVaried';
            map('MaterialPropertiesVaried')='physmod:sdl:library:enum:ShaftMaterialVaried';
        end
    end
end