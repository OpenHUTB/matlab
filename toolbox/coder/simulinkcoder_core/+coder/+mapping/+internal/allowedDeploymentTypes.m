function values=allowedDeploymentTypes(modelMapping)




    if isa(modelMapping,'Simulink.CoderDictionary.ModelMapping')
        values=cellfun(@coder.mapping.internal.Utils.getExternalDeploymentType,...
        modelMapping.allowedDeploymentTypes,'UniformOutput',false);
    else

        values=["Component","Subcomponent","Automatic"];
    end

end
