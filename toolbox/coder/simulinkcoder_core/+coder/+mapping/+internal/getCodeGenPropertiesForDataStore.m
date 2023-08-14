function props=getCodeGenPropertiesForDataStore(blockH,perspective,modelMapping,mappingType)




    props={};
    if isempty(modelMapping)
        return
    end
    model=bdroot(blockH);
    mappedDataStore=modelMapping.DataStores.findobj('OwnerBlockHandle',blockH);
    mappedToNonAuto=~isempty(mappedDataStore)&&~isempty(mappedDataStore.MappedTo);
    switch(perspective)
    case 'Simulink:studio:DataViewPerspective_CodeGen'
        if strcmp(mappingType,'AutosarTarget')
            props{end+1}=DAStudio.message('coderdictionary:mapping:MappedToColumnName');

            if mappedToNonAuto
                dictRef=mappedDataStore.MappedTo;
                allProps=dictRef.getPerInstancePropertyLocalizedNames(true)';
                for name=allProps
                    if~dictRef.isPerInstancePropertyCalibrationParameter(name{1})...
                        &&~dictRef.isPerInstancePropertyNvBlockNeeds(name{1})
                        props{end+1}=name{1};%#ok<AGROW>
                    end
                end
                if~strcmp(dictRef.ArDataRole,'StaticMemory')
                    props=setdiff(props,{DAStudio.message('RTW:autosar:uiTypeQualifierIsVolatile'),...
                    DAStudio.message('RTW:autosar:uiTypeQualifierAdditionalQualifier')},'stable');
                elseif~strcmp(dictRef.ArDataRole,'ArTypedPerInstanceMemory')
                    props=setdiff(props,{DAStudio.message('RTW:autosar:uiNeedsNVRAMAccess')},...
                    'stable');
                end
                if modelMapping.IsSubComponent


                    props=setdiff(props,{DAStudio.message('RTW:autosar:uiNeedsNVRAMAccess')},...
                    'stable');
                end
            end
        elseif strcmp(mappingType,'CoderDictionary')||strcmp(mappingType,'SimulinkCoderCTarget')
            props{end+1}=DAStudio.message('coderdictionary:mapping:StorageClassColumnName');
            if mappedToNonAuto
                props{end+1}=DAStudio.message('coderdictionary:mapping:CodeIdentifierColumnName');

                props=horzcat(props,mappedDataStore.MappedTo.getCSCAttributeNames(model)');
                props=setdiff(props,'PreserveDimensions','stable');


            end
        end
    case 'RTW:autosar:CalibrationParametersTitle'
        if strcmp(mappingType,'AutosarTarget')&&mappedToNonAuto
            dictRef=mappedDataStore.MappedTo;
            allProps=dictRef.getPerInstancePropertyLocalizedNames(true)';
            for name=allProps
                if dictRef.isPerInstancePropertyCalibrationParameter(name{1})
                    props{end+1}=name{1};%#ok<AGROW>
                end
            end
        end
    case 'RTW:autosar::uiNvBlockNeedsTitle'
        if strcmp(mappingType,'AutosarTarget')&&mappedToNonAuto
            dictRef=mappedDataStore.MappedTo;
            allProps=dictRef.getPerInstancePropertyLocalizedNames(true)';
            for name=allProps
                if dictRef.isPerInstancePropertyNvBlockNeeds(name{1})
                    props{end+1}=name{1};%#ok<AGROW>
                end
            end
        end
    otherwise
        props={};
    end


