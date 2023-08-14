function attribValue=getFunctionDefaults(modelH,modelFunction,attributeName)




    mapping=Simulink.CodeMapping.get(modelH,'CoderDictionary');
    coder.api.internal.validateArguments(modelH,mapping);
    if~any(strcmp(attributeName,{'FunctionClass','MemorySection'}))
        DAStudio.error('coderdictionary:api:invalidAttributeName',attributeName);
    end
    attribValue=mapping.DefaultsMapping.getDataRefDerivedName(...
    modelFunction,attributeName);
    if startsWith(attribValue,DAStudio.message('coderdictionary:mapping:ModelDefaultMappingForAPI'))
        attribValue=DAStudio.message('coderdictionary:mapping:ModelDefaultMappingForAPI');
    end
end


