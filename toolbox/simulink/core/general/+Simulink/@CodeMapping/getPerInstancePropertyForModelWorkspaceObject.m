








function value=getPerInstancePropertyForModelWorkspaceObject(modelH,uuid,...
    propertyName)

    modelMapping=Simulink.CodeMapping.getCurrentMapping(modelH);
    assert(isa(modelMapping,'Simulink.CoderDictionary.ModelMapping'));

    elemMapping=modelMapping.ModelScopedParameters.findobj('UUID',uuid);
    if isempty(elemMapping)
        mappingType='data store mapping';
        modelIdentifierType='model workspace signal object';
        elemMapping=modelMapping.SynthesizedLocalDataStores.findobj('UUID',uuid);
        modelIdentifier=elemMapping.Name;
    else
        mappingType='model parameter mapping';
        modelIdentifierType='model workspace parameter object';
        modelIdentifier=elemMapping.Parameter;
    end
    assert(length(elemMapping)==1)

    value=coder.mapping.internal.getIndividualDataProperty(...
    modelH,elemMapping,propertyName,mappingType,...
    modelIdentifierType,modelIdentifier);
end
