function[dType,w,nd,dims]=getSignalInfo(blkH)
    blkData=get(blkH);
    portDataType=get_param(blkH,'OutDataTypeStr');
    if~isempty(blkData.CompiledPortDataTypes)&&~isempty(blkData.CompiledPortDataTypes.Outport)
        if strcmp(portDataType,'Inherit: auto')
            dType=blkData.CompiledPortDataTypes.Outport{1};
        else
            dType=portDataType;
        end
    else
        if strcmp(portDataType,'Inherit: auto')
            dType='double';
        else
            dType=portDataType;
        end
    end
    if strcmp(get_param(blkH,'BlockType'),'TriggerPort')
        if strcmp(get_param(blkH,'TriggerType'),'function-call')
            dType='fcn_call';
        end
    end

    dims=[];
    if~isempty(blkData.CompiledPortDimensions)
        dims=int32(blkData.CompiledPortDimensions.Outport);
    end
    if isempty(dims)
        dims=int32(str2num(get_param(blkH,'PortDimensions')));
    else
        dims=dims(2:end);
    end
    w=prod(dims);
    nd=length(dims);
end
