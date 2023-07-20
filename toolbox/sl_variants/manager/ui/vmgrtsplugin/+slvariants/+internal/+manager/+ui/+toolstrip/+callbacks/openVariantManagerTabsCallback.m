function openVariantManagerTabsCallback(userdata,cbinfo)






    modelHandle=cbinfo.Context.Object.App.ModelHandle;
    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);
    modelName=getfullname(modelHandle);
    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configSchema=dlg.getSource;
    toolStrip=vmStudioHandle.getToolStrip;
    tabName=getTabNameFromCtx(userdata);


    diagInterceptor=slvariants.internal.manager.ui.diag.VMgrDiagInterceptor(modelName);
    diagProcessor=Simulink.output.registerProcessor(diagInterceptor);%#ok<SETNU>
    diagCleanupObj=onCleanup(@()cleanupFcn());

    tabChangeStageName=getString(message('Simulink:VariantManagerUI:TabChangeDiagStage',tabName));
    tabChangeDiagStage=sldiagviewer.createStage(tabChangeStageName,ModelName=diagInterceptor.DiagnosticViewerName);%#ok<NASGU>


    isDirty=strcmp(get_param(modelName,'Dirty'),'on');
    if isDirty


        slvariants.internal.manager.core.restoreDiagnosticViewer(modelHandle);
        sldiagviewer.reportInfo(MException(message('Simulink:VariantManagerUI:UnsavedModelErrorOnTabChange',modelName,tabName)));
        return;
    end


    if~slvariants.internal.manager.core.createDlgForUnexportedChanges(modelHandle,configSchema,toolStrip)
        return;
    end

    ddSpec=get_param(modelName,'DataDictionary');


    if~isempty(ddSpec)
        try
            isGlobal=true;
            slvariants.internal.manager.ui.importVariantControlVars(dlg,configSchema,isGlobal);
        catch exep
            slvariants.internal.manager.core.restoreDiagnosticViewer(modelHandle);
            sldiagviewer.reportError(exep);
            return;
        end
    end



    currTypeChain=cbinfo.Context.Object.TypeChain;

    cbinfo.Context.Object.TypeChain=[currTypeChain,{userdata}];


    toolStrip=vmStudioHandle.getToolStrip;
    slvariants.internal.manager.ui.utils.toolstripTabChangeCB(toolStrip.ActiveTab,modelHandle);

    function cleanupFcn()
        clear diagInterceptor;
        clear diagProcessor;
    end
end

function tabName=getTabNameFromCtx(ctx)
    switch ctx
    case 'variantReducerContext'
        tabName=getString(message('Simulink:VariantManagerUI:ReducerTab'));
    case 'variantAnalyzerContext'
        tabName=getString(message('Simulink:VariantManagerUI:AnalysisTab'));
    case 'generateConfigContext'
        tabName=getString(message('Simulink:VariantManagerUI:AutoGenConfigTabLabel'));
    end
end


