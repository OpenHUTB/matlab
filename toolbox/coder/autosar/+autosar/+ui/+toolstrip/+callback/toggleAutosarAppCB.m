function toggleAutosarAppCB(cbinfo)




    try


        modelName=get_param(cbinfo.model.Handle,'Name');
        Simulink.output.Stage(modelName,'ModelName',modelName,'UIMode',true);
        toggleAutosarApp(cbinfo);
    catch ME
        sldiagviewer.reportError(ME);
    end
end

function toggleAutosarApp(cbinfo)
    modelH=cbinfo.model.Handle;
    coder.internal.toolstrip.CoderAppContext.toggleCoderApp(cbinfo,'autosarApp',true);
    if autosar.api.Utils.isMapped(modelH)


        m3iModel=autosarcore.M3IModelLoader.loadM3IModel(modelH,showProgressBar=true,...
        IsUIMode=true);
        autosar.ui.utils.registerListenerCB(m3iModel);
    end
end
