function title=getTitleForEmbeddedCoderCPP(modelHandle,readOnlyText)




    modelMapping=Simulink.CodeMapping.getCurrentMapping(modelHandle);
    if~isempty(modelMapping)
        if isequal(modelMapping.DeploymentType,'Component')
            title=DAStudio.message('coderdictionary:mapping:CodeMappingsComponent',readOnlyText);
        elseif isequal(modelMapping.DeploymentType,'Subcomponent')
            title=DAStudio.message('coderdictionary:mapping:CodeMappingsSubAssembly',readOnlyText);
        else
            title=DAStudio.message('coderdictionary:mapping:CodeMappingsCpp',readOnlyText);
        end
    else
        title=DAStudio.message('coderdictionary:mapping:CodeMappingsCpp',readOnlyText);
    end
end
