function[ResultDescription,ResultDetails]=runCreateEmbeddedProject(system)



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
        [Result,logTxt]=hDI.runCreateEmbeddedProject;


        msg=hDI.hIP.checkUseIPCache(hDI.hIP.getUseIPCache);
        if~isempty(msg)
            Warning=ModelAdvisor.Text('Warning ',{'Warn'});
            ResultDescription{end+1}=ModelAdvisor.Text([Warning.emitHTML,msg.getString]);
            ResultDetails{end+1}='';
        end



        utilAdjustEmbeddedSystemBuild(mdladvObj,hDI);

    catch ME
        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message);
        return;
    end


    if Result
        statusText=Passed.emitHTML;
    else
        statusText=Failed.emitHTML;
    end
    text=ModelAdvisor.Text([statusText,'Create Project.']);
    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';

    [ResultDescription,ResultDetails]=utilDisplayResult(logTxt,...
    ResultDescription,ResultDetails,true);


    mdladvObj.setCheckResultStatus(Result);



