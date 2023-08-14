function createCoderDictionaryAndMappingForERT(modelH)






    bdType=get_param(modelH,'BlockDiagramType');
    if isequal(bdType,'subsystem')

        DAStudio.error('RTW:autosar:SubsystemReferenceModel',get_param(modelH,'Name'));
    elseif isequal(bdType,'library')

        DAStudio.error('RTW:autosar:LibraryModel',get_param(modelH,'Name'));
    end

    mappingType='CoderDictionary';
    modelName=get_param(modelH,'Name');
    mapping=Simulink.CodeMapping.get(modelH,mappingType);
    if isempty(mapping)


        Simulink.CodeMapping.addCoderGroups(modelName,'init');
        coder.mapping.internal.createDefaultMapping(modelName,mappingType);
    end
end


