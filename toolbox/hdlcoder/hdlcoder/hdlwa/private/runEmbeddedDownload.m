function[ResultDescription,ResultDetails]=runEmbeddedDownload(system)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(1);

    ResultDescription={};
    ResultDetails={};

    Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass'});
    Failed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGFailed'),{'Fail'});


    hModel=bdroot(system);
    hdriver=hdlmodeldriver(hModel);


    hDI=hdriver.DownstreamIntegrationDriver;


    try
        [Result,logTxt,validateCell]=hDI.runEmbeddedDownloadBitstream;
    catch ME
        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message);
        return;
    end


    [ResultDescription,ResultDetails]=utilDisplayValidation(validateCell,ResultDescription,ResultDetails);


    if Result
        statusText=Passed.emitHTML;
    else
        statusText=Failed.emitHTML;
    end

    text=ModelAdvisor.Text([statusText,'Program target FPGA device.']);
    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';



    if hDI.hIP.getProgrammingMethod==hdlcoder.ProgrammingMethod.JTAG&&...
        ismember(hdlcoder.ProgrammingMethod.Download,hDI.hIP.getProgrammingMethodAll)
        Warning=ModelAdvisor.Text('Warning ',{'Warn'});
        text=ModelAdvisor.Text([Warning.emitHTML,DAStudio.message('hdlcoder:workflow:JTAGDeprication')]);
        ResultDescription{end+1}=text;
        ResultDetails{end+1}='';
    end


    [ResultDescription,ResultDetails]=utilDisplayResult(logTxt,...
    ResultDescription,ResultDetails,true);


    mdladvObj.setCheckResultStatus(Result);



