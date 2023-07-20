function utilAdjustEmbeddedModelGen(mdladvObj,hDI)





    if~hDI.isIPCoreGen
        return;
    end

    hdlwaDriver=hdlwa.hdlwaDriver.getHDLWADriverObj;

    if(hDI.isShowCustomSWModelGenerationTask)
        targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.EmbeddedCustomModelGen');
    else
        targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.EmbeddedModelGen');
    end


    inputParams=mdladvObj.getInputParameters(targetObj.MAC);
    swModelOption=utilGetInputParameter(inputParams,DAStudio.message('hdlcommon:workflow:HDLWASWInterfaceModel'));
    swModelOption.Value=hDI.hIP.GenerateSoftwareInterfaceModel;
    swModelOption.Enable=hDI.hIP.getGenerateSoftwareInterfaceModelEnable;



    if~hDI.isShowCustomSWModelGenerationTask
        osOption=utilGetInputParameter(inputParams,DAStudio.message('hdlcommon:workflow:HDLWAOS'));
        osOption.Entries=hDI.hIP.getOperatingSystemAll;
        osOption.Value=hDI.hIP.getOperatingSystem;
        osOption.Enable=hDI.hIP.getGenerateSoftwareInterfaceModelEnable;

        hostInterfaceOption=utilGetInputParameter(inputParams,DAStudio.message('hdlcommon:workflow:HDLWAHostTargetInterfaceType'));
        hostInterfaceOption.Entries=hDI.hIP.getHostTargetInterfaceOptions;
        hostInterfaceOption.Value=hDI.hIP.getHostTargetInterface;
        hostInterfaceOption.Enable=hDI.hIP.getEnableHostInterfaceOptions;


        hostModelOption=utilGetInputParameter(inputParams,DAStudio.message('hdlcommon:workflow:HDLWAHostInterfaceModel'));
        hostModelOption.Value=hDI.hIP.GenerateHostInterfaceModel;
        hostModelOption.Enable=hDI.hIP.getGenerateHostInterfaceModelEnable;


        hostScriptOption=utilGetInputParameter(inputParams,DAStudio.message('hdlcommon:workflow:HDLWASWInterfaceScript'));
        hostScriptOption.Value=hDI.hIP.GenerateHostInterfaceScript;
        hostScriptOption.Enable=hDI.hIP.getGenerateHostInterfaceScriptEnable;

    end

end

