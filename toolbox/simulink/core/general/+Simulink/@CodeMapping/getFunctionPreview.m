function preview=getFunctionPreview(mapObj,model,modelElementCategory)




    fcnName=Simulink.CodeMapping.getResolvedFunctionName(mapObj,model,modelElementCategory);

    multiInstanceId='void';
    isMdlrefMulti=strcmp(get_param(model,'ModelReferenceNumInstancesAllowed'),'Multi');
    isMdlrefZero=strcmp(get_param(model,'ModelReferenceNumInstancesAllowed'),'Zero');
    isTopMulti=strcmp(get_param(model,'CodeInterfacePackaging'),'Reusable function');
    if(isMdlrefMulti||isMdlrefZero)&&isTopMulti
        multiInstanceId='* self';
    else
        if isMdlrefMulti||isTopMulti
            multiInstanceId='[* self]';
        end
    end
    [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
    if strcmp(mappingType,'CoderDictionary')
        deploymentType=mapping.DeploymentType;
        isComponent=strcmp(deploymentType,'Component');
        isSubcomponent=strcmp(deploymentType,'Subcomponent');
        if isComponent
            if isTopMulti
                multiInstanceId='* self';
            else
                multiInstanceId='void';
            end
        elseif isSubcomponent
            if isMdlrefMulti
                multiInstanceId='* self';
            else
                multiInstanceId='';
            end
        end
    end
    if strcmp(mappingType,'CppModelMapping')
        multiInstanceId='';
    end
    preview='';
    switch(modelElementCategory)
    case 'OutputFunctionMappings'
        preview=coder.mapping.internal.StepFunctionMapping.getFunctionPreview(...
        model,mapObj);
    case 'ServerFunctions'
        preview=coder.mapping.internal.SimulinkFunctionMapping.getFunctionPreview(...
        model,mapObj.SimulinkFunctionName);
    end

    if isempty(preview)
        preview=['void ',fcnName,'(',multiInstanceId,')'];
    end
end
