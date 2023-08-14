function cs=TestModelPumpMotorConfigSet()





    cs=Simulink.ConfigSet;


    if cs.versionCompare('1.16.5')<0
        error('Simulink:MFileVersionViolation','The version of the target configuration set is older than the original configuration set.');
    end







    cs.set_param('Name','TestModelPumpMotorConfigSet');
    cs.set_param('Description','');


    cs.switchTarget('grt.tlc','');

    cs.set_param('HardwareBoard','None');


    cs.set_param('StartTime','0.0');
    cs.set_param('StopTime','0');
    cs.set_param('SolverType','Fixed-step');
    cs.set_param('EnableConcurrentExecution','off');
    cs.set_param('SampleTimeConstraint','Unconstrained');
    cs.set_param('Solver','FixedStepAuto');
    cs.set_param('FixedStep','auto');
    cs.set_param('EnableMultiTasking','off');
    cs.set_param('AutoInsertRateTranBlk','off');
    cs.set_param('PositivePriorityOrder','off');


    cs.set_param('LoadExternalInput','off');
    cs.set_param('LoadInitialState','off');
    cs.set_param('SaveTime','on');
    cs.set_param('TimeSaveName','tout');
    cs.set_param('SaveState','off');
    cs.set_param('SaveFormat','Array');
    cs.set_param('SaveOutput','on');
    cs.set_param('OutputSaveName','yout');
    cs.set_param('SaveFinalState','off');
    cs.set_param('SignalLogging','on');
    cs.set_param('SignalLoggingName','logsout_sh_fixed_pump_motor_characteristic_model');
    cs.set_param('DSMLogging','on');
    cs.set_param('DSMLoggingName','dsmout');
    cs.set_param('LoggingToFile','off');
    cs.set_param('ReturnWorkspaceOutputs','off');
    cs.set_param('InspectSignalLogs','off');
    cs.set_param('StreamToWorkspace','off');
    cs.set_param('LimitDataPoints','off');
    cs.set_param('Decimation','1');
    cs.set_param('VisualizeSimOutput','on');


    cs.set_param('BlockReduction','on');
    cs.set_param('ConditionallyExecuteInputs','on');
    cs.set_param('BooleanDataType','on');
    cs.set_param('LifeSpan','auto');
    cs.set_param('UseDivisionForNetSlopeComputation','off');
    cs.set_param('UseFloatMulNetSlope','off');
    cs.set_param('DefaultUnderspecifiedDataType','double');
    cs.set_param('InitFltsAndDblsToZero','off');
    cs.set_param('EfficientFloat2IntCast','off');
    cs.set_param('EfficientMapNaN2IntZero','on');
    cs.set_param('SimCompilerOptimization','off');
    cs.set_param('AccelVerboseBuild','off');
    cs.set_param('DefaultParameterBehavior','Tunable');
    cs.set_param('OptimizeBlockIOStorage','on');
    cs.set_param('LocalBlockOutputs','on');
    cs.set_param('ExpressionFolding','on');
    cs.set_param('BufferReuse','on');
    cs.set_param('EnableMemcpy','on');
    cs.set_param('MemcpyThreshold',64);
    cs.set_param('RollThreshold',5);
    cs.set_param('MaxStackSize','Inherit from target');
    cs.set_param('StateBitsets','off');
    cs.set_param('DataBitsets','off');
    cs.set_param('ActiveStateOutputEnumStorageType','Native Integer');
    cs.set_param('AdvancedOptControl','');
    cs.set_param('BufferReusableBoundary','on');


    cs.set_param('AlgebraicLoopMsg','warning');
    cs.set_param('ArtificialAlgebraicLoopMsg','warning');
    cs.set_param('BlockPriorityViolationMsg','warning');
    cs.set_param('MinStepSizeMsg','warning');
    cs.set_param('TimeAdjustmentMsg','none');
    cs.set_param('MaxConsecutiveZCsMsg','error');
    cs.set_param('UnknownTsInhSupMsg','warning');
    cs.set_param('ConsistencyChecking','none');
    cs.set_param('SolverPrmCheckMsg','none');
    cs.set_param('ModelReferenceExtraNoncontSigs','error');
    cs.set_param('StateNameClashWarn','none');
    cs.set_param('SimStateInterfaceChecksumMismatchMsg','warning');
    cs.set_param('SimStateOlderReleaseMsg','error');
    cs.set_param('InheritedTsInSrcMsg','warning');
    cs.set_param('MultiTaskRateTransMsg','error');
    cs.set_param('SingleTaskRateTransMsg','none');
    cs.set_param('MultiTaskCondExecSysMsg','error');
    cs.set_param('TasksWithSamePriorityMsg','warning');
    cs.set_param('SigSpecEnsureSampleTimeMsg','warning');
    cs.set_param('SignalResolutionControl','UseLocalSettings');
    cs.set_param('CheckMatrixSingularityMsg','none');
    cs.set_param('IntegerSaturationMsg','warning');
    cs.set_param('UnderSpecifiedDataTypeMsg','none');
    cs.set_param('SignalRangeChecking','none');
    cs.set_param('IntegerOverflowMsg','warning');
    cs.set_param('SignalInfNanChecking','none');
    cs.set_param('RTPrefix','error');
    cs.set_param('ParameterDowncastMsg','error');
    cs.set_param('ParameterOverflowMsg','error');
    cs.set_param('ParameterUnderflowMsg','none');
    cs.set_param('ParameterPrecisionLossMsg','warning');
    cs.set_param('ParameterTunabilityLossMsg','warning');
    cs.set_param('ReadBeforeWriteMsg','UseLocalSettings');
    cs.set_param('WriteAfterReadMsg','UseLocalSettings');
    cs.set_param('WriteAfterWriteMsg','UseLocalSettings');
    cs.set_param('MultiTaskDSMMsg','error');
    cs.set_param('UniqueDataStoreMsg','none');
    cs.set_param('UnderspecifiedInitializationDetection','Simplified');
    cs.set_param('ArrayBoundsChecking','none');
    cs.set_param('AssertControl','UseLocalSettings');
    cs.set_param('AllowSymbolicDim','on');
    cs.set_param('UnnecessaryDatatypeConvMsg','none');
    cs.set_param('VectorMatrixConversionMsg','none');
    cs.set_param('Int32ToFloatConvMsg','warning');
    cs.set_param('FixptConstUnderflowMsg','none');
    cs.set_param('FixptConstOverflowMsg','none');
    cs.set_param('FixptConstPrecisionLossMsg','none');
    cs.set_param('SignalLabelMismatchMsg','none');
    cs.set_param('UnconnectedInputMsg','warning');
    cs.set_param('UnconnectedOutputMsg','warning');
    cs.set_param('UnconnectedLineMsg','warning');
    cs.set_param('RootOutportRequireBusObject','warning');
    cs.set_param('BusObjectLabelMismatch','warning');
    cs.set_param('StrictBusMsg','ErrorLevel1');
    cs.set_param('NonBusSignalsTreatedAsBus','none');
    cs.set_param('BusNameAdapt','WarnAndRepair');
    cs.set_param('InvalidFcnCallConnMsg','error');
    cs.set_param('FcnCallInpInsideContextMsg','error');
    cs.set_param('SFcnCompatibilityMsg','none');
    cs.set_param('FrameProcessingCompatibilityMsg','error');
    cs.set_param('ModelReferenceVersionMismatchMessage','none');
    cs.set_param('ModelReferenceIOMismatchMessage','none');
    cs.set_param('ModelReferenceIOMsg','none');
    cs.set_param('ModelReferenceDataLoggingMessage','warning');
    cs.set_param('SaveWithDisabledLinksMsg','warning');
    cs.set_param('SaveWithParameterizedLinksMsg','warning');
    cs.set_param('SFUnusedDataAndEventsDiag','warning');
    cs.set_param('SFUnexpectedBacktrackingDiag','error');
    cs.set_param('SFInvalidInputDataAccessInChartInitDiag','warning');
    cs.set_param('SFNoUnconditionalDefaultTransitionDiag','error');
    cs.set_param('SFTransitionOutsideNaturalParentDiag','warning');
    cs.set_param('SFUnreachableExecutionPathDiag','warning');
    cs.set_param('SFUndirectedBroadcastEventsDiag','warning');
    cs.set_param('SFTransitionActionBeforeConditionDiag','warning');
    cs.set_param('SFOutputUsedAsStateInMooreChartDiag','error');
    cs.set_param('SFTemporalDelaySmallerThanSampleTimeDiag','warning');
    cs.set_param('SFSelfTransitionDiag','warning');
    cs.set_param('SFExecutionAtInitializationDiag','warning');
    cs.set_param('SFMachineParentedDataDiag','warning');
    cs.set_param('IgnoredZcDiagnostic','warning');
    cs.set_param('InitInArrayFormatMsg','warning');
    cs.set_param('MaskedZcDiagnostic','warning');
    cs.set_param('ModelReferenceSymbolNameMessage','warning');
    cs.set_param('AllowedUnitSystems','all');
    cs.set_param('UnitsInconsistencyMsg','warning');
    cs.set_param('AllowAutomaticUnitConversions','on');


    cs.set_param('ProdHWDeviceType','Intel->x86-64 (Windows64)');
    cs.set_param('ProdLongLongMode','off');
    cs.set_param('ProdEqTarget','on');
    cs.set_param('TargetPreprocMaxBitsSint',32);
    cs.set_param('TargetPreprocMaxBitsUint',32);


    cs.set_param('UpdateModelReferenceTargets','IfOutOfDateOrStructuralChange');
    cs.set_param('EnableParallelModelReferenceBuilds','off');
    cs.set_param('ModelReferenceNumInstancesAllowed','Multi');
    cs.set_param('PropagateVarSize','Infer from blocks in model');
    cs.set_param('ModelReferenceMinAlgLoopOccurrences','off');
    cs.set_param('EnableRefExpFcnMdlSchedulingChecks','on');
    cs.set_param('PropagateSignalLabelsOutOfModel','on');
    cs.set_param('ModelReferencePassRootInputsByReference','on');
    cs.set_param('ModelDependencies','');
    cs.set_param('ParallelModelReferenceErrorOnInvalidPool','on');
    cs.set_param('SupportModelReferenceSimTargetCustomCode','off');


    cs.set_param('MATLABDynamicMemAlloc','on');
    cs.set_param('MATLABDynamicMemAllocThreshold',65536);
    cs.set_param('CompileTimeRecursionLimit',50);
    cs.set_param('EnableRuntimeRecursion','on');
    cs.set_param('SFSimEcho','on');
    cs.set_param('SimCtrlC','on');
    cs.set_param('SimIntegrity','on');
    cs.set_param('SimGenImportedTypeDefs','off');
    cs.set_param('SimBuildMode','sf_incremental_build');
    cs.set_param('SimReservedNameArray',[]);
    cs.set_param('SimParseCustomCode','on');
    cs.set_param('SimCustomSourceCode','');
    cs.set_param('SimCustomHeaderCode','');
    cs.set_param('SimCustomInitializer','');
    cs.set_param('SimCustomTerminator','');
    cs.set_param('SimUserIncludeDirs','');
    cs.set_param('SimUserSources','');
    cs.set_param('SimUserLibraries','');
    cs.set_param('SimUserDefines','');
    cs.set_param('SFSimEnableDebug','off');


    cs.set_param('TargetLang','C');
    cs.set_param('CompOptLevelCompliant','on');
    cs.set_param('Toolchain','Automatically locate an installed toolchain');
    cs.set_param('BuildConfiguration','Faster Builds');
    cs.set_param('ObjectivePriorities',[]);
    cs.set_param('CheckMdlBeforeBuild','Off');
    cs.set_param('GenCodeOnly','off');
    cs.set_param('PackageGeneratedCodeAndArtifacts','off');
    cs.set_param('RTWVerbose','on');
    cs.set_param('RetainRTWFile','off');
    cs.set_param('ProfileTLC','off');
    cs.set_param('TLCDebug','off');
    cs.set_param('TLCCoverage','off');
    cs.set_param('TLCAssert','off');
    cs.set_param('RTWUseSimCustomCode','off');
    cs.set_param('CustomSourceCode','');
    cs.set_param('CustomHeaderCode','');
    cs.set_param('CustomInclude','');
    cs.set_param('CustomSource','');
    cs.set_param('CustomLibrary','');
    cs.set_param('CustomLAPACKCallback','');
    cs.set_param('CustomDefine','');
    cs.set_param('CustomInitializer','');
    cs.set_param('CustomTerminator','');
    cs.set_param('PostCodeGenCommand','');
    cs.set_param('SaveLog','off');
    cs.set_param('TLCOptions','');
    cs.set_param('GenerateReport','off');
    cs.set_param('GenerateComments','on');
    cs.set_param('SimulinkBlockComments','on');
    cs.set_param('MATLABSourceComments','off');
    cs.set_param('ShowEliminatedStatement','off');
    cs.set_param('ForceParamTrailComments','off');
    cs.set_param('MaxIdLength',31);
    cs.set_param('UseSimReservedNames','off');
    cs.set_param('ReservedNameArray',[]);
    cs.set_param('CodeInterfacePackaging','Nonreusable function');
    cs.set_param('IncAutoGenComments','off');
    cs.set_param('IncDataTypeInIds','off');
    cs.set_param('IncHierarchyInIds','off');
    cs.set_param('PreserveName','off');
    cs.set_param('PreserveNameWithParent','off');
    cs.set_param('TargetLangStandard','C89/C90 (ANSI)');
    cs.set_param('CodeReplacementLibrary','None');
    cs.set_param('UtilityFuncGeneration','Auto');
    cs.set_param('GRTInterface','off');
    cs.set_param('SupportNonFinite','on');
    cs.set_param('MultiwordLength',2048);
    cs.set_param('CombineOutputUpdateFcns','on');
    cs.set_param('MatFileLogging','on');
    cs.set_param('LogVarNameModifier','rt_');
    cs.set_param('CPPClassGenCompliant','on');
    cs.set_param('ConcurrentExecutionCompliant','on');
    cs.set_param('ERTFirstTimeCompliant','off');
    cs.set_param('GenerateFullHeader','on');
    cs.set_param('InferredTypesCompatibility','off');
    cs.set_param('ModelReferenceCompliant','on');
    cs.set_param('ParMdlRefBuildCompliant','on');
    cs.set_param('TargetFcnLib','ansi_tfl_table_tmw.mat');
    cs.set_param('TargetLibSuffix','');
    cs.set_param('TargetPreCompLibLocation','');
    cs.set_param('UseToolchainInfoCompliant','on');
    cs.set_param('ExtMode','off');
    cs.set_param('RTWCAPIParams','off');
    cs.set_param('RTWCAPIRootIO','off');
    cs.set_param('RTWCAPISignals','off');
    cs.set_param('RTWCAPIStates','off');
    cs.set_param('GenerateASAP2','off');


    cs.set_param('CovModelRefEnable','off');
    cs.set_param('RecordCoverage','off');
    cs.set_param('CovEnable','off');
    cs.set_param('CovEnableCumulative','on');
    cs.set_param('CovSaveCumulativeToWorkspaceVar','on');
    cs.set_param('CovCumulativeVarName','covCumulativeData');
    cs.set_param('CovSaveName','covdata');
    cs.set_param('CovNameIncrementing','off');
    cs.set_param('CovReportOnPause','on');
    cs.set_param('CovHTMLOptions','');
    cs.set_param('CovCumulativeReport','off');
    cs.set_param('CovCompData','');
    cs.set_param('CovFilter','');
    cs.set_param('CovSaveOutputData','on');


    try
        cs_componentCC=hdlcoderui.hdlcc;
        cs_componentCC.createCLI();
        cs.attachComponent(cs_componentCC);
    catch ME
        warning('Simulink:ConfigSet:AttachComponentError',ME.message);
    end


    try
        cs_componentCC=SSC.SimscapeCC;
        cs.attachComponent(cs_componentCC);
        cs.set_param('EditingMode','Full');
        cs.set_param('ExplicitSolverDiagnosticOptions','warning');
        cs.set_param('GlobalZcOffDiagnosticOptions','warning');
        cs.set_param('SimscapeLogType','all');
        cs.set_param('SimscapeLogSimulationStatistics','on');
        cs.set_param('SimscapeLogOpenViewer','off');
        cs.set_param('SimscapeLogName','simlog_sh_fixed_pump_motor_characteristic_model');
        cs.set_param('SimscapeLogDecimation',1);
        cs.set_param('SimscapeLogLimitData','on');
        cs.set_param('SimscapeLogDataHistory',10000);
    catch ME
        warning('Simulink:ConfigSet:AttachComponentError',ME.message);
    end