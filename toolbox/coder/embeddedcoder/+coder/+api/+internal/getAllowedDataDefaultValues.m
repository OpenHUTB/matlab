function allowedValues=getAllowedDataDefaultValues(modelH,...
    modelingElementType,attributeName)





    mapping=Simulink.CodeMapping.get(modelH,'CoderDictionary');
    coder.api.internal.validateArguments(modelH,mapping);
    switch attributeName
    case 'StorageClass'
        allowedValues=mapping.DefaultsMapping.getAllowedGroupNames(...
        modelingElementType,'ModelLevel');
    case 'MemorySection'
        allowedValues=mapping.DefaultsMapping.getAllowedMemorySectionNames(...
        modelingElementType,'ModelLevel');
    otherwise
        propName=mapping.DefaultsMapping.getPropNameFromType(modelingElementType);
        targetDataRef=eval(['mapping.DefaultsMapping.',propName]);
        if isempty(targetDataRef)
            DAStudio.error('coderdictionary:api:invalidAttributeName',attributeName);
        end
        instanceSpecificProperties=targetDataRef.getCSCAttributeNames(modelH);
        if~ismember(attributeName,instanceSpecificProperties)
            DAStudio.error('coderdictionary:api:invalidAttributeName',attributeName);
        else
            allowedValues=targetDataRef.getCSCAttributeAllowedValues(modelH,attributeName);
        end
    end
end


