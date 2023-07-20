function[dataType,outDataType]=getNFPBlockDataType(blockHandle)





    dataType='';
    outDataType='';
    pHandles=get_param(blockHandle,'PortHandles');

    if~isempty(pHandles.Inport)&&~isempty(pHandles.Inport(1))

        dType=get_param(pHandles.Inport(1),'CompiledPortDataType');
        if strcmpi(dType,'single')
            dataType='SINGLE';
        elseif strcmpi(dType,'double')
            dataType='DOUBLE';
        elseif strcmpi(dType,'half')
            dataType='HALF';
        end
    end

    if~isempty(pHandles.Outport)&&~isempty(pHandles.Outport(1))
        dType=get_param(pHandles.Outport(1),'CompiledPortDataType');
        if strcmpi(dType,'single')
            outDataType='SINGLE';
        elseif strcmpi(dType,'double')
            outDataType='DOUBLE';
        elseif strcmpi(dType,'half')
            outDataType='HALF';
        end
    end
end

