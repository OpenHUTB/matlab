function utilAdjustTestPoints(mdladvObj,hDI)






    if~hDI.isIPCoreGen
        return;
    end


    targetInterfaceTaskID=utilGetTargetInterfaceTask(hDI);
    inputParams=mdladvObj.getInputParameters(targetInterfaceTaskID);
    testPointOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:hdlglblsettingsEnableTestpoints'));

    testPointOption.Value=hDI.isTestPointEnabledOnModel;

end