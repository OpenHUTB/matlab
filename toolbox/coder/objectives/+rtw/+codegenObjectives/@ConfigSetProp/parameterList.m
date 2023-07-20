

function params=parameterList(obj)

    paramHash=obj.ParamHash;

    idx=1;
    params(idx).name='SystemTargetFile';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ArtificialAlgebraicLoopMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='BasePriority';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='BlockReduction';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='BooleanDataType';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='BufferReuse';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='BusObjectLabelMismatch';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CheckExecutionContextPreStartOutputMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CheckExecutionContextRuntimeOutputMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CheckMatrixSingularityMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CheckModelReferenceTargetMessage';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CheckSSInitialOutputMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CombineOutputUpdateFcns';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ConditionallyExecuteInputs';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ConsistencyChecking';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CustomCommentsFcn';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CustomSymbolStrBlkIO';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CustomSymbolStrFcn';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CustomSymbolStrField';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CustomSymbolStrGlobalVar';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CustomSymbolStrMacro';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CustomSymbolStrTmpVar';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CustomSymbolStrType';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CustomSymbolStrUtil';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='DataBitsets';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='DefineNamingRule';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='DiscreteInheritContinuousMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='DownloadToVxWorks';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='EfficientFloat2IntCast';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='EnableCustomComments';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetLargestAtomicInteger';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ExpressionFolding';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='FcnCallInpInsideContextMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ForceParamTrailComments';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='GenCodeOnly';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='GenerateComments';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='GenerateErtSFunction';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='GenerateReport';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='GenerateTraceInfo';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='GenerateTraceReport';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='GenerateTraceReportEml';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetLangStandard';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CodeReplacementLibrary';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='GRTInterface';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='IncludeHyperlinkInReport';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='IncludeMdlTerminateFcn';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='InheritedTsInSrcMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='InlinedPrmAccess';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='InternalIdentifier';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='InlineInvariantSignals';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='InlineParams';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='InsertBlockDesc';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='Int32ToFloatConvMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='IntegerOverflowMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='IntegerSaturationMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='LaunchReport';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='LifeSpan';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='LocalBlockOutputs';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='MakeCommand';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='MangleLength';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='MatFileLogging';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='MaxConsecutiveZCsMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='MaxIdLength';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ModelReferenceCSMismatchMessage';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ModelReferenceDataLoggingMessage';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ModelReferenceIOMismatchMessage';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ModelReferenceIOMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ModelReferenceVersionMismatchMessage';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ModelReferenceMinAlgLoopOccurrences';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ModelReferencePassRootInputsByReference';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='MultiInstanceErrorCode';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='MultiInstanceERTCode';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='MultiTaskCondExecSysMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='MultiTaskDSMMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='MultiTaskRateTransMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='OptimizeBlockIOStorage';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ParameterDowncastMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ParameterOverflowMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ParameterPrecisionLossMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ParameterTunabilityLossMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ParameterUnderflowMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ParamNamingRule';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='PortableWordSizes';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdBitPerChar';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdIntDivRoundTo';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdShiftRightIntArith';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProfileTLC';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='PurelyIntegerCode';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='Y';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ReadBeforeWriteMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ReqsInCode';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='RetainRTWFile';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='RollThreshold';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='RootOutportRequireBusObject';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='RTPrefix';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='RTWCompilerOptimization';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='RTWCustomCompilerOptimizations';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='RTWVerbose';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SampleTimeConstraint';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SFDataObjDesc';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SFcnCompatibilityMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ShowEliminatedStatement';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='OperatorAnnotations';
    params(idx).id=idx;
    params(idx).default='off';
    params(idx).defaultComplementary='on';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SignalInfNanChecking';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SignalLabelMismatchMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SignalNamingRule';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SignalRangeChecking';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SignalResolutionControl';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SigSpecEnsureSampleTimeMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SimulinkBlockComments';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='StateflowObjectComments';
    params(idx).id=idx;
    params(idx).default='off';
    params(idx).defaultComplementary='on';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SimulinkDataObjDesc';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SingleTaskRateTransMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='Solver';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SolverPrmCheckMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SolverType';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='StartTime';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='StateBitsets';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='StethoScope';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='StopTime';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='StrictBusMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SupportAbsoluteTime';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SupportComplex';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SupportContinuousTime';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SupportNonFinite';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SupportNonInlinedSFcns';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SuppressErrorStatus';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='AlgebraicLoopMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TaskStackSize';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TasksWithSamePriorityMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TLCAssert';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TLCCoverage';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TLCDebug';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='UnconnectedInputMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='UnconnectedLineMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='UnconnectedOutputMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='UnderSpecifiedDataTypeMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='UnnecessaryDatatypeConvMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='UpdateModelReferenceTargets';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='UtilityFuncGeneration';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='VectorMatrixConversionMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='WriteAfterReadMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='WriteAfterWriteMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='AssertControl';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='BlockPriorityViolationMsg';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdEqTarget';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ExtMode';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ExtModeIntrfLevel';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='IgnoreCustomStorageClasses';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='GenerateTraceReportSl';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ZeroExternalMemoryAtStartup';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='Y';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='InitFltsAndDblsToZero';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='Y';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='OptimizeModelRefInitCode';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ERTCustomFileBanners';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='GenerateSampleERTMain';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='GenerateTestInterfaces';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ModelStepFunctionPrototypeControlCompliant';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CPPClassGenCompliant';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ParenthesesLevel';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='NoFixptDivByZeroProtection';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CustomSymbolStr';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='CustomSymbolStrBlkIO';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='GenerateTraceReportSf';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ZeroInternalMemoryAtStartup';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='Y';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='EnhancedBackFolding';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='UseDivisionForNetSlopeComputation';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='PassReuseOutputArgsAs';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ConvertIfToSwitch';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdHWDeviceType';
    params(idx).id=idx;
    params(idx).default='custom';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdBitPerInt';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdBitPerLong';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdBitPerShort';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdBitPerLongLong';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdLongLongMode';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdWordSize';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdEndianess';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetHWDeviceType';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetShiftRightIntArith';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetWordSize';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetBitPerChar';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetBitPerInt';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetBitPerShort';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetBitPerLong';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetBitPerLongLong';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetLongLongMode';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetEndianess';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='EvaledLifeSpan';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetIntDivRoundTo';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='EnableUserReplacementTypes';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ReplacementTypes';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='BooleansAsBitfields';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='AutoInsertRateTranBlk';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='DataDefinitionFile';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='DataReferenceFile';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='DefaultParameterBehavior';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='DefineNamingFcn';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ERTMultiwordLength';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ERTMultiwordTypeDef';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='EnableMemcpy';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ExtModeMexArgs';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ExtModeStaticAlloc';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ExtModeStaticAllocSize';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ExtModeTransport';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='GenerateMakefile';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='GlobalDataDefinition';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='GlobalDataReference';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='InsertRTBMode';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='InspectSignalLogs';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='LogVarNameModifier';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='MemcpyThreshold';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='MultiwordTypeDef';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='PositivePriorityOrder';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='RootIOFormat';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SaveCompleteFinalSimState';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SaveFinalState';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SignalLogging';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='SolverMode';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetOS';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetUnknown';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TemplateMakefile';
    params(idx).id=idx;
    params(idx).default='';
    params(idx).defaultComplementary='';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdBitPerFloat';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdBitPerDouble';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdBitPerPointer';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdBitPerSizeT';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdBitPerPtrDiffT';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdLargestAtomicFloat';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='ProdLargestAtomicInteger';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetBitPerDouble';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetBitPerFloat';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetBitPerPointer';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetBitPerSizeT';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetBitPerPtrDiffT';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    idx=idx+1;
    params(idx).name='TargetLargestAtomicFloat';
    params(idx).id=idx;
    params(idx).default='on';
    params(idx).defaultComplementary='off';
    params(idx).reversed='N';
    paramHash.put(params(idx).name,idx);

    obj.ParamHash=paramHash;

end



