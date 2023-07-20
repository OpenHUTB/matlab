function launchWizard(cbinfo)




    if~cbinfo.EventData
        return;
    end

    modelName=SLStudio.Utils.getModelName(cbinfo);
    dds.internal.ui.app.quickstart.WizardManager.wizard(modelName);

