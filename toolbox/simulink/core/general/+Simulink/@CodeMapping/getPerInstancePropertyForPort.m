








function value=getPerInstancePropertyForPort(modelH,portH,...
    propertyName)

    modelMapping=Simulink.CodeMapping.getCurrentMapping(modelH);
    assert(isa(modelMapping,'Simulink.CoderDictionary.ModelMapping'));

    modelName=get_param(modelH,'Name');
    parentBlock=get_param(portH,'Parent');
    if isequal(get_param(parentBlock,'BlockType'),'Inport')&&...
        isequal(get_param(parentBlock,'Parent'),modelName)

        mappingType='inport mapping';
        modelIdentifierType='Inport block';
        modelIdentifier=parentBlock;
        elemMapping=modelMapping.Inports.findobj('Block',parentBlock);
    else

        mappingType='signal mapping';
        modelIdentifierType='port handle';
        modelIdentifier=portH;
        elemMapping=modelMapping.Signals.findobj('PortHandle',portH);
    end
    assert(length(elemMapping)==1)

    value=coder.mapping.internal.getIndividualDataProperty(...
    modelH,elemMapping,propertyName,mappingType,...
    modelIdentifierType,modelIdentifier);
end
