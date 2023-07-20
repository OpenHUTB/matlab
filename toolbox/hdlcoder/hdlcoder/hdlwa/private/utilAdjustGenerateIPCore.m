function utilAdjustGenerateIPCore(mdladvObj,hDI)




    if~hDI.isIPCoreGen
        return;
    end

    taskObj=mdladvObj.getTaskObj('com.mathworks.HDL.GenerateIPCore');


    inputParams=mdladvObj.getInputParameters(taskObj.MAC);
    ipName=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPCoreName'));
    ipVersion=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPCoreVersion'));
    projectDir=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPCoreFolder'));
    ipReportOn=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPCoreReport'));
    ipCustomFile=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputAdditionalSourceFiles'));
    axi4ReadbackOn=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableAXI4SlaveReadback'));
    dcBufferSize=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPDataCaptureBufferSize'));
    dcSequenceDepth=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPDataCaptureSequenceDepth'));
    dcIncludeCaptureControl=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIncludeDataCaptureControlLogicEnable'));
    exposeDUTClockEnable=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableDUTClockEnable'));
    exposeDUTCEOut=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableCEOut'));
    IDWidthBox=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputAXISlaveIDWidth'));


    ipName.Value=hDI.hIP.getIPCoreName;
    ipVersion.Value=hDI.hIP.getIPCoreVersion;
    projectDir.Value=hDI.hIP.getIPCoreFolder;
    ipReportOn.Value=hDI.hIP.getIPCoreReportStatus;
    ipCustomFile.Value=hDI.hIP.getIPCoreCustomFile;
    axi4ReadbackOn.Value=hDI.hIP.getAXI4ReadbackEnable;
    dcBufferSize.Value=hDI.hIP.getIPDataCaptureBufferSize;
    dcSequenceDepth.Value=hDI.hIP.getIPDataCaptureSequenceDepth;
    dcIncludeCaptureControl.Value=hDI.hIP.getIncludeDataCaptureControlLogicEnable;

    exposeDUTClockEnable.Value=hDI.hIP.getDUTClockEnable;
    exposeDUTClockEnable.Enable=hDI.hIP.getDUTClockEnableGUI;
    exposeDUTCEOut.Value=hDI.hIP.getDUTCEOut;
    IDWidthBox.Value=hDI.hIP.getIDWidth;
    IDWidthBox.Enable=hDI.hIP.getIDWidthEnboxGUI;

end


