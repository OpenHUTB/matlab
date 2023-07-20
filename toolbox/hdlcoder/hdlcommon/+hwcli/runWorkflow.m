function runWorkflow(dut,hWC,varargin)










    if(nargin<1)
        error(message('hdlcoder:engine:invalidarglist','hdlcoder.runWorkflow'));
    end


    if(nargin<2)
        warning(message('hdlcoder:workflow:UsingDefaultConfig','Xilinx Vivado','Generic ASIC/FPGA'));
        hWC=hdlcoder.WorkflowConfig();
    elseif(~isa(hWC,'hwcli.base.WorkflowBase'))
        error(message('hdlcoder:workflow:InvalidWorkflowConfig'));
    end


    dut=convertStringsToChars(dut);
    if nargin>2
        [varargin{:}]=convertStringsToChars(varargin{:});
    end


    p=inputParser;







    p.addParameter('Verbosity','off');



    p.addParameter('TestChecksumFcn',[]);
    p.addParameter('DLProcessor',[]);
    p.addParameter('DLProcessorConfig',[]);
    p.addParameter('DLProcessorName','');


    p.parse(varargin{:});
    args=p.Results;
    if strcmpi(args.Verbosity,'on')
        Verbosity=1;
    elseif strcmpi(args.Verbosity,'off')
        Verbosity=0;
    else
        Verbosity=args.Verbosity;
    end
    TestChecksumFcn=args.TestChecksumFcn;


    hDLProcessor=args.DLProcessor;
    hPC=args.DLProcessorConfig;
    dlProcessorName=args.DLProcessorName;



    if(hdlwa.isWorkflowAdvisorOpen)
        error(message('hdlcoder:workflow:WorkflowAdvisorOpen'));
    end


    hModel=bdroot(dut);



    modelWorkflow=hdlget_param(hModel,'Workflow');
    if isempty(modelWorkflow)
        hdlset_param(hModel,'Workflow',hWC.TargetWorkflow);
    elseif~strcmpi(modelWorkflow,hWC.TargetWorkflow)
        error(message('hdlcoder:workflow:ModelWorkflowMismatchConfig',modelWorkflow,hWC.TargetWorkflow));
    end

    modelTool=hdlget_param(hModel,'SynthesisTool');
    if strcmpi(modelTool,'Microsemi Libero SoC')
        modelTool='Microchip Libero SoC';
    end

    if isempty(modelTool)
        hdlset_param(hModel,'SynthesisTool',hWC.SynthesisTool);
    elseif~strcmpi(modelTool,hWC.SynthesisTool)
        error(message('hdlcoder:workflow:ModelToolMismatchConfig',modelTool,hWC.SynthesisTool));
    end



    checkoutLicense=false;
    slhdlcoder.checkLicense(checkoutLicense);


    hSubSystem=hdlget_param(hModel,'HDLSubsystem');
    if(~strcmp(dut,hSubSystem))
        warning(message('hdlcoder:workflow:DutMismatch',dut,hSubSystem));
    end


    hdlcodegenmode('slcoder');


    hdlDispWithTimeStamp(message('hdlcommon:workflow:HWCLIWorkflowStart'),Verbosity);
    hdlDispWithTimeStamp(message('hdlcoder:workflow:WorkflowLoadingFromModel'),Verbosity);
    try
        hDI=downstream.integration('Model',dut,'cliDisplay',true,...
        'cmdDisplay',true,'ProjectFolder',hWC.ProjectFolder,...
        'Verbosity',Verbosity);
    catch ME



        hdlcoderObj=downstream.CodeGenInfo.getCodeGenHandle(hModel);
        autoCleanUp=onCleanup(@()safeCloseConnection(hdlcoderObj));
        throw(ME);
    end




    hdlcoderObj=hDI.hCodeGen.hCHandle;
    autoCleanUp=onCleanup(@()safeCloseConnection(hdlcoderObj));


    if Verbosity>0
        hDI.logDisplay=true;
    end


    hWC.configure(hDI);



    if~hDI.hAvailableToolList.isToolVersionSupported(hWC.SynthesisTool)
        if~hDI.getAllowUnsupportedToolVersion()
            error(message('HDLShared:hdldialog:HDLWAUnsupportedToolVersionAllowCLI',hWC.SynthesisTool,hDI.getToolVersion));
        else
            warning(message('HDLShared:hdldialog:HDLWAUnsupportedToolVersionAttempt',hWC.SynthesisTool,hDI.getToolVersion));
        end
    end










    isTurnkey=strcmp(hWC.TargetWorkflow,'FPGA Turnkey');
    isGeneric=strcmp(hWC.TargetWorkflow,'Generic ASIC/FPGA');
    isRealtime=strcmp(hWC.TargetWorkflow,'Simulink Real-Time FPGA I/O');
    isIPCore=strcmp(hWC.TargetWorkflow,'IP Core Generation');
    isDLProc=strcmp(hWC.TargetWorkflow,'Deep Learning Processor');
    isISE=strcmp(hWC.SynthesisTool,'Xilinx ISE');



    if isIPCore
        if~hWC.RunTaskGenerateRTLCodeAndIPCore&&hWC.RunTaskGenerateSoftwareInterface
            error(message('hdlcoder:workflow:MustGenerateRTLCodeAndIPCore'));
        end
    end

    validateCell=hDI.validateProjectFolder;

    downstream.tool.displayValidateCell(validateCell);


    if hDI.isIPWorkflow
        hDI.hIP.validateIPCoreWorkflow;
    end


    hDI.savetargetDeviceSettingToModel(hModel,hDI.get('Workflow'),hDI.get('Board'),...
    hDI.get('Tool'),hDI.get('Family'),hDI.get('Device'),hDI.get('Package'),hDI.get('Speed'));


    if hDI.isIPCoreGen
        hDI.hIP.validateTargetReferenceDesign;
    end


    if isIPCore
        if(hWC.RunTaskGenerateRTLCodeAndIPCore||hWC.RunTaskCreateProject||hWC.RunTaskGenerateSoftwareInterface)
            hDI.validateTargetInterface;
        end
    elseif isTurnkey
        if(hWC.RunTaskGenerateRTLCode||hWC.RunTaskCreateProject)
            hDI.validateTargetInterface;
        end
    elseif isRealtime
        if isISE&&(hWC.RunTaskGenerateRTLCode||hWC.RunTaskCreateProject||hWC.RunTaskGenerateSimulinkRealTimeInterface)
            hDI.validateTargetInterface;
        elseif hWC.RunTaskGenerateRTLCodeAndIPCore||hWC.RunTaskCreateProject||hWC.RunTaskGenerateSimulinkRealTimeInterface
            hDI.validateTargetInterface;
        end
    elseif isDLProc
        if(hWC.RunTaskGenerateRTLCodeAndIPCore||hWC.RunTaskCreateProject)
            hDI.validateTargetInterface;
        end
    end


    hWorkflowList=hdlworkflow.getWorkflowList;
    isDynamicWorkflowLoaded=hWorkflowList.isInWorkflowList(hDI.get('Workflow'));
    if isDynamicWorkflowLoaded
        hWorkflow=hWorkflowList.getWorkflow(hDI.get('Workflow'));





        hWorkflow.hdlcli_runWorkFlow(dut,hWC,hDI,Verbosity);
        return;
    end

    for i=1:length(hWC.Tasks)
        task=hWC.Tasks{i};
        if(hWC.(task)==true)
            switch task

            case 'RunTaskGenerateRTLCodeAndIPCore'

                hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWAGenerateIPCore',Verbosity);
                hDI.runIPCoreCodeGen();

            case 'RunTaskGenerateRTLCodeAndTestbench'

                hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWAGenerateRTLCodeAndTestbench',Verbosity);
                hDI.runGenerateRTLCodeAndTestbench(dut);

            case 'RunTaskGenerateRTLCode'

                hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWAGenerateRTLCode',Verbosity);
                hDI.runGenerateRTLCode(dut);

            case 'RunTaskVerifyWithHDLCosimulation'
                if hWC.GenerateTestbench
                    hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWAVerifyCosim',Verbosity);
                    hDI.runVerifyCosim(dut);
                end
            case 'RunTaskCreateProject'

                if(isTurnkey||(isRealtime&&isISE))
                    hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWACreateProject',Verbosity);
                    hDI.run('CreateProject');

                elseif isGeneric
                    hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWACreateProject',Verbosity);
                    hDI.run('CreateProject');



                    if~isempty(TestChecksumFcn)
                        if(feval(TestChecksumFcn))
                            hWC.clearAllTasks();
                        end
                    end

                else
                    hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWACreateProject',Verbosity);
                    hDI.runCreateEmbeddedProject();



                    if~isempty(TestChecksumFcn)
                        if(feval(TestChecksumFcn))
                            swinterfacegenStatus=logical.empty;
                            slrtinterfaceStatus=logical.empty;
                            if any(ismember(hWC.Tasks,'RunTaskGenerateSoftwareInterface'))
                                swinterfacegenStatus=hWC.RunTaskGenerateSoftwareInterface;
                            end

                            if any(ismember(hWC.Tasks,'RunTaskGenerateSimulinkRealTimeInterface'))
                                slrtinterfaceStatus=hWC.RunTaskGenerateSimulinkRealTimeInterface;
                            end

                            hWC.clearAllTasks();
                            if~isempty(swinterfacegenStatus)
                                hWC.RunTaskGenerateSoftwareInterface=swinterfacegenStatus;
                            end

                            if~isempty(slrtinterfaceStatus)
                                hWC.RunTaskGenerateSimulinkRealTimeInterface=slrtinterfaceStatus;
                            end
                        end
                    end

                end

            case 'RunTaskGenerateSoftwareInterface'

                hdlwa.dispTaskHeader('hdlcommon:workflow:HDLWAEmbeddedModelGen',Verbosity);
                hDI.runSWInterfaceGen();

            case 'RunTaskPerformLogicSynthesis'

                hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWAPerformLogicSynthesis',Verbosity);
                hDI.run('Synthesis');

            case 'RunTaskPerformMapping'

                hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWAPerformMapping',Verbosity);
                if hWC.SkipPreRouteTimingAnalysis
                    hDI.skipWorkflow('PostMapTiming');
                end

                [~,~,~,hardwareResults]=hDI.run({'Map','PostMapTiming'});


                displayHardwareResults(hardwareResults,hDI.SkipPreRouteTimingAnalysis);

                if hWC.SkipPreRouteTimingAnalysis
                    hDI.unskipWorkflow('PostMapTiming');
                end

            case 'RunTaskPerformPlaceAndRoute'

                hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWAPerformPlaceAndRoute',Verbosity);

                [~,~,~,hardwareResults]=hDI.run({'PAR','PostPARTiming'});


                displayHardwareResults(hardwareResults,false);

            case 'RunTaskRunSynthesis'

                hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWAVivadoSynthesis',Verbosity);
                if hWC.SkipPreRouteTimingAnalysis
                    hDI.skipWorkflow('PostMapTiming');
                end

                [~,~,~,hardwareResults]=hDI.run({'Synthesis','PostMapTiming'});


                displayHardwareResults(hardwareResults,hDI.SkipPreRouteTimingAnalysis);

                if hWC.SkipPreRouteTimingAnalysis
                    hDI.unskipWorkflow('PostMapTiming');
                end

            case 'RunTaskRunImplementation'

                hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWAVivadoImplementation',Verbosity);

                [~,~,~,hardwareResults]=hDI.run({'Implementation','PostPARTiming'});


                displayHardwareResults(hardwareResults,false);

            case 'RunTaskAnnotateModelWithSynthesisResult'

                hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWAAnnotateModelWithSynthesisResult',Verbosity);
                hDI.runAnnotateModel;
                hdlDispWithTimeStamp(message('hdlcommon:workflow:HWCLIResetHighlighting','<a href="matlab:hdlannotatepath(''reset'')">here</a>'),Verbosity);

            case 'RunTaskBuildFPGABitstream'

                hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWAEmbeddedSystemBuild',Verbosity);
                hDI.runEmbeddedSystemBuild();



                if isDLProc&&~hWC.RunExternalBuild
                    bitFileDestDir=hWC.ProjectFolder;
                    bitFileName=dlProcessorName;
                    vendorName=hDI.hIP.getBoardObject.FPGAVendor;
                    bitstreamPath=hDI.getBitstreamPath();

                    dnnfpga.build.copyBitstream(vendorName,bitstreamPath,bitFileDestDir,bitFileName);
                end

            case 'RunTaskGenerateProgrammingFile'

                hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWAGenerateProgrammingFile',Verbosity);
                hDI.run('ProgrammingFile');
                hDI.hTurnkey.runPostProgramFilePass;

            case 'RunTaskProgramTargetDevice'

                if(isTurnkey)
                    hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWAProgramTargetDevice',Verbosity);
                    hDI.hTurnkey.runDownloadCmd;
                else
                    hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWAProgramTargetDevice',Verbosity);
                    hDI.runEmbeddedDownloadBitstream();
                end

            case 'RunTaskGenerateSimulinkRealTimeInterface'

                hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWATitleGenerateXPCTargetInterface',Verbosity);
                hDI.runSWInterfaceGen;

            case 'RunTaskBuildFPGAInTheLoop'
                hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWATitleBuildFIL',Verbosity);
                if~hWC.RunExternalBuild
                    hDI.hFilWizardDlg.buildOptions={'FirstFPGAProcess','BitGeneration',...
                    'QuestionDialog','off',...
                    'ContinueOnWarning','on',...
                    'BuildOutput','FPGAFilesOnly'};
                else
                    hDI.hFilWizardDlg.buildOptions={'QuestionDialog','off',...
                    'ContinueOnWarning','on',...
                    'BuildOutput','FPGAFilesOnly'};
                end
                hDI.runFILBuild;

            case 'RunTaskEmitDLBitstreamMATFile'

                hdlwa.dispTaskHeader('HDLShared:hdldialog:HDLWAEmitDLMATFile',Verbosity);



                matFileDestDir=hWC.ProjectFolder;
                matFileName=dlProcessorName;

                if hPC.isGenericDLProcessor





                    dnnfpga.build.emitBitstreamMATFile(matFileName,matFileDestDir,...
                    'Processor',hDLProcessor,'ProcessorConfig',hPC,...
                    'Frequency',hPC.TargetFrequency);

                else


                    freq=hDI.getTargetFrequency();
                    boardPlugin=hDI.hIP.getBoardObject();
                    rdPlugin=hDI.hIP.getReferenceDesignPlugin();



                    dnnfpga.build.emitBitstreamMATFile(matFileName,matFileDestDir,...
                    'Processor',hDLProcessor,'ProcessorConfig',hPC,...
                    'Frequency',freq,...
                    'BoardPlugin',boardPlugin,'ReferenceDesignPlugin',rdPlugin);
                end

            otherwise

                error('Bad task');

            end
        end
    end

    hdlDispWithTimeStamp(message('hdlcommon:workflow:HWCLIWorkflowComplete'),Verbosity);


    hdlcodegenmode('reset');

end


function displayHardwareResults(hardwareResults,skipTiming)



    if~isempty(hardwareResults)

        resourceVariables=hardwareResults.ResourceVariables;
        usage=hardwareResults.ResourceData;
        availableResources=hardwareResults.AvailableResources;
        utilization=hardwareResults.Utilization;

        resourceFile=hardwareResults.ResourceFile;


        disp([newline,message('hdlcoder:hdldisp:ParsedResourceReport',hdlgetfilelink(resourceFile)).getString(),newline]);

        disp(table(resourceVariables,usage,availableResources,utilization,...
        'VariableNames',{'Resource','Usage','Available','Utilization (%)'}));

        if~skipTiming

            timingVariables=hardwareResults.TimingVariables;
            timingData=hardwareResults.TimingData;

            timingFile=hardwareResults.TimingFile;


            disp([newline,message('hdlcoder:hdldisp:ParsedTimingReport',hdlgetfilelink(timingFile)).getString(),newline]);

            disp(table(timingVariables,timingData,'VariableNames',{'Timing','Value'}));
        end
    end
end

function safeCloseConnection(hdlcoderObj)


    try %#ok<TRYNC>

        if~isempty(hdlcoderObj)&&~isempty(hdlcoderObj.ModelConnection)
            hdlcoderObj.closeConnection();
        end


        codegenStatus=hdlcoderObj.CodeGenSuccessful;
        if~codegenStatus&&~isempty(hdlcoderObj.hs)
            hdlcoderObj.cleanup(hdlcoderObj.hs,codegenStatus);
        end












    end
end





