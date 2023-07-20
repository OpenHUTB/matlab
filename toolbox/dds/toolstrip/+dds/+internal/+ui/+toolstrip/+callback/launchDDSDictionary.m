function launchDDSDictionary(cbinfo)




    modelName=SLStudio.Utils.getModelName(cbinfo);
    [attached,~,ddConn]=dds.internal.simulink.Util.isModelAttachedToDDSDictionary(modelName);
    if attached
        dds.internal.simulink.ui.internal.DDSLibraryUI.open(ddConn.filepath);
    end