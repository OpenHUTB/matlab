classdef PLCTypeConverter<handle

    properties
        fTargetIDE;
    end

    properties(Constant)
        GenericST2MLTypeMap_Data={...
        'BOOL','boolean';...
        'SINT','int8';...
        'USINT','uint8';...
        'INT','int16';...
        'UINT','uint16';...
        'DINT','int32';...
        'UDINT','uint32';...
        'REAL','single';...
        'LREAL','double';...
        };
        RockwellST2MLTypeMap_Data={...
        'BOOL','int16';...
        'SINT','int16';...
        'USINT','int16';...
        'INT','int16';...
        'UINT','int32';...
        'DINT','int32';...
        'UDINT','int32';...
        'REAL','single';...
        'LREAL','single';...
        };
    end

    methods(Static)
        function type_map=genTypeMap(type_map_data)
            type_map=containers.Map('KeyType','char','ValueType','char');
            [num_type_list,]=size(type_map_data);
            for i=1:num_type_list
                type_map(type_map_data{i,1})=type_map_data{i,2};
            end
        end

        function typ=convertType(target,typ)
            import PLCCoder.extmode.PLCTypeConverter;
            persistent GenericST2MLTypeMap;
            persistent RockwellST2MLTypeMap;

            if isempty(GenericST2MLTypeMap)
                GenericST2MLTypeMap=PLCTypeConverter.genTypeMap(PLCTypeConverter.GenericST2MLTypeMap_Data);
                RockwellST2MLTypeMap=PLCTypeConverter.genTypeMap(PLCTypeConverter.RockwellST2MLTypeMap_Data);
            end
            switch target
            case{'rslogix5000','studio5000'}
                typ=RockwellST2MLTypeMap(typ);
            otherwise
                typ=GenericST2MLTypeMap(typ);
            end
        end

        function typ_list=convertTypeList(target,typ_list)
            import PLCCoder.extmode.PLCTypeConverter;
            typ_list=cellfun(@(typ)PLCTypeConverter.convertType(target,typ),typ_list,'UniformOutput',false);
        end
    end

    methods
        function obj=PLCTypeConverter(target_ide)
            obj.fTargetIDE=target_ide;
        end

    end
end


