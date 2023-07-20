








function value=getPerInstancePropertyForStateOrDSM(modelH,blockH,...
    propertyName)

    modelMapping=Simulink.CodeMapping.getCurrentMapping(modelH);
    assert(isa(modelMapping,'Simulink.CoderDictionary.ModelMapping'));

    SLBlockPath=getfullname(blockH);
    if isequal(get_param(blockH,'BlockType'),'DataStoreMemory')

        mappingType='state mapping';
        modelIdentifierType='Simulink block';
        elemMapping=modelMapping.DataStores.findobj('OwnerBlockHandle',blockH);
    else

        mappingType='data store mapping';
        modelIdentifierType='Simulink block';
        elemMapping=modelMapping.States.findobj('OwnerBlockHandle',blockH);
    end

    assert(length(elemMapping)==1)

    value=coder.mapping.internal.getIndividualDataProperty(...
    modelH,elemMapping,propertyName,mappingType,...
    modelIdentifierType,SLBlockPath);
end
