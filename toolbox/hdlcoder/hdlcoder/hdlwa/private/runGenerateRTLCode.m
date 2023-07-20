function[ResultDescription,ResultDetails]=runGenerateRTLCode(system,varargin)


    if(nargin>1)
        fromCallback=varargin{1};
    else
        fromCallback=true;
    end

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    hDriver=hdlcoderargs(system);
    hDI=hDriver.DownstreamIntegrationDriver;%#ok<NASGU>

    if(fromCallback)
        mdladvObj.setCheckErrorSeverity(1);
    end

    ResultDescription={};
    ResultDetails={};




    if any(system==char(10))

        startNode=['[''',regexprep(system,'\n',''' char(10) '''),''']'];
    else
        startNode=['''',system,''''];
    end


    cmdStr=sprintf('hDI.runGenerateRTLCode(%s)',startNode);
    Result=true;

    try
        logTxt=evalc(cmdStr);

        [ResultDescription,ResultDetails]=utilDisplayResult(logTxt,...
        ResultDescription,ResultDetails);

    catch ME
        if(~fromCallback)
            rethrow(ME);
        end


        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,...
        ME.message,ME.cause,ResultDescription,ResultDetails,ME.getReport);

        Result=false;
    end


    if(fromCallback)
        mdladvObj.setCheckResultStatus(Result);
    end


    Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass'});
    Failed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGFailed'),{'Fail'});
    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;


    taskMsg='Generated HDL Code.';

    if Result
        text=ModelAdvisor.Text([Passed.emitHTML,...
        taskMsg,' Click on the file name link(s) to open the generated code in the editor']);
    else
        text=ModelAdvisor.Text([Failed.emitHTML,...
        taskMsg]);
    end
    text=[lb,lb,lb,text.emitHTML,lb];

    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';

end





