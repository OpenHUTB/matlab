function updateParameterForModelWkspChange(mdlName,maName,maProp,maPropval)




    if nargin<3
        maProp='';
    end

    zcMdl=get_param(mdlName,'SystemComposerModel');
    if isempty(zcMdl)
        return;
    end

    doWarning=systemcomposer.internal.arch.internal.parameterSyncWarningStatus;
    rootArch=zcMdl.Architecture;

    paramDef=rootArch.getParameterDefinition(maName);

    mdlWksp=get_param(mdlName,'ModelWorkspace');
    maVar=mdlWksp.getVariable(maName);

    if isempty(paramDef)


        paramNames=rootArch.getParameterNames;
        transformedNames=replace(paramNames,{'.','/'},'_');
        if~isempty(find(strcmp(maName,transformedNames),1))

            return;
        end


        if strcmp(maProp,'Argument')&&(strcmp(maPropval,'1')||maPropval)
            paramDef=systemcomposer.internal.parameters.arch.sync.updateParameterFromModelArgument(rootArch,mdlName,maName,maVar);

            maProp='';
        end
    else
        if strcmp(maProp,'Argument')&&(strcmp(maPropval,'1')||maPropval)
            maProp='';
        end
    end

    if isempty(paramDef)
        return;
    end


    import systemcomposer.internal.parameters.arch.sync.*

    if isempty(maProp)


        syncValue(paramDef,maVar,mdlName,doWarning);
        syncUnit(paramDef,maVar,doWarning);
        syncDataType(paramDef,maVar,mdlName,doWarning);
        syncDimensions(paramDef,maVar,doWarning);
        syncComplexity(paramDef,maVar,doWarning);
        syncMin(paramDef,maVar,doWarning);
        syncMax(paramDef,maVar,doWarning);
    else
        switch maProp
        case 'Value'
            syncValue(paramDef,maVar,mdlName,doWarning);
        case 'Unit'
            syncUnit(paramDef,maVar,doWarning);
        case 'DataType'
            syncDataType(paramDef,maVar,mdlName,doWarning);
        case 'Min'
            syncMin(paramDef,maVar,doWarning);
        case 'Max'
            syncMax(paramDef,maVar,doWarning);
        case 'Dimensions'
            syncDimensions(paramDef,maVar,doWarning);
        case 'Complexity'
            syncComplexity(paramDef,maVar,doWarning);
        end
    end
end
