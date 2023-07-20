function revertConfigsObjChanges(cbinfo)




    modelHandle=cbinfo.Context.Object.getModelHandle();
    modelName=getfullname(modelHandle);


    diagInterceptor=slvariants.internal.manager.ui.diag.VMgrDiagInterceptor(modelName);
    diagProcessor=Simulink.output.registerProcessor(diagInterceptor);%#ok<SETNU>
    diagCleanupObj=onCleanup(@()cleanupFcn());

    migDiagStageName=getString(message('Simulink:VariantManagerUI:VarConfigObjStage'));
    migDiagStage=sldiagviewer.createStage(migDiagStageName,ModelName=diagInterceptor.DiagnosticViewerName);%#ok<NASGU>
    cbinfo.Context.Object.setTempVarConfigsObjName(cbinfo.EventData);

    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configSchema=dlg.getSource;
    configSchema.refreshVariantConfigurations(dlg,configSchema);

    configSchema.IsSourceObjDirtyFlag=false;




    slvariants.internal.manager.ui.compbrowser.SpreadSheetTabChange.setCompBrowserVisible(modelName,false);

    function cleanupFcn()
        clear diagInterceptor;
        clear diagProcessor;
    end
end


