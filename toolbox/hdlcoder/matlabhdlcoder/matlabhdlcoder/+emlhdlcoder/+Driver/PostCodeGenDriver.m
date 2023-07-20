classdef PostCodeGenDriver<handle




    properties(Access=private)
        hPir;
        hHDLDriver;
        hDI;
        hHDLCfg;
        hTopFunctionName;
        hTopScriptName;
        hScriptParser;
        hEMLHDLConfig;
    end

    methods

        function this=PostCodeGenDriver(topFcnName,topScripName)
            [matlabMode,matlabConfig]=hdlismatlabmode;
            assert(matlabMode);

            this.hEMLHDLConfig=matlabConfig;
            this.hHDLDriver=hdlcurrentdriver;
            this.hDI=[];

            this.hPir=this.hHDLDriver.PirInstance;

            this.hTopFunctionName=topFcnName;
            this.hTopScriptName=topScripName;
        end


        function hdlDrv=getHDLDriver(this)
            hdlDrv=this.hHDLDriver;
        end


        function generateMFBlock(this,cgInfo)

            hdlDrv=this.hHDLDriver;
            hdlCfg=this.hEMLHDLConfig;

            mfbDriver=emlhdlcoder.Driver.MatlabFunctionBlockDriver(hdlCfg,hdlDrv);
            mfbDriver.doIt(cgInfo);

        end


        function generateXSGBlock(this,cgInfo)

            hdlDrv=this.hHDLDriver;
            hdlCfg=this.hEMLHDLConfig;
            if targetcodegen.xilinxsysgendriver.isXsgVivado
                simDriver=emlhdlcoder.Driver.XSGVivadoBBoxDriver(hdlCfg,hdlDrv);
            else
                simDriver=emlhdlcoder.Driver.XSGIseBBoxDriver(hdlCfg,hdlDrv);
            end
            simDriver.doIt(cgInfo);

        end


        function doIt(this)
            hdlDrv=this.hHDLDriver;
            hdlDrv.CodeGenSuccessful=true;
            hdlDrv.TimeStamp=datestr(now,31);
            hdlCfg=this.hEMLHDLConfig;

            runCodeGen=hdlCfg.GenerateHDLCode;
            if~runCodeGen


                return;
            end

            this.hPir.updateBaseRate;

            runTB=hdlCfg.GenerateHDLTestBench;
            runCosimTB=hdlCfg.SimulateCosimTestBench;
            runFILTB=hdlCfg.SimulateFILTestBench;
            genCustomScripts=hdlCfg.GenerateEDAScripts;
            genMFBlock=hdlCfg.GenerateMLFcnBlock;
            genXSGBlock=hdlCfg.GenerateXSGBlock;
            genCosimTb=hdlCfg.GenerateCosimTestBench;
            genFILTb=hdlCfg.GenerateFILTestBench;

            runSim=hdlCfg.SimulateGeneratedCode;
            simTool=hdlCfg.SimulationTool;

            runSyn=hdlCfg.SynthesizeGeneratedCode;
            runPAR=hdlCfg.PlaceAndRoute;

            topFcnName=this.hTopFunctionName;
            topScriptName=this.hTopScriptName;


            gp=pir;
            if gp.isPIRTCCtxBased&&strcmp(this.hPir.ModelName,gp.getTopPirCtx.ModelName)

                tcNws=gp.getTopPirCtx.findTimingControllerNetworks;
                if~isempty(tcNws)
                    this.hPir.addEntityNameAndPath(tcNws(1).Name,tcNws(1).FullPath);
                end
            end
            hdlDrv.setVhdlPackageName(this.hPir);
            hdlDrv.updateEntityInfo(this.hPir);
            topName=[hdlDrv.getParameter('module_prefix'),topFcnName];
            hdlDrv.cgInfo.topName=topName;
            hdlDrv.cgInfo.hdlFiles=hdlDrv.getEntityFileNames(this.hPir);

            isCodingForSystemC=(hdlCfg.TargetLanguage=="SystemC");
            if isCodingForSystemC

                codegenDir=hdlDrv.hdlGetCodegendir;
                className=codegenDir+"/"+topName+"Class"+".hpp";
                c_beautifier(convertStringsToChars(className));
                rtwtypes=codegenDir+"/"+"rtwtypes"+".hpp";
                c_beautifier(convertStringsToChars(rtwtypes));


                classFileName=convertStringsToChars(topName+"Class"+".hpp");
                rtwtypesFileName='rtwtypes.hpp';
                hdlDrv.cgInfo.hdlFiles={classFileName,rtwtypesFileName};
                if hdlCfg.SynthesisTool=="Xilinx Vitis HLS"
                    wrapperFileName=convertStringsToChars(topName+"_wrapper"+".cpp");
                    hdlDrv.cgInfo.hdlFiles{end+1}=wrapperFileName;
                    c_beautifier(fullfile(codegenDir,wrapperFileName));
                elseif hdlCfg.SynthesisTool~="Cadence Stratus"
                    moduleFileName=convertStringsToChars(topName+"Module"+".hpp");
                    hdlDrv.cgInfo.hdlFiles{end+1}=moduleFileName;
                    c_beautifier(moduleFileName);
                end
            end


            if~isCodingForSystemC
                hrr=emlhdlcoder.ResourceReportGenerator.HDLResourceReporter(topName);
                hrr.doIt;
            end

            [total_io_pin_count,~]=slhdlcoder.HDLTraceabilityDriver.calcIOPinsForDut(gp);
            IOThreshold=hdlgetparameter('IOThreshold');
            if(total_io_pin_count>IOThreshold)
                msgobj=message('hdlcoder:validate:IOThresholdExceeded',...
                sprintf('%d',total_io_pin_count),sprintf('%d',IOThreshold));


                emlhdlcoder.EmlChecker.CheckRepository.addCgirCheck(msgobj.getString,...
                msgobj.Identifier,...
                'Warning','',1,1);
            end


            [~,~,fcnExt]=fileparts(topScriptName);
            validExt={'.m'};


            multiTestbenchFiles=~isempty(fcnExt)&&~any(strcmpi(fcnExt,validExt))&&...
            contains(fcnExt,validExt);
            if multiTestbenchFiles
                error(message('hdlcoder:engine:multipletestbenches'));
            end





            cgInfo=generateCGInfo(hdlCfg,this.hTopFunctionName,this.hTopScriptName,hdlCfg.DebugLevel);

            if genMFBlock&&~hdlCfg.AggressiveDataflowConversion


                this.generateMFBlock(cgInfo);
            end





            p=pir();topN=p.getTopNetwork();
            subSysName=topN.Name;

            hdlFiles=hdlDrv.cgInfo.hdlFiles;
            codegenDir=hdlDrv.hdlGetCodegendir;



            switch(upper(hdlCfg.HDLLintTool))
            case{'LEDA'}
                prjFullName=fullfile(codegenDir,[subSysName,'_LEDA.prj']);
                hdlcodingstd.Report.genLEDAScript(subSysName,hdlFiles,prjFullName,'MLHDLC',hdlCfg);
            case{'SPYGLASS'}
                prjFullName=fullfile(codegenDir,[subSysName,'_spyglass.prj']);
                hdlcodingstd.Report.genSpyGlassScript(subSysName,hdlFiles,prjFullName,'MLHDLC',hdlCfg);
            case{'ASCENTLINT'}
                prjFullName=fullfile(codegenDir,[subSysName,'_AscentLint.prj']);
                hdlcodingstd.Report.genAscentLintScript(subSysName,hdlFiles,prjFullName,'MLHDLC',hdlCfg);
            case{'HDLDESIGNER'}
                prjFullName=fullfile(codegenDir,[subSysName,'_HDLDesigner.prj']);
                hdlcodingstd.Report.genHDLDesignerScript(subSysName,hdlFiles,prjFullName,'MLHDLC',hdlCfg);
            case{'CUSTOM'}
                prjFullName=fullfile(codegenDir,[subSysName,'_default.prj']);
                hdlcodingstd.Report.genDefaultScript(subSysName,hdlFiles,prjFullName,'MLHDLC',hdlCfg);
            otherwise
                0;
            end



            if(strcmpi(hdlCfg.HDLCodingStandard,'INDUSTRY'))
                topName=hdlDrv.cgInfo.topName;
                topScriptFullPath=fullfile(which(topFcnName));


                propScreenerObj=coderprivate.emlscreener_kernel(topFcnName);
                for itr=1:length(propScreenerObj.pFcnInfo)
                    if(strcmp(propScreenerObj.pFcnInfo{itr}.pName,topName))
                        topScriptFullPath=propScreenerObj.pFcnInfo{itr}.pPath;
                        break;
                    end
                end



                if(isempty(hdlCfg.HDLCodingStandardCustomizations))
                    hdlCfg.HDLCodingStandardCustomizations=hdlcoder.CodingStandard('INDUSTRY');
                end


                codingStdOptions=hdlCfg.HDLCodingStandardCustomizations;



                if(codingStdOptions.ModuleInstanceEntityNameLength.enable)
                    minNtwkL=codingStdOptions.ModuleInstanceEntityNameLength.length(1);
                    maxNtwkL=codingStdOptions.ModuleInstanceEntityNameLength.length(2);
                    chk=hdlcodingstd.STARCrules.checkMLTopLevelNetwork(topScriptFullPath,minNtwkL,maxNtwkL);
                    hdlcodingstd.Report.add(this.hTopFunctionName,chk);
                end




                showReport=hdlCfg.ErrorCheckReport;

                targetL=hdlCfg.TargetLanguage;
                codingStdEnum=hdlCfg.HDLCodingStandard;
                calledFromMakehdl=true;
                validator=hdlcodingstd.Checker(this.hPir,codingStdEnum,codingStdOptions,...
                targetL,calledFromMakehdl);
                codingstdChecks=validator.checkCodingStandardFromMATLAB(topScriptFullPath);
                hdlcodingstd.Report.add(this.hTopFunctionName,codingstdChecks);

                hdlcodingstd.Report.generateIndustryStandardReportMLHDLC(this.hTopFunctionName,topScriptFullPath,showReport,codingStdOptions);
                disp(['### ',hdlcodingstd.Report.getSummary(this.hTopFunctionName)])
            end

            if genXSGBlock
                this.generateXSGBlock(cgInfo);
            end

            useFiAccel=this.hEMLHDLConfig.UseFiAccelForTestBench;
            emlcHdlTB=emlhdlcoder.HDLCoderTB(topScriptName,topFcnName,hdlDrv,useFiAccel);

            gp=pir;
            topNetworkName=gp.getTopNetwork().getNameForReporting();



            if(genCustomScripts)
                postCodeGen=true;
                postTBGen=false;

                emlcHdlTB.generateCustomScripts(postCodeGen,postTBGen,hdlCfg.HDLSynthTool,topNetworkName);
            end

            if hdlCfg.TargetLanguage=="SystemC"
                this.runSystemCPostCodeGenTasks(emlcHdlTB);
                return;
            end

            if runTB
                gp.startTimer('HDL Testbench Generation','Phase tbg');
                tbStatus=emlcHdlTB.generateTB(hdlDrv,cgInfo.streamInfo);
                gp.stopTimer;

                if tbStatus



                    if(genCustomScripts)
                        postCodeGen=true;
                        postTBGen=true;
                        emlcHdlTB.generateCustomScripts(postCodeGen,postTBGen,hdlCfg.HDLSynthTool,topNetworkName);
                    end

                    if runSim

                        emlcHdlTB.generateTBScriptsForAutoSim(hdlDrv,simTool,topNetworkName);

                        simDriver=emlhdlcoder.Driver.SimulationDriver(hdlCfg,hdlDrv);
                        simDriver.doIt;
                    end
                end
            end

            if genCosimTb
                runMode=hdlCfg.CosimRunMode;
                switch hdlCfg.CosimTool
                case 'ModelSim'
                    gentb=emlhdlcoder.hdlverifier.GenMatlabModelSimTb(cgInfo,runMode);
                case 'Incisive'
                    gentb=emlhdlcoder.hdlverifier.GenMatlabIncisiveTb(cgInfo,runMode);
                case 'Vivado Simulator'
                    gentb=emlhdlcoder.hdlverifier.GenMatlabVivadoSimTb(cgInfo,runMode);
                end

                gentb.isOutputDataLogged=hdlCfg.CosimLogOutputs;

                gentb.doIt;

                if runCosimTB
                    runSimulation(gentb);
                end
            end

            if genFILTb
                gentb=emlhdlcoder.hdlverifier.GenMatlabFILTb(...
                cgInfo,...
                hdlCfg.FILBoardName,...
                hdlCfg.FILConnection,...
                hdlCfg.FILBoardIPAddress,...
                hdlCfg.FILBoardMACAddress,...
                hdlCfg.FILAdditionalFiles);
                gentb.isOutputDataLogged=hdlCfg.FILLogOutputs;

                gentb.doIt;

                if runFILTB
                    runSimulation(gentb);
                end
            end

            isIPWorkflow=strcmpi(hdlCfg.Workflow,'IP Core Generation');
            if(hdlCfg.FrameToSampleConversion&&isIPWorkflow)


                error(message('hdlcoder:matlabhdlcoder:IPCoreWorkflowFrameToSample'));
            end

            isTurnkeyWorkflow=strcmpi(hdlCfg.Workflow,'FPGA Turnkey');

            isGenericWorkflow=strcmpi(hdlCfg.Workflow,'Generic ASIC/FPGA');

            if isIPWorkflow||isTurnkeyWorkflow
                this.hDI=hdlDrv.DownstreamIntegrationDriver;
                if isempty(this.hDI)
                    error(message('hdlcoder:engine:NoDIDriver'));
                end
                if~isempty(hdlCfg.SynthesisTool)
                    this.hDI.set('Tool',hdlCfg.SynthesisTool);
                end
            end


            if isTurnkeyWorkflow
                this.preWrapperGenTurnkey;
            end


            if isIPWorkflow
                this.preWrapperGenIPCore;
            end


            if isGenericWorkflow

                this.hDI=downstream.integration('Model',topFcnName,'HDLDriver',hdlDrv,'isMLHDLC',true);
                this.hDI.isMLHDLC=true;
                this.preWrapperGeneric;
            end





            if isIPWorkflow||isTurnkeyWorkflow

                this.targetInferfaceAssignment;

                hT=this.hDI.hTurnkey;


                hT.makehdlturnkey;
            end

            if runSyn
                dumpResults=false;
                synDriver=emlhdlcoder.Driver.SynthesisDriver(hdlCfg,hdlDrv);
                synDriver.createProject(dumpResults);
                synDriver.runSynthesis(dumpResults);
                if runPAR
                    synDriver.runPAR(dumpResults);
                    synDriver.runReportCriticalPath;
                end
            end


            if isIPWorkflow||isTurnkeyWorkflow
                targetIntegrationDriver=emlhdlcoder.Driver.TargetIntegrationDriver(hdlCfg,hdlDrv);
                dumpResults=false;
                targetIntegrationDriver.doIt(dumpResults);
            end

            if hdlCfg.DebugLevel>0
                gp.printRunTimes;
            end
        end


        function preWrapperGenTurnkey(this)

            try
                this.hDI.setTargetFrequency(this.hEMLHDLConfig.TargetFrequency);
            catch ME
                error(message('hdlcoder:matlabhdlcoder:TurnkeyWorkflowInvalidDCMOutputFreq',ME.message));
            end
        end

        function preWrapperGeneric(this)



            try
                if(~strcmpi(this.hEMLHDLConfig.SynthesisTool,'Microchip Libero SoC')&&...
                    this.hEMLHDLConfig.TargetFrequency~=0)
                    if~isempty(this.hEMLHDLConfig.SynthesisTool)

                        this.hDI.set('Tool',this.hEMLHDLConfig.SynthesisTool);
                    end
                    this.hDI.setTargetFrequency(this.hEMLHDLConfig.TargetFrequency);
                    this.hDI.hGeneric.hConstraintEmitter.generateConstraintFile;
                end
            catch ME
                error(message('hdlcoder:matlabhdlcoder:TurnkeyWorkflowInvalidDCMOutputFreq',ME.message));
            end
        end


        function preWrapperGenIPCore(this)


            try
                if(this.hEMLHDLConfig.TargetFrequency~=0)
                    this.hDI.setTargetFrequency(this.hEMLHDLConfig.TargetFrequency);
                end
            catch ME
                error(message('hdlcoder:matlabhdlcoder:TurnkeyWorkflowInvalidDCMOutputFreq',ME.message));
            end

            if~isempty(this.hEMLHDLConfig.ReferenceDesign)
                this.hDI.hIP.setReferenceDesign(this.hEMLHDLConfig.ReferenceDesign);
            end

            if~isempty(this.hEMLHDLConfig.ReferenceDesignPath)
                this.hDI.hIP.setReferenceDesignPath(this.hEMLHDLConfig.ReferenceDesignPath);
            end


            try
                if~isempty(this.hEMLHDLConfig.IPCoreName)
                    this.hDI.hIP.setIPCoreName(this.hEMLHDLConfig.IPCoreName);
                end
            catch ME
                error(message('hdlcoder:matlabhdlcoder:IPCoreWorkflowInvalidIPCoreName',ME.message));
            end


            try
                if~isempty(this.hEMLHDLConfig.IPCoreVersion)
                    this.hDI.hIP.setIPCoreVersion(this.hEMLHDLConfig.IPCoreVersion);
                end
            catch ME
                error(message('hdlcoder:matlabhdlcoder:IPCoreWorkflowInvalidIPCoreVersion',ME.message));
            end




            try
                this.hDI.hTurnkey.setExecutionMode(this.hEMLHDLConfig.ExecutionMode);
            catch ME
                error(message('hdlcoder:matlabhdlcoder:IPCoreWorkflowExecutionMode',ME.message));
            end


            if~isempty(this.hEMLHDLConfig.AdditionalIPFiles)

                additIpFiles=strsplit(this.hEMLHDLConfig.AdditionalIPFiles);
                emptyEntriesIdx=find(cellfun(@(x)isempty(x),additIpFiles)>0);
                if~isempty(emptyEntriesIdx)
                    additIpFiles(emptyEntriesIdx)=[];
                end
                additIpFilesStr=strjoin(additIpFiles,';');
                additIpFilesStr=[additIpFilesStr,';'];
                this.hDI.hIP.setIPCoreCustomFile(additIpFilesStr)
            end

        end


        function targetInferfaceAssignment(this)

            portNames=cat(2,this.hDI.hTurnkey.hTable.hIOPortList.InputPortNameList,this.hDI.hTurnkey.hTable.hIOPortList.OutputPortNameList);
            for i=1:length(portNames)
                portName=portNames{i};
                portInterface=this.hEMLHDLConfig.getTargetInterface(portName);
                if~isempty(portInterface)
                    portInterfaceSplit=strtrim(strsplit(portInterface,'|'));
                    portInterfaceName=portInterfaceSplit{1};
                    portBitRange=portInterfaceSplit{2};

                    try
                        this.hDI.setTargetInterface(portName,portInterfaceName);
                    catch ME
                        error(message('hdlcoder:matlabhdlcoder:IPCoreTurnkeyWorkflowsInvalidPortInterface',portName,ME.message));
                    end


                    if~isempty(portBitRange)
                        try
                            this.hDI.setTargetOffset(portName,portBitRange);
                        catch ME
                            error(message('hdlcoder:matlabhdlcoder:IPCoreTurnkeyWorkflowsInvalidPortBitRange',portName,ME.message));
                        end
                    end
                end
            end


            try
                validateTableCell=this.hDI.hTurnkey.hTable.validateInterfaceTable;
            catch ME

                error(message('hdlcoder:matlabhdlcoder:IPCoreTurnkeyWorkflowsMissingInterfaceAssignment',ME.message));
            end
            if~isempty(validateTableCell)
                for ii=1:length(validateTableCell)
                    validateTableStruct=validateTableCell{ii};
                    validateStatus=validateTableStruct.Status;
                    if ischar(validateStatus)
                        if strcmpi(validateStatus,'Error')
                            status=1;
                        elseif strcmpi(validateStatus,'Warning')
                            status=2;
                        else
                            status=0;
                        end
                    else
                        status=validateStatus;
                    end

                    if status==1
                        error(validateTableStruct.MessageID,validateTableStruct.Message);
                    elseif status==2
                        warning(validateTableStruct.MessageID,validateTableStruct.Message);
                    elseif status==0
                        logTxt=sprintf('Note: %s',validateTableStruct.Message);
                        hdldisp(logTxt);
                    end
                end
            end
        end


        function runSystemCPostCodeGenTasks(this,emlcHdlTB)
            hdlDrv=this.hHDLDriver;
            hdlCfg=this.hEMLHDLConfig;
            hdlCfg.Workflow="High Level Synthesis";

            runTB=hdlCfg.GenerateHDLTestBench;
            runSim=hdlCfg.SimulateGeneratedCode;
            runSyn=hdlCfg.SynthesizeGeneratedCode;

            if~runTB&&hdlCfg.SynthesisTool=="Cadence Stratus"&&runSyn
                error(message('Coder:hdl:hdltb_skipped_for_stratus'));
            end

            gp=pir;
            if runTB
                if contains(hdlCfg.SystemCTestBenchStimulus,'HDL Test bench stimulus')
                    gp.startTimer('HDL Testbench Generation','Phase tbg');
                    emlcHdlTB.generateTB(hdlDrv);
                    gp.stopTimer;
                end


                tbFileName=convertStringsToChars(hdlDrv.cgInfo.topName+"Class_tb"+".hpp");
                hdlDrv.cgInfo.hdlFiles{end+1}=tbFileName;
                if(hdlCfg.SynthesisTool=="Xilinx Vitis HLS")
                    mainFcnFileName=convertStringsToChars(hdlDrv.cgInfo.topName+"_main"+".cpp");
                    hdlDrv.cgInfo.hdlFiles{end+1}=mainFcnFileName;
                end

                if(runSim||runSyn)
                    if hdlCfg.SynthesisTool=="Cadence Stratus"
                        emlcHdlTB.generateBDWImportScripts(hdlCfg.SystemCTestBenchStimulus,hdlCfg.DesignFunctionName);
                    elseif hdlCfg.SynthesisTool~="Xilinx Vitis HLS"



                        error(message('hdlcoder:workflow:InvalidHLSTool',hdlCfg.SynthesisTool));
                    end
                end

                if runSim
                    simDriver=emlhdlcoder.Driver.SimulationDriver(hdlCfg,hdlDrv);
                    simDriver.doIt;
                end
            end

            if runSyn

                dumpResults=false;
                synDriver=emlhdlcoder.Driver.SynthesisDriver(hdlCfg,hdlDrv);
                synDriver.runSynthesis(dumpResults);
            end
        end

    end
end




