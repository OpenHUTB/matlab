function setDataDefaults(modelH,modelingElementType,argParser)




    params=argParser.Unmatched;

    storageClass=argParser.Results.StorageClass;
    memorySection=argParser.Results.MemorySection;

    mapping=Simulink.CodeMapping.get(modelH,'CoderDictionary');
    coder.api.internal.validateArguments(modelH,mapping);
    if~isempty(storageClass)
        isLinkedToDataDictionary=~isempty(coderdictionary.data.SlCoderDataClient.getSharedCoderDictionarySource(get_param(modelH,'Handle')));
        if strcmp(storageClass,DAStudio.message('coderdictionary:mapping:SimulinkGlobal'))
            if~isLinkedToDataDictionary
                mapping.DefaultsMapping.unset(modelingElementType,'StorageClass');
            else
                values=coder.api.internal.getAllowedDataDefaultValues(modelH,modelingElementType,'StorageClass');
                DAStudio.error('coderdictionary:api:InvalidNonDictionaryAttribute','StorageClass',storageClass,strjoin(values,', '));
            end
        elseif startsWith(storageClass,DAStudio.message('coderdictionary:mapping:ModelDefaultMappingForAPI'))
            if isLinkedToDataDictionary
                mapping.DefaultsMapping.set(modelingElementType,'StorageClass','');
            else
                values=coder.api.internal.getAllowedDataDefaultValues(modelH,modelingElementType,'StorageClass');
                DAStudio.error('coderdictionary:api:InvalidDictionaryAttribute','StorageClass',storageClass,strjoin(values,', '));
            end
        else
            values=coder.api.internal.getAllowedDataDefaultValues(modelH,modelingElementType,'StorageClass');
            if~ismember(storageClass,values)
                DAStudio.error('coderdictionary:api:invalidAttributeValue',storageClass,'StorageClass',strjoin(values,', '));
            end
            uuid=mapping.DefaultsMapping.getGroupUuidFromName(storageClass);
            if~isempty(uuid)
                mapping.DefaultsMapping.set(modelingElementType,'StorageClass',uuid);
            else
                DAStudio.error('coderdictionary:api:invalidAttributeValue',storageClass,'StorageClass',strjoin(values,', '));
            end
        end
    end
    if~isempty(memorySection)
        isLinkedToDataDictionary=~isempty(coderdictionary.data.SlCoderDataClient.getSharedCoderDictionarySource(get_param(modelH,'Handle')));
        uuid=mapping.DefaultsMapping.getMemorySectionUuidFromName(memorySection);
        if strcmp(memorySection,DAStudio.message('coderdictionary:mapping:MappingNone'))
            mapping.DefaultsMapping.unset(modelingElementType,'MemorySection');
        elseif startsWith(memorySection,DAStudio.message('coderdictionary:mapping:ModelDefaultMappingForAPI'))
            if isLinkedToDataDictionary
                mapping.DefaultsMapping.set(modelingElementType,'MemorySection','');
            else
                values=coder.api.internal.getAllowedDataDefaultValues(modelH,modelingElementType,'MemorySection');
                DAStudio.error('coderdictionary:api:InvalidDictionaryAttribute','MemorySection',memorySection,strjoin(values,', '));
            end
        else
            values=coder.api.internal.getAllowedDataDefaultValues(modelH,modelingElementType,'MemorySection');
            if~ismember(memorySection,values)
                DAStudio.error('coderdictionary:api:invalidAttributeValue',memorySection,'MemorySection',strjoin(values,', '));
            end
            if~isempty(uuid)
                mapping.DefaultsMapping.set(modelingElementType,'MemorySection',uuid);
            else
                DAStudio.error('coderdictionary:api:invalidAttributeValue',memorySection,'MemorySection',strjoin(values,', '));
            end
        end
    end
    translatedString=mapping.DefaultsMapping.getPropNameFromType(modelingElementType);
    assert(~isempty(translatedString),sprintf('Unidentified modeling element type:%s. Control should not reach here.',...
    modelingElementType));
    dataRef=eval(['mapping.DefaultsMapping.',translatedString]);

    if~isempty(fields(params))
        if~isempty(dataRef)
            coder.api.internal.setInstanceSpecificProperty(modelH,...
            params,mapping,dataRef,modelingElementType);
        else

            propertiesNames=fieldnames(params);
            propertiesNames=setdiff(propertiesNames,'StorageClass');
            if numel(propertiesNames)>0
                DAStudio.error('coderdictionary:api:invalidAttributeName',propertiesNames{1});
            end
        end
    end

end


