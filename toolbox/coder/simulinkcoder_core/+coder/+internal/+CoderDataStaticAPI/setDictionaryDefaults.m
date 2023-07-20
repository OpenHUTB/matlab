function setDictionaryDefaults(ddSource,category,argParser)








    params=argParser.Unmatched;

    storageClass=argParser.Results.StorageClass;

    memorySection=argParser.Results.MemorySection;
    functionClass=argParser.Results.(DAStudio.message('coderdictionary:mapping:FunctionClass'));

    if~isempty(storageClass)
        coder.internal.CoderDataStaticAPI.setDefaultCoderDataForElement(ddSource,category,'StorageClass',storageClass);
    end

    if~isempty(functionClass)
        coder.internal.CoderDataStaticAPI.setDefaultCoderDataForElement(ddSource,category,'FunctionCustomizationTemplate',functionClass);
    end

    if~isempty(memorySection)
        coder.internal.CoderDataStaticAPI.setDefaultCoderDataForElement(ddSource,category,'MemorySection',memorySection);
    end

    if~isempty(fields(params))
        propertiesNames=fieldnames(params);


        if any(strcmp(category,coder.mapping.internal.functionCategories()))
            for ii=1:numel(propertiesNames)
                DAStudio.error('coderdictionary:api:invalidAttributeNameForCategory',propertiesNames{ii},category);
            end
        end
        hlp=coder.internal.CoderDataStaticAPI.getHelper;
        m_cdefinition=hlp.openDD(ddSource);
        instSps=coder.internal.CoderDataStaticAPI.getDataDefaultInstanceSpecificProperties(m_cdefinition,category);
        if~isempty(instSps)
            instanceSpecificProperties={instSps.Name};
            instSpecificPropertyNames=fieldnames(params);
            instSpecificPropertyValues=struct2cell(params);
            for ii=1:numel(instSpecificPropertyNames)
                propertyName=instSpecificPropertyNames{ii};
                if~ismember(propertyName,instanceSpecificProperties)
                    DAStudio.error('coderdictionary:api:invalidAttributeName',propertyName);
                end
            end

            if isempty(storageClass)
                storageClass=coder.mapping.defaults.get(ddSource,category,'StorageClass');
            end
            scObj=coder.internal.CoderDataStaticAPI.getByName(m_cdefinition,'StorageClass',storageClass);
            for ii=1:numel(instSpecificPropertyNames)
                for jj=1:numel(instanceSpecificProperties)
                    if strcmp(instSpecificPropertyNames{ii},instanceSpecificProperties{jj})
                        instSps(jj).Value=instSpecificPropertyValues{ii};
                        if isa(scObj,'coderdictionary.data.LegacyStorageClass')
                            coder.internal.CoderDataStaticAPI.validateInstanceSpecificProperty(...
                            m_cdefinition,category,scObj.Package,scObj.ClassName,...
                            instSpecificPropertyNames{ii},instSpecificPropertyValues{ii},instSps);
                        end
                        if~isempty(instSps(jj).Value)
                            instSps(jj).DisplayValue=instSps(jj).Value;
                        else
                            instSps(jj).DisplayValue='<Instance specific>';
                        end
                    end
                end
            end
            coder.internal.CoderDataStaticAPI.setDataDefaultInstanceSpecificProperties(m_cdefinition,category,instSps);
        else

            propertiesNames=setdiff(propertiesNames,'StorageClass');
            if numel(propertiesNames)>0
                DAStudio.error('coderdictionary:api:invalidAttributeName',propertiesNames{1});
            end
        end
    end


