function forceRebuild(modelName,fileName,checksumName,key,taskID)




    if exist(fileName,'file')
        hdlwfsmartbuild.ServerSmartbuild.saveVarToFile(fileName,checksumName,'');
    end

    hDI=downstream.handle('Model',modelName);
    if strcmp(key,'ipcoreWrapGenSb')
        codeGenhandle=hDI.hCodeGen.hCHandle;
        codeGenhandle.getIncrementalCodeGenDriver().forceRegenCode(codeGenhandle);
    end


    if~hDI.isMDS&&~hDI.cliDisplay
        hdlturnkey.resetHDLWATask(taskID);
    end

end




