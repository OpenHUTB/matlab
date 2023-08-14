function utilAdjustEmbeddedProject(mdladvObj,hDI)





    if isempty(hDI.hIP)
        return;
    end

    hdlwaDriver=hdlwa.hdlwaDriver.getHDLWADriverObj;
    targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.EmbeddedProject');


    inputParams=mdladvObj.getInputParameters(targetObj.MAC);
    toolNameOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEDKToolName'));
    toolFolderOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEDKToolFolder'));
    objectiveOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAObjective'));
    ipcacheOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPCache'));



    toolNameOption.Value=hDI.hIP.getEmbeddedTool;
    toolFolderOption.Value=hDI.hIP.getEmbeddedToolProjFolder;
    objectiveOption.Value=hDI.getObjectiveName;
    ipcacheOption.Value=hDI.hIP.getUseIPCache;



    ipcacheOption.Enable=hDI.hIP.enableUseIPCache;
    objectiveOption.Enable=hDI.hIP.enableObjective;
end





