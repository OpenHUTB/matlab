function allowedValues=getAllowedFunctionDefaultValues(modelH,...
    modelFunction,attributeName)





    mapping=Simulink.CodeMapping.get(modelH,'CoderDictionary');
    coder.api.internal.validateArguments(modelH,mapping);
    switch attributeName
    case 'MemorySection'
        allowedValues=mapping.DefaultsMapping.getAllowedMemorySectionNames(...
        modelFunction,'ModelLevel');
    case 'FunctionClass'
        allowedValues=mapping.DefaultsMapping.getAllowedFunctionClassNames(...
        modelFunction,'ModelLevel');
    otherwise
        DAStudio.error('coderdictionary:api:invalidAttributeName',attributeName);
    end
end


