function[ResultDescription,ResultDetails]=runTargetFrequency(system,varargin)

    if(nargin>1)
        fromCallback=varargin{1};
    else
        fromCallback=true;
    end


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    if(fromCallback)
        mdladvObj.setCheckErrorSeverity(1);
    end

    Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass'});


    hModel=bdroot(system);
    hdriver=hdlmodeldriver(hModel);


    hDI=hdriver.DownstreamIntegrationDriver;
    targetFrequency=hDI.getTargetFrequency;

    try



        logText=hDI.setTargetFrequency(targetFrequency);
        hDI.saveTargetFrequencyToModel(hModel,targetFrequency);


        [ResultDescription,ResultDetails]=utilDisplayResult(logText,{},{});

    catch ME

        if(~fromCallback)
            rethrow(ME);
        end

        if(strcmpi(ME.identifier,'hdlcoder:validate:dspbablkconflictfrequency'))
            msg=ME.message;
        else
            msg=[ME.message,...
            sprintf(' Change the value of ''%s'' or set it back to %s MHz',...
            DAStudio.message('HDLShared:hdldialog:FPGASystemClockFrequency'),targetFrequency)];
        end

        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,msg);

        return;
    end


    Result=true;
    statusText=Passed.emitHTML;
    text=ModelAdvisor.Text([statusText,'Set Target Frequency.']);
    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';


    if(fromCallback)
        mdladvObj.setCheckResultStatus(Result);
    end


