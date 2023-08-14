function[aobHierarchy,leafSignalOffset,portBusTypes,msgPortIdxs]=...
    retrieveAoBHierarchy(model,blockHandles,extInputs)












    numInports=length(blockHandles);
    aobHierarchy=cell(1,numInports);
    leafSignalOffset=cell(1,numInports);
    portBusTypes=cell(1,numInports);
    msgPortIdxs=false(1,numInports);
    for rootInportIdx=1:numInports
        portHandles=get_param(blockHandles(rootInportIdx),'PortHandles');
        portHandle=portHandles.Outport;
        datatypeName=get_param(portHandle,'CompiledPortDataType');
        dimensions=get_param(portHandle,'CompiledPortDimensions');
        dimensions(1)=[];
        complexity=get_param(portHandle,'CompiledPortComplexSignal');
        portBusTypes{rootInportIdx}=get_param(portHandle,'CompiledBusType');
        units='';
        compUnit=get_param(blockHandles(rootInportIdx),'CompiledPortUnits');
        units=compUnit.Outport{1};
        [aobHierarchy{rootInportIdx},leafSignalOffset{rootInportIdx}]=...
        slInternal(...
        'busDiagnostics',...
        'getAobHierarchy',...
        model,...
        datatypeName,...
        dimensions,...
        complexity,...
units...
        );

        msg=get_param(blockHandles(rootInportIdx),'CompiledPortIsMessage');
        msgPortIdxs(rootInportIdx)=msg.Outport;
    end
end


