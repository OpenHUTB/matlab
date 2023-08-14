function updateINI(this,hINI)







    try
        [clockHighTime,res1]=TMevaluatevars(this,'ClockHighTime');
        [clockLowTime,res2]=TMevaluatevars(this,'ClockLowTime');
        [holdTime,res3]=TMevaluatevars(this,'HoldTime');
        simResolutionWarning(max([res1,res2,res3]));

        errorMargin=lclevaluatevars(this,'ErrorMargin');
        verbosity=lclevaluatevars(this,'Verbosity');
        resetLength=lclevaluatevars(this,'ResetLength');
        synthesisTool=getLegalSynthesisTool(this);


        tbUserStim=lclevaluatevars(this,'TestBenchUserStimulus');
    catch me
        me.rethrow;
    end



    hGC=hINI.getPropSet('Global').getPropSet('Common');
    hTC=hINI.getPropSet('TestBench').getPropSet('Common');
    hEC=hINI.getPropSet('EDAScript').getPropSet('Compilation');
    hEM=hINI.getPropSet('EDAScript').getPropSet('Mapping');
    hES=hINI.getPropSet('EDAScript').getPropSet('Simulation');
    hESn=hINI.getPropSet('EDAScript').getPropSet('Synthesis');
    hEP=hINI.getPropSet('EDAScript').getPropSet('Projects');
    hFC=hINI.getPropSet('Filter').getPropSet('Common');

    sGC=rmfield(get(hGC),{'isvhdl','isverilog','issystemverilog'});
    sTC=get(hTC);
    sEC=get(hEC);
    sEM=get(hEM);
    sES=get(hES);
    sESn=get(hESn);
    sEP=get(hEP);
    sFC=get(hFC);

    try

        if isempty(this.HDLSubsystem)
            this.HDLSubsystem='';
        end
        hGC.hdl_subsystem=this.HDLSubsystem;
        if strcmpi(this.OptimBetweenMATLABAndSimulink,'on')

            hGC.using_ml2pir=2;
        else

            hGC.using_ml2pir=1;
        end

        hGC.target_language=this.TargetLanguage;



        if hGC.isvhdl
            hGC.base_data_type='std_logic';
            hGC.reg_data_type='std_logic';
            hGC.assign_prefix='';
            hGC.assign_op='<=';
            hGC.array_deref='()';
            hGC.loop_unrolling=false;
        else
            hGC.base_data_type='wire';
            hGC.reg_data_type='reg ';
            hGC.assign_prefix='assign ';
            hGC.assign_op='=';
            hGC.array_deref='[]';
            hGC.loop_unrolling=true;
        end

        hGC.workflow=this.Workflow;
        hGC.targetPlatform=this.TargetPlatform;
        hGC.referenceDesign=this.ReferenceDesign;
        hGC.referenceDesignPath=this.ReferenceDesignPath;
        hGC.EnableTestpoints=strcmpi(this.EnableTestpoints,'on');
        hGC.AvoidMatchingDelaysForTestpoints=strcmpi(this.BalanceDelaysForTestpoints,'off');
        hGC.GenDUTPortForTunableParam=strcmpi(this.GenDUTPortForTunableParam,'on');
        hGC.AvoidMatchingDelaysForTunableParam=strcmpi(this.BalanceDelaysForTunableParam,'off');
        hGC.ConcatenateHDLModules=strcmpi(this.ConcatenateHDLModules,'on');
        hGC.inlineHDLCode=strcmpi(this.InlineHDLCode,'on');



        if hGC.ConcatenateHDLModules
            hGC.ConcatenateHDLModules=false;
            hGC.inlineHDLCode=true;
        end
        hGC.ScalarizePorts=find(strcmpi(this.ScalarizePorts,...
        set(this,'ScalarizePorts')))-1;
        hGC.OneBasedPortIndexing=find(strcmpi(this.ScalarizedPortIndexing,...
        set(this,'ScalarizedPortIndexing')))-1;
        hGC.samplespercycle=this.SamplesPerCycle;
        hGC.inputfifosize=this.InputFIFOSize;
        hGC.outputfifosize=this.OutputFIFOSize;
        hGC.largedelaymemory=strcmpi(this.LargeDelayMemory,'on');
        hGC.delaysizethreshold=this.DelaySizeThreshold;
        hGC.oversampling=this.Oversampling;
        hGC.clockratepipeliningfraction=this.ClockRatePipeliningFraction;
        hGC.reserved_word_postfix=legalHDLName(this,'ReservedWordPostfix',true);
        hGC.product_of_elements_style=this.ProductOfElementsStyle;
        hGC.async_reset=strcmpi(this.ResetType,'asynchronous');
        hGC.bit_true_to_filter=strcmpi(this.OptimizeForHDL,'off');
        hGC.TCCounterLimitCompOp=this.TCCounterLimitCompOp;
        hGC.OptimizeTimingController=strcmpi(this.OptimizeTimingController,'on');
        hGC.ResettableTimingController=strcmpi(this.TimingControllerArch,'resettable');
        hGC.TimingControllerPostfix=legalHDLName(this,'TimingControllerPostfix',true);
        hGC.CriticalPathEstimationFile=legalfilename(this.CriticalPathEstimationFile);
        hGC.SLPALoopsFile=legalfilename(this.SLPALoopsFile);
        hGC.SLPAFile=legalfilename(this.SLPAFile);
        hGC.SLPABackEdgeFile=legalfilename(this.SLPABackEdgeFile);
        hGC.SLPAGMMapMATFile=legalfilename(this.SLPAGMMapMATFile);
        hGC.HardwarePipeliningCharacterizationFile=isemptyorlegalfilename(this.HardwarePipeliningCharacterizationFile);
        hGC.BlocksWithNoCharacterizationFile=legalfilename(this.BlocksWithNoCharacterizationFile);
        hGC.HighlightFeedbackLoopsFile=legalfilename(this.HighlightFeedbackLoopsFile);
        hGC.HighlightClockRatePipeliningDiagnostic=strcmpi(this.HighlightClockRatePipeliningDiagnostic,'on');
        hGC.HighlightClockRatePipeliningFile=legalfilename(this.HighlightClockRatePipeliningFile);
        hGC.HighlightRemovedDeadBlocks=strcmpi(this.HighlightRemovedDeadBlocks,'on');
        hGC.RetimingCP=strcmpi(this.RetimingCP,'on');
        hGC.RetimingCPFile=legalfilename(this.RetimingCPFile);
        hGC.DistributedPipeliningBarriers=strcmpi(this.DistributedPipeliningBarriers,'on');
        hGC.DistributedPipeliningBarriersFile=legalfilename(this.DistributedPipeliningBarriersFile);
        hGC.HighlightLUTPipeliningDiagnostic=strcmpi(this.HighlightLUTPipeliningDiagnostic,'on');
        hGC.HighlightLUTPipeliningDiagnosticFile=legalfilename(this.HighlightLUTPipeliningDiagnosticFile);
        hGC.SetLUTPipeliningOffScriptFile=legalfilename(this.SetLUTPipeliningOffScriptFile);
        hGC.ClearHighlightingFile=legalfilename(this.ClearHighlightingFile);
        hGC.cast_before_sum=strcmpi(this.CastBeforeSum,'on');
        hGC.checkhdl=strcmpi(this.CheckHDL,'on');
        hGC.enableprefix=legalHDLName(this,'EnablePrefix');
        hGC.clockenablename=legalHDLName(this,'ClockEnableInputPort');
        hGC.clockenableoutputname=legalHDLName(this,'ClockEnableOutputPort');
        hGC.minimizeclockenables=strcmpi(this.MinimizeClockEnables,'on');
        hGC.minimizeglobalresets=strcmpi(this.MinimizeGlobalResets,'on');
        hGC.NoResetInitializationMode=validateNoResetInitMode(this.NoResetInitializationMode);
        hGC.NoResetInitScript=legalfilename(this.NoResetInitScript);
        hGC.complexmulelaboration=this.ComplexMulElaboration;
        hGC.flattenbus=strcmpi(this.FlattenBus,'on');
        hGC.clockinputs=find(strcmpi(this.ClockInputs,set(this,'ClockInputs')));
        hGC.triggerasclock=strcmpi(this.TriggerAsClock,'on');
        hGC.asyncresetport=strcmpi(this.AsyncResetPort,'on');
        hGC.triggerAsClockWithoutSyncRegisters=strcmpi(this.TriggerAsClockWithoutSyncRegisters,'on');
        hGC.conditionalizePipeline=strcmpi(this.ConditionalizePipeline,'on');
        hGC.inferControlPorts=strcmpi(this.InferControlPorts,'on');
        hGC.clockname=legalHDLName(this,'ClockInputPort');
        hGC.codegendir=this.TargetDirectory;
        if~ispc&&~isempty(strfind(this.TargetDirectory,'\'))
            hGC.codegendir=strrep(this.TargetDirectory,'\',filesep);
        elseif ispc&&~isempty(strfind(this.TargetDirectory,'/'))
            hGC.codegendir=strrep(this.TargetDirectory,'/',filesep);
        end
        hGC.codegensubdir=find(strcmpi(this.TargetSubdirectory,...
        set(this,'TargetSubdirectory')));
        hGC.gain_multipliers=this.GainMultipliers;
        hGC.simulator_flags=this.SimulatorFlags;
        hGC.sum_of_elements_style=this.SumOfElementsStyle;
        hGC.compilestrategy=this.CompileStrategy;
        hGC.BuildToProtectModel=strcmpi(this.BuildToProtectModel,'on');



        if strcmpi(this.TargetLanguage,'vhdl')
            cchar='--';
        else
            cchar='//';
        end

        mver=ver('matlab');
        hver=ver('hdlcoder');
        hGC.tool_file_comment=...
        hdlformatcomment(['Generated by ',mver.Name,' ',mver.Version,' and ',hver.Name,' ',hver.Version]);
        hGC.comment_char=cchar;
        hGC.rcs_cvs_tag=hdlformatcomment(this.UserComment,[],cchar);
        hGC.CustomFileHeaderComment=this.CustomFileHeaderComment;
        hGC.CustomFileFooterComment=this.CustomFileFooterComment;
        hGC.datecomment=strcmpi(this.DateComment,'on');

        hGC.resetname=legalHDLName(this,'ResetInputPort');
        hGC.verbose=verbosity;
        hGC.reset_asserted_level=find(strcmpi(this.ResetAssertedLevel,...
        set(this,'ResetAssertedLevel')))-1;
        hGC.clockedge=find(strcmpi(this.ClockEdge,...
        set(this,'ClockEdge')))-1;
        hGC.clockedgestyle=strcmpi(this.UseRisingEdge,'on');

        hGC.block_generate_label=this.BlockGenerateLabel;
        hGC.clock_process_label=legalHDLName(this,'ClockProcessPostfix',true);
        hGC.complex_imag_postfix=legalHDLName(this,'ComplexImagPostfix',true);
        hGC.complex_real_postfix=legalHDLName(this,'ComplexRealPostfix',true);
        if strcmp(hGC.complex_real_postfix,hGC.complex_imag_postfix)


            hGC.complex_imag_postfix=[hGC.complex_imag_postfix,'_im'];
        end
        hGC.entity_conflict_postfix=legalHDLName(this,'EntityConflictPostfix',true);
        hGC.instance_generate_label=this.InstanceGenerateLabel;
        hGC.instance_prefix=this.InstancePrefix;
        hGC.instance_postfix=legalHDLName(this,'InstancePostfix',true);
        hGC.output_generate_label=this.OutputGenerateLabel;
        hGC.vector_prefix=this.VectorPrefix;
        hGC.pipelinepostfix=this.PipelinePostfix;
        hGC.vhdl_file_ext=legalfilename(this.VHDLFileExtension);
        hGC.verilog_file_ext=legalfilename(this.VerilogFileExtension);
        hGC.systemverilog_file_ext=legalfilename(this.SystemVerilogFileExtension);







        hGC.vhdl_library_name=this.VHDLLibraryName;
        hGC.top_level_vhdl_library_name=this.VHDLLibraryName;
        hGC.use_single_library=strcmpi(this.UseSingleLibrary,'on');
        hGC.vhdl_architecture_name=this.VHDLArchitectureName;
        hGC.module_prefix=this.ModulePrefix;

        hGC.debug=getDebugLevel(this.Debug);
        hGC.generatehdlcode=strcmpi(this.GenerateHDLCode,'on');
        hGC.generatemodel=strcmpi(this.GenerateModel,'on');
        hGC.generatetb=strcmpi(this.GenerateTB,'on');
        hGC.generatecegenmodel=strcmpi(this.GenerateCEGenModel,'on');
        hGC.LayoutStyle=this.LayoutStyle;
        hGC.hdlgeneratewebview=strcmpi(this.HDLGenerateWebview,'on');
        hGC.obfuscategeneratedhdlcode=strcmpi(this.ObfuscategeneratedHDLCode,'on');
        hGC.generaterecordtype=strcmpi(this.GenerateRecordType,'on')&&strcmpi(this.TargetLanguage,'VHDL');
        hGC.traceability=...
        strcmpi(this.Traceability,'on')&&...
        ~hGC.obfuscategeneratedhdlcode;
        hGC.TraceabilityStyle=this.TraceabilityStyle;
        hGC.TraceabilityProcessing=...
        hGC.generatehdlcode&&~hGC.obfuscategeneratedhdlcode&&...
        (hGC.traceability||...
        hGC.hdlgeneratewebview||...
        (strcmpi(this.TraceabilityProcessing,'on')&&strcmp(hdlfeature('HDLCodeView'),'on')));
        hGC.HDLDTO=find(strcmpi(this.HDLDTO,set(this,'HDLDTO')));
        hGC.runtimeReport=strcmpi(this.RuntimeReport,'on');
        hGC.resourceReport=strcmpi(this.ResourceReport,'on');
        hGC.optimizationReport=strcmpi(this.OptimizationReport,'on')&&strcmpi(this.GenerateModel,'on');
        hGC.ErrorCheckReport=strcmpi(this.ErrorCheckReport,'on');
        hGC.ipcoreReport=strcmpi(this.IPCoreReport,'on');
        hGC.recommendations=strcmpi(this.Recommendations,'on');
        hGC.emitRequirementComments=strcmpi(this.RequirementComments,'on');
        hGC.EnableComments=strcmpi(this.EnableComments,'on');
        hGC.backannotation=strcmpi(this.Backannotation,'on');
        hGC.hierarchicalDistPipelining=strcmpi(this.HierarchicalDistPipelining,'on');
        hGC.preserveDesignDelays=strcmpi(this.PreserveDesignDelays,'on');
        hGC.acquireDesignDelaysForEMLOptimizations=strcmpi(this.AcquireDesignDelaysForEMLOptimizations,'on');
        hGC.clockratepipelining=strcmpi(this.ClockRatePipelining,'on');
        hGC.crpDelayBalancingIterLimit=this.CRPDelayBalancingIterLimit;
        hGC.crpwithoutflattening=strcmpi(this.CRPWithoutFlattening,'on');
        hGC.usecrpalternativestrategy=strcmpi(this.UseCRPAlternativeStrategy,'on');
        hGC.increasecrpbudget=strcmpi(this.IncreaseCRPBudget,'on');
        hGC.adaptivepipelining=strcmpi(this.AdaptivePipelining,'on');
        hGC.lutmaptoram=strcmpi(this.LUTMapToRAM,'on');
        hGC.clonemodules=strcmpi(this.CloneModules,'on');
        hGC.clockratepipelineoutputports=strcmpi(this.ClockRatePipelineOutputPorts,'on');
        hGC.balanceclockrateoutputports=strcmpi(this.BalanceClockRateOutputPorts,'on');
        hGC.criticalPathEstimation=strcmpi(this.CriticalPathEstimation,'on');
        hGC.TimingDatabaseDirectory=this.TimingDatabaseDirectory;
        if~ispc&&~isempty(strfind(this.TimingDatabaseDirectory,'\'))
            hGC.TimingDatabaseDirectory=strrep(this.TimingDatabaseDirectory,'\',filesep);
        elseif ispc&&~isempty(strfind(this.TimingDatabaseDirectory,'/'))
            hGC.TimingDatabaseDirectory=strrep(this.TimingDatabaseDirectory,'/',filesep);
        end
        hGC.staticLatencyPathAnalysis=strcmpi(this.StaticLatencyPathAnalysis,'on');
        hGC.optimizeserializer=strcmpi(this.optimizeserializer,'on');
        hGC.ShareEqualWL=strcmpi(this.shareequalwl,'on');
        hGC.SharedMulSign=find(strcmpi(this.sharedmulsign,...
        set(this,'sharedmulsign')))-1;
        hGC.MultiplierPromotionThreshold=this.MultiplierPromotionThreshold;
        hGC.minDelaysRequiredAtLocalMultirateOutput=this.MinDelaysRequiredAtLocalMultirateOutput;
        hGC.RoutingFudgeFactor=this.RoutingFudgeFactor;
        hGC.optimizationCompatibilityCheck=strcmpi(this.OptimizationCompatibilityCheck,'on');

        hGC.adderSharingMinimumBitwidth=this.AdderSharingMinimumBitwidth;
        hGC.multiplierSharingMinimumBitwidth=this.MultiplierSharingMinimumBitwidth;
        hGC.multiplyAddSharingMinimumBitwidth=this.MultiplyAddSharingMinimumBitwidth;
        hGC.shareAdders=strcmpi(this.ShareAdders,'on');
        hGC.shareMultipliers=strcmpi(this.ShareMultipliers,'on');
        hGC.shareMultiplyAdds=strcmpi(this.ShareMultiplyAdds,'on');
        hGC.shareMATLABBlocks=strcmpi(this.ShareMATLABBlocks,'on');
        hGC.shareAtomicSubsystems=strcmpi(this.ShareAtomicSubsystems,'on');
        hGC.shareCounterSerDes=strcmpi(this.ShareCounterSerDes,'on');
        hGC.shareFloatingPointIPs=strcmpi(this.ShareFloatingPointIPs,'on');
        hGC.pipelinedSharing=strcmpi(this.PipelinedSharing,'on');
        hGC.optimizeCRPSharingRegisters=strcmpi(this.OptimizeCRPSharingRegisters,'on');
        hGC.clockRatePipeliningBudgetCheck=strcmpi(this.ClockRatePipeliningBudgetCheck,'on');

        hGC.axiStreamingTransformFeatureControl=strcmpi(this.AXIStreamingTransformFeatureControl,'on');
        hGC.axiInterface512BitDataPortFeatureControl=strcmpi(this.AXIInterface512BitDataPortFeatureControl,'on');
        hGC.SerializerRatioThreshold=this.SerializerRatioThreshold;

        hGC.highlightfeedbackloops=strcmpi(this.HighlightFeedbackLoops,'on');
        hGC.retimingcp=strcmpi(this.RetimingCP,'on');
        hGC.functionallyEquivalentRetiming=strcmpi(this.FunctionallyEquivalentRetiming,'on');
        hGC.DistributedPipelining=strcmpi(this.DistributedPipelining,'on');
        hGC.DistributedPipeliningPrecision=this.DistributedPipeliningPrecision;
        hGC.UseSynthesisEstimatesForDistributedPipelining=strcmpi(this.UseSynthesisEstimatesForDistributedPipelining,'on');
        hGC.distributedPipeliningPriority=find(strcmpi(this.DistributedPipeliningPriority,...
        set(this,'DistributedPipeliningPriority')));
        hGC.retimingDetails=strcmpi(this.RetimingDetails,'on');
        hGC.criticalPathDetails=strcmpi(this.CriticalPathDetails,'on');
        hGC.signalNamesMangling=strcmpi(this.SignalNamesMangling,'on');
        hGC.guidedRetiming=strcmpi(this.GuidedRetiming,'on');
        hGC.latencyConstraint=this.LatencyConstraint;
        hGC.reduceMatchingDelays=strcmpi(this.ReduceMatchingDelays,'on');
        hGC.numcriticalPathsEstimated=this.NumCriticalPathsEstimated;
        hGC.optimizationData=this.OptimizationData;
        hGC.cpGuidanceFile=this.CPGuidanceFile;
        hGC.cpAnnotationFile=this.CPAnnotationFile;
        hGC.maskParameterAsGeneric=strcmpi(this.MaskParameterAsGeneric,'on');
        hGC.optimizeMdlGen=strcmpi(this.OptimizeMdlGen,'on');
        hGC.gen_eda_scripts=strcmpi(this.EDAScriptGeneration,'on');
        hGC.OptimizeConstants=strcmpi(this.OptimizeConstants,'on');


        hGC.OptimizeFixedPointConstants=strcmpi(this.OptimizeFixedPointConstants,'on');
        hGC.FrameToSampleConversion=strcmpi(this.FrameToSampleConversion,'on');


        hGC.codegenerationoutput=this.CodeGenerationOutput;
        hGC.generatedmodelname=this.GeneratedModelName;
        hGC.generatedmodelnameprefix=this.GeneratedModelNamePrefix;
        hGC.validationmodelnamesuffix=this.ValidationModelNameSuffix;
        hGC.showcodegenpir=strcmpi(this.ShowCodeGenPIR,'on');
        hGC.serializemodel=this.SerializeModel;
        hGC.serializeio=this.SerializeIO;
        hGC.savepirtoscript=strcmpi(this.savepirtoscript,'on');
        hGC.autoroute=strcmpi(this.AutoRoute,'on');
        hGC.autoplace=strcmpi(this.AutoPlace,'on');
        hGC.UseArrangeSystem=strcmpi(this.UseArrangeSystem,'on');
        hGC.interblkhorzscale=this.InterBlkHorzScale;
        hGC.interblkvertscale=this.InterBlkVertScale;
        hGC.customdotpath=this.CustomDotPath;
        hGC.hiliteancestors=strcmpi(this.HighlightAncestors,'on');
        hGC.hilitecolor=this.HighlightColor;
        hGC.generatevalidationmodel=strcmpi(this.GenerateValidationModel,'on');
        hGC.targetFrequency=this.TargetFrequency;
        hGC.extraEffortMargin=this.ExtraEffortMargin;
        hGC.balancedelays=strcmpi(this.BalanceDelays,'on');
        hGC.balancedelayscontrolsfeedbackloops=strcmpi(this.BalanceDelaysControlsFeedbackLoops,'on');
        hGC.delayabsorption=strcmpi(this.DelayAbsorption,'on');
        hGC.subsystemreuse=this.SubsystemReuse;
        hGC.inlinesubsystems=strcmpi(this.InlineSubsystems,'on');
        hGC.stringtypesupport=strcmpi(this.StringTypeSupport,'on');
        hGC.deleteunusedblocks=strcmpi(this.DeleteUnusedBlocks,'on');
        hGC.deleteunusedblocksundermask=strcmpi(this.DeleteUnusedBlocksUnderMask,'on');
        hGC.deleteunusedports=strcmpi(this.DeleteUnusedPorts,'on');
        hGC.rammappingthreshold=this.RAMMappingThreshold;
        hGC.iothreshold=this.IOThreshold;
        hGC.mappipelinedelaystoram=strcmpi(this.MapPipelineDelaysToRAM,'on');
        hGC.removeredundantcounters=strcmpi(this.RemoveRedundantCounters,'on');
        hGC.replaceunitdelaywithintegerdelay=strcmpi(this.ReplaceUnitDelayWithIntegerDelay,'on');
        hGC.concatenatedelays=strcmpi(this.ConcatenateDelays,'on');
        hGC.mergedelaysonfanouts=strcmpi(this.MergeDelaysOnFanouts,'on');
        hGC.folddelaystoconstant=strcmpi(this.FoldDelaysToConstant,'on');
        hGC.maxoversampling=this.MaxOversampling;
        if hGC.maxoversampling==inf
            hGC.maxoversampling=0;
        end
        hGC.maxcomputationlatency=this.MaxComputationLatency;
        hGC.ramarchitecture=strcmpi(this.RAMArchitecture,'WithClockEnable');
        hGC.usematrixtypesineml=strcmpi(this.UseMatrixTypesInEML,'on');
        hGC.CompactSwitch=strcmpi(this.CompactSwitch,'on');
        hGC.SimIndexCheck=strcmpi(this.SimIndexCheck,'on');
        hGC.inlinematlabblockcode=strcmpi(this.InlineMATLABBlockCode,'on');
        hGC.MultiplierPartitioningThreshold=this.MultiplierPartitioningThreshold;
        if hGC.MultiplierPartitioningThreshold==inf
            hGC.MultiplierPartitioningThreshold=0;
        end
        hGC.treatdelaybalancingfailureas=this.TreatDelayBalancingFailureAs;
        hGC.transformdelayswithcontrollogic=strcmpi(this.TransformDelaysWithControlLogic,'on');
        hGC.transformnonzeroinitvaldelay=strcmpi(this.TransformNonZeroInitValDelay,'on');
        hGC.delayelaborationlimit=this.DelayElaborationLimit;


        hGC.synthesisondirective=this.SynthesisOnDirective;
        hGC.synthesisoffdirective=this.SynthesisOffDirective;

        hGC.multicyclepathinfo=strcmpi(this.MulticyclePathInfo,'on');
        hGC.MulticyclePathConstraints=strcmpi(this.MulticyclePathConstraints,'on');
        hGC.floatingPointTargetConfiguration=this.FloatingPointTargetConfiguration;
        hGC.alteraBackwardIncompatibleSinCosPipeline=strcmpi(this.AlteraBackwardIncompatibleSinCosPipeline,'on');
        hGC.generateTargetComps=strcmpi(this.GenerateTargetComps,'on');

        hGC.nativeFloatingPoint=find(strcmpi(this.NativeFloatingPoint,set(this,'NativeFloatingPoint')))-1;
        hGC.familyDevicePackageSpeed=this.FamilyDevicePackageSpeed;
        hGC.toolName=this.ToolName;
        hGC.synthesisToolChipFamily=this.SynthesisToolChipFamily;
        hGC.synthesisToolDeviceName=this.SynthesisToolDeviceName;
        hGC.synthesisToolPackageName=this.SynthesisToolPackageName;
        hGC.synthesisToolSpeedValue=this.SynthesisToolSpeedValue;
        hGC.synthesisTool=synthesisTool;
        hGC.synthesisProjectAdditionalFiles=this.SynthesisProjectAdditionalFiles;
        hGC.simulationLibPath=this.SimulationLibPath;
        hGC.xilinxSimulatorLibPath=this.XilinxSimulatorLibPath;
        hGC.initializeBlockRAM=this.InitializeBlockRAM;
        hGC.initializeRealPort=this.InitializeRealPort;
        hGC.mapVectorPortToStream=strcmpi(this.MapVectorPortToStream,'on');
        hGC.minimizeIntermediateSignals=strcmpi(this.MinimizeIntermediateSignals,'on');
        hGC.generatecodeinfo=strcmpi(this.GenerateCodeInfo,'on');


        hGC.gatewayoutwithdtc=strcmpi(this.GatewayoutWithDTC,'on');


        hGC.incrementalcodegenfortopmodel=strcmpi(this.IncrementalCodeGenForTopModel,'on');


        hGC.hdlwfSmartbuild=strcmpi(this.HDLWFSmartbuild,'on');

        if hGC.obfuscategeneratedhdlcode

            HDLCodingStandardVal='None';
        else
            HDLCodingStandardVal=this.HDLCodingStandard;
        end
        hGC.hdlcodingstandard=find(strcmpi(HDLCodingStandardVal,set(this,'HDLCodingStandard')));
        hGC.hdllinttool=find(strcmpi(this.HDLLintTool,set(this,'HDLLintTool')));
        hGC.HDLCodingStandardCustomizations=this.HDLCodingStandardCustomizations;
        hGC.ReferenceDesignParameter=this.ReferenceDesignParameter;
        hGC.hdllintinit=this.HDLLintInit;
        hGC.hdllintcmd=this.HDLLintCmd;
        hGC.hdllintterm=this.HDLLintTerm;
        hGC.pirtc=strcmpi(this.PIRTC,'on');


        hGC.nfpLatency=this.nfpLatency;
        hGC.nfpDenormals=find(strcmpi(this.nfpDenormals,set(this,'nfpDenormals')))-1;
        hGC.FPToleranceValue=this.FPToleranceValue;
        hGC.FPToleranceStrategy=find(strcmpi(this.FPToleranceStrategy,set(this,'FPToleranceStrategy')))-1;

        hGC.sschdlMatrixProductSumCustomLatency=this.sschdlMatrixProductSumCustomLatency;

        hGC.DetectBlackBoxNameCollision=this.DetectBlackBoxNameCollision;

        if strcmpi(this.FrameToSampleConversion,'on')
            hGC.TreatRealsInGeneratedCodeAs='Error';
        else
            hGC.TreatRealsInGeneratedCodeAs=this.TreatRealsInGeneratedCodeAs;
        end

        hGC.TreatBalanceDelaysOffAs=this.TreatBalanceDelaysOffAs;
        hGC.UsePipelinedToolboxFunctions=strcmpi(this.UsePipelinedToolboxFunctions,'on');
        hGC.filter_input_type_std_logic=strcmpi(this.InputType,'std_logic_vector');
        hGC.filter_output_type_std_logic=filterOutputStdlogic(this);
        hGC.split_entity_arch=strcmpi(this.SplitEntityArch,'on');
        hGC.splitMooreChartStateUpdate=~strcmpi(this.SplitMooreChartStateUpdate,'off');



        hGC.EnableForGenerateLoops=strcmpi(this.EnableForGenerateLoops,'on');
        hGC.EnumEncodingScheme=find(strcmpi(this.EnumEncodingScheme,...
        set(this,'EnumEncodingScheme')))-1;

        hGC.RAMStyleAttributeName=this.RAMStyleAttributeName;


        if hGC.generatemodel
            layoutType=hGC.LayoutStyle;
            if strcmpi(layoutType,'Default')
                hGC.autoplace=true;
                hGC.UseArrangeSystem=false;
            elseif strcmpi(layoutType,'AutoArrange')
                hGC.autoplace=false;
                hGC.autoroute=false;
                hGC.UseArrangeSystem=true;
            else
                hGC.autoplace=false;
                hGC.autoroute=false;
                hGC.UseArrangeSystem=false;
            end
        end


        hTC.tb_name=legalHDLName(this,'TestBenchName');
        hTC.multifiletestbench=strcmpi(this.MultifileTestBench,'on');
        hTC.usefileiointestbench=strcmpi(this.UseFileIOInTestBench,'on');
        hTC.ignoreDataChecking=this.IgnoreDataChecking;
        hTC.tb_postfix=this.TestBenchPostfix;
        hTC.tbdata_postfix=this.TestBenchDataPostfix;
        hTC.tb_stimulus=this.TestBenchStimulus;
        hTC.tb_rate_stimulus=this.TestBenchRateStimulus;
        hTC.tb_user_stimulus=tbUserStim;
        hTC.tb_fracdelay_stimulus=this.TestBenchFracDelayStimulus;
        hTC.tb_coeff_stimulus=this.TestBenchCoeffStimulus;
        hTC.force_clockenable=strcmpi(this.ForceClockEnable,'on');
        hTC.force_clockenable_value=find(strcmpi(this.ClockEnableValue,...
        set(this,'ClockEnableValue')));
        hTC.testbenchclockenabledelay=this.TestBenchClockEnableDelay;
        hTC.force_clock=strcmpi(this.ForceClock,'on');
        hTC.force_clock_high_time=clockHighTime;
        hTC.force_clock_low_time=clockLowTime;
        hTC.force_reset=strcmpi(this.ForceReset,'on');
        hTC.force_hold_time=holdTime;
        hTC.error_margin=errorMargin;
        hTC.force_reset_value=find(strcmpi(this.ResetAssertedLevel,...
        set(this,'ResetAssertedLevel')))-1;
        hTC.holdinputdatabetweensamples=strcmpi(this.HoldInputDataBetweenSamples,'on');
        hTC.initializetestbenchinputs=strcmpi(this.InitializeTestBenchInputs,'on');
        hTC.resetlength=resetLength;
        hTC.testbenchreferencepostfix=this.TestBenchReferencePostFix;
        hTC.generatecosimblock=strcmpi(this.GenerateCoSimBlock,'on');
        hTC.hdlcodecoverage=strcmpi(this.HDLCodeCoverage,'on');
        hTC.generatehdltestbench=strcmpi(this.GenerateHDLTestBench,'on');
        hTC.generatecosimmodel=this.GenerateCoSimModel;
        hTC.simulationtool=this.SimulationTool;
        hTC.cosimmodelsetup=this.CoSimModelSetup;
        hTC.generatesvdpitestbench=this.GenerateSVDPITestBench;
        hTC.generatefilblock=strcmpi(this.GenerateFILBlock,'on');
        hTC.inputdatainterval=this.InputDataInterval;


        hEC.hdlcompilefilepostfix=this.HDLCompileFilePostfix;
        hEC.hdlcompileinit=this.HDLCompileInit;
        hEC.hdlcompileterm=this.HDLCompileTerm;
        hEC.hdlcompileverilogcmd=this.HDLCompileVerilogCmd;
        hEC.hdlcompilevhdlcmd=this.HDLCompileVHDLCmd;



        hEM.hdlmapfilepostfix=this.HDLMapFilePostfix;
        hEM.hdlmapseparator=this.HDLMapSeparator;


        hES.hdlsimcmd=this.HDLSimCmd;
        hES.hdlsimfilepostfix=this.HDLSimFilePostfix;
        hES.hdlsiminit=this.HDLSimInit;
        hES.hdlsimterm=this.HDLSimTerm;
        hES.hdlsimviewwavecmd=this.HDLSimViewWaveCmd;



        if strcmpi(this.SimulationTool,'Cadence Incisive')&&~strcmpi(hdlcodegenmode,'filtercoder')

            l_CheckForConflictingSimToolCmds(this);

            hEC.hdlcompilefilepostfix='_compile.sh';
            hEC.hdlcompileinit=['INSTALL_DIR=$(ncroot)\n',...
            'export INSTALL_DIR\n'];
            hEC.hdlcompileverilogcmd='ncvlog -64bit %s %s \n';
            hEC.hdlcompilevhdlcmd='ncvhdl -64bit %s %s \n';
            if strcmpi(this.TargetLanguage,'vhdl')
                hGC.simulator_flags=['-v93 ',this.SimulatorFlags];
            end
            hEC.hdlelaborationcmd='ncelab -64bit -access +wc %s %s \n';
            hEC.hdlcodecoverageelaborationflag='-coverage A';


            hES.hdlsimcmd='ncsim -64bit -gui %s %s \\\n';
            hES.hdlsimfilepostfix='_sim.sh';
            hES.hdlsiminit=['INSTALL_DIR=$(ncroot)\n',...
            'export INSTALL_DIR\n'];
            hES.hdlsimterm='-run\n';
            hES.hdlsimviewwavecmd='-input "@simvision {waveform add -using \\$w -signals :%s}" \\\n';

            hES.hdlsimviewwavesetupcmd='-input "@simvision {set w [waveform new]}" \';
            hES.hdlcodecoveragesimulationflag='-covtest CodeCoverage';

            hES.hdlcodecoveragereportgen='imc -load cov_work/scope/CodeCoverage/ -execcmd "report -detail -html -all -out CodeCoverageReport"';

        elseif strcmpi(this.SimulationTool,'Mentor Graphics ModelSim')&&~strcmpi(hdlcodegenmode,'filtercoder')

            l_CheckForConflictingSimToolCmds(this);


            hEC.hdlcompilefilepostfix='_compile.do';
            hEC.hdlcompileinit='vlib %s\n';
            hEC.hdlcompileverilogcmd='vlog %s %s\n';
            hEC.hdlcompilevhdlcmd='vcom %s %s\n';
            hGC.simulator_flags=this.SimulatorFlags;
            hEC.hdlcodecoveragecompilationflag='+cover';

            hES.hdlsimcmd='vsim -voptargs=+acc %s.%s\n';
            hES.hdlsimfilepostfix='_sim.do';
            hES.hdlsiminit=['onbreak resume\n','onerror resume\n'];
            hES.hdlsimterm='run -all\n';
            hES.hdlsimviewwavecmd='add wave sim:%s\n';
            hES.hdlcodecoveragesimulationflag='-coverage';

            hES.hdlcodecoveragereportgen=['coverage report -html CodeCoverage.html\n',...
            'coverage save CodeCoverage.ucdb\n'];

        end



        hEP.hdlsimprojectcmd=this.HDLSimProjectCmd;
        hEP.hdlsimprojectterm=this.HDLSimProjectTerm;
        hEP.hdlsimprojectfilepostfix=this.HDLSimProjectFilePostfix;
        hEP.hdlsimprojectinit=this.HDLSimProjectInit;


        hESn.hdlsynthtool=this.HDLSynthTool;
        hESn.hdlsynthcmd=this.HDLSynthCmd;
        hESn.hdlsynthfilepostfix=this.HDLSynthFilePostfix;
        hESn.hdlsynthinit=this.HDLSynthInit;
        hESn.hdlsynthterm=this.HDLSynthTerm;
        hESn.hdlsynthlibcmd=this.HDLSynthLibCmd;
        hESn.hdlsynthlibspec=this.HDLSynthLibSpec;


        hGC.loop_unrolling=strcmpi(this.LoopUnrolling,'on');
        hGC.inline_configurations=strcmpi(this.InlineConfigurations,'on');
        hGC.package_suffix=legalHDLName(this,'PackagePostfix',true);
        hGC.use_aggregates_for_const=strcmpi(this.UseAggregatesForConst,'on');
        hGC.safe_zero_concat=strcmpi(this.SafeZeroConcat,'on');
        if strcmpi(this.SplitEntityArch,'on')&&~isempty(this.SplitArchFilePostfix)
            hGC.split_arch_file_postfix=legalHDLName(this,'SplitArchFilePostfix',true);
        end
        if strcmpi(this.SplitEntityArch,'on')&&~isempty(this.SplitEntityFilePostfix)
            hGC.split_entity_file_postfix=legalHDLName(this,'SplitEntityFilePostfix',true);
        end


        hGC.use_verilog_timescale=strcmpi(this.UseVerilogTimescale,'on');
        hGC.timescale=this.Timescale;


        hFC.filter_coeff_name=this.CoeffPrefix;
        hFC.filter_fir_final_adder=this.FIRAdderStyle;
        hFC.filter_multipliers=this.CoeffMultipliers;
        hFC.multiplier_input_pipeline=this.MultiplierInputPipeline;
        hFC.multiplier_output_pipeline=this.MultiplierOutputPipeline;
        hFC.filter_registered_input=strcmpi(this.AddInputRegister,'on');
        hFC.filter_registered_output=strcmpi(this.AddOutputRegister,'on');
        hFC.filter_pipelined=strcmpi(this.AddPipelineRegisters,'on');
        if~isempty(this.InputPort)
            hFC.filter_input_name=legalHDLName(this,'InputPort');
        end
        if~isempty(this.OutputPort)
            hFC.filter_output_name=legalHDLName(this,'OutputPort');
        end
        if~isempty(this.Name)
            hFC.filter_name=legalHDLName(this,'Name');
        end
        if~isempty(this.FracDelayPort)
            hFC.filter_fracdelay_name=legalHDLName(this,'FracDelayPort');
        end
        hFC.filter_reuseaccum=strcmpi(this.ReuseAccum,'on');
        hFC.filter_scalewarnbits=this.ScaleWarnBits;
        hFC.filter_serialsegment_inputs=this.SerialPartition;
        hFC.filter_dalutpartition=this.DALUTPartition;
        hFC.filter_daradix=this.DARadix;
        hFC.filter_coefficient_source=this.CoefficientSource;
        hFC.filter_storage_type=this.CoefficientMemory;
        hFC.filter_complex_inputs=strcmpi(this.InputComplex,'on');
        hFC.RemoveResetFrom=this.RemoveResetFrom;
        hFC.enable_fpga_workflow=strcmpi(this.EnableFPGAWorkflow,'on');
        hFC.fpga_workflow_parameters=this.FPGAWorkflowParameters;
        hFC.RateChangePort=strcmpi(this.AddRatePort,'on');
        hFC.userspecified_foldingfactor=this.FoldingFactor;
        hFC.filter_nummultipliers=this.NumMultipliers;
        hFC.filter_input_datatype=this.InputDataType;
        hFC.fracdelay_datatype=this.FractionalDelayDataType;
        hFC.filter_systemobject=this.FilterSystemObject;
    catch me
        warning(me.identifier,'%s',me.message);

        set(hGC,sGC);
        set(hTC,sTC);
        set(hEC,sEC);
        set(hEM,sEM);
        set(hES,sES);
        set(hESn,sESn);
        set(hEP,sEP);
        set(hFC,sFC);
        me.rethrow;
    end


    function debugLevel=getDebugLevel(dbg)

        if ischar(dbg)&&strcmpi(dbg,'on')
            debugLevel=1;
        elseif islogical(dbg)&&dbg
            debugLevel=1;
        elseif isnumeric(dbg)
            debugLevel=dbg;
        else
            debugLevel=0;
        end



        function value=lclevaluatevars(this,property)

            value=get(this,property);

            if ischar(value)
                try
                    value=evalin('base',value);
                catch me
                    error(message('HDLShared:CLI:invalidValue',property));
                end
            end


            function synthesisToolName=getLegalSynthesisTool(this)
                if strcmpi(hdlcodegenmode,'filtercoder')
                    toolName=this.HDLSynthTool;
                else
                    toolName=this.SynthesisTool;
                end
                if strcmp(this.SynthesisTool,'Microsemi Libero SoC')
                    toolName='Microchip Libero SoC';
                end
                if(isempty(toolName)||strcmpi(toolName,'No synthesis tool specified')||...
                    strcmpi(toolName,'None'))
                    synthesisToolName='';
                elseif(strcmpi(toolName,'Xilinx ISE')||strcmpi(toolName,'ISE'))
                    synthesisToolName='Xilinx ISE';
                elseif(strcmpi(toolName,'Altera Quartus II')||strcmpi(toolName,'Quartus'))
                    synthesisToolName='Altera Quartus II';
                elseif(strcmpi(toolName,'Intel Quartus Pro')||strcmpi(toolName,'QuartusPro'))
                    synthesisToolName='Intel QUARTUS PRO';
                elseif(strcmpi(toolName,'Vivado')||strcmpi(toolName,'Xilinx Vivado'))
                    synthesisToolName='Xilinx Vivado';
                elseif(strcmpi(toolName,'Microchip Libero')||strcmpi(toolName,'Libero'))
                    synthesisToolName='Libero';
                elseif strcmpi(toolName,'Microchip Libero SoC')
                    synthesisToolName='Microchip Libero SoC';
                elseif(strcmpi(toolName,'Mentor Graphics Precision')||strcmpi(toolName,'Precision'))
                    synthesisToolName='Precision';
                elseif(strcmpi(toolName,'Synopsys Synplify Pro')||strcmpi(toolName,'Synplify'))
                    synthesisToolName='Synplify';
                elseif(strcmpi(toolName,'Custom'))
                    synthesisToolName='Custom';
                else

                    if isequal(exist('hdlworkflow.Workflow','class'),8)
                        workflow=this.Workflow;
                        hWorkflowList=hdlworkflow.getWorkflowList;
                        isDynamicWorkflowLoaded=hWorkflowList.isInWorkflowList(workflow);




                        if isDynamicWorkflowLoaded
                            synthesisToolName=this.SynthesisTool;
                        else
                            synthesisToolName='';
                            hdlset_param(fileparts(this.HDLSubsystem),'SynthesisTool',synthesisToolName);
                            warning(message('HDLShared:CLI:unsupportedsynthesistool',toolName));
                        end
                    else
                        synthesisToolName='';
                        hdlset_param(fileparts(this.HDLSubsystem),'SynthesisTool',synthesisToolName);
                        warning(message('HDLShared:CLI:unsupportedsynthesistool',toolName));
                    end
                end

                function valueStr=validateNoResetInitMode(myStr)


                    if(isempty(myStr))
                        valueStr='None';
                        warning(message('HDLShared:CLI:emptynoresetinitializationmode'));
                        return;
                    end

                    if~((strcmpi(myStr,'None')||(strcmpi(myStr,'Script'))||...
                        strcmpi(myStr,'InsideModule')))
                        error(message('HDLShared:CLI:unsupportedresetinitialization',myStr));
                    else
                        valueStr=myStr;
                    end



                    function deviceDetails=getLegalDeviceDetails(this,property)

                        alteraDeviceFamilyList={...
                        'Arria GX',...
                        'Arria II GX',...
                        'Cyclone',...
                        'Cyclone II',...
                        'Cyclone III',...
                        'Cyclone III LS',...
                        'Cyclone IV GX',...
                        'Stratix',...
                        'Stratix GX',...
                        'Stratix II',...
                        'Stratix II GX',...
                        'Stratix III',...
                        'Stratix IV',...
                        };

                        xilinxDeviceFamilyList={...
                        'Automotive Spartan3',...
                        'Automotive Spartan3A',...
                        'Automotive Spartan-3A DSP',...
                        'Automotive Spartan3E',...
                        'Automotive Spartan6',...
                        'Space-Grade Virtex-4QV',...
                        'Defense-Grade Spartan-6Q',...
                        'Defense-Grade Spartan-6Q Lower Power',...
                        'Defense-Grade Virtex-4Q',...
                        'Defense-Grade Virtex-5Q',...
                        'Defense-Grade Virtex-6Q',...
                        'Spartan3',...
                        'Spartan3A and Spartan3AN',...
                        'Spartan-3A DSP',...
                        'Spartan3E',...
                        'Spartan6',...
                        'Spartan6 Lower Power',...
                        'Virtex4',...
                        'Virtex5',...
                        'Virtex6',...
                        'Virtex6 Lower Power',...
                        };

                        deviceDetails=get(this,property);

                        if strcmpi(this.UseAlteraMegaFunctions,'on')&&...
                            isempty(find(ismember(alteraDeviceFamilyList,deviceDetails{1}),1))
                            warning(message('HDLShared:CLI:IllegalDeviceName',deviceDetails{1}));
                        end

                        if strcmpi(this.UseXilinxCoregenBlocks,'on')&&...
                            isempty(find(ismember(xilinxDeviceFamilyList,deviceDetails{1}),1))
                            warning(message('HDLShared:CLI:IllegalDeviceName',deviceDetails{1}));
                        end




                        function oName=legalHDLName(this,property,isSuffix)
                            if nargin==2
                                isSuffix=false;
                            end
                            origName=get(this,property);
                            if isempty(origName)
                                oName='';
                                return;
                            end
                            if isSuffix&&origName(1)=='_'
                                leadingUnderscore=true;
                                iName=origName(2:end);
                            else
                                leadingUnderscore=false;
                                iName=origName;
                            end
                            switch lower(this.TargetLanguage)
                            case 'vhdl'
                                if isSuffix
                                    oName=vhdllegalname(iName);
                                else
                                    oName=vhdllegalnamersvd(iName);
                                end
                            case 'verilog'
                                if isSuffix
                                    oName=veriloglegalname(iName);
                                else
                                    oName=veriloglegalnamersvd(iName);
                                end
                            case 'systemverilog'
                                if isSuffix
                                    oName=veriloglegalname(iName);
                                else
                                    oName=veriloglegalnamersvd(iName);
                                end
                            otherwise
                                error(message('HDLShared:CLI:unsupportedlanguage',this.TargetLanguage));
                            end
                            if leadingUnderscore
                                oName=['_',oName];
                            end
                            if~strcmp(oName,origName)
                                warning(message('HDLShared:CLI:hdllegalname',property));
                            end


                            function legalName=legalfilename(inputName)


                                legalName=regexprep(inputName,'[/\\()]','_');



                                function legalName=isemptyorlegalfilename(inputName)
                                    legalName=inputName;
                                    if isempty(inputName)||strcmpi(inputName,'')
                                        legalName='';
                                    end


                                    function slogicyesno=filterOutputStdlogic(this)

                                        if strcmpi(this.OutputType,'Same as input type')
                                            slogicyesno=strcmp(this.InputType,'std_logic_vector');
                                        else
                                            slogicyesno=strcmpi(this.OutputType,'std_logic_vector');
                                        end


                                        function[value,resolution]=TMevaluatevars(this,property)

                                            value=get(this,property);

                                            if ischar(value)
                                                error(message('HDLShared:CLI:invalidValue',property));
                                            else
                                                resolution=getResolution(this,value);
                                            end


                                            function resolution=getResolution(this,value)

                                                resolution=1;
                                                if(rem(value,1)==0)
                                                    resolution=1;
                                                elseif~(rem(value*1000000,1)==0)
                                                    error(message('HDLShared:CLI:INIsimresolution','1fs'));
                                                elseif strcmpi(this.TargetLanguage,'vhdl')
                                                    for exp=1:6
                                                        if(rem(value*10^exp,1)==0)
                                                            resolution=10^exp;
                                                            break;
                                                        end
                                                    end
                                                end


                                                function simResolutionWarning(res)
                                                    if(res==10)
                                                        str=('100 ps');
                                                    elseif(res==100)
                                                        str=('10 ps');
                                                    elseif(res==1000)
                                                        str=('1 ps');
                                                    elseif(res==10000)
                                                        str=('100 fs');
                                                    elseif(res==100000)
                                                        str=('10 fs');
                                                    elseif(res==1000000)
                                                        str=('1 fs');
                                                    end
                                                    if res~=1
                                                        warning(message('HDLShared:CLI:INIsimresolution',str));
                                                    end

                                                    function l_CheckForConflictingSimToolCmds(this)

                                                        ConflictingCmd=containers.Map;
                                                        ConflictingCmd('HDLCompileInit')='vlib %s\n';
                                                        ConflictingCmd('HDLCompileVerilogCmd')='vlog %s %s\n';
                                                        ConflictingCmd('HDLCompileVHDLCmd')='vcom %s %s\n';
                                                        ConflictingCmd('HDLSimCmd')='vsim -voptargs=+acc %s.%s\n';
                                                        ConflictingCmd('HDLSimInit')=['onbreak resume\n','onerror resume\n'];
                                                        ConflictingCmd('HDLSimTerm')='run -all\n';
                                                        ConflictingCmd('HDLSimViewWaveCmd')='add wave sim:%s\n';
                                                        ConflictingCmd('HDLCompileFilePostfix')='_compile.do';
                                                        ConflictingCmd('HDLSimFilePostfix')='_sim.do';

                                                        for ConflictingProp=keys(ConflictingCmd)
                                                            ConflictingProp_Key=ConflictingProp{1};
                                                            if~strcmpi(this.(ConflictingProp_Key),ConflictingCmd(ConflictingProp_Key))

                                                                warning(message('HDLShared:CLI:ConflictingSimCmdAndSimTool',ConflictingProp_Key,this.SimulationTool));
                                                            end
                                                        end








