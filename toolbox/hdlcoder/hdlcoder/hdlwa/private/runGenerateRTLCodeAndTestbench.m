function[ResultDescription,ResultDetails]=runGenerateRTLCodeAndTestbench(system,varargin)




    if(nargin>1)
        fromCallback=varargin{1};
    else
        fromCallback=true;
    end

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    hModel=bdroot(system);
    hDriver=hdlcoderargs(system);
    hDI=hDriver.DownstreamIntegrationDriver;

    if(fromCallback)
        mdladvObj.setCheckErrorSeverity(1);
    end

    ResultDescription={};
    ResultDetails={};


    errMsg=validateFILSettings(hDI);
    if~isempty(errMsg)
        [ResultDescription,ResultDetails]=utilDisplayResult(errMsg,...
        ResultDescription,ResultDetails);

        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,...
        'FPGA-in-the-Loop validation',[],ResultDescription,ResultDetails);


        if(fromCallback)
            mdladvObj.setCheckResultStatus(false);
        end
        return;
    end


    if~hDI.GenerateRTLCode&&~hDI.GenerateTestbench
        if(fromCallback)
            mdladvObj.setCheckResultStatus(true);
        end
        return;
    end









    if hDI.isFILWorkflow
        setTransientCLI(hModel,'GenerateCodeInfo','on');
        if hDriver.DUTMdlRefHandle>0


            hDriver.updateCmdLineHDLSubsystem(hDriver.OrigStartNodeName);
        end
        gp=pir;
        gp.destroy;
        hDriver.createConfigManager(hDriver.ModelName);
        hDriver.getCPObj;
        [oldDriver,oldMode,oldAutosaveState]=hDriver.inithdlmake(hDriver.ModelName,true);
        hs.oldDriver=oldDriver;
        hs.oldMode=oldMode;
        hs.oldAutosaveState=oldAutosaveState;
        hDriver.OrigModelName=hDriver.ModelName;
        hDriver.OrigStartNodeName=hDriver.getStartNodeName;
        hDriver.nonTopDut=hDriver.prelimNonTopDUTChecks;
        hs=hDriver.nonTopDutDriver(hs);
        hDriver.createModelList;
        try
            hDriver.CalledFromMakehdl=false;
            hDriver.createPir;


            l_checkHDLOptionsForFIL(system,hDriver.AllModels(end).slFrontEnd,hDriver);
            hDriver.cleanup(hs,false,true);
        catch me
            hDriver.cleanup(hs,false,true);
            [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,...
            me.message,[],ResultDescription,ResultDetails);
            return;
        end
    elseif hDI.isUSRPWorkflow
        [success,errmsg,~]=USRPFPGATarget.checkHDLPropsForUSRP(system,hDriver);
        if~success
            [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,...
            errmsg,[],ResultDescription,ResultDetails);
            return;
        end

    elseif hDI.isSDRWorkflow
        setTransientCLI(hModel,'GenerateCodeInfo','on');
        [success,ResultDescription,ResultDetails]=...
        sdr.internal.hdlwa.checkDUTCodeGenOptions(system,@publishFailedMessage,...
        ResultDescription,ResultDetails);
        if~success
            return;
        end

    elseif hDI.isPluginWorkflow
        [success,ResultDescription,ResultDetails]=...
        hDI.pim.checkDUTCodeGenOptions(system,@setTransientCLI,@publishFailedMessage,...
        ResultDescription,ResultDetails);
        if~success
            return;
        end
    end



    cmdStr=sprintf('hDI.runGenerateRTLCodeAndTestbench(%s)',cleanBlockNameForQuotedDisp(system));
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


    taskMsg='Generated';
    prefix=false;
    if hDI.GenerateRTLCode
        taskMsg=[taskMsg,' HDL code'];
        prefix=true;
    end
    if hDI.GenerateTestbench
        if prefix
            taskMsg=[taskMsg,', testbench'];
        else
            taskMsg=[taskMsg,' testbench'];
        end
    end
    taskMsg=[taskMsg,'.'];

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

function errMsg=validateFILSettings(hDI)

    errMsg='';

    if hdlwa.hdlwaDriver.isFILFeatureOn


        if~hDI.isGenericWorkflow||~hDI.isToolEmpty
            errMsg=sprintf(['The following settings in Task 1.1 '...
            ,'are required for FPGA-in-the-Loop:\n'...
            ,'Target workflow: Generic ASIC/FPGA\n'...
            ,'Synthesis tool: No Synthesis Tool Specified\n']);
            return;
        end


        if~hDI.GenerateRTLCode
            errMsg=sprintf(['HDL code generation is required '...
            ,'for FPGA-in-the-Loop.\n'...
            ,'Make sure the input parameter "Generate RTL code" is selected.\n']);
        end
    end
end


function l_checkHDLOptionsForFIL(system,pirFrontEnd,hdlcoderObj)


    taskMsg=message('HDLShared:hdldialog:HDLWASetHDLOptions');


    isscalar=(hdlgetparameter('ScalarizePorts')~=0)||~hdlgetparameter('isvhdl');

    if~isscalar
        ninput=length(pirFrontEnd.hPir.getTopNetwork.SLInputPorts);
        noutput=length(pirFrontEnd.hPir.getTopNetwork.SLOutputPorts);
        hasVectorPort=false;
        for ii=1:ninput
            if isDutInportAtIdxVector(hdlcoderObj.PirInstance,ii)
                hasVectorPort=true;
                break;
            end
        end

        if~hasVectorPort
            for ii=1:noutput
                if isDutOutportAtIdxVector(hdlcoderObj.PirInstance,ii)
                    hasVectorPort=true;
                    break;
                end
            end
        end

        if hasVectorPort
            widgetMsg=message('HDLShared:hdldialog:hdlglblsettingsScalarizePorts');
            error(message('HDLShared:hdldialog:HDLWAFILScalarizePorts',...
            widgetMsg.getString,taskMsg.getString));
        end
    end


    rates=pirFrontEnd.hPir.getModelSampleTimes;
    clockInputs=hdlget_param(bdroot(system),'ClockInputs');
    if length(unique(rates))>1&&~strcmpi(clockInputs,'Single')
        widgetMsg=message('HDLShared:hdldialog:clockInputs');
        widgetValueMsg=message('HDLShared:hdldialog:clockInputsSingle');
        error(message('HDLShared:hdldialog:HDLWAFILClockMultiple',...
        widgetMsg.getString,taskMsg.getString,widgetValueMsg.getString));
    end

end

function isvector=isDutInportAtIdxVector(pir,idx)
    hn=getTopNetwork(pir);
    t=hn.PirInputSignals(idx);
    tInfo=pirgetdatatypeinfo(t.Type);
    isvector=tInfo.isvector;
end

function isvector=isDutOutportAtIdxVector(pir,idx)
    hn=getTopNetwork(pir);
    t=hn.PirOutputSignals(idx);
    tInfo=pirgetdatatypeinfo(t.Type);
    isvector=tInfo.isvector;
end



