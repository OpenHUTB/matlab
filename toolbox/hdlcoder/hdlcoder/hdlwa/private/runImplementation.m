function[ResultDescription,ResultDetails]=runImplementation(system)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(1);

    ResultDescription={};
    ResultDetails={};

    Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass'});
    Failed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGFailed'),{'Fail'});
    Warning=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGWarn'),{'Warn'});


    hModel=bdroot(system);
    hdriver=hdlmodeldriver(hModel);


    hDI=hdriver.DownstreamIntegrationDriver;

    if hDI.SkipPlaceAndRoute
        [ResultDescription,ResultDetails]=publishSkippedMessage(mdladvObj,'Implementation');
        return;
    end



    try
        [Result,logTxt,warnMsg,hardwareResults]=hDI.run({'Implementation','PostPARTiming'});
        if strcmpi(hDI.get('Tool'),'Xilinx Vivado')

            if Result
                fullName=fullfile(hDI.getFullFPGADir(),'timing_post_route.rpt');
                x=message('hdlcoder:hdldisp:PostRouteTimingReportGenerated',hdlgetfilelink(fullName));
                cmdTxt=sprintf('%s\n',x.getString());
                logTxt=[cmdTxt,logTxt];
            end
        end
    catch ME
        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message);
        return;
    end


    if Result
        if isempty(warnMsg)
            statusText=Passed.emitHTML;
            statusStr={'Pass'};
        else
            statusText=Warning.emitHTML;
            statusStr={'Warn'};
        end
    elseif hDI.IgnorePlaceAndRouteErrors
        statusText=Warning.emitHTML;
        statusStr={'Warn'};
    else
        statusText=Failed.emitHTML;
        statusStr={'Fail'};
    end

    text=ModelAdvisor.Text([statusText,'Implementation.']);
    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';



    if~Result&&hDI.IgnorePlaceAndRouteErrors
        ResultDescription{end+1}=ModelAdvisor.Text('Warning: Ignored place and route error(s).',statusStr);
        ResultDetails{end+1}='';


        Result=true;


        if(~strcmp(hDI.CriticalPathSource,'pre-route'))
            ResultDescription{end+1}=ModelAdvisor.Text('Changing ''critical source path'' to ''pre-route'' since implementation failed.',statusStr);
            ResultDetails{end+1}='';
            hDI.CriticalPathSource='pre-route';
            utilAnnotateModel(mdladvObj,hDI);
        end
    end


    if Result&&~isempty(warnMsg)
        ResultDescription{end+1}=ModelAdvisor.Text(warnMsg,statusStr);
        ResultDetails{end+1}='';

        if hDI.isTurnkeyWorkflow||hDI.isXPCWorkflow

            inputParams=mdladvObj.getInputParameters('com.mathworks.HDL.SetTargetFrequency');
            dcmOutputFrequency=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:FPGASystemClockFrequency'));
            messageObj=message('hdlcoder:workflow:TimingWarning',dcmOutputFrequency.Value,DAStudio.message('HDLShared:hdldialog:FPGASystemClockFrequency'));
            messageStr=messageObj.getString;

            ResultDescription{end+1}=ModelAdvisor.Text(messageStr,statusStr);
            ResultDetails{end+1}='';
        end
    end


    [ResultDescription,ResultDetails]=utilDisplayHardwareResults(hardwareResults,false,...
    ResultDescription,ResultDetails);


    [ResultDescription,ResultDetails]=utilDisplayResult(logTxt,...
    ResultDescription,ResultDetails,true);


    mdladvObj.setCheckResultStatus(Result);
