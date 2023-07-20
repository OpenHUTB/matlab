function toggleDDSAppCB(cbinfo)



















































































    modelName=cbinfo.model.Name;
    isDDSModel=dds.internal.simulink.Util.checkIfModelMappingIsSetToDDS(modelName);











    if isDDSModel
        coder.internal.toolstrip.CoderAppContext.toggleCoderApp(cbinfo,'ddsApp',true);
    else
        if~isempty(cbinfo.EventData)
            if cbinfo.EventData


                dds.internal.ui.app.quickstart.WizardManager.wizard(modelName);
            end
        else


            dds.internal.ui.app.quickstart.WizardManager.wizard(modelName);
        end
    end
