function props=getCodeGenPropertiesForSignal(portH,perspective,modelMapping,mappingType)

    props={};
    if isempty(modelMapping)
        return
    end
    model=bdroot(portH);
    mappedSignal=modelMapping.Signals.findobj('PortHandle',portH);
    mappedToNonAuto=~isempty(mappedSignal)&&~isempty(mappedSignal.MappedTo);
    switch(perspective)
    case 'Simulink:studio:DataViewPerspective_CodeGen'
        if strcmp(mappingType,'CoderDictionary')
            props{end+1}=DAStudio.message('coderdictionary:mapping:StorageClassColumnName');
            if mappedToNonAuto
                props{end+1}=DAStudio.message('coderdictionary:mapping:CodeIdentifierColumnName');

                props=horzcat(props,mappedSignal.MappedTo.getCSCAttributeNames(model)');
                props=setdiff(props,'PreserveDimensions','stable');


            end
        elseif strcmp(mappingType,'AutosarTarget')
            props{end+1}=DAStudio.message('coderdictionary:mapping:MappedToColumnName');

            if mappedToNonAuto
                dictRef=mappedSignal.MappedTo;
                allProps=dictRef.getPerInstancePropertyLocalizedNames(true)';
                for name=allProps
                    if~dictRef.isPerInstancePropertyCalibrationParameter(name{1})
                        props{end+1}=name{1};%#ok<AGROW>
                    end
                end
                if~strcmp(dictRef.ArDataRole,'StaticMemory')
                    props=setdiff(props,{DAStudio.message('RTW:autosar:uiTypeQualifierIsVolatile'),...
                    DAStudio.message('RTW:autosar:uiTypeQualifierAdditionalQualifier')},'stable');
                end
                props=setdiff(props,{DAStudio.message('RTW:autosar:uiNeedsNVRAMAccess')},...
                'stable');
            end
        end
    case 'RTW:autosar:CalibrationParametersTitle'
        if strcmp(mappingType,'AutosarTarget')&&mappedToNonAuto
            dictRef=mappedSignal.MappedTo;
            allProps=dictRef.getPerInstancePropertyLocalizedNames(true)';
            for name=allProps
                if dictRef.isPerInstancePropertyCalibrationParameter(name{1})
                    props{end+1}=name{1};%#ok<AGROW>
                end
            end
        end
    otherwise
        props={};
    end