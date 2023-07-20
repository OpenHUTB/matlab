function[ResultDescription,ResultDetails]=runGenerateBitstream(system)



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

        [Result1,logTxt1]=hDI.run('ProgrammingFile');

        [Result2,logTxt2]=hDI.hTurnkey.runPostProgramFilePass;

        Result=Result1&&Result2;
        logTxt=sprintf('%s\n%s',logTxt1,logTxt2);

    catch ME
        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message);
        return;
    end


    if Result
        statusText=Passed.emitHTML;
    else
        statusText=Failed.emitHTML;
    end
    text=ModelAdvisor.Text([statusText,'Generate programming file.']);
    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';

    [ResultDescription,ResultDetails]=utilDisplayResult(logTxt,...
    ResultDescription,ResultDetails,true);


    mdladvObj.setCheckResultStatus(Result);


