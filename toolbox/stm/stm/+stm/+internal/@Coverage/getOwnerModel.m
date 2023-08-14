

function ownerModels=getOwnerModel(modelinfo)
    if isfield(modelinfo,'ownerModel')...
        &&~isempty(modelinfo.ownerModel)

        ownerModels=strsplit(modelinfo.ownerModel,', ');
    else

        ownerModels={Simulink.SimulationData.BlockPath.getModelNameForPath(modelinfo.analyzedModel)};
    end
end