function isReset=utilParseEmbeddedSystemBuild(mdladvObj,hDI)




    hdlwaDriver=hdlwa.hdlwaDriver.getHDLWADriverObj;
    taskObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.EmbeddedSystemBuild');


    inputParams=mdladvObj.getInputParameters(taskObj.MAC);
    extbuildOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEDKExternal'));
    designCheckpointOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableDesignCheckpoint'));
    buildTclOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableDefaultBuildTcl'));
    customTclFile=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWASpecifyCustomBuildTcl'));

    maxNumOfCoresOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputNoOfCores'));
    defaultCheckpointOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableDefaultCheckpointFile'));
    routedDesignCheckpointFilePath=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableDesignCheckpointFile'));


    isReset=false;

    try
        if~isequal(extbuildOption.Value,hDI.hIP.getEmbeddedExternalBuild)
            hDI.hIP.setEmbeddedExternalBuild(extbuildOption.Value);
        end

        if~isequal(designCheckpointOption.Value,hDI.getEnableDesignCheckpoint)
            hDI.setEnableDesignCheckpoint(designCheckpointOption.Value);
        end

        if~isequal(buildTclOption.Value,hDI.TclFileForSynthesisBuild)
            hDI.TclFileForSynthesisBuild=buildTclOption.Value;
        end

        if~isequal(customTclFile.Value,hDI.getCustomBuildTclFile)
            hDI.setCustomBuildTclFile(customTclFile.Value);
        end

        if~isequal(maxNumOfCoresOption.Value,hDI.getMaxNumOfCores)
            hDI.setMaxNumOfCores(maxNumOfCoresOption.Value);
        end

        if~isequal(defaultCheckpointOption.Value,hDI.DefaultCheckpointFile)
            hDI.DefaultCheckpointFile=defaultCheckpointOption.Value;
        end

        if~isequal(routedDesignCheckpointFilePath.Value,hDI.getRoutedDesignCheckpointFilePath)
            hDI.setRoutedDesignCheckpointFilePath(routedDesignCheckpointFilePath.Value);
        end
    catch ME

        taskObj.reset;
        isReset=true;

        errorMsg=sprintf(['Error occurred in Task 4.3 when loading Restore Point.\n',...
        'The error message is:\n%s\n'],...
        ME.message);
        hf=errordlg(errorMsg,'Error','modal');

        set(hf,'tag','load Embedded System Build error dialog');
        setappdata(hf,'MException',ME);
    end

end


