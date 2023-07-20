function title=getTitleForEmbeddedCoderC(modelHandle,readOnlyText)




    modelMapping=Simulink.CodeMapping.getCurrentMapping(modelHandle);
    if~isempty(modelMapping)&&slfeature('DeploymentTypeInCMapping')>0


        if isequal(modelMapping.DeploymentType,'Component')
            title=DAStudio.message('coderdictionary:mapping:CodeMappingsComponent',readOnlyText);
        elseif isequal(modelMapping.DeploymentType,'Subcomponent')
            title=DAStudio.message('coderdictionary:mapping:CodeMappingsSubAssembly',readOnlyText);
        else
            title=DAStudio.message('coderdictionary:mapping:CodeMappingsC',readOnlyText);
        end
    elseif slfeature('DefaultsSSInCMapping')==1
        title=DAStudio.message('coderdictionary:mapping:CodeMappingsNCDefault',readOnlyText);
    else
        title=DAStudio.message('coderdictionary:mapping:CodeMappingsC',readOnlyText);
    end
end
