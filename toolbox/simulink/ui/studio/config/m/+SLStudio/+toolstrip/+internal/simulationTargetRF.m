



function simulationTargetRF(cbinfo,action)
    action.enabled=true;
    modelName=SLStudio.Utils.getModelName(cbinfo,false);
    bdType=get_param(modelName,'BlockDiagramType');
    if(strcmpi(bdType,'subsystem'))
        action.enabled=false;
    end
end
