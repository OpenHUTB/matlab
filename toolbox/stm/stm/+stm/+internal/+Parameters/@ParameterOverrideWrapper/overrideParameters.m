
function[overridesCache,originalValues,hModelWorkspace,dataDictionaryStates,...
    modelWorkspaceDirtyState,errors]=...
    overrideParameters(modelToRun,overridesStruct,fromIteration)

    import stm.internal.Parameters.*;
    poWrapper=stm.internal.Parameters.ParameterOverrideWrapper;

    try
        modelWorkspaceDirtyState=false;
        errors.messages={};
        errors.errorOrLog={};

        len=length(overridesStruct);

        overridesCache=repmat({0;-1;''},[1,len]);
        originalValues=repmat(struct(...
        'OriginalValue','',...
        'Error',false,...
        'Skip',false,...
        'DataDictionaryState',DataDictionaryState.empty...
        ),len,1);
        hModelWorkspace=false;
        dataDictionaryStates=DataDictionaryState.empty;

        for x=1:len
            assert(overridesStruct(x).IsChecked);

            if strcmp(overridesStruct(x).SourceType,'base workspace')
                [originalValues,overridesCache,errors]=...
                overrideBaseWorkspace(x,originalValues,overridesStruct(x),overridesCache,errors);
            elseif strcmp(overridesStruct(x).SourceType,'model workspace')
                [originalValues,overridesCache,errors,modelWorkspaceDirtyState,hModelWorkspace]=...
                overrideModelWorkspace(x,originalValues,overridesStruct(x),overridesCache,errors,modelToRun);
            elseif endsWith(overridesStruct(x).SourceType,'.sldd')
                [originalValues,overridesCache,errors,dataDictionaryStates]=...
                overrideSldd(x,originalValues,overridesStruct(x),overridesCache,errors,poWrapper,dataDictionaryStates);
            elseif strcmp(overridesStruct(x).SourceType,'mask workspace')
                try
                    source=overridesStruct(x).Source;
                    name=overridesStruct(x).Name;
                    [maskParam,errStr]=stm.internal.MRT.share.getMaskParameter(source,name);
                    if isempty(maskParam)



                        originalValues(x).Error=true;
                        if(~isempty(errStr))
                            errors.messages{end+1}=errStr;
                            errors.errorOrLog{end+1}=true;
                        end
                    else
                        originalValues(x).OriginalValue=maskParam.Value;
                        ParameterOverrideWrapper.setMaskParamValue(...
                        overridesStruct(x).Value,source,name,maskParam);
                    end
                catch me
                    originalValues(x).Error=true;
                    errors.messages{end+1}=stm.internal.MRT.share.getString('stm:Parameters:MaskOverrideError',overridesStruct(x).Name);
                    errors.errorOrLog{end+1}=true;
                    errors.messages{end+1}=me.message;
                    errors.errorOrLog{end+1}=true;
                end
                overridesCache{1,x}=overridesStruct(x).Value;
            end

            if(fromIteration)

                overridesCache{2,x}=overridesStruct(x).Id;
                [~,overridesCache{3,x}]=stm.internal.util.getDisplayValue(overridesStruct(x).Value);
            else
                overridesCache{2,x}=overridesStruct(x).NamedParamId;
            end
        end
    catch err
        errors.messages{end+1}=err.message;
        errors.errorOrLog{end+1}=true;
    end
end

function[originalValues,overridesCache,errors]=overrideBaseWorkspace(...
    x,originalValues,overridesStruct,overridesCache,errors)

    if overridesStruct.IsDerived
        overridesCache{1,x}=overridesStruct.RuntimeValue;
        [~,overridesCache{3,x}]=stm.internal.util.getDisplayValue(overridesStruct.RuntimeValue);
    else

        try
            value=overridesStruct.Value;
            if~overridesStruct.IsOverridingChar
                value=evalin('base',overridesStruct.Value);
            end
            overridesCache{1,x}=value;
        catch me
            overridesCache{1,x}=overridesStruct.Value;
            originalValues(x).Error=true;
            errors.messages{end+1}=me.message;
            errors.errorOrLog{end+1}=true;
        end
    end

    if~originalValues(x).Error
        try
            originalValues(x).OriginalValue=evalin('base',overridesStruct.Name);
        catch me
            overridesCache{1,x}=overridesStruct.Value;
            originalValues(x).Error=true;
            errors.messages{end+1}=me.message;
            errors.errorOrLog{end+1}=true;
        end
        if~originalValues(x).Error
            if isa(originalValues(x).OriginalValue,'Simulink.Parameter')
                if isa(overridesCache{1,x},'Simulink.Parameter')
                    assignin('base',overridesStruct.Name,overridesCache{1,x});
                else


                    tmpObj=originalValues(x).OriginalValue.copy;
                    tmpObj.Value=overridesCache{1,x};
                    assignin('base',overridesStruct.Name,tmpObj);
                    overridesCache{1,x}=tmpObj;
                end
                if isempty(overridesCache{3,x})
                    [~,overridesCache{3,x}]=stm.internal.util.getDisplayValue(overridesCache{1,x});
                end
            else
                assignin('base',overridesStruct.Name,overridesCache{1,x});
            end
        end
    end
end

function[originalValues,overridesCache,errors,modelWorkspaceDirtyState,hModelWorkspace]=...
    overrideModelWorkspace(x,originalValues,overridesStruct,...
    overridesCache,errors,modelToRun)


    hModelWorkspace=get_param(modelToRun,'modelworkspace');
    modelWorkspaceDirtyState=hModelWorkspace.isdirty;

    if overridesStruct.IsDerived
        overridesCache{1,x}=overridesStruct.RuntimeValue;
        [~,overridesCache{3,x}]=stm.internal.util.getDisplayValue(overridesStruct.RuntimeValue);
    else
        try
            value=overridesStruct.Value;
            if~overridesStruct.IsOverridingChar
                value=eval(overridesStruct.Value);
            end
            overridesCache{1,x}=value;
        catch me
            overridesCache{1,x}=overridesStruct.Value;
            originalValues(x).Error=true;
            errors.messages{end+1}=me.message;
            errors.errorOrLog{end+1}=true;
        end
    end

    if~originalValues(x).Error
        try
            originalValues(x).OriginalValue=hModelWorkspace.evalin(overridesStruct.Name);
        catch me
            overridesCache{1,x}=overridesStruct.Value;
            originalValues(x).Error=true;
            errors.messages{end+1}=me.message;
            errors.errorOrLog{end+1}=true;
        end
        if~originalValues(x).Error
            if isa(originalValues(x).OriginalValue,'Simulink.Parameter')
                if isa(overridesCache{1,x},'Simulink.Parameter')
                    hModelWorkspace.assignin(overridesStruct.Name,overridesCache{1,x});
                else


                    tmpObj=slprivate('copyHelper',originalValues(x).OriginalValue.copy);
                    tmpObj.Value=overridesCache{1,x};
                    hModelWorkspace.assignin(overridesStruct.Name,tmpObj);
                    overridesCache{1,x}=tmpObj;
                end
                if isempty(overridesCache{3,x})
                    [~,overridesCache{3,x}]=stm.internal.util.getDisplayValue(overridesCache{1,x});
                end
            else
                hModelWorkspace.assignin(overridesStruct.Name,overridesCache{1,x});
            end
        end
    end
end

function[originalValues,overridesCache,errors,dataDictionaryStates]=...
    overrideSldd(x,originalValues,overridesStruct,overridesCache,errors,poWrapper,dataDictionaryStates)
    if overridesStruct.IsDerived
        overridesCache{1,x}=overridesStruct.RuntimeValue;
        [~,overridesCache{3,x}]=stm.internal.util.getDisplayValue(overridesStruct.RuntimeValue);
    else
        try
            value=overridesStruct.Value;
            if~overridesStruct.IsOverridingChar
                value=eval(overridesStruct.Value);
            end
            overridesCache{1,x}=value;
        catch me
            overridesCache{1,x}=overridesStruct.Value;
            originalValues(x).Error=true;
            errors.messages{end+1}=me.message;
            errors.errorOrLog{end+1}=true;
        end
    end

    try
        dataDictionary=Simulink.data.dictionary.open(overridesStruct.SourceType);
        [dataDictionaryStates,index]=poWrapper.addDataDictionary(dataDictionary,dataDictionaryStates);
        originalValues(x).DataDictionaryState=dataDictionaryStates(index);
    catch me
        overridesCache{1,x}=overridesStruct.Value;
        originalValues(x).Error=true;
        errors.messages{end+1}=me.message;
        errors.errorOrLog{end+1}=true;
    end

    if originalValues(x).Error
        return;
    end

    dds=dataDictionaryStates(index).DataDictionary.getSection('Design Data');
    try
        name=overridesStruct.Name;
        if dds.exist(name)
            entry=dds.getEntry(name);
        else
            dds=dataDictionary.getSection('Configurations');
            entry=dds.getEntry(name);
        end
    catch me
        overridesCache{1,x}=overridesStruct.Value;
        originalValues(x).Error=true;
        errors.messages{end+1}=me.message;
        errors.errorOrLog{end+1}=true;
    end

    if originalValues(x).Error
        return;
    end

    obj.Discard=false;
    obj.Value=entry.getValue();
    if dataDictionaryStates(index).Dirty
        if strcmp(entry.Status,'Unchanged')


            obj.Discard=true;
        elseif strcmp(entry.Status,'Modified')||strcmp(entry.Status,'New')

        else
            return;
        end
    end

    if~originalValues(x).Error
        originalValues(x).OriginalValue=obj;
        if isa(originalValues(x).OriginalValue.Value,'Simulink.Parameter')
            if isa(overridesCache{1,x},'Simulink.Parameter')
                dds.assignin(overridesStruct.Name,overridesCache{1,x});
            else
                assert(~originalValues(x).OriginalValue.Value.CoderInfo.HasContext,'Expected objects without context');
                tmpObj=originalValues(x).OriginalValue.Value.copy;
                tmpObj.Value=overridesCache{1,x};
                dds.assignin(overridesStruct.Name,tmpObj);
                overridesCache{1,x}=tmpObj;
            end
            if isempty(overridesCache{3,x})
                [~,overridesCache{3,x}]=stm.internal.util.getDisplayValue(overridesCache{1,x});
            end
        else
            dds.assignin(overridesStruct.Name,overridesCache{1,x});
        end
    end
end
