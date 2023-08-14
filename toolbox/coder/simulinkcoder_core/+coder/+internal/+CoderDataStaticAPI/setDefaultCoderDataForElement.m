function setDefaultCoderDataForElement(dd,category,coderDataType,entry)















    import coder.internal.CoderDataStaticAPI.*;
    hlp=getHelper();
    category=coder.internal.CoderDataStaticAPI.convertToInternalCategoryName(category);
    isStorageClass=strcmp(coderDataType,'StorageClass');
    isMemorySection=strcmp(coderDataType,'MemorySection');
    isFunctionClass=strcmp(coderDataType,'FunctionClass')||strcmp(coderDataType,'FunctionCustomizationTemplate');
    if isStorageClass||isMemorySection||isFunctionClass
        dd=hlp.openDD(dd);
        if~hlp.hasSWCT(dd)
            coder.internal.CoderDataStaticAPI.initializeDictionary(dd);
        end
        if iscell(entry)
            entry=entry{1};
        end
        if ischar(entry)||isstring(entry)
            entryObj=coder.internal.CoderDataStaticAPI.getByName(dd,coderDataType,entry);
        else
            entryObj=entry;
            entry=entryObj.DisplayName;
        end
        inputEntryName=entry;
        swc=coder.internal.CoderDataStaticAPI.getSWCT(dd);
        cat=hlp.getProp(swc,category);
        if isStorageClass
            allowedValues=coder.mapping.defaults.allowedValues(dd,category,coderDataType);
            emptySCName=message('coderdictionary:mapping:SimulinkGlobal').getString;
            if isempty(entryObj)
                if isempty(inputEntryName)||strcmp(inputEntryName,emptySCName)
                    hlp.setProp(cat,'InitialStorageClass',[]);
                    hlp.setProp(cat,'InitialCSCAttributesSchema','');
                else
                    DAStudio.error('coderdictionary:api:InvalidStorageClass',inputEntryName,strjoin(allowedValues,', '));
                end
            else
                isAllowed=ismember(inputEntryName,allowedValues);
                if isAllowed
                    hlp.setProp(cat,'InitialStorageClass',entryObj);

                    if isa(entryObj,'coderdictionary.data.StorageClass')
                        hlp.setProp(cat,'InitialCSCAttributesSchema','');
                    else

                        hlp.setProp(cat,'InitialCSCAttributesSchema',entryObj.getPropertyValue('CSCAttributesSchema'));
                    end
                else
                    DAStudio.error('coderdictionary:api:InvalidStorageClass',inputEntryName,strjoin(allowedValues,', '));
                end
            end
        elseif isMemorySection


            switch category
            case coder.mapping.internal.dataCategories()
                sc=hlp.getProp(cat,'InitialStorageClass');
                loc_setMemorySectionForDefaultStorageClass(cat,category,sc,entryObj,entry);
            case coder.mapping.defaults.functionCategories()
                loc_setMemorySectionForDefaultFunctionClass(cat,category,dd,entryObj,entry);
            end
        elseif isFunctionClass
            if isempty(entryObj)
                emptyFCName=message('coderdictionary:mapping:MappingFunctionDefault').getString;
                if isempty(inputEntryName)||strcmp(inputEntryName,emptyFCName)
                    hlp.setProp(cat,'InitialFunctionClass',[]);
                else
                    allowEntries=coder.internal.CoderDataStaticAPI.getAllowableCoderDataForElement(dd,...
                    category,coderDataType);
                    allowValues=coder.internal.CoderDataStaticAPI.getDisplayName(dd,allowEntries);
                    allowValues=[emptyFCName,allowValues];
                    DAStudio.error('coderdictionary:api:InvalidFunctionClass',inputEntryName,strjoin(allowValues,', '));
                end
            else
                hlp.setProp(cat,'InitialFunctionClass',entryObj);
            end
        end
    end
end
function loc_setMemorySectionForDefaultStorageClass(cat,category,sc,entryObj,entryName)
    hlp=coder.internal.CoderDataStaticAPI.getHelper();
    if isempty(sc)||strcmp(sc.Name,message('coderdictionary:mapping:SimulinkGlobal').getString)
        if isempty(entryObj)||strcmp(entryName,message('coderdictionary:mapping:MappingNone').getString)
            hlp.setProp(cat,'InitialMemorySection',[]);
        else
            hlp.setProp(cat,'InitialMemorySection',entryObj);
        end
    else

        instSpecificSchema=hlp.getProp(cat,'InitialCSCAttributesSchema');
        foundProp=false;
        if~isempty(instSpecificSchema)
            instSp=jsondecode(instSpecificSchema);
            for i=1:length(instSp)
                if strcmp(instSp(i).Name,'MemorySection')
                    allowedValues=instSp(i).AllowedValues;


                    if isempty(allowedValues)
                        continue;
                    end
                    if~iscell(allowedValues)
                        if isempty(allowedValues)
                            allowedValues={};
                        else
                            allowedValues={allowedValues};
                        end
                    end
                    if ismember(entryName,allowedValues)
                        instSp(i).Value=entryName;
                    else
                        DAStudio.error('coderdictionary:api:invalidAttributeValue',hlp.getProp(sc,'DisplayName'),'MemorySection',strjoin(allowedValues,', '));
                    end
                    hlp.setProp(cat,'InitialCSCAttributesSchema',jsonencode(instSp));
                    foundProp=true;
                    break;
                end
            end
        end
        if~foundProp
            DAStudio.error('coderdictionary:mapping:DataMemorySectionNotConfigurable',category,hlp.getProp(sc,'DisplayName'));
        end
    end
end
function loc_setMemorySectionForDefaultFunctionClass(cat,category,dd,entryObj,entryName)
    hlp=coder.internal.CoderDataStaticAPI.getHelper();
    fc=hlp.getProp(cat,'InitialFunctionClass');

    if~isempty(fc)
        DAStudio.error('coderdictionary:mapping:FunctionMemorySectionNotConfigurable',category,fc.DisplayName);
    else
        if isempty(entryObj)&&strcmp(entryName,message('coderdictionary:mapping:MappingNone').getString)
            hlp.setProp(cat,'InitialMemorySection',[]);
        else
            if~isempty(entryObj)
                hlp.setProp(cat,'InitialMemorySection',entryObj);
            else

                mss=coder.internal.CoderDataStaticAPI.getAllowableCoderDataForFunction(dd,category,'MemorySection');
                mssName={};
                if~isempty(mss)
                    mssName=coder.internal.CoderDataStaticAPI.getDisplayName(dd,mss);
                    if~iscell(mssName)
                        mssName={mssName};
                    end
                end
                msOptions=[message('coderdictionary:mapping:MappingNone').getString;mssName];
                DAStudio.error('coderdictionary:api:invalidAttributeValue',entryName,'MemorySection',strjoin(msOptions,', '));
            end
        end
    end
end


