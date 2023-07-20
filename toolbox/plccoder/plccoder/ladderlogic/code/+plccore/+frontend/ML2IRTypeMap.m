classdef ML2IRTypeMap<handle



    methods(Static)
        function ret=mapData
            import plccore.type.*;
            ML2IRTypeMap_Data={...
            'BOOL',BOOLType;...
            'SINT',SINTType;...
            'INT',INTType;...
            'DINT',DINTType;...
            'REAL',REALType;...
            'BOOLEAN',BOOLType;...
            'INT8',SINTType;...
            'INT16',INTType;...
            'INT32',DINTType;...
            'SINGLE',REALType;...
            };
            ret=ML2IRTypeMap_Data;
        end

        function type_map=genTypeMap(type_map_data)
            type_map=containers.Map('KeyType','char','ValueType','any');
            [num_type_list,]=size(type_map_data);
            for i=1:num_type_list
                type_map(type_map_data{i,1})=type_map_data{i,2};
            end
        end

        function typ=map(typ_name)
            import plccore.frontend.ML2IRTypeMap;
            persistent typ_map;
            typ=[];
            if isempty(typ_map)
                typ_map=ML2IRTypeMap.genTypeMap(ML2IRTypeMap.mapData);
            end
            if typ_map.isKey(typ_name)
                typ=typ_map(typ_name);
            end
        end
    end
end


