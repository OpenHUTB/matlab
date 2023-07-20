function paramGenerateIPCore(taskobj)



    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    ipNameOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPCoreName'));
    ipVerOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPCoreVersion'));
    ipFolderOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPCoreFolder'));
    ipRepositoryOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPRepository'));
    ipCustomFileOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputAdditionalSourceFiles'));
    ipReportOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPCoreReport'));

    IDWidthBox=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputAXISlaveIDWidth'));
    axi4ReadbackEnableOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableAXI4SlaveReadback'));
    exposeDUTClockEnable=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableDUTClockEnable'));
    exposeDUTCEOut=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAEnableCEOut'));
    axi4SlavePortToPipelineRegisterRatioOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAAXI4SlavePortToPipelineRegisterRatio'));


    ipBufferSize=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPDataCaptureBufferSize'));
    ipSequenceDepth=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPDataCaptureSequenceDepth'));
    enableCaptureControl=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIncludeDataCaptureControlLogicEnable'));

    try
        updateParameterName='';
        if~strcmp(ipNameOption.Value,hDI.hIP.getIPCoreName)
            updateParameterName='name';
            hDI.hIP.setIPCoreName(ipNameOption.Value);

        elseif~strcmp(ipVerOption.Value,hDI.hIP.getIPCoreVersion)
            updateParameterName='ver';
            hDI.hIP.setIPCoreVersion(ipVerOption.Value);

        elseif~strcmp(ipRepositoryOption.Value,hDI.hIP.getIPRepository)
            updateParameterName='iprep';
            hDI.hIP.setIPRepository(ipRepositoryOption.Value);

        elseif~strcmp(ipCustomFileOption.Value,hDI.hIP.getIPCoreCustomFile)
            updateParameterName='file';
            hDI.hIP.setIPCoreCustomFile(ipCustomFileOption.Value);

        elseif~isequal(ipReportOption.Value,hDI.hIP.getIPCoreReportStatus)
            hDI.hIP.setIPCoreReportStatus(ipReportOption.Value);

        elseif~isequal(axi4ReadbackEnableOption.Value,hDI.hIP.getAXI4ReadbackEnable)
            hDI.hIP.setAXI4ReadbackEnable(axi4ReadbackEnableOption.Value);

        elseif~isequal(exposeDUTClockEnable.Value,hDI.hIP.getDUTClockEnable)
            hDI.hIP.setDUTClockEnable(exposeDUTClockEnable.Value);

        elseif~isequal(exposeDUTCEOut.Value,hDI.hIP.getDUTCEOut)
            hDI.hIP.setDUTCEOut(exposeDUTCEOut.Value);

        elseif~isequal(axi4SlavePortToPipelineRegisterRatioOption.Value,hDI.hIP.getInsertAXI4PipelineRegisterEnable)
            hDI.hIP.setInsertAXI4PipelineRegisterEnable(axi4SlavePortToPipelineRegisterRatioOption.Value);

        elseif~isequal(ipBufferSize.Value,hDI.hIP.getIPDataCaptureBufferSize)
            hDI.hIP.setIPDataCaptureBufferSize(ipBufferSize.Value);

        elseif~isequal(ipSequenceDepth.Value,hDI.hIP.getIPDataCaptureSequenceDepth)
            hDI.hIP.setIPDataCaptureSequenceDepth(ipSequenceDepth.Value);

        elseif~isequal(enableCaptureControl.Value,hDI.hIP.getIncludeDataCaptureControlLogicEnable)
            hDI.hIP.setIncludeDataCaptureControlLogicEnable(enableCaptureControl.Value);

        elseif~isequal(IDWidthBox.Value,hDI.hIP.getIDWidth)
            hDI.hIP.setIDWidth(IDWidthBox.Value);
        end
    catch ME
        hf=errordlg(ME.message,'Error','modal');

        set(hf,'tag','HDL Workflow Advisor error dialog');
        setappdata(hf,'MException',ME);


        uiwait(hf);


        hMAExplorer=mdladvObj.MAExplorer;
        if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
            currentDialog=hMAExplorer.getDialog;
            if strcmpi(updateParameterName,'name')
                currentDialog.setWidgetValue('InputParameters_1',hDI.hIP.getIPCoreName);
            elseif strcmpi(updateParameterName,'ver')
                currentDialog.setWidgetValue('InputParameters_2',hDI.hIP.getIPCoreVersion);
            elseif strcmpi(updateParameterName,'iprep')
                currentDialog.setWidgetValue('InputParameters_4',hDI.hIP.getIPRepository);
            elseif strcmpi(updateParameterName,'file')
                currentDialog.setWidgetValue('InputParameters_6',hDI.hIP.getIPCoreCustomFile);
            end
        end
    end


    utilAdjustGenerateIPCore(mdladvObj,hDI);

end


