function setDataDefault(modelH,category,argParser,mapping)







    params=argParser.Unmatched;

    storageClass=argParser.Results.StorageClass;
    memorySection=argParser.Results.MemorySection;
    functionClass=argParser.Results.(DAStudio.message('coderdictionary:mapping:FunctionClass'));



    hlp=coder.internal.CoderDataStaticAPI.getHelper;
    dictName=coderdictionary.data.SlCoderDataClient.getSharedCoderDictionarySource(get_param(modelH,'Handle'));
    if isempty(dictName)||strcmp(get_param(modelH,'IsERTTarget'),'off')
        dictHasCoderDict=false;
    else
        cDefintions=hlp.openDD(dictName);
        dictHasCoderDict=strcmp(cDefintions.owner.context,'dictionary')&&~cDefintions.owner.isEmpty();
    end



    isLinkedToDataDictionary=dictHasCoderDict;
    if~isempty(storageClass)
        coder.mapping.internal.validateArguments(modelH,mapping,category,'StorageClass');
        if strcmp(storageClass,DAStudio.message('coderdictionary:mapping:SimulinkGlobal'))
            mapping.DefaultsMapping.unset(category,'StorageClass');
        elseif startsWith(storageClass,DAStudio.message('coderdictionary:mapping:ModelDefaultMappingForAPI'))

            if isLinkedToDataDictionary
                mapping.DefaultsMapping.set(category,'StorageClass','');
            else
                values=coder.mapping.internal.allowedValues(modelH,category,'StorageClass',mapping);
                DAStudio.error('coderdictionary:api:InvalidDictionaryAttribute','storage class',storageClass,strjoin(values,', '));
            end
        else
            values=coder.mapping.internal.allowedValues(modelH,category,'StorageClass',mapping);
            if~ismember(storageClass,values)
                DAStudio.error('coderdictionary:api:invalidAttributeValue',storageClass,'storage class',strjoin(values,', '));
            end
            uuid=mapping.DefaultsMapping.getGroupUuidFromName(storageClass);
            if~isempty(uuid)
                mapping.DefaultsMapping.set(category,'StorageClass',uuid);
            else
                DAStudio.error('coderdictionary:api:invalidAttributeValue',storageClass,'storage class',strjoin(values,', '));
            end
        end
    end

    if~isempty(functionClass)
        coder.mapping.internal.validateArguments(modelH,mapping,category,DAStudio.message('coderdictionary:mapping:FunctionClass'));
        uuid=codermapping.internal.c.dictionary.getFunctionCustomizationTemplateUuidFromName(...
        modelH,functionClass,category);
        if strcmp(functionClass,DAStudio.message('coderdictionary:mapping:MappingFunctionDefault'))
            mapping.DefaultsMapping.unset(category,'FunctionClass');
        elseif startsWith(functionClass,DAStudio.message('coderdictionary:mapping:ModelDefaultMappingForAPI'))

            if isLinkedToDataDictionary
                mapping.DefaultsMapping.set(category,'FunctionClass','');
            else
                values=coder.mapping.internal.allowedValues(modelH,category,DAStudio.message('coderdictionary:mapping:FunctionClass'),mapping);
                DAStudio.error('coderdictionary:api:InvalidDictionaryAttribute','Memory section',functionClass,strjoin(values,', '));
            end
        else
            if~isempty(uuid)
                mapping.DefaultsMapping.set(category,'FunctionClass',uuid);
            else
                values=coder.mapping.internal.allowedValues(modelH,category,DAStudio.message('coderdictionary:mapping:FunctionClass'),mapping);
                DAStudio.error('coderdictionary:api:invalidAttributeValue',functionClass,DAStudio.message('coderdictionary:mapping:FunctionClass'),strjoin(values,', '));
            end
        end
    end

    if~isempty(memorySection)
        coder.mapping.internal.validateArguments(modelH,mapping,category,'MemorySection');
        uuid=mapping.DefaultsMapping.getMemorySectionUuidFromName(memorySection);
        if strcmp(memorySection,DAStudio.message('coderdictionary:mapping:MappingNone'))
            mapping.DefaultsMapping.unset(category,'MemorySection');
        elseif startsWith(memorySection,DAStudio.message('coderdictionary:mapping:ModelDefaultMappingForAPI'))

            if isLinkedToDataDictionary
                mapping.DefaultsMapping.set(category,'MemorySection','');
            else
                values=coder.mapping.internal.allowedValues(modelH,category,'MemorySection',mapping);
                DAStudio.error('coderdictionary:api:InvalidDictionaryAttribute','memory section',memorySection,strjoin(values,', '));
            end
        else
            values=coder.mapping.internal.allowedValues(modelH,category,'MemorySection',mapping);
            if~ismember(memorySection,values)
                DAStudio.error('coderdictionary:api:invalidAttributeValue',memorySection,'memory section',strjoin(values,', '));
            end
            if~isempty(uuid)
                mapping.DefaultsMapping.set(category,'MemorySection',uuid);
            else
                DAStudio.error('coderdictionary:api:invalidAttributeValue',memorySection,'memory section',strjoin(values,', '));
            end
        end
    end

    if~isempty(fields(params))
        propertiesNames=fieldnames(params);


        if any(strcmp(category,coder.mapping.internal.functionCategories()))
            for ii=1:numel(propertiesNames)
                DAStudio.error('coderdictionary:api:invalidAttributeNameForCategory',propertiesNames{ii},category);
            end
        end
        translatedString=mapping.DefaultsMapping.getPropNameFromType(category);
        assert(~isempty(translatedString),sprintf('Unidentified modeling element type:%s. Control should not reach here.',...
        category));
        dataRef=mapping.DefaultsMapping.(translatedString);
        if~isempty(dataRef.StorageClass)
            coder.mapping.internal.setInstanceSpecificProperty(modelH,...
            params,mapping,dataRef,category);
        else

            propertiesNames=setdiff(propertiesNames,'StorageClass');
            if numel(propertiesNames)>0
                DAStudio.error('coderdictionary:api:invalidAttributeName',propertiesNames{1});
            end
        end
    end

    if isempty(storageClass)&&isempty(functionClass)&&...
        isempty(memorySection)&&isempty(fields(params))
        if any(strcmp(category,coder.mapping.internal.dataCategories()))
            allowedProps={'StorageClass','MemorySection'};
        else
            allowedProps={'FunctionCustomizationTemplate','MemorySection'};
        end
        DAStudio.error('coderdictionary:api:UnspecifiedPropertyName',...
        argParser.FunctionName,strjoin(allowedProps,', '));
    end
end


