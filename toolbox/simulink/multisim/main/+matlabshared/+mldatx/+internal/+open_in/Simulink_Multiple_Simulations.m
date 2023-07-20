function Simulink_Design_Suite(fileName)





    fileReader=simulink.simmanager.FileReader(fileName);
    readAsXML=false;
    modelName=fileReader.getPart("/ModelName",readAsXML);

    try
        open_system(modelName);
    catch ME
        error(message("multisim:SetupGUI:ModelNotFound",modelName));
    end
    studios=simulink.multisim.internal.getAllStudiosForModel(modelName);
    simulink.multisim.internal.openDesignSession(studios(1));

    modelHandle=get_param(modelName,"Handle");
    dataId=simulink.multisim.internal.blockDiagramAssociatedDataId();
    bdData=Simulink.BlockDiagramAssociatedData.get(modelHandle,dataId);

    simulink.multisim.internal.utils.Session.openFile(...
    bdData.SessionDataModel,bdData.Session,modelHandle,fileName);
end
