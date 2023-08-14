classdef MxArrayToProtoFactory<handle




    properties(Constant)
        elemTable=struct(...
        'uint8','uint8_element',...
        'int8','int8_element',...
        'uint16','uint16_element',...
        'int16','int16_element',...
        'uint32','uint32_element',...
        'int32','int32_element',...
        'uint64','uint64_element',...
        'int64','int64_element',...
        'single','single_element',...
        'double','double_element',...
        'logical','logical_element',...
        'char','char_element',...
        'string','string_element'...
        );
    end

    methods(Static)


        function numValue=getNumberObject(data)
            numType=class(data);
            numValue=mathworks.scenario.common.Number;


            element=ssm.sl_agent_metadata.internal.MxArrayToProtoFactory.getData(data);
            numValue.(ssm.sl_agent_metadata.internal.MxArrayToProtoFactory.elemTable.(numType))=element;
        end

        function vArray=getArrayObject(data)
            vArray=mathworks.scenario.common.Array;
            vArray.dimensions=uint64(size(data));

            if isempty(data);return;end

            dataType=class(data);

            for idx=numel(data):-1:1
                vValue(idx)=mathworks.scenario.common.Value;
                vValue(idx).(ssm.sl_agent_metadata.internal.MxArrayToProtoFactory.elemTable.(dataType))=...
                ssm.sl_agent_metadata.internal.MxArrayToProtoFactory.getData(data(idx));
            end
            vArray.elements=vValue;
        end

        function vStruct=getStructElement(data)
            vStruct=mathworks.scenario.common.Struct;
            fieldNames=fields(data);



            if isempty(fieldNames);return;end

            for idx=length(fieldNames):-1:1
                fieldValue=data.(fieldNames{idx});
                buf(idx)=ssm.sl_agent_metadata.MxArrayToProto(fieldValue);
            end

            vStruct.names=fieldNames;
            vStruct.elements=buf;
        end
    end

    methods(Static)
        function ret=getData(data)

            switch class(data)
            case 'uint8'
                ret=uint32(data(:));
            case 'int8'
                ret=int32(data(:));
            case 'uint16'
                ret=uint32(data(:));
            case 'int16'
                ret=int32(data(:));
            case 'uint32'
                ret=data(:);
            case 'int32'
                ret=data(:);
            case 'uint64'
                ret=data(:);
            case 'int64'
                ret=data(:);
            case 'single'
                ret=data(:);
            case 'double'
                ret=data(:);
            case 'logical'
                ret=data(:);
            case 'char'
                ret=uint32(data(:));
            otherwise
                ret=[];
            end
        end
    end
end
