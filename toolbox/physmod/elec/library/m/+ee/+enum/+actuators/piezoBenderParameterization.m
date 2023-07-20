classdef piezoBenderParameterization<int32




    enumeration
        datasheet(1)
        material(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('datasheet')='physmod:ee:library:comments:enum:actuators:piezoBenderParameterization:map_Datasheet';
            map('material')='physmod:ee:library:comments:enum:actuators:piezoBenderParameterization:map_Material';
        end
    end
end