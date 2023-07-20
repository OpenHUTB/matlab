function applyConfigsObjChanges(cbinfo)




    modelHandle=cbinfo.Context.Object.getModelHandle();
    modelName=getfullname(modelHandle);
    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configSchema=dlg.getSource;
    isSuccess=configSchema.applyVariantConfigurations(configSchema);

    if isSuccess

        configSchema.IsSourceObjDirtyFlag=false;




        slvariants.internal.manager.core.restoreDiagnosticViewer(modelHandle);
        ddSpec=get_param(modelName,'DataDictionary');

        diagInterceptor=slvariants.internal.manager.ui.diag.VMgrDiagInterceptor(modelName);
        diagProcessor=Simulink.output.registerProcessor(diagInterceptor);%#ok<SETNU>
        diagCleanupObj=onCleanup(@()cleanupFcn());

        varConfigStageName=getString(message('Simulink:VariantManagerUI:VarConfigObjStage'));
        varConfigStage=sldiagviewer.createStage(varConfigStageName,ModelName=diagInterceptor.DiagnosticViewerName);%#ok<NASGU>

        baseWorkspace=getString(message('Simulink:VariantManagerUI:BaseWorkspace'));
        if isempty(ddSpec)
            importVarConfigMsg=MException(message('Simulink:VariantManagerUI:MessageInfoVarConfigObjToWorkspace',cbinfo.Context.Object.VarConfigsObjName,baseWorkspace));
        else
            importVarConfigMsg=MException(message('Simulink:VariantManagerUI:MessageInfoVarConfigObjToWorkspace',cbinfo.Context.Object.VarConfigsObjName,ddSpec));
        end
        sldiagviewer.reportInfo(importVarConfigMsg);
    end

    function cleanupFcn()
        clear diagInterceptor;
        clear diagProcessor;
    end
end


