function[ResultDescription,ResultDetails]=runGeneratexPCInterface(system)



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
        [Result,logTxt]=hDI.runSWInterfaceGen;
    catch ME
        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message);
        return;
    end


    if Result
        statusText=Passed.emitHTML;
    else
        statusText=Failed.emitHTML;
    end
    text=ModelAdvisor.Text([statusText,'Generate Simulink Real-Time Interface.']);
    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';


    [ResultDescription,ResultDetails]=utilDisplayResult(logTxt,...
    ResultDescription,ResultDetails);


    mdladvObj.setCheckResultStatus(Result);



