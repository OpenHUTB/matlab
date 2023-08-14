function[ResultDescription,ResultDetails]=runEmbeddedModelGen(system)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(1);

    ResultDescription={};
    ResultDetails={};

    Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass'});
    Failed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGFailed'),{'Fail'});



    hModel=bdroot(system);
    hdriver=hdlmodeldriver(hModel);


    hDI=hdriver.DownstreamIntegrationDriver;


    taskTitle=getString(message('hdlcommon:workflow:HDLWAEmbeddedModelGen'));


    try
        [Result,logTxt,validateCell]=hDI.runSWInterfaceGen;
    catch ME
        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message);
        return;
    end













    validateCell=downstream.tool.filterEmptyCell(validateCell);
    [ResultDescription,ResultDetails,hasError]=utilDisplayValidation(validateCell,ResultDescription,ResultDetails);


    Result=Result&&~hasError;
    if Result
        text=ModelAdvisor.Text([Passed.emitHTML,taskTitle,'.']);
    else
        text=ModelAdvisor.Text([Failed.emitHTML,taskTitle,'.']);
    end
    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';


    [ResultDescription,ResultDetails]=utilDisplayResult(logTxt,...
    ResultDescription,ResultDetails);


    mdladvObj.setCheckResultStatus(Result);



