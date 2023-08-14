function importVariantControlVars(dlg,configDlgSchema,isGlobal)






    if nargin<3
        isGlobal=false;
    end

    modelName=configDlgSchema.BDName;
    modelH=get_param(modelName,'handle');
    slvariants.internal.manager.core.restoreDiagnosticViewer(modelH);

    diagInterceptor=slvariants.internal.manager.ui.diag.VMgrDiagInterceptor(modelName);
    diagProcessor=Simulink.output.registerProcessor(diagInterceptor);%#ok<SETNU>
    diagCleanupObj=onCleanup(@()cleanupFcn());

    migDiagStageName=getString(message('Simulink:VariantManagerUI:ImportVarCtrlStage'));
    migDiagStage=sldiagviewer.createStage(migDiagStageName,ModelName=diagInterceptor.DiagnosticViewerName);%#ok<NASGU>

    ctrlVarsInfo=slvariants.internal.manager.core.findVariantControlVars(modelName);

    if isempty(ctrlVarsInfo)
        noVarsFoundInfoMsg=MException(message('Simulink:VariantManagerUI:MessageInfoNovariables'));
        sldiagviewer.reportInfo(noVarsFoundInfoMsg);
        return;
    end

    if isGlobal
        ctrlVarSSSrc=configDlgSchema.GlobalConfigSSSrc.CtrlVarSources(1);
    else
        ctrlVarSSSrc=configDlgSchema.CtrlVarSSSrc;
    end
    convertUndefinedCtrlVarsToSLVarCtrl=isa(ctrlVarSSSrc.getNewCtrlVarCtxBased(),'Simulink.VariantControl')||getIsAnyCtrlVarSLVarCtrl(ctrlVarsInfo);

    for idx=1:numel(ctrlVarsInfo)
        if~ctrlVarsInfo(idx).Exists&&convertUndefinedCtrlVarsToSLVarCtrl&&~isa(ctrlVarsInfo(idx).Value,'Simulink.VariantControl')


            ctrlVarsInfo(idx).Value=Simulink.VariantControl(Value=ctrlVarsInfo(idx).Value);
        end
    end


    ctrlVarsFullNamesInConfig=ctrlVarSSSrc.getControlVariableFullNames();

    ctrlVarsInfoFullNames=arrayfun(@(X)[X.Name,'/',X.Source],ctrlVarsInfo,'UniformOutput',false)';


    [~,configIdx,ctrlVarsInfoIdx]=intersect(ctrlVarsFullNamesInConfig,ctrlVarsInfoFullNames,'stable');
    [~,ctrlVarsInfoDiffIdx]=setdiff(ctrlVarsInfoFullNames,ctrlVarsFullNamesInConfig);


    if ctrlVarSSSrc.IsGlobalWksConfig
        for idx=1:length(configIdx)
            ctrlVarSSSrc.Children(configIdx(idx)).setControlVariableValue(ctrlVarsInfo(ctrlVarsInfoIdx(idx)).Value);
            ctrlVarSSSrc.Children(configIdx(idx)).setControlVariableSource(ctrlVarsInfo(ctrlVarsInfoIdx(idx)).Source);
        end
    end


    for idx=1:numel(ctrlVarsInfoDiffIdx)
        ctrlVarSSSrc.addControlVariable(dlg);
        newRow=ctrlVarSSSrc.Children(end);
        newRow.setControlVariableName(ctrlVarsInfo(ctrlVarsInfoDiffIdx(idx)).Name);
        ctrlVarValue=ctrlVarsInfo(ctrlVarsInfoDiffIdx(idx)).Value;
        newRow.setControlVariableValue(Simulink.variant.utils.deepCopy(ctrlVarValue,'ErrorForNonCopyableHandles',false));
        newRow.setControlVariableSource(ctrlVarsInfo(ctrlVarsInfoDiffIdx(idx)).Source);
    end

    populateCtrlVarNameToUsageMap(ctrlVarsInfo,configDlgSchema);


    if~isGlobal&&any(strcmp(configDlgSchema.SelectedConfig,configDlgSchema.SourceObj.getConfigurationNames()))

        configDlgSchema.setSourceObjDirtyFlag(configDlgSchema);
    end
    configDlgSchema.callUpdateOnSpreadsheet(dlg,'controlVariablesSSWidgetTag');

    varsFoundAndImportedMsg=getString(message('Simulink:VariantManagerUI:MessageImportVariablesFound'));
    sldiagviewer.reportInfo(varsFoundAndImportedMsg);

    function cleanupFcn()
        clear diagInterceptor;
        clear diagProcessor;
    end

end

function populateCtrlVarNameToUsageMap(ctrlVarsInfo,configDlgSchema)




    ctrlVarNameToUsageMap=containers.Map('keyType','char','valueType','any');
    for idx=1:length(ctrlVarsInfo)
        ctrlVarName=ctrlVarsInfo(idx).Name;
        if isKey(ctrlVarNameToUsageMap,ctrlVarName)

            ctrlVarUsage=ctrlVarNameToUsageMap(ctrlVarName);
            ctrlVarUsage{end+1}=ctrlVarsInfo(idx).Usage;%#ok<AGROW>
            ctrlVarNameToUsageMap(ctrlVarName)=ctrlVarUsage;
        else
            ctrlVarUsage{1}=ctrlVarsInfo(idx).Usage;
            ctrlVarNameToUsageMap(ctrlVarName)=ctrlVarUsage;
        end
    end

    configDlgSchema.setControlVariablesUsageMap(ctrlVarNameToUsageMap);
end

function isAnyCtrlVarSLVarCtrl=getIsAnyCtrlVarSLVarCtrl(ctrlVarsInfo)
    isAnyCtrlVarSLVarCtrl=false;
    for i=1:numel(ctrlVarsInfo)
        if ctrlVarsInfo(i).Exists&&isa(ctrlVarsInfo(i).Value,'Simulink.VariantControl')
            isAnyCtrlVarSLVarCtrl=true;
            break;
        end
    end
end


