classdef translationalDetentParameterization<int32

    enumeration
        force(1)
        tlu(2)
        geometry(3)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('force')='physmod:sdl:library:enum:ForceWidth';
            map('tlu')='physmod:sdl:library:enum:TableLookup';
            map('geometry')='physmod:sdl:library:enum:Geometry';
        end
    end
end