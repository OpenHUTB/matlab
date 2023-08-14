function utilAdjustEmbeddedSystemBuild(mdladvObj,hDI)





    if isempty(hDI.hIP)
        return;
    end

    hdlwaDriver=hdlwa.hdlwaDriver.getHDLWADriverObj;
    targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.EmbeddedSystemBuild');


    inputParams=mdladvObj.getInputParameters(targetObj.MAC);
    extbuildOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEDKExternal'));
    designCheckpointOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableDesignCheckpoint'));
    buildTclOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableDefaultBuildTcl'));
    customTclFile=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWASpecifyCustomBuildTcl'));
    browse=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWACustomTclBrowse'));
    maxNumOfCoresOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputNoOfCores'));
    defaultCheckpointOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableDefaultCheckpointFile'));
    routedDesignCheckpointFilePath=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableDesignCheckpointFile'));
    browseCheckpoint=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableDesignCheckpointFileBrowse'));





    if(strcmp(hDI.getTclFileForSynthesisBuild,'Default'))
        customTclFile.Value='';
        customTclFile.Enable=false;
        browse.Enable=false;
        buildTclOption.Value='Default';
    else
        customTclFile.Value=hDI.getCustomBuildTclFile;
        customTclFile.Enable=true;
        browse.Enable=true;
        buildTclOption.Value='Custom';
    end
    extbuildOption.Value=hDI.hIP.getEmbeddedExternalBuild;







    hRD=hDI.hIP.getReferenceDesignPlugin;
    extbuildOption.Enable=isempty(hRD)||isempty(hRD.PostBuildBitstreamFcn);

    designCheckpointOption.Value=hDI.getEnableDesignCheckpoint;
    maxNumOfCoresOption.Value=hDI.getMaxNumOfCores;


    tool=hDI.get('Tool');
    isVivado=strcmp(tool,'Xilinx Vivado');

    if~isVivado
        designCheckpointOption.Enable=false;
        maxNumOfCoresOption.Enable=false;
    else
        maxNumOfCoresOption.Enable=true;
        designCheckpointOption.Enable=true;
    end

    if hDI.isLiberoSoc
        buildTclOption.Enable=false;
    end


    if(~designCheckpointOption.Value)
        routedDesignCheckpointFilePath.Value=hDI.hIP.getIPCoreDesignCheckpointFile;
        routedDesignCheckpointFilePath.Enable=false;
        browseCheckpoint.Enable=false;
        defaultCheckpointOption.Value='Default';
        defaultCheckpointOption.Enable=false;
    elseif(designCheckpointOption.Value&&(strcmp(hDI.getDefaultCheckpointFile,'Default')))
        routedDesignCheckpointFilePath.Value=hDI.hIP.getIPCoreDesignCheckpointFile;
        routedDesignCheckpointFilePath.Enable=false;
        browseCheckpoint.Enable=false;
        defaultCheckpointOption.Enable=true;
        defaultCheckpointOption.Value='Default';
    else
        routedDesignCheckpointFilePath.Value=hDI.getRoutedDesignCheckpointFilePath;
        routedDesignCheckpointFilePath.Enable=true;
        browseCheckpoint.Enable=true;
        defaultCheckpointOption.Enable=true;
        defaultCheckpointOption.Value='Custom';
    end

end





