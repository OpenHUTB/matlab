

function dependency=dependencyList(~)

    idx=1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='MatFileLogging';
    dependency{idx}.valueLeft='On';
    dependency{idx}.nameRight{1}='SuppressErrorStatus';
    dependency{idx}.valueRight{1}='Off';




    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='ExtMode';
    dependency{idx}.valueLeft='on';
    dependency{idx}.nameRight{1}='SuppressErrorStatus';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GRTInterface';
    dependency{idx}.valueLeft='on';
    dependency{idx}.nameRight{1}='PurelyIntegerCode';
    dependency{idx}.valueRight{1}='on';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GRTInterface';
    dependency{idx}.valueLeft='On';
    dependency{idx}.nameRight{1}='CombineOutputUpdateFcns';
    dependency{idx}.valueRight{1}='Off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='PurelyIntegerCode';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='SupportNonFinite';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='OptimizeBlockIOStorage';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='ExpressionFolding';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='OptimizeBlockIOStorage';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='BufferReuse';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='OptimizeBlockIOStorage';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='GlobalBufferReuse';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='OptimizeBlockIOStorage';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='LocalBlockOutputs';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='OptimizeBlockIOStorage';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='EnhancedBackFolding';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='OptimizeBlockIOStorage';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='BusAssignmentInplaceUpdate';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='OptimizeBlockIOStorage';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='OptimizeDataStoreBuffers';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='OptimizeBlockIOStorage';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='GlobalVariableUsage';
    dependency{idx}.valueRight{1}='None';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='OptimizeBlockIOStorage';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='DifferentSizesBufferReuse';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateReport';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='GenerateTraceInfo';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateReport';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='GenerateTraceReport';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateReport';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='GenerateTraceReportSl';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateReport';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='GenerateTraceReportSf';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateReport';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='GenerateTraceReportEml';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateReport';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='LaunchReport';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateReport';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='GenerateCodeReplacementReport';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateReport';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='GenerateWebview';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateReport';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='IncludeHyperlinkInReport';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateComments';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='SimulinkBlockComments';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateComments';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='StateflowObjectComments';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateComments';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='ShowEliminatedStatement';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateComments';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='OperatorAnnotations';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateComments';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='ForceParamTrailComments';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateComments';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='InsertBlockDesc';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateComments';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='SimulinkDataObjDesc';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateComments';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='EnableCustomComments';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateComments';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='SFDataObjDesc';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateComments';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='ReqsInCode';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateComments';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='MATLABSourceComments';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='GenerateComments';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='MATLABFcnDesc';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='ProdHWDeviceType';
    dependency{idx}.valueLeft='32-bit Generic';
    dependency{idx}.nameRight{1}='ProdLongLongMode';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='TargetHWDeviceType';
    dependency{idx}.valueLeft='32-bit Generic';
    dependency{idx}.nameRight{1}='TargetLongLongMode';
    dependency{idx}.valueRight{1}='off';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='ProdEqTarget';
    dependency{idx}.valueLeft='on';
    dependency{idx}.nameRight{1}='TargetHWDeviceType';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='EnableUserReplacementTypes';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='ReplacementTypes';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='EnableCustomComments';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='CustomCommentsFcn';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='GlobalDataDefinition';
    dependency{idx}.valueLeft='InSeparateSourceFile';
    dependency{idx}.nameRight{1}='DataDefinitionFile';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='GlobalDataReference';
    dependency{idx}.valueLeft='InSeparateHeaderFile';
    dependency{idx}.nameRight{1}='DataReferenceFile';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='SignalNamingRule';
    dependency{idx}.valueLeft='Custom';
    dependency{idx}.nameRight{1}='DefineNamingFcn';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='EnableMemcpy';
    dependency{idx}.valueLeft='on';
    dependency{idx}.nameRight{1}='MemcpyThreshold';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='ExtModeStaticAlloc';
    dependency{idx}.valueLeft='on';
    dependency{idx}.nameRight{1}='ExtModeStaticAllocSize';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='GenerateMakefile';
    dependency{idx}.valueLeft='on';
    dependency{idx}.nameRight{1}='MakeCommand';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='GenerateMakefile';
    dependency{idx}.valueLeft='on';
    dependency{idx}.nameRight{1}='TemplateMakefile';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='GenerateSampleERTMain';
    dependency{idx}.valueLeft='on';
    dependency{idx}.nameRight{1}='TargetOS';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='AutoInsertRateTranBlk';
    dependency{idx}.valueLeft='on';
    dependency{idx}.nameRight{1}='InsertRTBMode';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='SignalLogging';
    dependency{idx}.valueLeft='on';
    dependency{idx}.nameRight{1}='InspectSignalLogs';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='MatFileLogging';
    dependency{idx}.valueLeft='On';
    dependency{idx}.nameRight{1}='LogVarNameModifier';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='CodeInterfacePackaging';
    dependency{idx}.valueLeft='Nonreusable function';
    dependency{idx}.nameRight{1}='MultiInstanceErrorCode';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='CodeInterfacePackaging';
    dependency{idx}.valueLeft='Reusable function';
    dependency{idx}.nameRight{1}='RootIOFormat';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='SaveFinalState';
    dependency{idx}.valueLeft='On';
    dependency{idx}.nameRight{1}='SaveCompleteFinalSimState';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='ParamNamingRule';
    dependency{idx}.valueLeft='Custom';
    dependency{idx}.nameRight{1}='DefineNamingFcn';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='RTWCompilerOptimization';
    dependency{idx}.valueLeft='Custom';
    dependency{idx}.nameRight{1}='RTWCustomCompilerOptimizations';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='SolverType';
    dependency{idx}.valueLeft='Fixed-step';
    dependency{idx}.nameRight{1}='SampleTimeConstraint';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='SampleTimeConstraint';
    dependency{idx}.valueLeft='Unconstrained';
    dependency{idx}.nameRight{1}='SolverMode';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='SampleTimeConstraint';
    dependency{idx}.valueLeft='Unconstrained';
    dependency{idx}.nameRight{1}='AutoInsertRateTranBlk';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='SampleTimeConstraint';
    dependency{idx}.valueLeft='Unconstrained';
    dependency{idx}.nameRight{1}='PositivePriorityOrder';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='UpdateModelReferenceTargets';
    dependency{idx}.valueLeft='AssumeUpToDate';
    dependency{idx}.nameRight{1}='CheckModelReferenceTargetMessage';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='ExtMode';
    dependency{idx}.valueLeft='on';
    dependency{idx}.nameRight{1}='ExtModeTransport';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='ExtMode';
    dependency{idx}.valueLeft='on';
    dependency{idx}.nameRight{1}='ExtModeMexArgs';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='ExtMode';
    dependency{idx}.valueLeft='on';
    dependency{idx}.nameRight{1}='ExtModeStaticAlloc';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='LoadExternalInput';
    dependency{idx}.valueLeft='On';
    dependency{idx}.nameRight{1}='ExternalInput';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='LoadInitialState';
    dependency{idx}.valueLeft='On';
    dependency{idx}.nameRight{1}='InitialState';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='SaveTime';
    dependency{idx}.valueLeft='On';
    dependency{idx}.nameRight{1}='TimeSaveName';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='SaveState';
    dependency{idx}.valueLeft='On';
    dependency{idx}.nameRight{1}='StateSaveName';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='SaveOutput';
    dependency{idx}.valueLeft='On';
    dependency{idx}.nameRight{1}='OutputSaveName';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='SaveFinalState';
    dependency{idx}.valueLeft='On';
    dependency{idx}.nameRight{1}='FinalStateName';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='SignalLogging';
    dependency{idx}.valueLeft='On';
    dependency{idx}.nameRight{1}='InspectSignalLogs';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='DSMLogging';
    dependency{idx}.valueLeft='On';
    dependency{idx}.nameRight{1}='DSMLoggingName';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='ReturnWorkspaceOutputs';
    dependency{idx}.valueLeft='On';
    dependency{idx}.nameRight{1}='ReturnWorkspaceOutputsName';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='LimitDataPoints';
    dependency{idx}.valueLeft='On';
    dependency{idx}.nameRight{1}='MaxDataPoints';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='n';
    dependency{idx}.nameLeft='DefaultParameterBehavior';
    dependency{idx}.valueLeft='Inlined';
    dependency{idx}.nameRight{1}='InlineInvariantSignals';
    dependency{idx}.valueRight{1}='DISABLED';

    idx=idx+1;
    dependency{idx}.id=idx;
    dependency{idx}.force='Y';
    dependency{idx}.logic='p';
    dependency{idx}.nameLeft='OptimizeBlockIOStorage';
    dependency{idx}.valueLeft='off';
    dependency{idx}.nameRight{1}='ReuseModelBlockBuffer';
    dependency{idx}.valueRight{1}='off';

end


