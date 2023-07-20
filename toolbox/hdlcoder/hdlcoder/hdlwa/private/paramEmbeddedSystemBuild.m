function paramEmbeddedSystemBuild(taskobj)






    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    extbuildOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEDKExternal'));
    designCheckpointOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableDesignCheckpoint'));
    buildTclOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableDefaultBuildTcl'));
    customTclFile=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWASpecifyCustomBuildTcl'));
    maxNumOfCoresOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputNoOfCores'));
    defaultCheckpointOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableDefaultCheckpointFile'));
    routedDesignCheckpointFilePath=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableDesignCheckpointFile'));



    if~isequal(extbuildOption.Value,hDI.hIP.getEmbeddedExternalBuild)
        hDI.hIP.setEmbeddedExternalBuild(extbuildOption.Value);
    end

    if~isequal(designCheckpointOption.Value,hDI.getEnableDesignCheckpoint)
        hDI.setEnableDesignCheckpoint(designCheckpointOption.Value);
    end

    if~isequal(maxNumOfCoresOption.Value,hDI.getMaxNumOfCores)
        hDI.setMaxNumOfCores(maxNumOfCoresOption.Value);
    end


    try
        updateParameterName='';
        if(~strcmp(buildTclOption.Value,hDI.getTclFileForSynthesisBuild))
            updateParameterName='tclSelection';
            hDI.setTclFileForSynthesisBuild(buildTclOption.Value);
        elseif~strcmp(customTclFile.Value,hDI.getCustomBuildTclFile)
            updateParameterName='customBuildTclFile';
            hDI.setCustomBuildTclFile(customTclFile.Value);
        end
        updateParamName='';
        if(~strcmp(defaultCheckpointOption.Value,hDI.getDefaultCheckpointFile))
            updateParamName='checkpointSelection';
            hDI.setDefaultCheckpointFile(defaultCheckpointOption.Value);
            hDI.setRoutedDesignCheckpointFilePath(routedDesignCheckpointFilePath.Value);
        elseif~strcmp(routedDesignCheckpointFilePath.Value,hDI.getRoutedDesignCheckpointFilePath)
            updateParamName='customCheckpointFile';
            hDI.setRoutedDesignCheckpointFilePath(routedDesignCheckpointFilePath.Value);
        end
    catch ME
        hf=errordlg(ME.message,'Error','modal');

        set(hf,'tag','HDL Workflow Advisor error dialog');
        setappdata(hf,'MException',ME);


        uiwait(hf);


        hMAExplorer=mdladvObj.MAExplorer;
        if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
            currentDialog=hMAExplorer.getDialog;
            if strcmpi(updateParameterName,'customBuildTclFile')
                currentDialog.setWidgetValue('InputParameters_3',hDI.getCustomBuildTclFile);
            end
        end
        if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
            currentDialog=hMAExplorer.getDialog;
            if strcmpi(updateParamName,'customCheckpointFile')
                currentDialog.setWidgetValue('InputParameters_5',hDI.getRoutedDesignCheckpointFilePath);
            end
        end
    end


    utilAdjustEmbeddedSystemBuild(mdladvObj,hDI);
end


