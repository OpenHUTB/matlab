function out=getDataDefault(modelH,category,propertyName,mapping)








    coder.mapping.internal.validateArguments(modelH,mapping,category,propertyName);

    if any(strcmp(propertyName,{'StorageClass',DAStudio.message('coderdictionary:mapping:FunctionClass'),'MemorySection'}))
        if strcmp(propertyName,DAStudio.message('coderdictionary:mapping:FunctionClass'))
            propertyName='FunctionClass';
        end
        if isa(mapping,'Simulink.CoderDictionary.ModelMappingSLC')...
            &&any(strcmp(propertyName,{DAStudio.message('coderdictionary:mapping:FunctionClass'),'MemorySection'}))
            DAStudio.error('coderdictionary:api:invalidAttributeName',propertyName);
        end
        out=mapping.DefaultsMapping.getDataRefDerivedName(category,propertyName);
        if startsWith(out,DAStudio.message('coderdictionary:mapping:ModelDefaultMappingForAPI'))
            out=DAStudio.message('coderdictionary:mapping:ModelDefaultMappingForAPI');
        end
    else
        propName=mapping.DefaultsMapping.getPropNameFromType(category);
        targetDataRef=eval(['mapping.DefaultsMapping.',propName]);
        if isempty(targetDataRef)
            DAStudio.error('coderdictionary:api:invalidAttributeName',propertyName);
        end
        instanceSpecificProperties=targetDataRef.getCSCAttributeNames(modelH);
        if~ismember(propertyName,instanceSpecificProperties)
            DAStudio.error('coderdictionary:api:invalidAttributeName',propertyName);
        else
            out=targetDataRef.getCSCAttributeValue(modelH,propertyName);
        end
    end

end


