function isReset=utilParseEmbeddedProject(mdladvObj,hDI)




    hdlwaDriver=hdlwa.hdlwaDriver.getHDLWADriverObj;
    taskObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.EmbeddedProject');

    isReset=false;


    inputParams=mdladvObj.getInputParameters(taskObj.MAC);
    toolNameOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEDKToolName'));
    toolFolderOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEDKToolFolder'));
    objectiveOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAObjective'));
    ipcacheOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPCache'));



    try
        if(~isequal(toolNameOption.Value,hDI.hIP.getEmbeddedTool))
            hDI.hIP.setEmbeddedTool(toolNameOption.Value);
        end

        if(~isequal(toolFolderOption.Value,hDI.hIP.getEmbeddedToolProjFolder))
            hDI.hIP.setEmbeddedToolProjFolder(toolFolderOption.Value);
        end

        if(~isequal(objectiveOption.Value,hDI.getObjectiveName))
            hDI.setObjectiveFromName(objectiveOption.Value);
        end

        if(~isequal(ipcacheOption.Value,hDI.hIP.getUseIPCache))
            hDI.hIP.setUseIPCache(ipcacheOption.Value);
        end
    catch ME

        taskObj.reset;
        isReset=true;

        errorMsg=sprintf(['Error occurred in Task 4.1 when loading Restore Point.\n',...
        'The error message is:\n%s\n'],...
        ME.message);
        hf=errordlg(errorMsg,'Error','modal');

        set(hf,'tag','load Embedded System Build error dialog');
        setappdata(hf,'MException',ME);
    end
end

