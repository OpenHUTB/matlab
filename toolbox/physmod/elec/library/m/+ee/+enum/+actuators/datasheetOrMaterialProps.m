classdef datasheetOrMaterialProps<int32





    enumeration
        datasheet(1)
        materials(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('datasheet')='physmod:ee:library:comments:enum:actuators:datasheetOrMaterialProps:map_datasheet';
            map('materials')='physmod:ee:library:comments:enum:actuators:datasheetOrMaterialProps:map_materials';
        end
    end
end