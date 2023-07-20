classdef L5XTypeMap<handle



    methods(Static)
        function ret=mapData
            import plccore.type.*;
            L5XTypeMap_Data={...
            'BOOL',BOOLType;...
            'SINT',SINTType;...
            'INT',INTType;...
            'DINT',DINTType;...
            'REAL',REALType;...
            };
            ret=L5XTypeMap_Data;
        end

        function type_map=genTypeMap(type_map_data)
            type_map=containers.Map('KeyType','char','ValueType','any');
            [num_type_list,]=size(type_map_data);
            for i=1:num_type_list
                type_map(type_map_data{i,1})=type_map_data{i,2};
            end
        end

        function typ=map(typ_name)
            import plccore.frontend.L5XTypeMap;
            persistent typ_map;
            typ=[];
            if isempty(typ_map)
                typ_map=L5XTypeMap.genTypeMap(L5XTypeMap.mapData);
            end
            if typ_map.isKey(typ_name)
                typ=typ_map(typ_name);
            elseif strcmpi(typ_name,'STRING')
                import plccore.common.plcThrowError;
                plcThrowError('plccoder:plccore:UnsupportedTypeString',typ_name);
            elseif strcmpi(typ_name,'LINT')
                import plccore.common.plcThrowError;
                plcThrowError('plccoder:plccore:UnsupportedTypeString',typ_name);
            end
        end
    end
end


