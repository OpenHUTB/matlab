function portDims=getCompiledPortDimsForBlock(blockH)



    oc=compileModel(blockH);

    pHs=get_param(blockH,'PortHandles');
    num=length(pHs.Inport);

    portDims=1;
    for i=1:num
        portDims=get_param(pHs.Inport(i),'CompiledPortDimensions');
        portDims=portDims(2:end);
        if 1~=prod(portDims)
            break;
        end
    end

    if 1==numel(portDims)
        portDims=[portDims,1];
    end
end


function oc=compileModel(blockH)
    modelName=get_param(bdroot(blockH),'Name');
    oc=[];
    simStatus=get_param(modelName,'SimulationStatus');
    compStatus=strcmp(simStatus,'paused')||strcmp(simStatus,'initializing');
    if~compStatus
        feval(modelName,[],[],[],'compile');
        oc=onCleanup(@()feval(modelName,[],[],[],'term'));
    end
end