function[ResultDescription,ResultDetails]=generateIPCore(system,varargin)



    if(nargin>1)
        fromCallback=varargin{1};
    else
        fromCallback=true;
    end

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    if(fromCallback)
        mdladvObj.setCheckErrorSeverity(1);
    end

    ResultDescription={};
    ResultDetails={};

    Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass'});






    hModel=bdroot(system);
    hDriver=hdlcoderargs(system);


    hDI=hDriver.DownstreamIntegrationDriver;%#ok<NASGU>


    hdlset_param(hModel,'HDLSubsystem',system);
    setupParams(hModel);


    cmdStr='hDI.runIPCoreCodeGen';

    try

        [logTxt,validateCell]=evalc(cmdStr);


        [ResultDescription,ResultDetails,hasError]=utilDisplayValidation(validateCell,...
        ResultDescription,ResultDetails);%#ok<ASGLU>


        [ResultDescription,ResultDetails]=utilDisplayResult(logTxt,...
        ResultDescription,ResultDetails);

    catch ME
        if(~fromCallback)
            rethrow(ME);
        end


        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,...
        ME.message,ME.cause,ResultDescription,ResultDetails,ME.getReport);

        return;
    end


    if(fromCallback)
        mdladvObj.setCheckResultStatus(true);
    end


    statusText=Passed.emitHTML;
    text=ModelAdvisor.Text([statusText,'Generated HDL Code and IP Core. Click on the file name link(s) to open the generated code in the editor.']);
    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';

end

function setupParams(mdlName)



    try
        hcc=gethdlcc(mdlName);



        hcc.createCLI;

    catch me
        if hdlgetparameter('debug')>1
            rethrow(me);
        end
    end





end


