function out=getDictionaryDefaults(ddSource,category,propertyName)








    out='';
    switch category
    case coder.mapping.internal.dataCategories()
        scRef=coder.internal.CoderDataStaticAPI.getDefaultCoderDataForElement(ddSource,category,'StorageClass');
        switch propertyName
        case 'StorageClass'
            if isempty(scRef)||isempty(scRef.getCoderDataEntry.owner)
                out=message('coderdictionary:mapping:SimulinkGlobal').getString;
            else
                out=scRef.getProperty('DisplayName');
            end
        case 'MemorySection'
            out=loc_getMemorySectionForDefaultStorageClass(ddSource,scRef,category);
        otherwise
            out=loc_getInstanceSpecificProperty(ddSource,category,propertyName);
        end
    case coder.mapping.defaults.functionCategories()
        if strcmp(propertyName,DAStudio.message('coderdictionary:mapping:FunctionClass'))
            propertyName='FunctionClass';
        end
        entryRef=coder.internal.CoderDataStaticAPI.getDefaultCoderDataForFunction(ddSource,category,'FunctionClass');
        switch propertyName
        case 'MemorySection'
            out=loc_getMemorySectionForDefaultFunctionClass(ddSource,entryRef,category);
        case 'FunctionClass'
            if isempty(entryRef)
                out=message('coderdictionary:mapping:MappingFunctionDefault').getString;
            else
                out=entryRef.getProperty('DisplayName');
            end
        otherwise
            DAStudio.error('coderdictionary:api:invalidAttributeNameForCategory',category,propertyName);
        end
    end
end

function out=loc_getMemorySectionForDefaultStorageClass(ddSource,scRef,category)
    if isempty(scRef)

        ms=coder.internal.CoderDataStaticAPI.getDefaultCoderDataForElement(ddSource,category,'MemorySection');
        if isempty(ms)
            out=message('coderdictionary:mapping:MappingNone').getString;
        else
            out=ms.getProperty('DisplayName');
        end
    else
        sc=scRef.getCoderDataEntry;

        if isa(sc,'coderdictionary.data.LegacyStorageClass')

            try
                out=loc_getInstanceSpecificProperty(ddSource,category,'MemorySection');
            catch
                DAStudio.error('coderdictionary:mapping:DataMemorySectionNotConfigurable',category,scRef.getProperty('DisplayName'));
            end
        else
            DAStudio.error('coderdictionary:mapping:DataMemorySectionNotConfigurable',category,scRef.getProperty('DisplayName'));
        end
    end
end
function out=loc_getMemorySectionForDefaultFunctionClass(ddSource,entry,category)
    if isempty(entry)

        ms=coder.internal.CoderDataStaticAPI.getDefaultCoderDataForElement(ddSource,category,'MemorySection');
        if isempty(ms)||isempty(ms.getCoderDataEntry.owner)
            out=message('coderdictionary:mapping:MappingNone').getString;
        else
            out=ms.getProperty('DisplayName');
        end
    else

        DAStudio.error('coderdictionary:mapping:FunctionMemorySectionNotConfigurable',category,entry.getProperty('DisplayName'));
    end
end
function out=loc_getInstanceSpecificProperty(ddSource,category,propertyName)
    instSps=coder.internal.CoderDataStaticAPI.getDataDefaultInstanceSpecificProperties(ddSource,category);
    if~isempty(instSps)
        instanceSpecificProperties={instSps.Name};
        if~ismember(propertyName,instanceSpecificProperties)
            DAStudio.error('coderdictionary:api:invalidAttributeName',propertyName);
        end
        instSp=instSps(contains(instanceSpecificProperties,propertyName));
        out=instSp.Value;
    else

        DAStudio.error('coderdictionary:api:invalidAttributeName',propertyName);
    end
end


