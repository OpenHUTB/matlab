function[ResultDescription,ResultDetails]=runEmbeddedSystemBuild(system)



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
        [Result,logTxt,validateCell]=hDI.runEmbeddedSystemBuild;
    catch ME
        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message);
        return;
    end


    [ResultDescription,ResultDetails]=utilDisplayValidation(validateCell,ResultDescription,ResultDetails);


    if Result
        statusText=Passed.emitHTML;
        statusStr={'Pass'};
    else
        statusText=Failed.emitHTML;
        statusStr={'Fail'};
    end

    text=ModelAdvisor.Text([statusText,'Build Embedded System.']);

    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';


    ResultDescription{end+1}=ModelAdvisor.Text('Synthesis Tool Log:',statusStr);
    ResultDetails{end+1}='';


    if Result

        tool=hDI.get('Tool');
        workflow=hDI.get('Workflow');
        dutName=hdlget_param(hModel,'HDLSubsystem');
        file='hdlworkflow_ProgramTargetDevice.m';
        hdl_prj=hDI.getProjectFolder;
        toolVer=hDI.hIP.getRDToolVersion;
        mismatch=hDI.hIP.getIgnoreRDToolVersionMismatch;
        method=hDI.hIP.getProgrammingMethod;


        cmd=sprintf('<a href="matlab:hWC=hdlcoder.WorkflowConfig(''SynthesisTool'',''%s'',''TargetWorkflow'',''%s'');',tool,workflow);
        cmd=sprintf('%shWC.ProjectFolder=''%s'';',cmd,hdl_prj);
        cmd=sprintf('%shWC.ReferenceDesignToolVersion=''%s'';',cmd,toolVer);
        if mismatch
            cmd=sprintf('%shWC.IgnoreToolVersionMismatch=true;',cmd);
        else
            cmd=sprintf('%shWC.IgnoreToolVersionMismatch=false;',cmd);
        end
        cmd=sprintf('%shWC.ProgrammingMethod=hdlcoder.ProgrammingMethod.%s;',cmd,method);
        cmd=sprintf('%shWC.export(''Filename'',''%s'',''Overwrite'',true,''Warn'',false,''DUT'',''%s'',''Headers'',false,''Comments'',true,''ProgramTargetDevice'',true);',cmd,file,dutName);
        cmd=sprintf('%s">%s</a>',cmd,file);


        logTxt=[logTxt,message('hdlcommon:workflow:GenerateProgrammingScript',cmd).getString];
    end

    [ResultDescription,ResultDetails]=utilDisplayResult(logTxt,...
    ResultDescription,ResultDetails,true);


    mdladvObj.setCheckResultStatus(Result);



