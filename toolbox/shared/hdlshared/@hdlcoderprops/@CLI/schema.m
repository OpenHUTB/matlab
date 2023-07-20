function schema















    mlock;

    pk=findpackage('hdlcoderprops');
    c=schema.class(pk,'CLI',pk.findclass('AbstractProp'));

    definetypes;


    p=schema.prop(c,'HDLSubsystem','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'Workflow','ustring');
    set(p,'FactoryValue','Generic ASIC/FPGA');

    p=schema.prop(c,'TargetPlatform','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'ReferenceDesign','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'ReferenceDesignPath','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'CoeffPrefix','nestring');
    set(p,'FactoryValue','coeff');

    p=schema.prop(c,'CoeffName','mxArray');
    set(p,'SetFunction',{@set_phantom,'CoeffPrefix'},...
    'GetFunction',{@get_phantom,'CoeffPrefix'},...
    'AccessFlags.Init','Off',...
    'Visible','Off');


    schema.prop(c,'InputType','HDLInputTypes');
    schema.prop(c,'OutputType','HDLOutputTypes');

    p=schema.prop(c,'ScalarizePorts','ScalarizePortsOption');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'ScalarizedPortIndexing','ScalarizedPortIndexingOption');
    set(p,'FactoryValue','Zero-based');

    p=schema.prop(c,'SamplesPerCycle','double');
    set(p,'FactoryValue',1);

    p=schema.prop(c,'InputFIFOSize','double');
    set(p,'FactoryValue',10,'SetFunction',@set_inputfifosize);
    p=schema.prop(c,'OutputFIFOSize','double');
    set(p,'FactoryValue',10,'SetFunction',@set_outputfifosize);

    p=schema.prop(c,'LargeDelayMemory','on/off');
    set(p,'FactoryValue','off');
    p=schema.prop(c,'DelaySizeThreshold','double');
    set(p,'FactoryValue',1024,'SetFunction',@set_delaysizethreshold);

    schema.prop(c,'CoeffMultipliers','HDLMultipliersType');
    schema.prop(c,'ResetType','HDLResetTypes');

    schema.prop(c,'FIRAdderStyle','HDLFinalAddersType');

    p=schema.prop(c,'MultiplierInputPipeline','mxArray');
    set(p,'FactoryValue',0,'SetFunction',@set_editboxInteger);

    p=schema.prop(c,'MultiplierOutputPipeline','mxArray');
    set(p,'FactoryValue',0,'SetFunction',@set_editboxInteger);

    p=schema.prop(c,'FoldingFactor','double');
    set(p,'FactoryValue',1,'SetFunction',@set_foldingfactor);

    p=schema.prop(c,'NumMultipliers','double');
    set(p,'FactoryValue',-1,'SetFunction',@set_nummultipliers);

    schema.prop(c,'OptimizeForHDL','on/off');

    p=schema.prop(c,'TimingControllerPostfix','ustring');
    set(p,'FactoryValue','_tc');
    p=schema.prop(c,'OptimizeTimingController','on/off');
    set(p,'FactoryValue','on');
    p=schema.prop(c,'TimingControllerArch','TCArchType');
    set(p,'FactoryValue','default');

    p=schema.prop(c,'CastBeforeSum','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'TCCounterLimitCompOp','ustring');
    set(p,'FactoryValue','>=','SetFunction',@check_tcCounterCompOp);

    schema.prop(c,'CheckHDL','on/off');

    p=schema.prop(c,'EnablePrefix','nestring');
    set(p,'FactoryValue','enb');

    p=schema.prop(c,'ClockEnableInputPort','nestring');
    set(p,'FactoryValue','clk_enable');

    p=schema.prop(c,'ClockEnableOutputPort','nestring');
    set(p,'FactoryValue','ce_out');

    p=schema.prop(c,'ClockInputPort','nestring');
    set(p,'FactoryValue','clk');

    p=schema.prop(c,'ClockEdge','ClockEdgeType');
    set(p,'FactoryValue','Rising');

    p=schema.prop(c,'ResetInputPort','nestring');
    set(p,'FactoryValue','reset');

    schema.prop(c,'SimulatorFlags','ustring');

    p=schema.prop(c,'HDLCompileFilePostfix','ustring');
    set(p,'FactoryValue','_compile.do');

    p=schema.prop(c,'HDLCompilePostfix','mxArray');
    set(p,'SetFunction',{@set_phantom,'HDLCompileFilePostfix'},...
    'GetFunction',{@get_phantom,'HDLCompileFilePostfix'},...
    'AccessFlags.Init','Off',...
    'Visible','Off');

    p=schema.prop(c,'HDLCompileInit','ustring');
    set(p,'FactoryValue','vlib %s\n');

    schema.prop(c,'HDLCompileTerm','ustring');

    p=schema.prop(c,'HDLCompileVerilogCmd','ustring');
    set(p,'FactoryValue','vlog %s %s\n');

    p=schema.prop(c,'HDLCompileVHDLCmd','ustring');
    set(p,'FactoryValue','vcom %s %s\n');

    p=schema.prop(c,'EnableForGenerateLoops','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'HDLMapFilePostfix','ustring');
    set(p,'FactoryValue','_map.txt');

    p=schema.prop(c,'HDLMapPostfix','mxArray');
    set(p,'SetFunction',{@set_phantom,'HDLMapFilePostfix'},...
    'GetFunction',{@get_phantom,'HDLMapFilePostfix'},...
    'AccessFlags.Init','Off',...
    'Visible','Off');

    schema.prop(c,'HDLMapSeparator','ustring');

    p=schema.prop(c,'HDLSimCmd','ustring');
    set(p,'FactoryValue','vsim -voptargs=+acc %s.%s\n');

    p=schema.prop(c,'HDLSimFilePostfix','ustring');
    set(p,'FactoryValue','_sim.do');

    p=schema.prop(c,'HDLSimPostfix','mxArray');
    set(p,'SetFunction',{@set_phantom,'HDLSimFilePostfix'},...
    'GetFunction',{@get_phantom,'HDLSimFilePostfix'},...
    'AccessFlags.Init','Off',...
    'Visible','Off');

    p=schema.prop(c,'HDLSimProjectFilePostfix','ustring');
    set(p,'FactoryValue','_init.do');

    p=schema.prop(c,'HDLSimProjectPostfix','mxArray');
    set(p,'SetFunction',{@set_phantom,'HDLSimProjectFilePostfix'},...
    'GetFunction',{@get_phantom,'HDLSimProjectFilePostfix'},...
    'AccessFlags.Init','Off',...
    'Visible','Off');

    p=schema.prop(c,'HDLSimInit','ustring');
    set(p,'FactoryValue','onbreak resume\nonerror resume\n');

    p=schema.prop(c,'HDLSimProjectCmd','ustring');
    set(p,'FactoryValue','project addfile %s\n');

    p=schema.prop(c,'HDLSimProjectTerm','ustring');
    set(p,'FactoryValue','project compileall\n');

    p=schema.prop(c,'HDLSimProjectInit','ustring');
    set(p,'FactoryValue','project new . %s work\n');

    p=schema.prop(c,'HDLSimTerm','ustring');
    set(p,'FactoryValue','run -all\n');

    p=schema.prop(c,'HDLSimViewWaveCmd','ustring');
    set(p,'FactoryValue','add wave sim:%s\n');

    p=schema.prop(c,'HDLSynthTool','SynthesisToolType');
    set(p,'FactoryValue','None');

    p=schema.prop(c,'HDLSynthCmd','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'HDLSynthFilePostfix','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'HDLSynthInit','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'HDLSynthLibCmd','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'HDLSynthLibSpec','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'HDLSynthTerm','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'ReservedWordPostfix','nestring');
    set(p,'FactoryValue','_rsvd');

    p=schema.prop(c,'BlockGenerateLabel','ustring');
    set(p,'FactoryValue','_gen');

    p=schema.prop(c,'VHDLLibraryName','ustring');
    set(p,'FactoryValue','work');

    p=schema.prop(c,'UseSingleLibrary','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'VHDLArchitectureName','ustring');
    set(p,'FactoryValue','rtl');

    p=schema.prop(c,'ClockProcessPostfix','ustring');
    set(p,'FactoryValue','_process');

    p=schema.prop(c,'ComplexImagPostfix','nestring');
    set(p,'FactoryValue','_im');

    p=schema.prop(c,'ComplexRealPostfix','nestring');
    set(p,'FactoryValue','_re');

    p=schema.prop(c,'EntityConflictPostfix','nestring');
    set(p,'FactoryValue','_block');

    p=schema.prop(c,'InstancePrefix','nestring');
    set(p,'FactoryValue','u_');

    p=schema.prop(c,'InstancePostfix','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'InstanceGenerateLabel','ustring');
    set(p,'FactoryValue','_gen');

    p=schema.prop(c,'OutputGenerateLabel','ustring');
    set(p,'FactoryValue','outputgen');

    p=schema.prop(c,'PackagePostfix','nestring');
    set(p,'FactoryValue','_pkg');

    p=schema.prop(c,'SplitEntityArch','on/off');
    set(p,'SetFunction',@set_splitentityarch,'GetFunction',@get_splitentityarch);

    p=schema.prop(c,'SplitMooreChartStateUpdate','on/off');
    set(p,'FactoryValue','on');

    schema.prop(c,'SplitArchFilePostfix','ustring');

    p=schema.prop(c,'SplitEntityFilePostfix','ustring');
    set(p,'FactoryValue','_entity','SetFunction',@set_SplitEntityFilePostfix);

    p=schema.prop(c,'SplitArchFilePostfix','ustring');
    set(p,'FactoryValue','_arch','SetFunction',@set_SplitArchFilePostfix);

    p=schema.prop(c,'VectorPrefix','nestring');
    set(p,'FactoryValue','vector_of_');

    p=schema.prop(c,'ClockInputs','HDLClockInputsType');
    set(p,'SetFunction',@set_clockmode,'FactoryValue','Single');

    p=schema.prop(c,'TriggerAsClock','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'AsyncResetPort','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'ConditionalizePipeline','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'InferControlPorts','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'UseRisingEdge','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'TargetDirectory','nestring');
    set(p,'FactoryValue','hdlsrc');

    p=schema.prop(c,'TargetSubdirectory','HDLSubdirType');
    set(p,'FactoryValue','Model');

    p=schema.prop(c,'EDAScriptGeneration','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'AddInputRegister','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'AddOutputRegister','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'AddPipelineRegisters','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'PipelinePostfix','nestring');
    set(p,'FactoryValue','_pipe');

    p=schema.prop(c,'InputPort','nestring');
    set(p,'FactoryValue','filter_in');

    p=schema.prop(c,'OutputPort','nestring');
    set(p,'FactoryValue','filter_out');

    p=schema.prop(c,'FracDelayPort','nestring');
    set(p,'FactoryValue','filter_fd');

    p=schema.prop(c,'Name','nestring');
    set(p,'FactoryValue','filter');

    p=schema.prop(c,'RemoveResetFrom','FilterResetTypeEnum');
    set(p,'FactoryValue','None');

    p=schema.prop(c,'ResetAssertedLevel','HDLActiveLevels');
    set(p,'FactoryValue','active-high');

    p=schema.prop(c,'ResetValue','mxArray');
    set(p,'SetFunction',{@set_phantom,'ResetAssertedLevel'},...
    'GetFunction',{@get_phantom,'ResetAssertedLevel'},...
    'AccessFlags.Init','Off',...
    'Visible','Off');

    p=schema.prop(c,'ReuseAccum','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'ScaleWarnBits','int32');
    set(p,'FactoryValue',3);

    p=schema.prop(c,'SerialPartition','mxArray');
    set(p,'SetFunction',@set_serialparttop,'FactoryValue',-1);

    p=schema.prop(c,'DALUTPartition','mxArray');
    set(p,'SetFunction',@set_dalutparttop,'FactoryValue',-1);

    p=schema.prop(c,'DARadix','power2_scalar');
    set(p,'FactoryValue',2);

    schema.prop(c,'CoefficientSource','CoeffSourceType');

    schema.prop(c,'CoefficientMemory','RAMType');

    p=schema.prop(c,'InputComplex','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'AddRatePort','on/off');
    set(p,'FactoryValue','off');

    schema.prop(c,'InputDataType','mxArray');
    p=schema.prop(c,'FractionalDelayDataType','mxArray');
    set(p,'Visible','Off','FactoryValue',[]);


    p=schema.prop(c,'Debug','mxArray');...
    set(p,'Visible','Off','FactoryValue','off');


    p=schema.prop(c,'GenerateHDLCode','on/off');
    set(p,'FactoryValue','on');
    p=schema.prop(c,'GenerateModel','on/off');
    set(p,'FactoryValue','on');
    p=schema.prop(c,'GenerateTB','on/off');
    set(p,'FactoryValue','off');
    p=schema.prop(c,'GenerateCEGenModel','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'ObfuscateGeneratedHDLCode','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'GenerateRecordType','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'Traceability','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'RuntimeReport','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'ResourceReport','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'OptimizationReport','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'ErrorCheckReport','on/off');
    set(p,'FactoryValue','on');


    p=schema.prop(c,'HDLGenerateWebview','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'IPCoreReport','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'Recommendations','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'RequirementComments','on/off');
    set(p,'FactoryValue','on');


    p=schema.prop(c,'EnableComments','on/off');
    set(p,'FactoryValue','on');


    p=schema.prop(c,'Backannotation','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'HierarchicalDistPipelining','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'PreserveDesignDelays','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'AcquireDesignDelaysForEMLOptimizations','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'ClockRatePipelining','on/off');
    set(p,'FactoryValue','on');


    p=schema.prop(c,'CRPWithoutFlattening','on/off');
    set(p,'FactoryValue','on');


    p=schema.prop(c,'CRPDelayBalancingIterLimit','int32');
    set(p,'FactoryValue',10);


    p=schema.prop(c,'UseCRPAlternativeStrategy','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'IncreaseCRPBudget','on/off');
    set(p,'FactoryValue','on');


    p=schema.prop(c,'AdaptivePipelining','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'LUTMapToRAM','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'CloneModules','on/off');
    set(p,'FactoryValue','on');



    p=schema.prop(c,'MinDelaysRequiredAtLocalMultirateOutput','int32');
    set(p,'FactoryValue',1,'SetFunction',@set_MinDelaysRequiredAtLocalMultirateOutput);



    p=schema.prop(c,'ClockRatePipelineOutputPorts','on/off');
    set(p,'FactoryValue','off');



    p=schema.prop(c,'BalanceClockRateOutputPorts','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'CriticalPathEstimation','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'TimingDatabaseDirectory','ustring');
    set(p,'FactoryValue','');


    p=schema.prop(c,'StaticLatencyPathAnalysis','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'optimizeserializer','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'shareequalwl','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'sharedmulsign','SharedMulSignEnum');
    set(p,'FactoryValue','Signed');

    p=schema.prop(c,'MultiplierPromotionThreshold','int32');
    set(p,'FactoryValue',0,'SetFunction',@set_sharediffWLthreshold);

    p=schema.prop(c,'RoutingFudgeFactor','double');
    set(p,'FactoryValue',0.5);


    p=schema.prop(c,'OptimizationCompatibilityCheck','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'NumCriticalPathsEstimated','double');
    set(p,'FactoryValue',1,'SetFunction',@set_numestimatedcriticalpaths);

    p=schema.prop(c,'CriticalPathEstimationFile','nestring');
    set(p,'FactoryValue','criticalPathEstimated');

    p=schema.prop(c,'SLPAFile','nestring');
    set(p,'FactoryValue','staticLatPathAnalysis');

    p=schema.prop(c,'SLPALoopsFile','nestring');
    set(p,'FactoryValue','staticLatLoops');

    p=schema.prop(c,'SLPABackEdgeFile','nestring');
    set(p,'FactoryValue','staticLatLoopBackEdge');

    p=schema.prop(c,'SLPAGMMapMATFile','nestring');
    set(p,'FactoryValue','staticLatGMMap');

    p=schema.prop(c,'HardwarePipeliningCharacterizationFile','ustring');
    set(p,'FactoryValue','');


    p=schema.prop(c,'HighlightFeedbackLoops','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'HighlightFeedbackLoopsFile','nestring');
    set(p,'FactoryValue','highlightFeedbackLoop');

    p=schema.prop(c,'HighlightClockRatePipeliningDiagnostic','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'HighlightClockRatePipeliningFile','nestring');
    set(p,'FactoryValue','highlightClockRatePipelining');

    p=schema.prop(c,'HighlightRemovedDeadBlocks','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'DistributedPipeliningBarriers','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'DistributedPipeliningBarriersFile','nestring');
    set(p,'FactoryValue','highlightDistributedPipeliningBarriers');

    p=schema.prop(c,'HighlightLUTPipeliningDiagnostic','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'HighlightLUTPipeliningDiagnosticFile','nestring');
    set(p,'FactoryValue','highlightLUTPipeliningDiagnostic');

    p=schema.prop(c,'SetLUTPipeliningOffScriptFile','nestring');
    set(p,'FactoryValue','setLUTPipelineOffScript');

    p=schema.prop(c,'BlocksWithNoCharacterizationFile','nestring');
    set(p,'FactoryValue','highlightCriticalPathEstimationOffendingBlocks');


    p=schema.prop(c,'AXIStreamingTransformFeatureControl','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'AXIInterface512BitDataPortFeatureControl','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'SerializerRatioThreshold','int32');
    set(p,'FactoryValue',8192,'SetFunction',@set_SerializerRatioThreshold);

    p=schema.prop(c,'RetimingCP','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'RetimingCPFile','nestring');
    set(p,'FactoryValue','highlightRetimingCP');

    p=schema.prop(c,'ClearHighlightingFile','nestring');
    set(p,'FactoryValue','clearhighlighting');


    p=schema.prop(c,'FunctionallyEquivalentRetiming','on/off');
    set(p,'FactoryValue','on');


    p=schema.prop(c,'DistributedPipeliningPrecision','int32');
    set(p,'FactoryValue',-1);


    p=schema.prop(c,'DistributedPipelining','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'UseSynthesisEstimatesForDistributedPipelining','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'DistributedPipeliningPriority','DPPriorityType');
    set(p,'FactoryValue','Numerical Integrity');


    p=schema.prop(c,'RetimingDetails','on/off');
    set(p,'FactoryValue','on');



    p=schema.prop(c,'CriticalPathDetails','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'SignalNamesMangling','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'GuidedRetiming','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'LatencyConstraint','double');
    set(p,'FactoryValue',0,'SetFunction',@set_latencyconstraint);


    p=schema.prop(c,'ReduceMatchingDelays','on/off');
    set(p,'FactoryValue','on');


    p=schema.prop(c,'OptimizationData','ustring');
    set(p,'FactoryValue','');


    p=schema.prop(c,'CPGuidanceFile','ustring');
    set(p,'FactoryValue','');


    p=schema.prop(c,'CPAnnotationFile','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'OptimizeMdlGen','on/off');
    set(p,'FactoryValue','on');



    p=schema.prop(c,'MulticyclePathInfo','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'MulticyclePathConstraints','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'FloatingPointTargetConfiguration','mxArray');
    set(p,'SetFunction',@set_floatingpointtargetconfiguration,'FactoryValue',[]);

    p=schema.prop(c,'GenerateTargetComps','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'NativeFloatingPoint','NfpMode');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'FPToleranceValue','double');
    set(p,'FactoryValue',1.0e-7);

    p=schema.prop(c,'FPToleranceStrategy','FPTolStrategyEnum');
    set(p,'FactoryValue','DEFAULT');

    p=schema.prop(c,'nfpLatency','ustring');
    set(p,'FactoryValue','DEFAULT','SetFunction',@check_nfpLatency);

    p=schema.prop(c,'nfpDenormals','DenormalMode');
    set(p,'FactoryValue','DEFAULT');

    p=schema.prop(c,'sschdlMatrixProductSumCustomLatency','int32');
    set(p,'FactoryValue',-1,'SetFunction',@set_sschdlcustomlatency);

    p=schema.prop(c,'AlteraBackwardIncompatibleSinCosPipeline','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'FamilyDevicePackageSpeed','mxArray');
    set(p,'FactoryValue',{});

    p=schema.prop(c,'ToolName','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'SynthesisToolChipFamily','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'SynthesisToolDeviceName','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'SynthesisToolPackageName','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'SynthesisToolSpeedValue','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'SynthesisTool','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'SynthesisProjectAdditionalFiles','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'SimulationLibPath','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'XilinxSimulatorLibPath','ustring');
    set(p,'FactoryValue','');


    p=schema.prop(c,'AdderSharingMinimumBitwidth','int32');
    set(p,'FactoryValue',0,'SetFunction',@set_adderSharingMinimumBitwidth);

    p=schema.prop(c,'MultiplierSharingMinimumBitwidth','int32');
    set(p,'FactoryValue',0,'SetFunction',@set_multiplierSharingMinimumBitwidth);

    p=schema.prop(c,'MultiplyAddSharingMinimumBitwidth','int32');
    set(p,'FactoryValue',0,'SetFunction',@set_macSharingMinimumBitwidth);


    p=schema.prop(c,'ShareAdders','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'ShareMultipliers','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'ShareMultiplyAdds','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'ShareMATLABBlocks','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'ShareAtomicSubsystems','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'ShareCounterSerDes','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'ShareFloatingPointIPs','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'PipelinedSharing','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'OptimizeCRPSharingRegisters','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'ClockRatePipeliningBudgetCheck','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'EnableFPGAWorkflow','on/off');
    set(p,'FactoryValue','off');

    schema.prop(c,'FPGAWorkflowParameters','mxArray');

    schema.prop(c,'GainMultipliers','HDLMultipliersType');
    schema.prop(c,'ProductOfElementsStyle','HDLFinalAddersType');

    schema.prop(c,'UserComment','ustring');

    schema.prop(c,'CustomFileHeaderComment','ustring');
    schema.prop(c,'CustomFileFooterComment','ustring');



    p=schema.prop(c,'DateComment','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'SafeZeroConcat','on/off');
    set(p,'FactoryValue','on');

    schema.prop(c,'SumOfElementsStyle','HDLFinalAddersType');
    schema.prop(c,'TargetLanguage','HDLTargetLanguageType');

    p=schema.prop(c,'Oversampling','double');
    set(p,'SetFunction',@set_oversampling,'FactoryValue',1);

    p=schema.prop(c,'ClockRatePipeliningFraction','double');
    set(p,'SetFunction',@set_clockratepipeliningfraction,'FactoryValue',1);

    p=schema.prop(c,'Verbosity','HDLEditboxType');
    set(p,'FactoryValue',1);

    p=schema.prop(c,'TestBenchName','nestring');
    set(p,'FactoryValue','filter_tb');

    p=schema.prop(c,'MultifileTestBench','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'IgnoreDataChecking','mxArray');
    set(p,'FactoryValue',0,'SetFunction',@set_editboxInteger);

    p=schema.prop(c,'TestBenchPostfix','nestring');
    set(p,'FactoryValue','_tb');

    p=schema.prop(c,'TestBenchDataPostfix','nestring');
    set(p,'FactoryValue','_data');

    p=schema.prop(c,'TestBenchStimulus','mxArray');
    set(p,'SetFunction',@set_testbenchstimulus)

    p=schema.prop(c,'TestBenchUserStimulus','HDLEditboxType');
    set(p,'FactoryValue',[]);

    p=schema.prop(c,'TestBenchFracDelayStimulus','mxArray');
    set(p,'SetFunction',@set_testbenchfracdelaystimulus);

    p=schema.prop(c,'TestBenchCoeffStimulus','mxArray');
    set(p,'SetFunction',@set_testbenchcoeffstimulus);

    p=schema.prop(c,'TestBenchRateStimulus','mxArray');
    set(p,'SetFunction',@set_testbenchratestimulus);

    p=schema.prop(c,'ForceClockEnable','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'ClockEnableValue','HDLActiveLevels');
    set(p,'SetFunction',@set_clockenablevalue,...
    'GetFunction',@get_clockenablevalue,...
    'AccessFlags.Init','Off',...
    'Visible','Off');

    p=schema.prop(c,'MinimizeClockEnables','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'MinimizeGlobalResets','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'NoResetInitializationMode','NoResetInitType');
    set(p,'FactoryValue','InsideModule');

    p=schema.prop(c,'NoResetInitScript','ustring');
    set(p,'FactoryValue','noresetinitscript.tcl');

    p=schema.prop(c,'ComplexMulElaboration','ustring');
    set(p,'FactoryValue','MultiplyAddBlock');

    p=schema.prop(c,'FlattenBus','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'TestBenchClockEnableDelay','mxArray');
    set(p,'FactoryValue',1,'SetFunction',@set_editboxInteger);

    p=schema.prop(c,'ForceClock','on/off');
    set(p,'FactoryValue','on');




    p=schema.prop(c,'ClockHighTime','double');
    set(p,'FactoryValue',5,'SetFunction',@set_clockHighTime);

    p=schema.prop(c,'ClockLowTime','double');
    set(p,'FactoryValue',5,'SetFunction',@set_clockLowTime);

    p=schema.prop(c,'HoldTime','double');
    set(p,'FactoryValue',2,'SetFunction',@set_clockHoldTime);

    p=schema.prop(c,'SetupTime','mxArray');
    set(p,'GetFunction',@get_clockSetupTime,'SetFunction',@set_clockSetupTime,...
    'AccessFlags.Init','Off',...
    'Visible','Off');

    p=schema.prop(c,'InputDataInterval','double');
    set(p,'FactoryValue',0);

    p=schema.prop(c,'FilterSystemObject','mxArray');
    set(p,'Visible','Off','FactoryValue',[]);



    p=schema.prop(c,'ForceReset','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'ErrorMargin','HDLEditboxType');
    set(p,'FactoryValue',4);

    p=schema.prop(c,'HoldInputDataBetweenSamples','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'InitializeTestBenchInputs','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'ResetLength','mxArray');
    set(p,'FactoryValue',2,'SetFunction',@set_editboxInteger);

    p=schema.prop(c,'TestBenchReferencePostFix','ustring');
    set(p,'FactoryValue','_ref');



    p=schema.prop(c,'GenerateValidationModel','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'RAMMappingThreshold','double');
    set(p,'SetFunction',@set_ramthreshold,'FactoryValue',256);

    p=schema.prop(c,'IOThreshold','double');
    set(p,'SetFunction',@set_iothreshold,'FactoryValue',5000);

    p=schema.prop(c,'MapPipelineDelaysToRAM','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'RemoveRedundantCounters','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'ReplaceUnitDelayWithIntegerDelay','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'ConcatenateDelays','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'MergeDelaysOnFanouts','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'FoldDelaysToConstant','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'RAMArchitecture','RAMArch');
    set(p,'FactoryValue','WithClockEnable');

    p=schema.prop(c,'RAMStyleAttributeName','ustring');
    set(p,'FactoryValue','');


    p=schema.prop(c,'UseMatrixTypesInEML','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'InlineMATLABBlockCode','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'SubsystemReuse','SubsystemReuseOption');
    set(p,'FactoryValue','Atomic only');

    p=schema.prop(c,'InlineHDLCode','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'MaskParameterAsGeneric','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'InlineSubsystems','on/off');
    set(p,'FactoryValue','on')

    p=schema.prop(c,'StringTypeSupport','on/off');
    set(p,'FactoryValue','off')

    p=schema.prop(c,'DeleteUnusedBlocks','on/off');
    set(p,'FactoryValue','on')

    p=schema.prop(c,'DeleteUnusedBlocksUnderMask','on/off');
    set(p,'FactoryValue','off')

    p=schema.prop(c,'DeleteUnusedPorts','on/off');
    set(p,'FactoryValue','on')

    p=schema.prop(c,'BalanceDelays','on/off');
    set(p,'FactoryValue','on')

    p=schema.prop(c,'BalanceDelaysControlsFeedbackLoops','on/off');
    set(p,'FactoryValue','on')


    p=schema.prop(c,'DelayAbsorption','on/off');
    set(p,'FactoryValue','on')

    p=schema.prop(c,'TargetFrequency','double');
    set(p,'SetFunction',@set_targetfrequency,'FactoryValue',0);

    p=schema.prop(c,'ExtraEffortMargin','double');
    set(p,'SetFunction',@set_extraeffortmargin,'FactoryValue',1);

    p=schema.prop(c,'MaxOversampling','double');
    set(p,'SetFunction',@set_maxoversampling,'FactoryValue',inf);

    p=schema.prop(c,'MaxComputationLatency','double');
    set(p,'SetFunction',@set_maxcomputationlatency,'FactoryValue',1);

    p=schema.prop(c,'MultiplierPartitioningThreshold','double');
    set(p,'SetFunction',@set_multiplierpartitioningthreshold,'FactoryValue',inf);

    p=schema.prop(c,'TreatDelayBalancingFailureAs','ustring');
    set(p,'FactoryValue','Error');

    p=schema.prop(c,'TransformDelaysWithControlLogic','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'TransformNonZeroInitValDelay','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'DelayElaborationLimit','int32');
    set(p,'FactoryValue',20,'SetFunction',@set_delayelablimit);

    p=schema.prop(c,'GenerateCoSimBlock','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'HDLCodeCoverage','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'GenerateHDLTestBench','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'GenerateCoSimModel','CosimModelTypes');
    set(p,'FactoryValue','None');

    p=schema.prop(c,'GenerateSVDPITestBench','SVDPITBTypes');
    set(p,'FactoryValue','None');

    p=schema.prop(c,'SimulationTool','SimulationToolType');
    set(p,'FactoryValue','Mentor Graphics ModelSim');

    p=schema.prop(c,'CoSimModelSetup','CosimModelSetupTypes');
    set(p,'FactoryValue','CosimBlockAndDut');

    p=schema.prop(c,'SynthesisOnDirective','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'SynthesisOffDirective','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'LoopUnrolling','on/off');
    set(p,'SetFunction',@set_loopunrolling,'GetFunction',@get_loopunrolling);

    p=schema.prop(c,'InlineConfigurations','on/off');
    set(p,'FactoryValue','on');

    schema.prop(c,'UseAggregatesForConst','on/off');

    p=schema.prop(c,'UseVerilogTimescale','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'Timescale','ustring');
    set(p,'FactoryValue','`timescale 1 ns / 1 ns');

    p=schema.prop(c,'VerilogFileExtension','ustring');
    set(p,'FactoryValue','.v');

    p=schema.prop(c,'SystemVerilogFileExtension','ustring');
    set(p,'FactoryValue','.sv');

    p=schema.prop(c,'VHDLFileExtension','ustring');
    set(p,'FactoryValue','.vhd');





    p=schema.prop(c,'CodeGenerationOutput','CodeGenerationOutputType');
    set(p,'FactoryValue','GenerateHDLCode');

    p=schema.prop(c,'GeneratedModelName','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'GeneratedModelNamePrefix','ustring');
    set(p,'SetFunction',@set_gmPrefix,'FactoryValue','gm_');

    p=schema.prop(c,'ValidationModelNameSuffix','ustring');
    set(p,'SetFunction',@set_vnlSuffix,'FactoryValue','_vnl');


    p=schema.prop(c,'LayoutStyle','ModelLayoutStyle');
    set(p,'FactoryValue','Default');


    p=schema.prop(c,'UseDotLayout','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'ShowCodeGenPIR','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'SerializeModel','double');
    set(p,'FactoryValue',0);

    p=schema.prop(c,'SerializeIO','double');
    set(p,'SetFunction',@set_serialio,'FactoryValue',0);


    p=schema.prop(c,'AutoRoute','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'AutoPlace','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'InterBlkHorzScale','double');
    set(p,'SetFunction',@set_BlkToBlkHVScale,'FactoryValue',1.7);

    p=schema.prop(c,'InterBlkVertScale','double');
    set(p,'SetFunction',@set_BlkToBlkHVScale,'FactoryValue',1.2);

    p=schema.prop(c,'CustomDotPath','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'HighlightAncestors','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'HighlightColor','ustring');
    set(p,'FactoryValue','cyan');

    p=schema.prop(c,'InitializeBlockRAM','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'InitializeRealPort','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'MapVectorPortToStream','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'UseFileIOInTestBench','on/off');
    set(p,'FactoryValue','on');



    p=schema.prop(c,'TurnkeyWorkflow','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'AlteraWorkflow','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'GenerateFILBlock','on/off');
    set(p,'FactoryValue','off');





    p=schema.prop(c,'CoSimLibPostfix','nestring');
    set(p,'FactoryValue','_cosim');

    schema.prop(c,'TestBenchInitializeInputs','on/off');

    p=schema.prop(c,'MinimizeIntermediateSignals','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'GenerateCodeInfo','on/off');
    set(p,'FactoryValue','off');




    p=schema.prop(c,'GatewayoutWithDTC','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'IncrementalCodeGenForTopModel','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'HDLWFSmartbuild','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'HDLCodingStandard','HDLCodingStandardType');
    set(p,'FactoryValue','None');

    p=schema.prop(c,'HDLCodingStandardCustomizations','mxArray');
    set(p,'FactoryValue',[]);

    p=schema.prop(c,'ReferenceDesignParameter','mxArray');
    set(p,'SetFunction',@set_referencedesignparameter,'FactoryValue',{});


    p=schema.prop(c,'HDLLintTool','HDLLintToolType');
    set(p,'FactoryValue','None');

    p=schema.prop(c,'HDLLintInit','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'HDLLintTerm','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'HDLLintCmd','ustring');
    set(p,'FactoryValue','');


    p=schema.prop(c,'ModulePrefix','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'DetectBlackBoxNameCollision','DetectBlackBoxNameCollisionType');
    set(p,'FactoryValue','Warning');


    p=schema.prop(c,'PIRTC','on/off');
    set(p,'FactoryValue','on');


    p=schema.prop(c,'UsePipelinedToolboxFunctions','on/off');
    set(p,'FactoryValue','on');


    p=schema.prop(c,'savepirtoscript','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'ConcatenateHDLModules','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'ML2PIR','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'OptimBetweenMATLABAndSimulink','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'EnableTestpoints','on/off');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'BalanceDelaysForTestpoints','on/off');
    set(p,'FactoryValue','on');


    p=schema.prop(c,'GenDUTPortForTunableParam','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'BalanceDelaysForTunableParam','on/off');
    set(p,'FactoryValue','on');


    p=schema.prop(c,'TraceabilityStyle','HDLTraceabilityStyle');
    set(p,'FactoryValue','Line Level');



    p=schema.prop(c,'TraceabilityProcessing','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'TreatRealsInGeneratedCodeAs','TreatRealsInGeneratedCodeAsType');
    set(p,'FactoryValue','Error');


    p=schema.prop(c,'TreatBalanceDelaysOffAs','TreatBalanceDelaysOffAsType');
    set(p,'FactoryValue','Error');


    p=schema.prop(c,'EnumEncodingScheme','EnumEncodingSchemeType');
    set(p,'FactoryValue','default');


    p=schema.prop(c,'CompileStrategy','EnumCompileStrategy');
    set(p,'FactoryValue','CompileAll');


    p=schema.prop(c,'BuildToProtectModel','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'OptimizeConstants','on/off');
    set(p,'FactoryValue','on');


    p=schema.prop(c,'OptimizeFixedPointConstants','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'FrameToSampleConversion','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'HDLDTO','HDLDTOType');
    set(p,'FactoryValue','off');

    p=schema.prop(c,'UseArrangeSystem','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'TriggerAsClockWithoutSyncRegisters','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'CompactSwitch','on/off');
    set(p,'FactoryValue','off');


    p=schema.prop(c,'SimIndexCheck','on/off');
    set(p,'FactoryValue','off');



    function lu=set_loopunrolling(this,lu)




        if strcmpi(this.TargetLanguage,'verilog')&&strcmpi(lu,'off')&&...
            (isempty(this.up)||strcmp(this.up.IsDialogCache,'off'))





            warnObj=message('HDLShared:CLI:invalidLoopUnrolling');
            slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',warnObj,'log to terminal if required');
            lu='on';
        end


        function lu=get_loopunrolling(this,lu)

            if strcmpi(this.TargetLanguage,'verilog')
                lu='on';
            end


            function sea=set_splitentityarch(this,sea)




                if strcmpi(this.TargetLanguage,'verilog')&&strcmpi(sea,'on')
                    warning(message('HDLShared:CLI:invalidSetting'));
                    sea='off';
                end


                function sea=get_splitentityarch(this,sea)

                    if strcmpi(this.TargetLanguage,'verilog')
                        sea='off';
                    end


                    function cev=set_clockenablevalue(this,cev)%#ok

                        warning(message('HDLShared:CLI:clockenablenotsettable'));


                        function cev=get_clockenablevalue(~,~)

                            cev='Active-high';


                            function value=set_serialio(~,value)
                                if isnumeric(value)&&~isempty(value)&&isscalar(value)

                                    if~((floor(value)==value)&&value>=-1)
                                        error(message('HDLShared:CLI:illegalparametervalue',sprintf('%g',value),'SerializeIO'));
                                    end

                                else
                                    error(message('HDLShared:CLI:missingparametervalue','SerializeIO'));
                                end


                                function value=set_inputfifosize(~,value)
                                    if isnumeric(value)&&~isempty(value)&&isscalar(value)

                                        if~((floor(value)==value)&&value>=0)
                                            error(message('HDLShared:CLI:illegalparametervalue',value,'InputFIFOSize'));
                                        end

                                    else
                                        error(message('HDLShared:CLI:missingparametervalue','InputFIFOSize'));
                                    end


                                    function value=set_outputfifosize(~,value)
                                        if isnumeric(value)&&~isempty(value)&&isscalar(value)

                                            if~((floor(value)==value)&&value>=0)
                                                error(message('HDLShared:CLI:illegalparametervalue',value,'OutputFIFOSize'));
                                            end

                                        else
                                            error(message('HDLShared:CLI:missingparametervalue','OutputFIFOSize'));
                                        end


                                        function value=set_delaysizethreshold(~,value)
                                            if isnumeric(value)&&~isempty(value)&&isscalar(value)

                                                if~((floor(value)==value)&&value>=0)
                                                    error(message('HDLShared:CLI:illegalparametervalue',value,'DelaySizeThreshold'));
                                                end

                                            else
                                                error(message('HDLShared:CLI:missingparametervalue','DelaySizeThreshold'));
                                            end


                                            function value=set_ramthreshold(~,value)
                                                if isnumeric(value)&&~isempty(value)&&isscalar(value)

                                                    if~((floor(value)==value)&&value>=0)
                                                        error(message('HDLShared:CLI:illegalparametervalue',value,'RAMMappingThreshold'));
                                                    end

                                                else
                                                    error(message('HDLShared:CLI:missingparametervalue','RAMMappingThreshold'));
                                                end


                                                function value=set_iothreshold(~,value)
                                                    if isnumeric(value)&&~isempty(value)&&isscalar(value)

                                                        if~((floor(value)==value)&&value>=0)
                                                            error(message('HDLShared:CLI:illegalparametervalue',value,'IOThreshold'));
                                                        end

                                                    else
                                                        error(message('HDLShared:CLI:missingparametervalue','IOThreshold'));
                                                    end


                                                    function value=set_latencyconstraint(~,value)
                                                        if~(isnumeric(value)&&~isempty(value)&&isscalar(value))
                                                            error(message('HDLShared:CLI:missingparametervalue','LatencyConstraint'));
                                                        end


                                                        function value=set_maxcomputationlatency(~,value)
                                                            if isnumeric(value)&&~isempty(value)&&isscalar(value)

                                                                if isinf(value)
                                                                    error(message('HDLShared:CLI:illegalparametervalueInf','MaxComputationLatency'));
                                                                elseif~((floor(value)==value)&&value>0)
                                                                    error(message('HDLShared:CLI:illegalparametervalue',value,'MaxComputationLatency'));
                                                                end

                                                            else
                                                                error(message('HDLShared:CLI:missingparametervalue','MaxComputationLatency'));
                                                            end


                                                            function value=set_numestimatedcriticalpaths(~,value)
                                                                if isnumeric(value)&&~isempty(value)&&isscalar(value)

                                                                    if~((floor(value)==value)&&value>=0)
                                                                        error(message('HDLShared:CLI:illegalparametervalue',value,'NumEstimatedCriticalPaths'));
                                                                    end

                                                                else
                                                                    error(message('HDLShared:CLI:missingparametervalue','NumEstimatedCriticalPaths'));
                                                                end


                                                                function value=set_delayelablimit(~,value)
                                                                    if isnumeric(value)&&~isempty(value)&&isscalar(value)

                                                                        if~((floor(value)==value)&&value>=0)
                                                                            error(message('HDLShared:CLI:illegalparametervalue',value,'DelayElaborationLimit'));
                                                                        end

                                                                    else
                                                                        error(message('HDLShared:CLI:missingparametervalue','NumEstimatedCriticalPaths'));
                                                                    end


                                                                    function value=set_maxoversampling(~,value)
                                                                        if isnumeric(value)&&~isempty(value)&&isscalar(value)

                                                                            if~((floor(value)==value)&&value>=0)
                                                                                error(message('HDLShared:CLI:illegalparametervalue',value,'MaxOversampling'));
                                                                            end

                                                                        else
                                                                            error(message('HDLShared:CLI:missingparametervalue','MaxOversampling'));
                                                                        end


                                                                        function gmPrefix=set_gmPrefix(this,gmPrefix)
                                                                            hdlSubsystem=this.HDLSubsystem;
                                                                            mdlName=extractBefore(hdlSubsystem,'/');
                                                                            if isempty(mdlName)
                                                                                mdlName=hdlSubsystem;
                                                                            end
                                                                            if~isempty(gmPrefix)
                                                                                if isempty(mdlName)
                                                                                    mdlName='';
                                                                                end
                                                                                if iscell(mdlName)
                                                                                    mdlName=mdlName{1};
                                                                                end
                                                                                gmMdlName=[gmPrefix,mdlName];
                                                                                if length(gmMdlName)>namelengthmax
                                                                                    error(message('hdlcoder:validate:ExceedNameLengthMaxSize',gmMdlName,'generated model'));
                                                                                end
                                                                                if~isvarname(gmMdlName)
                                                                                    error(message('hdlcoder:validate:InvalidGMPrefixName'));
                                                                                end
                                                                            else
                                                                                error(message('hdlcoder:validate:InvalidGMPrefixName'));
                                                                            end


                                                                            function vnlSuffix=set_vnlSuffix(this,vnlSuffix)
                                                                                hdlSubsystem=this.HDLSubsystem;
                                                                                mdlName=extractBefore(hdlSubsystem,'/');
                                                                                if isempty(mdlName)
                                                                                    mdlName=hdlSubsystem;
                                                                                end
                                                                                if~isempty(vnlSuffix)
                                                                                    if isempty(mdlName)
                                                                                        gmPrefix='gm_';
                                                                                        mdlName='';
                                                                                    else
                                                                                        if iscell(mdlName)
                                                                                            mdlName=mdlName{1};
                                                                                        end
                                                                                        gmPrefix=hdlget_param(mdlName,'GeneratedModelNamePrefix');
                                                                                    end
                                                                                    vnlMdlName=[gmPrefix,mdlName,vnlSuffix];
                                                                                    if length(vnlMdlName)>namelengthmax
                                                                                        error(message('hdlcoder:validate:ExceedNameLengthMaxSize',vnlMdlName,'validation model'));
                                                                                    end
                                                                                    if~isvarname(vnlMdlName)
                                                                                        error(message('hdlcoder:validate:InvalidVNLSuffixName'));
                                                                                    end
                                                                                else
                                                                                    error(message('hdlcoder:validate:InvalidVNLSuffixName'));
                                                                                end


                                                                                function value=set_BlkToBlkHVScale(~,value)
                                                                                    if isfinite(value)&&~isempty(value)&&isscalar(value)

                                                                                        if value<0
                                                                                            error(message('HDLShared:CLI:invalidHVScaleValue'));
                                                                                        end

                                                                                    else
                                                                                        error(message('HDLShared:CLI:invalidHVScaleValue'));
                                                                                    end


                                                                                    function value=set_targetfrequency(~,value)
                                                                                        if isfinite(value)&&~isempty(value)&&isscalar(value)

                                                                                            if value<0
                                                                                                error(message('HDLShared:CLI:invalidTargetFrequency'));
                                                                                            end

                                                                                        else
                                                                                            error(message('HDLShared:CLI:invalidTargetFrequency'));
                                                                                        end


                                                                                        function value=set_referencedesignparameter(~,value)
                                                                                            if iscell(value)
                                                                                                if~isempty(value)
                                                                                                    for ii=1:length(value)
                                                                                                        a_value=value{ii};
                                                                                                        if~ischar(a_value)
                                                                                                            error(message('HDLShared:CLI:invalidRDParameter'));
                                                                                                        end
                                                                                                    end
                                                                                                end
                                                                                            else
                                                                                                error(message('HDLShared:CLI:invalidRDParameter'));
                                                                                            end


                                                                                            function value=set_extraeffortmargin(~,value)
                                                                                                if isnumeric(value)&&~isempty(value)&&isscalar(value)

                                                                                                    if value<0
                                                                                                        error(message('HDLShared:CLI:invalidExtraEffortMargin'));
                                                                                                    end

                                                                                                else
                                                                                                    error(message('HDLShared:CLI:invalidExtraEffortMargin'));
                                                                                                end

                                                                                                function value=set_multiplierpartitioningthreshold(~,value)
                                                                                                    if isnumeric(value)&&~isempty(value)&&isscalar(value)
                                                                                                        minValue=2;
                                                                                                        if~((floor(value)==value)&&value>=minValue)
                                                                                                            error(message('HDLShared:CLI:valueNotGreaterThan','Multiplier partitioning threshold',value,'Multiplier partitioning threshold',minValue));
                                                                                                        end

                                                                                                    else
                                                                                                        error(message('HDLShared:CLI:missingparametervalue','MultiplierPartitioningThreshold'));
                                                                                                    end


                                                                                                    function value=set_sharediffWLthreshold(~,value)
                                                                                                        if isnumeric(value)&&~isempty(value)&&isscalar(value)
                                                                                                            minValue=-1;
                                                                                                            if~((floor(value)==value)&&value>=minValue)
                                                                                                                error(message('HDLShared:CLI:valueNotGreaterThan','Share Different WordLength threshold',value,'Share Different WordLength threshold',minValue));
                                                                                                            end

                                                                                                        else
                                                                                                            error(message('HDLShared:CLI:missingparametervalue','Share Different WordLength threshold'));
                                                                                                        end

                                                                                                        function value=set_MinDelaysRequiredAtLocalMultirateOutput(~,value)
                                                                                                            if isnumeric(value)&&~isempty(value)&&isscalar(value)
                                                                                                                minValue=0;
                                                                                                                if~((floor(value)==value)&&value>=minValue)
                                                                                                                    error(message('HDLShared:CLI:valueNotGreaterThan','MinDelaysRequiredAtLocalMultirateOutput ',value,' MinDelaysRequiredAtLocalMultirateOutput ',0));
                                                                                                                end

                                                                                                            else
                                                                                                                error(message('HDLShared:CLI:missingparametervalue','MinDelaysRequiredAtLocalMultirateOutput'));
                                                                                                            end




                                                                                                            function value=set_SerializerRatioThreshold(~,value)
                                                                                                                if isnumeric(value)&&~isempty(value)&&isscalar(value)
                                                                                                                    minValue=0;
                                                                                                                    if~((floor(value)==value)&&value>=minValue)
                                                                                                                        error(message('HDLShared:CLI:valueNotGreaterThan','Serializer Ratio Threshold',value,'Serializer Ratio Threshold',minValue));
                                                                                                                    end
                                                                                                                else
                                                                                                                    error(message('HDLShared:CLI:missingparametervalue','Serializer Ratio Threshold'));
                                                                                                                end



                                                                                                                function retval=set_serialparttop(this,value)
                                                                                                                    if iscell(value)

                                                                                                                        retval={};
                                                                                                                        for n=1:length(value)
                                                                                                                            retval=[retval,set_serialpartition(this,value{n})];%#ok<AGROW>
                                                                                                                        end
                                                                                                                    else
                                                                                                                        retval=set_serialpartition(this,value);
                                                                                                                    end



                                                                                                                    function value=set_serialpartition(this,value)%#ok

                                                                                                                        if isnumeric(value)&&~isempty(value)
                                                                                                                            if isscalar(value)
                                                                                                                                if~((floor(value)==value)&&value>=-1)
                                                                                                                                    error(message('HDLShared:CLI:illegalparametervalue',value,'SerialPartition'));
                                                                                                                                end
                                                                                                                            else

                                                                                                                            end
                                                                                                                        else
                                                                                                                            error(message('HDLShared:CLI:missingparametervalueorvec','SerialPartition'));
                                                                                                                        end

                                                                                                                        function retval=set_dalutparttop(this,value)

                                                                                                                            if iscell(value)

                                                                                                                                retval={};
                                                                                                                                for n=1:length(value)
                                                                                                                                    retval=[retval,set_dalutpartition(this,value{n})];%#ok<AGROW>
                                                                                                                                end
                                                                                                                            else
                                                                                                                                retval=set_dalutpartition(this,value);
                                                                                                                            end


                                                                                                                            function value=set_dalutpartition(this,value)%#ok

                                                                                                                                if isnumeric(value)&&~isempty(value)
                                                                                                                                    if isscalar(value)
                                                                                                                                        if~((floor(value)==value)&&value>=-1)
                                                                                                                                            error(message('HDLShared:CLI:illegalparametervalue',value,'DALUTPartition'));
                                                                                                                                        end
                                                                                                                                    else

                                                                                                                                    end
                                                                                                                                else
                                                                                                                                    error(message('HDLShared:CLI:missingparametervalueorvec','DALUTPartition'));
                                                                                                                                end


                                                                                                                                function value=set_testbenchstimulus(this,value)%#ok

                                                                                                                                    if isempty(value)
                                                                                                                                        value={};
                                                                                                                                    end
                                                                                                                                    if ischar(value)
                                                                                                                                        value={value};
                                                                                                                                    end
                                                                                                                                    if~iscellstr(value)
                                                                                                                                        error(message('HDLShared:CLI:stringparametervalue','TestBenchStimulus'));
                                                                                                                                    end

                                                                                                                                    function value=set_testbenchfracdelaystimulus(this,value)%#ok

                                                                                                                                        if~(isvector(value)&&isnumeric(value)&&(isempty(find(value>1))&&isempty(find(value<0))))&&...
                                                                                                                                            ~(ischar(value)&&...
                                                                                                                                            (strcmpi(value,'randsweep')||strcmpi(value,'rampsweep')||isempty(value)))%#ok<EFIND>
                                                                                                                                            error(message('HDLShared:CLI:illegaltbfracdelaystimulus','TestBenchFracDelayStimulus'));
                                                                                                                                        end

                                                                                                                                        function value=set_testbenchratestimulus(this,value)%#ok<INUSL>

                                                                                                                                            if~(isnumeric(value)&&~isempty(value))||...
                                                                                                                                                ~isscalar(value)||...
                                                                                                                                                ~((floor(value)==value)&&value>0)

                                                                                                                                                error(message('HDLShared:CLI:illegaltbratestimulus',...
                                                                                                                                                sprintf('%g',value),'TestBenchRateStimulus'));
                                                                                                                                            end


                                                                                                                                            function value=set_testbenchcoeffstimulus(this,value)%#ok

                                                                                                                                                if~(isnumeric(value)&&(isempty(value)||isvector(value)))
                                                                                                                                                    if~(iscell(value))
                                                                                                                                                        error(message('HDLShared:CLI:illegaltbcoeffstimulus','TestBenchCoeffStimulus'));
                                                                                                                                                    else
                                                                                                                                                        if(numel(value)>2)
                                                                                                                                                            error(message('HDLShared:CLI:toomanytbcoeffstimulus','TestBenchCoeffStimulus'));
                                                                                                                                                        else
                                                                                                                                                            for i=1:numel(value)
                                                                                                                                                                if~(isnumeric(value{i}))
                                                                                                                                                                    error(message('HDLShared:CLI:nonnumerictbcoeffstimulus','TestBenchCoeffStimulus'));
                                                                                                                                                                end
                                                                                                                                                            end
                                                                                                                                                        end
                                                                                                                                                    end
                                                                                                                                                end

                                                                                                                                                function value=set_foldingfactor(~,value)


                                                                                                                                                    if any(rem(value,1))||value<=0||any(size(value)~=1)
                                                                                                                                                        error(message('HDLShared:CLI:gtzero'));
                                                                                                                                                    end


                                                                                                                                                    function value=set_nummultipliers(~,value)


                                                                                                                                                        if any(rem(value,1))||value==0||value<-1||any(size(value)~=1)
                                                                                                                                                            error(message('HDLShared:CLI:gtzero'));
                                                                                                                                                        end


                                                                                                                                                        function value=set_phantom(this,value,propname)

                                                                                                                                                            set(this,propname,value);
                                                                                                                                                            value='';


                                                                                                                                                            function value=get_phantom(this,value,propname)%#ok

                                                                                                                                                                value=get(this,propname);


                                                                                                                                                                function definetypes

                                                                                                                                                                    if isempty(findtype('HDLResetTypes'))
                                                                                                                                                                        schema.EnumType('HDLResetTypes',{'Asynchronous','Synchronous'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('HDLClockInputsType'))
                                                                                                                                                                        schema.EnumType('HDLClockInputsType',{'Single','Multiple'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('HDLEditboxType'))
                                                                                                                                                                        schema.UserType('HDLEditboxType','mxArray',@check_editboxtype);
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('HDLActiveLevels'))
                                                                                                                                                                        schema.EnumType('HDLActiveLevels',{'Active-low','Active-high'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('SubsystemReuseOption'))
                                                                                                                                                                        schema.EnumType('SubsystemReuseOption',{'Atomic and Virtual','Atomic only','off'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('ClockEdgeType'))
                                                                                                                                                                        schema.EnumType('ClockEdgeType',{'Rising','Falling'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('HDLInputTypes'))
                                                                                                                                                                        schema.EnumType('HDLInputTypes',{'std_logic_vector','signed/unsigned'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('HDLOutputTypes'))
                                                                                                                                                                        schema.EnumType('HDLOutputTypes',{'Same as input type','std_logic_vector','signed/unsigned'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('CoeffSourceType'))
                                                                                                                                                                        schema.EnumType('CoeffSourceType',{'Internal','ProcessorInterface'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('RAMType'))
                                                                                                                                                                        schema.EnumType('RAMType',{'Registers','SinglePortRAMs','DualPortRAMs'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('NoResetInitType'))
                                                                                                                                                                        schema.EnumType('NoResetInitType',{'None','Script','InsideModule'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('RAMArch'))
                                                                                                                                                                        schema.EnumType('RAMArch',{'WithClockEnable','WithoutClockEnable'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('CosimModelTypes'))
                                                                                                                                                                        schema.EnumType('CosimModelTypes',{'None','ModelSim','Incisive','Vivado Simulator'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('SimulationToolType'))
                                                                                                                                                                        schema.EnumType('SimulationToolType',{'Custom','Mentor Graphics Modelsim','Cadence Incisive','Xilinx Vivado Simulator'});
                                                                                                                                                                    end


                                                                                                                                                                    if isempty(findtype('SVDPITBTypes'))
                                                                                                                                                                        schema.EnumType('SVDPITBTypes',{'None','ModelSim','Incisive','VCS','Vivado Simulator'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('DetectBlackBoxNameCollisionType'))
                                                                                                                                                                        schema.EnumType('DetectBlackBoxNameCollisionType',{'None','Warning','Error'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('CosimModelSetupTypes'))
                                                                                                                                                                        schema.EnumType('CosimModelSetupTypes',{'CosimBlockAndDut','CosimBlockAsDut','CosimBlockOnly'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('nestring'))
                                                                                                                                                                        schema.UserType('nestring','ustring',@check_nonempty_string);
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('power2_scalar'))
                                                                                                                                                                        schema.UserType('power2_scalar','MATLAB array',@check_pwr2scalar);
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('SynthesisToolType'))
                                                                                                                                                                        schema.EnumType('SynthesisToolType',{'None','Vivado','ISE','Libero','Precision','Quartus','Synplify','Custom'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('HDLCodingStandardType'))
                                                                                                                                                                        schema.EnumType('HDLCodingStandardType',{'None','Industry'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('HDLLintToolType'))
                                                                                                                                                                        schema.EnumType('HDLLintToolType',{'None','SpyGlass','LEDA','AscentLint','HDLDesigner','Custom'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('ScalarizePortsOption'))
                                                                                                                                                                        schema.EnumType('ScalarizePortsOption',{'off','on','DUTLevel'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('ScalarizedPortIndexingOption'))
                                                                                                                                                                        schema.EnumType('ScalarizedPortIndexingOption',{'Zero-based','One-based'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('HDLSubdirType'))
                                                                                                                                                                        schema.EnumType('HDLSubdirType',{'None','Model','Model_Dut'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('TCArchType'))
                                                                                                                                                                        schema.EnumType('TCArchType',{'default','resettable'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('DPPriorityType'))
                                                                                                                                                                        schema.EnumType('DPPriorityType',{'Numerical Integrity','Performance'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('NfpMode'))
                                                                                                                                                                        schema.EnumType('NfpMode',{'off','on','simp'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('DenormalMode'))
                                                                                                                                                                        schema.EnumType('DenormalMode',{'DEFAULT','Auto','On','Off'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('FPTolStrategyEnum'))
                                                                                                                                                                        schema.EnumType('FPTolStrategyEnum',{'DEFAULT','Relative','ULP'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('SharedMulSignEnum'))
                                                                                                                                                                        schema.EnumType('SharedMulSignEnum',{'Signed','Unsigned'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('TreatRealsInGeneratedCodeAsType'))
                                                                                                                                                                        schema.EnumType('TreatRealsInGeneratedCodeAsType',{'None','Warning','Error'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('TreatBalanceDelaysOffAsType'))
                                                                                                                                                                        schema.EnumType('TreatBalanceDelaysOffAsType',{'None','Warning','Error'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('EnumEncodingSchemeType'))
                                                                                                                                                                        schema.EnumType('EnumEncodingSchemeType',{'default','onehot','twohot','binary'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('EnumCompileStrategy'))
                                                                                                                                                                        schema.EnumType('EnumCompileStrategy',{'CompileAll','CompileChanged'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('HDLTraceabilityStyle'))
                                                                                                                                                                        schema.EnumType('HDLTraceabilityStyle',{'Line Level','Comment Based'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('HDLDTOType'))
                                                                                                                                                                        schema.EnumType('HDLDTOType',{'off','d2s','d2h','s2h'});
                                                                                                                                                                    end

                                                                                                                                                                    if isempty(findtype('ModelLayoutStyle'))
                                                                                                                                                                        schema.EnumType('ModelLayoutStyle',{'Default','AutoArrange','None'});
                                                                                                                                                                    end



                                                                                                                                                                    function check_pwr2scalar(value)

                                                                                                                                                                        if iscell(value)

                                                                                                                                                                            for n=1:length(value)
                                                                                                                                                                                check_integer(value{n});
                                                                                                                                                                                check_singular(value{n});
                                                                                                                                                                                check_pwr2(value{n});
                                                                                                                                                                            end
                                                                                                                                                                        else
                                                                                                                                                                            check_integer(value);
                                                                                                                                                                            check_singular(value);
                                                                                                                                                                            check_pwr2(value);
                                                                                                                                                                        end


                                                                                                                                                                        function check_integer(value)

                                                                                                                                                                            if any(rem(value,1))
                                                                                                                                                                                error(message('HDLShared:CLI:noninteger'));
                                                                                                                                                                            end



                                                                                                                                                                            function check_pwr2(value)

                                                                                                                                                                                c=log2(value);
                                                                                                                                                                                if~isreal(c)||any(rem(c,1))||c==0
                                                                                                                                                                                    error(message('HDLShared:CLI:nonpower2'));
                                                                                                                                                                                end


                                                                                                                                                                                function check_singular(value)

                                                                                                                                                                                    if any(size(value)~=1)
                                                                                                                                                                                        error(message('HDLShared:CLI:nonscalar'));
                                                                                                                                                                                    end


                                                                                                                                                                                    function check_editboxtype(value)



                                                                                                                                                                                        if~(ischar(value)||isnumeric(value))



                                                                                                                                                                                            error(message('HDLShared:CLI:nonnumericeditbox'));
                                                                                                                                                                                        end


                                                                                                                                                                                        function check_nonempty_string(value)

                                                                                                                                                                                            if isempty(value)
                                                                                                                                                                                                error(message('HDLShared:CLI:stringempty'));
                                                                                                                                                                                            end


                                                                                                                                                                                            function value=set_SplitArchFilePostfix(this,value)
                                                                                                                                                                                                if strcmpi(this.SplitEntityArch,'on')
                                                                                                                                                                                                    Validate_SplitEntityArchFilePostfix(value,this.SplitEntityFilePostfix);
                                                                                                                                                                                                end


                                                                                                                                                                                                function value=set_SplitEntityFilePostfix(this,value)
                                                                                                                                                                                                    if strcmpi(this.SplitEntityArch,'on')
                                                                                                                                                                                                        Validate_SplitEntityArchFilePostfix(value,this.SplitArchFilePostfix);
                                                                                                                                                                                                    end


                                                                                                                                                                                                    function Validate_SplitEntityArchFilePostfix(value,comparingValue)
                                                                                                                                                                                                        if strcmpi(value,comparingValue)

                                                                                                                                                                                                            if isempty(value)
                                                                                                                                                                                                                error(message('HDLShared:CLI:HDLFilePostfixNonEmpty'));

                                                                                                                                                                                                            else
                                                                                                                                                                                                                error(message('HDLShared:CLI:HDLFilePostfixNotUnique'));
                                                                                                                                                                                                            end
                                                                                                                                                                                                        end


                                                                                                                                                                                                        if length(value)>=128
                                                                                                                                                                                                            error(message('HDLShared:CLI:invalidPostfixNameLength'));
                                                                                                                                                                                                        end


                                                                                                                                                                                                        if contains(value,' ')
                                                                                                                                                                                                            error(message('HDLShared:CLI:unsupportedSpacesInPostfixName'));
                                                                                                                                                                                                        end


                                                                                                                                                                                                        function value=set_editboxInteger(this,value)%#ok

                                                                                                                                                                                                            if isempty(value)||~isnumeric(value)||(rem(value,1)~=0)||(value<0)
                                                                                                                                                                                                                error(message('HDLShared:CLI:posinteditbox'));
                                                                                                                                                                                                            end


                                                                                                                                                                                                            function value=set_oversampling(this,value)
                                                                                                                                                                                                                if isempty(value)||~isnumeric(value)||(~((floor(value)==value)&&value>=1))
                                                                                                                                                                                                                    error(message('HDLShared:CLI:nonpositiveinteger'));
                                                                                                                                                                                                                elseif strcmpi(this.ClockInputs,'Multiple')&&value>1
                                                                                                                                                                                                                    error(message('HDLShared:CLI:multiclock_oversampling'));
                                                                                                                                                                                                                end


                                                                                                                                                                                                                function value=set_clockratepipeliningfraction(this,value)%#ok
                                                                                                                                                                                                                    if isempty(value)||~isnumeric(value)||(~(value>=0&&value<=1&&mod((value*100),1)==0))
                                                                                                                                                                                                                        error(message('HDLShared:CLI:illegalCRPFractionValue','ClockRatePipeliningFraction'));
                                                                                                                                                                                                                    end


                                                                                                                                                                                                                    function value=set_clockmode(this,value)
                                                                                                                                                                                                                        if strcmpi(value,'Multiple')&&(this.Oversampling>1)
                                                                                                                                                                                                                            error(message('HDLShared:CLI:multiclock_oversampling'));
                                                                                                                                                                                                                        end


                                                                                                                                                                                                                        function value=get_clockSetupTime(this,~)
                                                                                                                                                                                                                            setup=this.ClockHighTime+this.ClockLowTime-this.HoldTime;
                                                                                                                                                                                                                            if(rem(setup,1)==0)
                                                                                                                                                                                                                                fmat='%0.0f';
                                                                                                                                                                                                                            elseif(rem(setup*1e1,1)==0)
                                                                                                                                                                                                                                fmat='%0.1f';
                                                                                                                                                                                                                            elseif(rem(setup*1e2,1)==0)
                                                                                                                                                                                                                                fmat='%0.2f';
                                                                                                                                                                                                                            elseif(rem(setup*1e3,1)==0)
                                                                                                                                                                                                                                fmat='%0.3f';
                                                                                                                                                                                                                            elseif(rem(setup*1e4,1)==0)
                                                                                                                                                                                                                                fmat='%0.4f';
                                                                                                                                                                                                                            elseif(rem(setup*1e5,1)==0)
                                                                                                                                                                                                                                fmat='%0.5f';
                                                                                                                                                                                                                            elseif(rem(setup*1e6,1)==0)
                                                                                                                                                                                                                                fmat='%0.6f';
                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                fmat='%0.6f';
                                                                                                                                                                                                                            end

                                                                                                                                                                                                                            value=str2double(sprintf(fmat,setup));



                                                                                                                                                                                                                            function value=set_clockSetupTime(this,value)%#ok
                                                                                                                                                                                                                                warning(message('HDLShared:CLI:timingwarningsetup'));


                                                                                                                                                                                                                                function value=set_clockHoldTime(this,value)

                                                                                                                                                                                                                                    if isempty(value)||~isnumeric(value)||(value<=0)
                                                                                                                                                                                                                                        error(message('HDLShared:CLI:poseditbox'));
                                                                                                                                                                                                                                    elseif~(rem(value*1000000,1)==0)
                                                                                                                                                                                                                                        error(message('HDLShared:CLI:hdlsimresolution','HoldTime'));
                                                                                                                                                                                                                                    elseif value>=this.ClockHighTime+this.ClockLowTime-1


                                                                                                                                                                                                                                        clockPeriod=this.ClockHighTime+this.ClockLowTime;
                                                                                                                                                                                                                                        error(message('HDLShared:CLI:timingerrorhold',sprintf('%g',value),sprintf('%g',clockPeriod)));
                                                                                                                                                                                                                                    else

                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                    value=check_timeScale(value,'HoldTime');


                                                                                                                                                                                                                                    function value=set_clockHighTime(this,value)

                                                                                                                                                                                                                                        if isempty(value)||~isnumeric(value)||(value<=0)
                                                                                                                                                                                                                                            error(message('HDLShared:CLI:poseditbox'));
                                                                                                                                                                                                                                        elseif~(rem(value*1000000,1)==0)
                                                                                                                                                                                                                                            error(message('HDLShared:CLI:hdlsimresolution','ClockHighTime'));
                                                                                                                                                                                                                                        elseif this.HoldTime>this.ClockLowTime+value
                                                                                                                                                                                                                                            error(message('HDLShared:CLI:timingerrorhigh',sprintf('%g',value)));
                                                                                                                                                                                                                                        elseif this.HoldTime==this.ClockLowTime+value
                                                                                                                                                                                                                                            clockPeriod=value+this.ClockLowTime;
                                                                                                                                                                                                                                            warning(message('HDLShared:CLI:timingwarning',sprintf('%g',clockPeriod),sprintf('%g',this.HoldTime)));
                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                        value=check_timeScale(value,'ClockHighTime');


                                                                                                                                                                                                                                        function value=set_clockLowTime(this,value)

                                                                                                                                                                                                                                            if isempty(value)||~isnumeric(value)||(value<=0)
                                                                                                                                                                                                                                                error(message('HDLShared:CLI:poseditbox'));
                                                                                                                                                                                                                                            elseif~(rem(value*1000000,1)==0)
                                                                                                                                                                                                                                                error(message('HDLShared:CLI:hdlsimresolution','ClockLowTime'));
                                                                                                                                                                                                                                            elseif this.HoldTime>this.ClockHighTime+value
                                                                                                                                                                                                                                                error(message('HDLShared:CLI:timingerrorlow',sprintf('%g',value)));
                                                                                                                                                                                                                                            elseif this.HoldTime==this.ClockHighTime+value
                                                                                                                                                                                                                                                clockPeriod=value+this.ClockHighTime;
                                                                                                                                                                                                                                                warnObj=message('HDLShared:CLI:timingwarning',sprintf('%g',clockPeriod),sprintf('%g',this.HoldTime));
                                                                                                                                                                                                                                                slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',warnObj,'log to terminal if required');
                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                            value=check_timeScale(value,'ClockLowTime');

                                                                                                                                                                                                                                            function newValue=check_timeScale(value,settingName)

                                                                                                                                                                                                                                                newValue=value;
                                                                                                                                                                                                                                                if rem(value,1)~=0
                                                                                                                                                                                                                                                    warnObj=message('HDLShared:CLI:timescale',settingName,num2str(value));
                                                                                                                                                                                                                                                    slhdlcoder.HDLCoder.addCheckCurrentDriver('Warning',warnObj,'log to terminal if required');
                                                                                                                                                                                                                                                end


                                                                                                                                                                                                                                                function value=set_adderSharingMinimumBitwidth(~,value)
                                                                                                                                                                                                                                                    value=check_sharingThreshold(value);

                                                                                                                                                                                                                                                    function value=set_multiplierSharingMinimumBitwidth(~,value)
                                                                                                                                                                                                                                                        value=check_sharingThreshold(value);

                                                                                                                                                                                                                                                        function value=set_macSharingMinimumBitwidth(~,value)
                                                                                                                                                                                                                                                            value=check_sharingThreshold(value);

                                                                                                                                                                                                                                                            function newValue=check_sharingThreshold(value)
                                                                                                                                                                                                                                                                newValue=value;
                                                                                                                                                                                                                                                                if isempty(value)||~isnumeric(value)||(value<0)||(rem(value,1)~=0)
                                                                                                                                                                                                                                                                    error(message('HDLShared:CLI:posinteditbox'));
                                                                                                                                                                                                                                                                end

                                                                                                                                                                                                                                                                function newValue=check_nfpLatency(~,value)
                                                                                                                                                                                                                                                                    if isempty(value)
                                                                                                                                                                                                                                                                        value='DEFAULT';
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                    if~ischar(value)
                                                                                                                                                                                                                                                                        error(message('HDLShared:CLI:nfplatencyerror'));
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                    if~strcmpi(value,'MAX')&&~strcmpi(value,'ZERO')&&~strcmpi(value,'MIN')...
                                                                                                                                                                                                                                                                        &&~strcmpi(value,'DEFAULT')
                                                                                                                                                                                                                                                                        error(message('HDLShared:CLI:nfplatencyerror'));
                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                    newValue=upper(value);

                                                                                                                                                                                                                                                                    function newValue=set_floatingpointtargetconfiguration(~,value)
                                                                                                                                                                                                                                                                        if~(isempty(value)||isa(value,'hdlcoder.FloatingPointTargetConfig'))
                                                                                                                                                                                                                                                                            error(message('HDLShared:CLI:unsupportedfloatingpointtargetconfig'));
                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                        newValue=value;


                                                                                                                                                                                                                                                                        function newValue=set_sschdlcustomlatency(~,value)
                                                                                                                                                                                                                                                                            max_latency=8;
                                                                                                                                                                                                                                                                            if((value>max_latency)||(value<-1))
                                                                                                                                                                                                                                                                                error(message('HDLShared:CLI:unsupportedSSCHDLCustomLatency','0',num2str(max_latency)))
                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                            newValue=value;

                                                                                                                                                                                                                                                                            function newValue=check_tcCounterCompOp(~,value)
                                                                                                                                                                                                                                                                                if isempty(value)
                                                                                                                                                                                                                                                                                    value='>=';
                                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                                if~ischar(value)
                                                                                                                                                                                                                                                                                    error(message('HDLShared:CLI:tcCounterCompOpError',value));
                                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                                if~strcmpi(value,'>=')&&~strcmpi(value,'==')
                                                                                                                                                                                                                                                                                    error(message('HDLShared:CLI:tcCounterCompOpError',value));
                                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                                newValue=upper(value);









