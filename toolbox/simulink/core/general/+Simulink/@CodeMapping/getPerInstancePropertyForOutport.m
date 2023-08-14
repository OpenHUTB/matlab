








function value=getPerInstancePropertyForOutport(modelH,blockH,...
    propertyName)
    mappingType='outport mapping';
    modelIdentifierType='Outport block';

    modelMapping=Simulink.CodeMapping.getCurrentMapping(modelH);
    assert(isa(modelMapping,'Simulink.CoderDictionary.ModelMapping'));

    SLBlockPath=getfullname(blockH);
    blockMapping=modelMapping.Outports.findobj('Block',SLBlockPath);
    assert(length(blockMapping)==1)

    value=coder.mapping.internal.getIndividualDataProperty(...
    modelH,blockMapping,propertyName,mappingType,...
    modelIdentifierType,SLBlockPath);
end
