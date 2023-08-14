function setReducerExcludeFiles(cbInfo)




    modelHandle=cbInfo.Context.Object.getModelHandle();
    modelName=getfullname(modelHandle);

    if isempty(cbInfo.EventData)
        cbInfo.Context.Object.App.ReductionOptions.ExcludeFiles={};
        return;
    end

    isValidValue=true;
    try





        eventData=eval(cbInfo.EventData);
    catch
        isValidValue=false;
    end

    isValidValue=isValidValue&&iscell(eventData)&&numel(eventData)>0;
    isValidValue=isValidValue&&all(cellfun(@(x)(ischar(x)),eventData));
    if~isValidValue






        slvariants.internal.manager.core.restoreDiagnosticViewer(modelHandle);

        diagInterceptor=slvariants.internal.manager.ui.diag.VMgrDiagInterceptor(modelName);
        diagProcessor=Simulink.output.registerProcessor(diagInterceptor);%#ok<SETNU>
        diagCleanupObj=onCleanup(@()cleanupFcn());
        me=MException(message('Simulink:VariantReducer:InvalidExcludeFilesUI'));
        sldiagviewer.reportError(me);

    else
        cbInfo.Context.Object.App.ReductionOptions.ExcludeFiles=eventData;
    end



    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);
    toolStrip=vmStudioHandle.getToolStrip;
    as=toolStrip.getActionService();
    as.refreshAction('variantReductionExcludeFilesEditBoxAction');

    function cleanupFcn()
        clear diagInterceptor;
        clear diagProcessor;
    end
end


