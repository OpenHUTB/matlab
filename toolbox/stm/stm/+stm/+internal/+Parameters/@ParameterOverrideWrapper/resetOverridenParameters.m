
function resetOverridenParameters(hModelWorkspace,overridesStruct,originalValues,...
    dataDictionaryStates,modelWorkspaceDirtyState,modelToRun,originalModelDirtyState)

    poWrapper=stm.internal.Parameters.ParameterOverrideWrapper;


    assert(length(overridesStruct)==length(originalValues),'Overrides misaligned');
    len=length(overridesStruct);
    for x=1:len
        if(~overridesStruct(x).IsChecked)
            continue;
        end

        if(originalValues(x).Error)
            continue;
        end
        if(originalValues(x).Skip)
            continue;
        end

        if(strcmp(overridesStruct(x).SourceType,'base workspace'))
            assignin('base',overridesStruct(x).Name,originalValues(x).OriginalValue);
        elseif(strcmp(overridesStruct(x).SourceType,'model workspace'))
            if(isa(hModelWorkspace,'Simulink.ModelWorkspace'))
                hModelWorkspace.assignin(overridesStruct(x).Name,originalValues(x).OriginalValue);
            end
        elseif~isempty(strfind(overridesStruct(x).SourceType,'.sldd'))&&...
            originalValues(x).DataDictionaryState.Dirty

            dataDictionary=originalValues(x).DataDictionaryState.DataDictionary;
            dds=dataDictionary.getSection('Design Data');

            if(originalValues(x).OriginalValue.Discard)
                entry=dds.getEntry(overridesStruct(x).Name);
                discardChanges(entry);
            else
                dds.assignin(overridesStruct(x).Name,originalValues(x).OriginalValue.Value);
            end
        elseif(strcmp(overridesStruct(x).SourceType,'mask workspace'))
            source=overridesStruct(x).Source;
            name=overridesStruct(x).Name;
            value=originalValues(x).OriginalValue;
            [maskParam,~]=stm.internal.MRT.share.getMaskParameter(source,name);
            poWrapper.setMaskParamValue(value,source,name,maskParam);
        end
    end

    if(isa(hModelWorkspace,'Simulink.ModelWorkspace'))
        hModelWorkspace.isdirty=modelWorkspaceDirtyState;
    end

    poWrapper.revertDataDictionaries(dataDictionaryStates);

    set_param(modelToRun,'Dirty',originalModelDirtyState);
end