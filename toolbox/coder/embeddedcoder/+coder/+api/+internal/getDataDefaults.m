function attribValue=getDataDefaults(modelH,modelingElementType,attributeName)




    mapping=Simulink.CodeMapping.get(modelH,'CoderDictionary');
    coder.api.internal.validateArguments(modelH,mapping);

    if any(strcmp(attributeName,{'StorageClass',DAStudio.message('coderdictionary:mapping:FunctionClass'),'MemorySection'}))
        attribValue=mapping.DefaultsMapping.getDataRefDerivedName(modelingElementType,attributeName);
        if startsWith(attribValue,DAStudio.message('coderdictionary:mapping:ModelDefaultMappingForAPI'))
            attribValue=DAStudio.message('coderdictionary:mapping:ModelDefaultMappingForAPI');
        end
    else
        propName=mapping.DefaultsMapping.getPropNameFromType(modelingElementType);
        targetDataRef=eval(['mapping.DefaultsMapping.',propName]);
        if isempty(targetDataRef)
            DAStudio.error('coderdictionary:api:invalidAttributeName',attributeName);
        end
        instanceSpecificProperties=targetDataRef.getCSCAttributeNames(modelH);
        if~ismember(attributeName,instanceSpecificProperties)
            DAStudio.error('coderdictionary:api:invalidAttributeName',attributeName);
        else
            attribValue=targetDataRef.getCSCAttributeValue(modelH,attributeName);
        end
    end
end


