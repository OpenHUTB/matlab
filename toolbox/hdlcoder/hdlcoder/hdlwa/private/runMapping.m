function[ResultDescription,ResultDetails]=runMapping(system)



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
        if hDI.SkipPreRouteTimingAnalysis
            hDI.skipWorkflow('PostMapTiming');
        end

        [Result,logTxt,~,hardwareResults]=hDI.run({'Map','PostMapTiming'});

        if hDI.SkipPreRouteTimingAnalysis



            hDI.unskipWorkflow('PostMapTiming');
        end
    catch ME
        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message);
        return;
    end


    if Result
        statusText=Passed.emitHTML;
    else
        statusText=Failed.emitHTML;
    end
    text=ModelAdvisor.Text([statusText,'Mapping.']);
    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';


    [ResultDescription,ResultDetails]=utilDisplayHardwareResults(hardwareResults,hDI.SkipPreRouteTimingAnalysis,...
    ResultDescription,ResultDetails);


    [ResultDescription,ResultDetails]=utilDisplayResult(logTxt,...
    ResultDescription,ResultDetails,true);


    mdladvObj.setCheckResultStatus(Result);