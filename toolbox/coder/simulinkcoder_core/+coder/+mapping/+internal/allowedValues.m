function allowedValues=allowedValues(modelH,category,propertyName,mapping)









    coder.mapping.internal.validateArguments(modelH,mapping,category,propertyName);
    switch propertyName
    case 'StorageClass'
        allowedValues=mapping.DefaultsMapping.getAllowedGroupNames(...
        category,'ModelLevel');
    case 'MemorySection'
        allowedValues=mapping.DefaultsMapping.getAllowedMemorySectionNames(...
        category,'ModelLevel');
    case DAStudio.message('coderdictionary:mapping:FunctionClass')
        allowedValues=mapping.DefaultsMapping.getAllowedFunctionClassNames(...
        category,'ModelLevel');
    otherwise
        propName=mapping.DefaultsMapping.getPropNameFromType(category);
        targetDataRef=eval(['mapping.DefaultsMapping.',propName]);
        if isempty(targetDataRef)
            DAStudio.error('coderdictionary:api:invalidAttributeName',propertyName);
        end
        instanceSpecificProperties=targetDataRef.getCSCAttributeNames(modelH);
        instanceSpecificProperties=setdiff(instanceSpecificProperties,targetDataRef.getPerInstanceAttributeNames,'stable');
        if~ismember(propertyName,instanceSpecificProperties)
            DAStudio.error('coderdictionary:api:invalidAttributeName',propertyName);
        else
            allowedValues=targetDataRef.getCSCAttributeAllowedValues(modelH,propertyName);
        end
    end
end


