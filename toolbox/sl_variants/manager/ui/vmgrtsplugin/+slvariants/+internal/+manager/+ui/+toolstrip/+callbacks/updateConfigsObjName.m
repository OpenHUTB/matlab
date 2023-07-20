function updateConfigsObjName(cbinfo)











    if strcmp(cbinfo.Context.Object.VarConfigsObjName,cbinfo.EventData)...
        ||strcmp(cbinfo.Context.Object.TempVarConfigsObjName,cbinfo.EventData)

        return;
    end

    cbinfo.Context.Object.setTempVarConfigsObjName(cbinfo.EventData);

    modelHandle=cbinfo.Context.Object.getModelHandle();
    modelName=getfullname(modelHandle);

    slvariants.internal.manager.core.restoreDiagnosticViewer(modelHandle);


    diagInterceptor=slvariants.internal.manager.ui.diag.VMgrDiagInterceptor(modelName);
    diagProcessor=Simulink.output.registerProcessor(diagInterceptor);%#ok<SETNU>
    diagCleanupObj=onCleanup(@()cleanupFcn());

    migDiagStageName=getString(message('Simulink:VariantManagerUI:VarConfigObjStage'));
    migDiagStage=sldiagviewer.createStage(migDiagStageName,ModelName=diagInterceptor.DiagnosticViewerName);%#ok<NASGU>

    if~isvarname(cbinfo.EventData)&&~isempty(cbinfo.EventData)
        invalidNameMsg=MException(message('Simulink:VariantManagerUI:MessageInvalidconfigdataname'));
        sldiagviewer.reportError(invalidNameMsg);
        return;
    end

    [~,varIsVarConfigDataObject,~]=Simulink.variant.utils.existsVCDO(modelHandle,cbinfo.EventData);
    prevVarConfigsObjName=cbinfo.Context.Object.VarConfigsObjName;

    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configSchema=dlg.getSource;

    if isempty(prevVarConfigsObjName)&&configSchema.IsSourceObjDirtyFlag&&varIsVarConfigDataObject
        yesStr=message('MATLAB:uistring:popupdialogs:Yes').getString();
        noStr=message('MATLAB:uistring:popupdialogs:No').getString();
        questMsg=DAStudio.message('Simulink:VariantManagerUI:VariantManagerPromptOverwriteUnsavedVCDO',...
        cbinfo.EventData);

        selection=questdlg(questMsg,configSchema.BDName,yesStr,noStr,noStr);
        switch selection
        case yesStr
        case noStr
            return;
        end
    end

    success=configSchema.updateVariantConfigurationsName(cbinfo.EventData,configSchema);






    if~success
        return;
    end

    cbinfo.Context.Object.setVarConfigsObjName(cbinfo.EventData);



    if varIsVarConfigDataObject
        configSchema.refreshVariantConfigurations(dlg,configSchema);
        return;
    end

    if isempty(cbinfo.Context.Object.VarConfigsObjName)
        msgId='Simulink:VariantManagerUI:VariantManagerDisassociatedVCDOSuccessfulMessage';
        updateVarConfigNameMsg=MException(message(msgId,prevVarConfigsObjName));
    else
        msgId='Simulink:VariantManagerUI:VariantManagerImportSuccessfulMessageCreateV2';
        vcdoName=cbinfo.EventData;
        ddSpec=get_param(modelName,'DataDictionary');
        if isempty(ddSpec)
            baseWorkspace=getString(message('Simulink:VariantManagerUI:BaseWorkspace'));
            updateVarConfigNameMsg=MException(message(msgId,vcdoName,baseWorkspace));
        else
            updateVarConfigNameMsg=MException(message(msgId,vcdoName,ddSpec));
        end
    end

    sldiagviewer.reportInfo(updateVarConfigNameMsg);

    function cleanupFcn()
        clear diagInterceptor;
        clear diagProcessor;
    end
end
