function setFunctionDefaults(modelH,modelFunction,argParser)




    params=argParser.Unmatched;
    functionClass=argParser.Results.FunctionClass;
    memorySection=argParser.Results.MemorySection;
    mapping=Simulink.CodeMapping.get(modelH,'CoderDictionary');
    coder.api.internal.validateArguments(modelH,mapping);

    if~isempty(memorySection)
        isLinkedToDataDictionary=~isempty(coderdictionary.data.SlCoderDataClient.getSharedCoderDictionarySource(get_param(modelH,'Handle')));
        uuid=mapping.DefaultsMapping.getMemorySectionUuidFromName(memorySection);
        if strcmp(memorySection,DAStudio.message('coderdictionary:mapping:MappingNone'))
            if~isLinkedToDataDictionary
                mapping.DefaultsMapping.unset(modelFunction,'MemorySection');
            else
                values=coder.api.internal.getAllowedFunctionDefaultValues(modelH,modelFunction,'MemorySection');
                DAStudio.error('coderdictionary:api:InvalidNonDictionaryAttribute','Memory section',memorySection,strjoin(values,', '));
            end

        elseif startsWith(memorySection,DAStudio.message('coderdictionary:mapping:ModelDefaultMappingForAPI'))
            if isLinkedToDataDictionary
                mapping.DefaultsMapping.set(modelFunction,'MemorySection','');
            else
                values=coder.api.internal.getAllowedFunctionDefaultValues(modelH,modelFunction,'MemorySection');
                DAStudio.error('coderdictionary:api:InvalidDictionaryAttribute','Memory section',memorySection,strjoin(values,', '));
            end
        else
            if~isempty(uuid)
                mapping.DefaultsMapping.set(modelFunction,'MemorySection',uuid);
            else
                values=coder.api.internal.getAllowedFunctionDefaultValues(modelH,modelFunction,'MemorySection');
                DAStudio.error('coderdictionary:api:invalidAttributeValue',memorySection,'MemorySection',strjoin(values,', '));
            end
        end
    end
    if~isempty(functionClass)
        isLinkedToDataDictionary=~isempty(get_param(modelH,'DataDictionary'));
        uuid=codermapping.internal.c.dictionary.getFunctionCustomizationTemplateUuidFromName(...
        modelH,functionClass,modelFunction);
        if strcmp(functionClass,DAStudio.message('coderdictionary:mapping:MappingFunctionDefault'))
            if~isLinkedToDataDictionary
                mapping.DefaultsMapping.unset(modelFunction,'FunctionClass');
            else
                values=coder.api.internal.getAllowedFunctionDefaultValues(modelH,modelFunction,'FunctionClass');
                DAStudio.error('coderdictionary:api:InvalidNonDictionaryAttribute','Function Class',functionClass,strjoin(values,', '));
            end

        elseif startsWith(functionClass,DAStudio.message('coderdictionary:mapping:ModelDefaultMappingForAPI'))
            if isLinkedToDataDictionary
                mapping.DefaultsMapping.set(modelFunction,'FunctionClass','');
            else
                values=coder.api.internal.getAllowedFunctionDefaultValues(modelH,modelFunction,'FunctionClass');
                DAStudio.error('coderdictionary:api:InvalidDictionaryAttribute','Memory section',functionClass,strjoin(values,', '));
            end
        else
            if~isempty(uuid)
                mapping.DefaultsMapping.set(modelFunction,'FunctionClass',uuid);
            else
                values=coder.api.internal.getAllowedFunctionDefaultValues(modelH,modelFunction,'FunctionClass');
                DAStudio.error('coderdictionary:api:invalidAttributeValue',functionClass,'FunctionClass',strjoin(values,', '));
            end
        end
    end
    if~isempty(fields(params))
        propertiesNames=fieldnames(params);
        DAStudio.error('coderdictionary:api:invalidAttributeName',propertiesNames{1});
    end
end


