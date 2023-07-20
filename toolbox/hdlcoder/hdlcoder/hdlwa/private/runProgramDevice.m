function[ResultDescription,ResultDetails]=runProgramDevice(system)



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
        [Result,logTxt]=hDI.hTurnkey.runDownloadCmd;
    catch ME
        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message);
        return;
    end


    if Result
        statusText=Passed.emitHTML;
        statusStr={'Pass'};
    else
        statusText=Failed.emitHTML;
        statusStr={'Fail'};
    end
    text=ModelAdvisor.Text([statusText,'Program target FPGA device.']);
    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';


    ResultDescription{end+1}=ModelAdvisor.Text('Synthesis Tool Log:',statusStr);
    ResultDetails{end+1}='';

    [ResultDescription,ResultDetails]=utilDisplayResult(logTxt,...
    ResultDescription,ResultDetails,true);


    mdladvObj.setCheckResultStatus(Result);


