function runPIRTransformAndCodegen(this,gp,codegenParams,params)




    if nargin<4
        params={};
    end

    try


        this.hdlMakeCodegendir;

        autoCleanUp=onCleanup(@()this.closeConnection());

        gp.progressTransformPhase();


        targetCodegenSanityCheck(this);


        this.getIncrementalCodeGenDriver().init(this);

        singleratemode=(this.getParameter('maxoversampling')==1);

        if(this.getParameter('maxoversampling')~=Inf&&...
            this.getParameter('maxoversampling')~=0)
            msgobj=message('hdlcoder:makehdl:DeprecateMaxOverSampling');
            warning(msgobj);
            this.addCheck(this.ModelName,'Warning',msgobj);
            this.setParameter('maxoversampling',Inf);
        end

        if(this.getParameter('maxcomputationlatency')~=1)
            msgobj=message('hdlcoder:makehdl:DeprecateMaxComputationLatency');
            warning(msgobj);
            this.addCheck(this.ModelName,'Warning',msgobj);
            this.setParameter('maxcomputationlatency',1);
        end


        resolveDutDelayBalancingSetting(this,gp.getTopPirCtx);

        targetcodegen.alteradspbadriver.process('phase2',this);

        gp.progressTransformPhase();

        gp.updateCompiledFlags;

        numModels=numel(this.AllModels);
        for mdlIdx=1:numModels
            this.mdlIdx=mdlIdx;
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);
            this.PirInstance=p;




            if this.getParameter('EnableTestpoints')
                gp.startTimer('Testpoint Port Propagation','Phase tpp');
                p.testpointPortPropagation;
                gp.stopTimer;
            end

            hdldisp(message("hdlcoder:hdldisp:BeginHDLOptimizations",this.ModelName));






            p.propagateSignalRatesForBSS;


            gp.startTimer('Bus to Vector Conversion','Phase btvc');
            p.bustoVectorInsertion;
            gp.stopTimer;




            gp.startTimer('For Each Subsystem Transformation','Phase fest');
            p.doForEachSubsystemTransformation;
            gp.stopTimer;

            this.getTargetCodeGenDriver(p);


            gp.startTimer('Insert Traceability and Requirement Comments','Phase itrc');
            insertComments(this,p);
            gp.stopTimer;







            gp.startTimer('Compute Base Rate','Phase cbr1');
            p.updateBaseRate;
            gp.stopTimer;


            gp.startTimer('Early Elaborate','Phase eela');
            p.earlyElaborate;
            gp.stopTimer;




            gp.startTimer('For Iterator Subsystem Rate Setting','Phase fisrs');
            p.doForIterSubsystemSetRates;
            gp.stopTimer;

            if this.getParameter('FrameToSampleConversion')
                gp.startTimer('NPU Subsystem Rate Setting','Phase npusrs');
                p.doNPUSubsystemSetRates;
                gp.stopTimer;
            end






            gp.startTimer('Group Elaboration Helper Networks','Phase gehn1');
            p.groupElabNetworks;
            gp.stopTimer;


            gp.startTimer('From Goto Lowering','Phase fgl');
            p.wireFromGotoComps(true,false);
            gp.stopTimer;
        end



        gp.startTimer('Flatten User Networks','Phase fun1');
        gp.flattenUserNetworks;
        gp.stopTimer;

        for mdlIdx=1:numModels
            this.mdlIdx=mdlIdx;
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);
            this.PirInstance=p;

            gp.startTimer('Compute Base Rate','Phase cbr2');
            p.updateBaseRate;
            gp.stopTimer;


            gp.startTimer('Optimization Lowering','Phase opl');
            p.doOptimizationLowering;
            gp.stopTimer;

        end
        gp.progressTransformPhase();



        gp.startTimer('Dut Port Streaming','Phase dps');
        gp.dutPortStreaming(this.getParameter('mapVectorPortToStream'),this.getParameter('inferControlPorts'));
        gp.stopTimer;





        for mdlIdx=1:numModels
            this.mdlIdx=mdlIdx;
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);
            this.PirInstance=p;

            gp.startTimer('Enable Port Lowering','Phase epl');
            hdlcoder.TransformDriver.systemElaboration(p);
            gp.stopTimer;
        end


        gp.startTimer('Flatten User Networks','Phase fun2');
        gp.flattenUserNetworks;
        gp.stopTimer;

        if this.getParameter('EnableTestpoints')
            hdlcodingstd.Report.reportForTestpointsInIndustryStandardMode(mdlName);
        end

        for mdlIdx=1:numModels
            this.mdlIdx=mdlIdx;
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);
            this.PirInstance=p;



            gp.startTimer('Tunable Parameter Transformation','Phase tpt');
            p.doTunableParametersTransformation;
            gp.stopTimer;
        end






        gp.startTimer('PIR Dead Logic Elimination','Phase delUCP1');
        gp.doDeadLogicElimination(true);
        gp.stopTimer;




        if(~gp.getTopPirCtx.getTopNetwork.hasComponents&&...
            gp.getTopPirCtx.getTopNetwork.NumberOfPirOutputPorts==0&&...
            gp.getTopPirCtx.getTopNetwork.NumberOfPirInputPorts==0&&...
            gp.getTopPirCtx.getTopNetwork.NumberOfPirGenericPorts==0)

            msgData=message('hdlcoder:hdldisp:AllCompsDeadInDUT',this.OrigStartNodeName);
            this.addCheck(this.ModelName,'Warning',msgData);

            hAC=pirelab.getAnnotationComp(gp.getTopPirCtx.getTopNetwork,'EmptyDUT',msgData.string.char);
            hAC.setPreserve(true);
        end




        if runClockRatePipelining(this,false)
            for mdlIdx=1:numModels
                this.mdlIdx=mdlIdx;
                mdlName=this.AllModels(mdlIdx).modelName;
                p=pir(mdlName);
                this.PirInstance=p;

                gp.startTimer('Clock Rate Partitioning','Phase crp');
                p.clockRatePartitioning;
                gp.stopTimer;
            end
        end

        gp.progressTransformPhase();


        for mdlIdx=1:numModels
            this.mdlIdx=mdlIdx;
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);
            this.PirInstance=p;





            gp.startTimer('Add Pipeline Registers','Phase apr');

            hdlcoder.TransformDriver.addPipelineRegisters(p);
            gp.stopTimer;



            gp.startTimer('Elaborate','Phase ela');
            p.elaborate;
            gp.stopTimer;



            internal.ml2pir.FunctionInfoRegistryCache.clearCacheValues;



            if this.getParameter('FrameToSampleConversion')
                gp.startTimer('Streaming matrix transforms','Phase smt');
                streamingmatrix.runTransforms(gp,p,false);
                gp.stopTimer;

                if this.checkForErrors
                    this.reportMessages;
                    return;
                end
            end


            gp.startTimer('Matrix Expansion','Phase mep');
            hdlcoder.TransformDriver.matrixExpansion(p);
            gp.stopTimer;


            hdlserializepir(this,p);







            gp.startTimer('Group Elaboration Helper Networks','Phase gehn2');
            p.groupElabNetworks;
            gp.stopTimer;






            if this.getParameter('OptimizeConstants')
                gp.startTimer('PIR Constant Folding Optimization','Phase pircfo');
                p.doPIRConstantFoldingOptimization;
                gp.stopTimer;

                gp.startTimer('NFP Peephole Optimizer Transformation','Phase nfpot');
                p.doNfpPeepholeOptimizerTransformation;
                gp.stopTimer;
            end


            gp.startTimer('Pseudo Elab Lowering','Phase pel');
            p.doPseudoElabLowering;
            gp.stopTimer;



            p.runVectorMACCompTransformer(true);
        end

        gp.startTimer('Adaptive Pipelines Insertion','Phase api');

        if~isempty(this.getParameter('SynthesisTool'))




            if(this.getParameter('TargetFrequency')>0)&&~gp.isHardwarePipeliningOn&&...
                ~this.getParameter('AdaptivePipelining')


                msgobj=message('hdlcoder:workflow:AdaptivePipelineOffMessage',this.ModelName);
                hdldisp(msgobj);
                this.addCheck(this.ModelName,'Message',msgobj);
            end


            if this.getParameter('LUTMapToRAM')
                toolName=this.getParameter('SynthesisTool');
                if(strncmpi(toolName,'xilinx',6)||strncmpi(toolName,'Altera',6)||...
                    strncmpi(toolName,'Intel',5))

                    msgobj=message('hdlcoder:workflow:LUTMapToRAMOffMessage',this.ModelName);
                    hdldisp(msgobj);
                    this.addCheck(this.ModelName,'Message',msgobj);
                end
            end
        end


        gp.applyHardwarePipelining;






        gp.updateVectorMACsDelayTag();

        gp.stopTimer;

        blackBoxVHDLLibNames=containers.Map('KeyType','char','ValueType','char');
        for mdlIdx=1:numModels
            this.mdlIdx=mdlIdx;
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);
            this.PirInstance=p;


            this.runCompTransformer(p);


            this.processBlackBoxes(p,blackBoxVHDLLibNames);





            gp.startTimer('Apply Modelgen Tags','Phase amt');
            p.applyModelgenTags;
            gp.stopTimer;


            gp.startTimer('Run Elab Optimizations','Phase reo');
            p.runElabOptimizations;
            p.doPeepholeDelayOptimization;
            gp.stopTimer;



            gp.startTimer('Peephole Delay Optimizer','Phase pdo');
            p.doPeepholeDelayOptimization;
            gp.stopTimer;

            gp.startTimer('Adjust Hardware Mode Delays','Phase ahmd');
            p.adjustHardwareModeDelays;
            p.runVectorMACCompTransformer(false);
            gp.stopTimer;

            gp.startTimer('Remove Matrix Reshapes','Phase rmr');
            ignoreElementWiseComps=false;
            p.removeMatrixReshapes(ignoreElementWiseComps);
            gp.stopTimer;








        end



        if(this.checkForErrors)
            this.reportMessages;
        end

        p=gp.getTopPirCtx;


        p.setCompositeBlocksTags;

        for mdlIdx=1:numModels
            this.mdlIdx=mdlIdx;
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);
            this.PirInstance=p;

            gp.startTimer('Run Complex Multiplier Elaborator','Phase rcme');
            p.runComplexMulElaborator;
            gp.stopTimer;

            gp.startTimer('Expose Rounding Saturation Logic','Phase rsDTC');
            p.exposeRoundingSaturationLogic;
            gp.stopTimer;
        end

        targetcodegen.alteradspbadriver.process('phase3',this);

        if this.getParameter('MultiplierPartitioningThreshold')
            for mdlIdx=numModels:-1:1
                this.mdlIdx=mdlIdx;
                mdlName=this.AllModels(mdlIdx).modelName;
                p=pir(mdlName);
                this.PirInstance=p;


                gp.startTimer('Run Multiplier Splitter','Phase rms');
                p.runMultiplierSplitter;
                gp.stopTimer;
            end
        end



        gp.startTimer('Check Delay Balancing','Phase cdb1');
        gp.checkDelayBalancing(true);
        gp.stopTimer;



        if this.getParameter('UseSynthesisEstimatesForDistributedPipelining')
            p=gp.getTopPirCtx;
            characterization.readCharacterizationData(p,true);
        end

        for mdlIdx=numModels:-1:1
            this.mdlIdx=mdlIdx;
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);
            this.PirInstance=p;

            if~singleratemode







                gp.startTimer('Constrained Retiming','Phase crt');
                hdlcoder.TransformDriver.retimeConstrained(p,this.getParameter('functionallyEquivalentRetiming'));
                gp.stopTimer;
            end
        end

        topPirCtx=pir(this.ModelName);

        updateSampleTimesForBBSubModels(this,this.ProtectedModels);

        if strcmp(hdlgetparameter('compilestrategy'),'CompileChanged')
            updateSampleTimesForBBSubModels(this,this.BlackBoxModels);
        end

        for mdlIdx=1:numModels
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);




            gp.startTimer('For Iterator Subsystem Transformation','Phase fist');
            p.doForIterSubsystemLowering;



            p.doForIterSubsystemCheckLatency;
            gp.stopTimer;
        end

        gp.startTimer('Run Serialization','Phase rse');
        runSerialization(this,gp);

        topPirCtx.updateBaseRate();
        gp.stopTimer;

        for mdlIdx=1:numModels
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);


            gp.startTimer('Target Code Generation','Phase tcg');
            targetSpecificFunctionMessage(this,p);
            hdlcoder.TransformDriver.targetCodeGeneration(p);





            p.doForIterSubsystemCheckLatency;

            targetCodeGenStatusCheck(p);
            gp.stopTimer;


            gp.startTimer('Make Eml Clock Requests','Phase mecr');
            p.makeEmlClockRequests;
            gp.stopTimer;
        end

        gp.progressTransformPhase();
        if~strcmp(hdlfeature('GuidedRetiming'),'on')
            if(codegenParams.guidedRetiming)
                latencyConstraint=this.getParameter('latencyConstraint');
                cpAnnotationFile=this.getParameter('cpAnnotationFile');
                grFirstIteration=~(exist(cpAnnotationFile,'file')==2);
                cpGuidanceFile=this.getParameter('cpGuidanceFile');
                if(~isempty(codegenParams.guidanceFile))
                    resolvedGuidanceFile=codegenParams.guidanceFile;
                else
                    resolvedGuidanceFile=cpGuidanceFile;
                end
                if(~grFirstIteration)
                    temp=qoroptimizations.loadFile(cpAnnotationFile);
                    criticalPathSet=temp.criticalPathSet;
                else
                    criticalPathSet=[];
                end
                for mdlIdx=1:numModels
                    this.mdlIdx=mdlIdx;
                    mdlName=this.AllModels(mdlIdx).modelName;
                    p=pir(mdlName);

                    this.runGuidedRetiming(p,criticalPathSet,latencyConstraint,resolvedGuidanceFile,~grFirstIteration,codegenParams.grIsRegenMode);
                end
            end
        end
        gp.progressTransformPhase();


        gp.startTimer('Check Delay Balancing','Phase cdb2');
        gp.checkDelayBalancing(true);
        gp.stopTimer;



        gp.startTimer('Mark Networks for Scheduling','Phase mns');
        gp.markNetworksForScheduling;
        gp.stopTimer;

        gp.progressTransformPhase();

        if runClockRatePipelining(this,false)
            gp.startTimer('Retime and Balance CRPs','Phase rbc');
            gp.retimeAndBalanceCRPs;
            gp.stopTimer;

            if this.getParameter('MulticyclePathConstraints')&&gp.crpSuccess
                warnObj=message('HDLShared:hdlshared:mcpConflictCrp');
                this.addCheck(this.ModelName,'Warning',warnObj);
                this.reportMessages;
            end
        end

        gp.progressTransformPhase();

        gp.startTimer('Run Pre Delay Balancing Callbacks','Phase pdbc');
        this.runPreDBCallbacks;
        gp.stopTimer;




        topPirCtx.promoteCtxInfo;
        gp.startTimer('Automatic Delay Balancing','Phase adb');
        topPirCtx.balancePathDelays;
        gp.stopTimer;




        if gp.getParamValue('largedelaymemory')
            delaySizeThreshold=gp.getParamValue('delaysizethreshold');
            streamingmatrix.moveLargeDelaysOutsideDUT(p,delaySizeThreshold);
        end

        if(this.getParameter('reduceMatchingDelays'))
            for mdlIdx=1:numModels
                mdlName=this.AllModels(mdlIdx).modelName;
                p=pir(mdlName);
                p.reduceMatchingDelays;
            end
        end

        gp.progressTransformPhase();


        if runClockRatePipelining(this,true)
            gp.startTimer('Flatten Clock Rate Networks','Phase fcr');
            gp.flattenClockRatePartitions;
            gp.stopTimer;
        end


        gp.startTimer('PIR Dead Logic Elimination','Phase delUCP2');
        gp.doDeadLogicElimination;
        gp.stopTimer;

        for mdlIdx=numModels:-1:1
            this.mdlIdx=mdlIdx;
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);
            this.PirInstance=p;

            if singleratemode



                gp.startTimer('Constrained Retiming After Delay Balancing','Phase crtadb');
                hdlcoder.TransformDriver.retimeConstrainedAfterDelayBalancing(p,this.getParameter('functionallyEquivalentRetiming'));
                gp.stopTimer;
            end
        end

        if singleratemode

            gp.startTimer('Schedule Global Enables','Phase sge');
            gp.scheduleGlobalEnables;
            gp.stopTimer;
        end

        for mdlIdx=numModels:-1:1
            this.mdlIdx=mdlIdx;
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);
            this.PirInstance=p;

            gp.startTimer('Retiming','Phase ret');
            hdlcoder.TransformDriver.retime(p,...
            this.getParameter('functionallyEquivalentRetiming'),...
            this.getParameter('optimizationReport'),...
            this.getParameter('recommendations'));
            gp.stopTimer;
        end

        for mdlIdx=numModels:-1:1
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);



            gp.startTimer('Zero Protection','Phase azp');
            p.addZeroProtection;
            gp.stopTimer;



            gp.startTimer('Rate Transition Phase Matching Transform','Phase rtpmt');
            p.runRateTranPhaseMatching(hdlcoderui.isDSTinstalled);
            gp.stopTimer;





            p.flattenOptimizationPartitionNetworks;
        end
        gp.startTimer('Report Optimization Information','Phase roi');
        this.reportOptInfo;
        gp.deleteUnusedClockRates;
        gp.stopTimer;




        if(gp.DutBaseRate<0.0)
            gp.addDutSampleTime(1);
        end

        gp.startTimer('Serializer Optimization','Phase sop');
        gp.optimizeSerializers;
        gp.stopTimer;

        gp.startTimer('Replace Old Serializer Deserializer Comps','Phase rosdc');
        gp.replaceOldSeDsComps;
        gp.stopTimer;

        if any([this.getParameter('CriticalPathEstimation'),this.getParameter('OptimizationCompatibilityCheck')])
            p=gp.getTopPirCtx;
            characterization.readCharacterizationData(p,false);
        end

        if any(this.getParameter('OptimizationCompatibilityCheck'))
            p=gp.getTopPirCtx;
            p.doOptimizationCompatibilityChecks;
        end


        gp.startTimer('Adaptive Pipelining','Phase scl');
        gp.insertHwModeRegisters;
        gp.stopTimer;


        if any(this.getParameter('CriticalPathEstimation'))
            p=gp.getTopPirCtx;
            gp.startTimer('Critical Path Estimation','Phase STA');
            p.doCriticalPathEstimation;
            gp.stopTimer;

            CriticalPathDelay=gp.getCriticalPathDelay;
            hdlcodegenstatusFile=fullfile(this.hdlGetBaseCodegendir,'hdlcodegenstatus.mat');
            if isfile(hdlcodegenstatusFile)

                s=load(hdlcodegenstatusFile);
                s.CriticalPathDelay=CriticalPathDelay;
                s=orderfields(s);
                save(hdlcodegenstatusFile,'-struct','s');
            else
                save(hdlcodegenstatusFile,'CriticalPathDelay');
            end


            if~strcmp(hdlfeature('GuidedRetiming'),'on')
                guidedCPFileName="cpAnnotation.mat";
                qoroptimizations.backAnnotateCPE(gp,guidedCPFileName);
            end
        end

        gp.startTimer('Run State Control Lowering','Phase scl');
        p=gp.getTopPirCtx;
        p.runStateControlLowering;
        gp.stopTimer;



        if any(this.getParameter('StaticLatencyPathAnalysis'))
            hAllN=p.Networks;
            for ii=1:length(hAllN)
                hAllN(ii).renderCodegenPir(true);
            end
        end

        if this.getParameter('FrameToSampleConversion')
            streamingmatrix.insertFIFOsAtDUTBoundaries(gp,...
            this.getParameter('InputFIFOSize'),...
            this.getParameter('OutputFIFOSize'));
        end


        doOnlyMdlGen=this.runModelGeneration(gp,this.hs);


        gp.removeAllElabHelpers;



        needCodeGenReport=~doOnlyMdlGen&&...
        (this.getParameter('traceability')...
        ||this.getParameter('resourceReport')...
        ||this.getParameter('optimizationReport')...
        ||this.getParameter('hdlgeneratewebview')...
        ||this.getParameter('ipcoreReport')...
        ||this.getParameter('CriticalPathEstimation')...
        ||this.getParameter('StaticLatencyPathAnalysis')...
        ||this.getParameter('obfuscateGeneratedHDLCode'));
        if needCodeGenReport
            gp.startTimer('Run Optimization Reports','Phase ror');
            reportInfoObjects=cell(1,numModels);
            for mdlIdx=1:numModels
                this.mdlIdx=mdlIdx;
                mdlName=this.AllModels(mdlIdx).modelName;
                p=pir(mdlName);
                this.PirInstance=p;
                reportInfo=initializeReports(this,p);
                reportInfo.emitOptimizationReportPages;
                reportInfoObjects{mdlIdx}=reportInfo;
            end
            gp.stopTimer;
        elseif this.getParameter('TraceabilityProcessing')



            reportInfoObjects=cell(1,numModels);
            for mdlIdx=1:numModels
                this.mdlIdx=mdlIdx;
                mdlName=this.AllModels(mdlIdx).modelName;
                p=pir(mdlName);
                this.PirInstance=p;
                reportInfo=initializeReports(this,p);
                reportInfoObjects{mdlIdx}=reportInfo;
            end
        else

            slhdlcoder.HDLTraceabilityDriver.removeTraceabilityInfo(this);

            for mdlIdx=1:numModels
                this.mdlIdx=mdlIdx;
                mdlName=this.AllModels(mdlIdx).modelName;
                hdlcoder.report.ReportInfo.getSavedRptPath(mdlName,true,[]);
            end
        end

        gp.startTimer('Run Post Model Callbacks','Phase pmc');
        this.runPostModelCallbacks;
        gp.stopTimer;

        if doOnlyMdlGen||this.checkForErrors
            this.reportMessages;
            return;
        end


        p=gp.getTopPirCtx;
        p.elaborateCompositeBlocks;



        gp.startTimer('Set Top Network For Codegen','Phase sct');
        gp.setTopNetworkForCodegen;
        this.setCurrentNetwork(gp.getTopNetwork);
        gp.stopTimer;



        this.fixPortNames;

        gp.progressTransformPhase();


        if this.getParameter('resourcereport')&&targetcodegen.targetCodeGenerationUtils.isNFPMode()

            for mdlIdx=1:numModels
                this.mdlIdx=mdlIdx;
                mdlName=this.AllModels(mdlIdx).modelName;
                p=pir(mdlName);
                nfp_stat=hdlcoder.characterization.create();
                nfp_stat.doit(p);
                this.nfp_stats(mdlName)=nfp_stat;



            end
        end




        gp.startTimer('PIR Dead Logic Elimination','Phase delUCP3');
        gp.doDeadLogicElimination(true);
        gp.stopTimer;



        if strcmp(hdlfeature('EnableFlattenSFComp'),'on')
            gp.flattenMarkedSFHolderNetworks;
        end

        for mdlIdx=1:numModels
            this.mdlIdx=mdlIdx;
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);

            this.PirInstance=p;
            gp.startTimer('Flatten Modelgen Networks','Phase fmn');


            p.flattenModelgenNetworks;




            p.inlineUserSpecifiedNetworks;





            this.flattenSubsystemBlocks()
            gp.stopTimer;

            gp.startTimer('Target Specific Replacement','Phase tsr');
            if targetcodegen.targetCodeGenerationUtils.isNFPMode()

                hdlcoder.TransformDriver.matrixLowerTargetComps(p);
                transformnfp.doIt(p);
                tcgInventory=[];
            else

                tcgInventory=performTargetSpecificFunctionReplacement(this,p);
            end
            p.processSimpleTargetComps();
            gp.stopTimer;


            gp.startTimer('Generate CGIR','Phase cgi');
            p.prepareForEmission;
            this.runGenerateCGIR(p);
            gp.stopTimer;
        end

        gp.startTimer('Inline HDL Code','Phase ihc');
        if this.getParameter('inlineHDLCode')
            gp.inlineHDLCode;
        end
        gp.stopTimer;





        if(strcmpi(this.getParameter('target_language'),'vhdl')||...
            strcmpi(this.getParameter('target_language'),'verilog'))&&...
            this.getParameter('EnableForGenerateLoops')

            gp.startTimer('For Each NICs To Generate Loop Transformation','Phase fgl')

            for mdlIdx=1:numModels
                this.mdlIdx=mdlIdx;
                mdlName=this.AllModels(mdlIdx).modelName;
                p=pir(mdlName);
                p.doForEachNICsToGenerateLoopTransformation;
            end

            gp.stopTimer;

        end

        gp.finalizeClocks(false);

        targetcodegen.alteradspbadriver.process('phase4',this);

        mpcg=[];

        for mdlIdx=1:numModels
            this.mdlIdx=mdlIdx;
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);
            this.PirInstance=p;

            gp.startTimer('Run Clock Generation And Init PIR BackEnd','Phase rcp');
            p.invokeBackEnd;
            gp.stopTimer;
        end



        if(this.checkForErrors)
            this.reportMessages;
        end




        gp.startTimer('PIR Dead Logic Elimination','Phase delUCP4');
        gp.doDeadLogicElimination(true);
        gp.stopTimer;



        try
            generateRemovedDeadBlockScripts(this,gp);
        catch me
            warning(me.message)
        end


        toppir=pir(this.AllModels(numModels).modelName);
        pirtcName=this.elaborateTimingControllers(toppir);

        storeAllBBSubModelScriptData(this,this.ProtectedModels,blackBoxVHDLLibNames);

        if strcmp(hdlgetparameter('compilestrategy'),'CompileChanged')
            storeAllBBSubModelScriptData(this,this.BlackBoxModels,blackBoxVHDLLibNames);
        end

        topMdlName=bdroot(this.OrigStartNodeName);

        if this.getParameter('traceability')
            hdldisp(message('hdlcoder:makehdl:MakehdlParamUpdateLog',topMdlName,'Traceability'));
        end

        if this.getParameter('hdlgeneratewebview')
            hdldisp(message('hdlcoder:makehdl:MakehdlParamUpdateLog',topMdlName,'HDLGenerateWebview'));
        end

        for mdlIdx=1:numModels
            this.mdlIdx=mdlIdx;
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);
            this.PirInstance=p;

            if~checkIncrementalCodegen(this,p)
                p.finishEmission;
                this.postBackEnd(p,true);
                this.printIncrementalCodeGenInfo(p);
                fileList=this.getIncrementalCodeGenDriver.getGenFileList(mdlName);
                storeSubModelScriptData(this,mdlName,fileList);
                generateIndustryStandardReport(this,mdlName);
                if needCodeGenReport
                    generateCodeGenReport(this,reportInfoObjects{mdlIdx},p,tcgInventory);
                elseif this.getParameter('TraceabilityProcessing')



                    reportInfo=reportInfoObjects{mdlIdx};
                    reportInfo.processTraceInfo(this,p,tcgInventory);
                end
                continue;
            end


            gp.startTimer('Init Connectivity','Phase isc');
            hdlconnectivity.slhcConnectivityInit(p);
            gp.stopTimer;



            gp.startTimer('Run BackEnd','Phase rbe');
            this.preBackEnd(p);


            if mdlIdx==numModels&&~isempty(pirtcName)&&gp.isPIRTCCtxBased
                pirtc=pir(pirtcName);
                tcNtwks=pirtc.Networks;
                for ii=1:length(tcNtwks)
                    hN=tcNtwks(ii);
                    p.addEntityNameAndPath(hN.Name,hN.FullPath);
                end
            end

            this.postBackEnd(p,false);
            gp.stopTimer;

            gp.startTimer('Generate Code Generation Scripts','Phase gcgs');

            generateIndustryStandardReport(this,mdlName);


            this.generateCoderScripts(p);
            storeSubModelScriptData(this,mdlName,this.getEntityFileNames(p));
            gp.stopTimer;


            if(strcmp(hdlfeature('HDLCodeView'),'on'))
                isRef=false;
                if~strcmp(this.ModelName,p.ModelName)
                    isRef=true;
                end

                if needCodeGenReport&&~isempty(reportInfo)
                    codeGenDirRoot=reportInfo.codeGenDirRoot;
                else
                    codeGenDirRoot=pwd;
                end
                simulinkcoder.internal.HDLCodeView.saveGeneratedFilesPath(p,this.hdlGetCodegendir,isRef,codeGenDirRoot,this.getParameter('TraceabilityStyle'));
            end

            if needCodeGenReport

                gp.startTimer('Generate Code Generation Report','Phase gcg');
                generateCodeGenReport(this,reportInfoObjects{mdlIdx},p,tcgInventory);
                gp.stopTimer;
            elseif this.getParameter('TraceabilityProcessing')



                reportInfo=reportInfoObjects{mdlIdx};
                reportInfo.processTraceInfo(this,p,tcgInventory);
            end

            if strcmp(hdlfeature('HDLCodeView'),'on')

                src=simulinkcoder.internal.util.getSource(mdlName);
                studio=src.studio;
                if~isempty(studio)
                    contextManager=studio.App.getAppContextManager;
                    customContext=contextManager.getCustomContext('hdlcoderApp');

                    if~isempty(customContext)
                        if isempty(customContext.hdlCodeView)
                            customContext.hdlCodeView=simulinkcoder.internal.CodeView_HDL(studio);
                        end
                        customContext.hdlCodeView.open('',true);
                    end
                end
            end


            gp.startTimer('Finish Connectivity','Phase fc1');
            mpcg=finishConnectivity(this,p);
            gp.stopTimer;
        end

        [total_io_pin_count,~]=slhdlcoder.HDLTraceabilityDriver.calcIOPinsForDut(gp);
        IOThreshold=hdlgetparameter('IOThreshold');
        if(total_io_pin_count>IOThreshold)
            if slfeature('StreamingMatrixWorkflow')
                msg_id='hdlcoder:validate:IOThresholdExceededSMT';
                msgobj=message(msg_id,...
                sprintf('%d',total_io_pin_count),sprintf('%d',IOThreshold),bdroot(this.getStartNodeName));
            else
                msg_id='hdlcoder:validate:IOThresholdExceeded';
                msgobj=message(msg_id,...
                sprintf('%d',total_io_pin_count),sprintf('%d',IOThreshold));
            end


            this.addCheck(this.ModelName,'Warning',msgobj);
        end

        for mdlIdx=1:numModels
            this.mdlIdx=mdlIdx;
            mdlName=this.AllModels(mdlIdx).modelName;
            p=pir(mdlName);
            this.PirInstance=p;
            this.setVhdlPackageName(p);
            this.getIncrementalCodeGenDriver().saveHDLCodeGenerationStatus(this,p)


            if this.getParameter('generatecodeinfo')
                gp.startTimer('Generate Code Info','Phase gci');
                generateCodeInfo(this);
                gp.stopTimer;
            end
        end


        if this.getParameter('MulticyclePathConstraints')
            gp.startTimer('Generate Multicycle Path Constraints','Phase gmt');
            generateMulticyclePathConstraints(this);
            gp.stopTimer;
        end


        if this.getParameter('generatefilblock')
            gp.startTimer('Generate FIL Wizard','Phase gfw');
            generateFILWizard(this);
            gp.stopTimer;
        end

        this.reportMessages();
    catch me
        this.reportMessagesOnException(me);
        cr=simulinkcoder.internal.Report.getInstance;
        crCleanup=onCleanup(@()cr.unlock(this.ModelName));
        this.doMakehdlCleanup(this.hs,me);
    end


    cr=simulinkcoder.internal.Report.getInstance;
    crCleanup=onCleanup(@()cr.unlock(this.ModelName));

    gp.startTimer('Finish Connectivity','Phase fc2');
    hdlconnectivity.slhcConnectivityCleanup(mpcg,this.ModelName,true);
    gp.stopTimer;

    gp.startTimer('Finish Makehdl','Phase fmk');
    this.finishMakehdl(this.hs);
    gp.stopTimer;

    targetcodegen.alteradspbadriver.process('phase5',this,codegenParams.dspbaOrginSettings);

    gp.stopMakehdlTimer;

    if this.getParameter('RuntimeReport')
        jsonFileName=fullfile(this.hdlGetBaseCodegendir,...
        [this.ModelName,'_runtime_info.json']);
        gp.dumpRunTimes(jsonFileName);
        this.reportRuntimeInfo;

        delete(jsonFileName);
    end

    if codegenParams.genTB
        gp.startTimer('HDL Testbench Generation','Phase hdltbg');
        this.makehdltb(params);
        gp.stopTimer;
    end

    if this.getParameter('debug')
        gp.dumpRunTimes(fullfile(this.hdlGetBaseCodegendir,...
        [this.ModelName,'_runtime_info.json']));
        gp.printRunTimes;
    end

    gp.progressTransformPhase();
end















