function[ResultDescription,ResultDetails]=runCreateProject(system)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(1);

    ResultDescription={};
    ResultDetails={};

    Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass'});
    Failed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGFailed'),{'Fail'});
    Warning=ModelAdvisor.Text('Warning ',{'Warn'});


    hModel=bdroot(system);
    hdriver=hdlmodeldriver(hModel);


    hDI=hdriver.DownstreamIntegrationDriver;


    if hDI.hToolDriver.hTool.UnSupportedVersion
        ResultDescription{end+1}=ModelAdvisor.Text([Warning.emitHTML,...
        hDI.hToolDriver.hTool.VersionWarningMsg]);
        ResultDetails{end+1}='';
    end





    try
        [Result,logTxt]=hDI.run('CreateProject');
        projDir=hDI.getProjectPath;
        saveModelChecksum(system,projDir);

        resultStrT=logTxt;
        if(~isempty(hDI.hToolDriver.hTool.cmd_logRegExp))
            allLines=regexp(resultStrT,'([^\n]*)','match');
            matchingLines=regexp(allLines,hDI.hToolDriver.hTool.cmd_logRegExp,'match');
            resultStrT='';
            for i=1:numel(matchingLines)
                tstring=strjoin(matchingLines{i});
                if(~isempty(tstring))
                    resultStrT=sprintf('%s%s\n',resultStrT,tstring);
                end
            end
        end
        logTxt=resultStrT;
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
    ResultDescription,ResultDetails);


    mdladvObj.setCheckResultStatus(Result);


