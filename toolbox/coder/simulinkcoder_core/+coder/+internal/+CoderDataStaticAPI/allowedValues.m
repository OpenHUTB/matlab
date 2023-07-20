function allowedValues=allowedValues(dictName,category,propertyName)








    if isa(dictName,'Simulink.data.Dictionary')
        dictName=dictName.filepath;
    end
    switch category
    case coder.mapping.internal.dataCategories()
        if strcmp(propertyName,DAStudio.message('coderdictionary:mapping:FunctionClass'))
            DAStudio.error('coderdictionary:api:invalidAttributeNameForCategory',propertyName,dictName);
        end
    case coder.mapping.defaults.functionCategories()
        if~any(strcmp(propertyName,{DAStudio.message('coderdictionary:mapping:FunctionClass'),'MemorySection'}))
            DAStudio.error('coderdictionary:api:invalidAttributeNameForCategory',propertyName,dictName);
        end
    otherwise
        assert(false,sprintf('Add handling for Simulink modeling element type %s',modelingElementType));
    end
    allowedValues={};
    switch propertyName
    case 'StorageClass'
        hlp=coder.internal.CoderDataStaticAPI.getHelper;
        container=hlp.openDD(dictName);
        container=container.owner;
        allowedRefs=coderdictionary.data.SlCoderDataClient.getAllCoderDataForModelElementTypeForContainer(container,category,propertyName,'ModelLevel');
        emptySCName=message('coderdictionary:mapping:SimulinkGlobal').getString;
        allowedValues={emptySCName};
        for i=1:length(allowedRefs)
            allowedValues{end+1}=allowedRefs(i).getProperty('DisplayName');%#ok<AGROW>
        end
    case{'FunctionClass',DAStudio.message('coderdictionary:mapping:FunctionClass')}
        allowedEntries=coder.internal.CoderDataStaticAPI.get(dictName,'FunctionClass');
        allowedValues=coder.internal.CoderDataStaticAPI.getDisplayName(dictName,allowedEntries);
        if~iscell(allowedValues)
            allowedValues={allowedValues};
        end
        defaultFCName=message('coderdictionary:mapping:SimulinkGlobal').getString;
        allowedValues=[defaultFCName;allowedValues];
    case 'MemorySection'
        switch category
        case coder.mapping.internal.dataCategories()
            allowedValues=loc_getAllowedMemorySectionForData(dictName,category);
        case coder.mapping.defaults.functionCategories()
            allowedValues=loc_getAllowedMemorySectionForFunction(dictName,category);
        end
    otherwise

        if any(strcmp(category,coder.mapping.internal.dataCategories()))
            hlp=coder.internal.CoderDataStaticAPI.getHelper;
            m_cdefinition=hlp.openDD(dictName);
            instSps=coder.internal.CoderDataStaticAPI.getDataDefaultInstanceSpecificProperties(m_cdefinition,category);
            for ii=1:numel(instSps)
                if strcmp(instSps(ii).Name,propertyName)
                    allowedValues=instSps(ii).AllowedValues;
                    if~iscell(allowedValues)

                        if isempty(allowedValues)
                            allowedValues={};
                        else

                            allowedValues={allowedValues};
                        end
                    end
                    break;
                end
            end
        end
    end
end

function allowedValues=loc_getAllowedMemorySectionForData(dictName,category)
    allowedValues={};
    swc=coder.internal.CoderDataStaticAPI.getSWCT(dictName);
    hlp=coder.internal.CoderDataStaticAPI.getHelper;
    cat=hlp.getProp(swc,category);
    sc=hlp.getProp(cat,'InitialStorageClass');
    emptyMSName=message('coderdictionary:mapping:MappingNone').getString;
    hlp=coder.internal.CoderDataStaticAPI.getHelper;
    container=hlp.openDD(dictName);
    container=container.owner;
    allowedRefs=coderdictionary.data.SlCoderDataClient.getAllCoderDataForModelElementTypeForContainer(container,category,'MemorySection','ModelLevel');
    allowedValuesInSWC={emptyMSName};
    for i=1:length(allowedRefs)
        allowedValuesInSWC{end+1}=allowedRefs(i).getProperty('DisplayName');%#ok<AGROW>
    end
    if isempty(sc)

        allowedValues=allowedValuesInSWC;
    else

        if isa(sc,'coderdictionary.data.LegacyStorageClass')


            instSpecificSchema=hlp.getProp(cat,'InitialCSCAttributesSchema');
            if~isempty(instSpecificSchema)
                instSp=jsondecode(instSpecificSchema);
                for i=1:length(instSp)
                    if strcmp(instSp(i).Name,'MemorySection')
                        allowedValues=instSp(i).AllowedValues;
                        if~iscell(allowedValues)

                            if isempty(allowedValues)
                                allowedValues={};
                            else

                                allowedValues={allowedValues};
                            end
                        end

                        [~,IA]=intersect(allowedValues,allowedValuesInSWC);

                        allowedValues=allowedValues(sort(IA));
                        break;
                    end
                end
            end
        end
        if isempty(allowedValues)
            DAStudio.error('coderdictionary:mapping:DataMemorySectionNotConfigurable',category,hlp.getProp(sc,'DisplayName'));
        end
    end
end
function allowedValues=loc_getAllowedMemorySectionForFunction(dictName,category)
    emptyMSName=message('coderdictionary:mapping:MappingNone').getString;
    swc=coder.internal.CoderDataStaticAPI.getSWCT(dictName);
    hlp=coder.internal.CoderDataStaticAPI.getHelper;
    cat=hlp.getProp(swc,category);
    fc=hlp.getProp(cat,'InitialFunctionClass');
    if~isempty(fc)
        DAStudio.error('coderdictionary:mapping:FunctionMemorySectionNotConfigurable',category,hlp.getProp(fc,'DisplayName'));
    else


        dd=hlp.openDD(dictName);
        allowedRefs=coderdictionary.data.SlCoderDataClient.getAllElementsOfCoderDataTypeForContainer(dd.owner,'MemorySection');
        allowedValues={emptyMSName};
        for i=1:length(allowedRefs)
            allowedValues{end+1}=allowedRefs(i).getProperty('DisplayName');%#ok<AGROW>
        end
    end
end


