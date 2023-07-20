function[busName,dimensions,virtuality]=util_getTopLvlBusDataForBEP(blockH)













    busName=[];
    dimensions=-1;
    virtuality=[];
    if~isBusElem(blockH)
        return;
    end


    rootElementBlock=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(blockH);
    rootElementPort=rootElementBlock.port;
    rootTree=rootElementPort.tree;
    rootElementNode=Simulink.internal.CompositePorts.TreeNode.findNode(rootTree,'');
    virtuality=Simulink.internal.CompositePorts.TreeNode.getVirtuality(rootElementNode);
    busDataType=Simulink.internal.CompositePorts.TreeNode.getDataType(rootElementNode);

    if(strcmp(get_param(blockH,'BlockType'),'Outport')&&...
        (isempty(get_param(blockH,'Element'))&&...
        strcmp(busDataType,'Inherit: auto')))||...
        util_is_builtin_or_fxp_type(busDataType)












        [busName,dimensions,virtuality]=getCompileTimeBlockParams(blockH);




        if~util_is_builtin_or_fxp_type(busDataType)&&strcmp(get_param(blockH,'BlockType'),'Outport')
            busName=Simulink.internal.CompositePorts.TreeNode.getDataType(rootElementNode);
            dimensions=-1;
            busName=getDataType(busName);
        end
        return;
    end


    dimensions=Simulink.internal.CompositePorts.TreeNode.getDims(rootElementNode);
    dimensions=util_resolve_dimensions(dimensions,bdroot(blockH));
    if dimensions==-1
        [~,dimensions,~]=getCompileTimeBlockParams(blockH);
    end

    if strcmp(virtuality,'INHERIT')
        [~,~,virtuality]=getCompileTimeBlockParams(blockH);
    end
    busName=getDataType(busDataType);
end

function dataType=getDataType(busDataType)


    dataType=busDataType;
    tempBusNamesArr=strsplit(busDataType,': ');


    if length(tempBusNamesArr)>1
        dataType=tempBusNamesArr{2};
    end
end

function[type,dimensions,virtuality]=getCompileTimeBlockParams(blockH)


    [compiledportPrm,portH]=getCompileDataForInOutPorts(blockH);
    type=compiledportPrm.DataType;
    dimensions=util_resolve_dimensions(compiledportPrm.Dimensions,bdroot(blockH));
    virtuality=get_param(portH,'CompiledBusType');
    if strcmp(virtuality,'VIRTUAL_BUS')
        virtuality='VIRTUAL';
    else
        virtuality='NON_VIRTUAL';
    end
end

function[compiledportPrm,portH]=getCompileDataForInOutPorts(blockH)





    if strcmp(get_param(blockH,'BlockType'),'Inport')
        portTypeConnected='Outport';
    else
        portTypeConnected='Inport';
    end
    ph=get_param(blockH,'porthandles');
    portH=ph.(portTypeConnected);
    compiledportPrm=Simulink.CompiledPortInfo(portH);
end

