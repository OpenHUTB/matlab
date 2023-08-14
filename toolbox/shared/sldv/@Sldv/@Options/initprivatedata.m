function initprivatedata(h)









    pd=h.PrivateData;

    pd.Mode='TestGeneration';

    pd.MaxProcessTime=300;

    pd.AnalysisLevel=2;

    pd.DisplayUnsatisfiableObjectives='off';

    pd.AutomaticStubbing='on';

    pd.UseParallel='off';

    pd.DesignMinMaxConstraints='on';

    pd.AnalysisFilter='off';

    pd.AnalysisFilterFileName='';

    pd.OutputDir='sldv_output/$ModelName$';

    pd.MakeOutputFilesUnique='on';

    pd.BlockReplacement='off';

    pd.BlockReplacementRulesList='<FactoryDefaultRules>';

    pd.BlockReplacementModelFileName='$ModelName$_replacement';


    pd.ParameterConfiguration='None';

    pd.Parameters='off';

    pd.ParametersConfigFileName='sldv_params_template.m';




    pd.ParametersUseConfig='off';

    pd.TestgenTarget='Model';

    pd.ModelCoverageObjectives='ConditionDecision';

    pd.TestConditions='UseLocalSettings';

    pd.TestObjectives='UseLocalSettings';

    pd.MaxTestCaseSteps=10000;

    pd.AllowLegacyTestSuiteOptimization='off';

    pd.TestSuiteOptimization='Auto';

    pd.PathBasedTestGeneration='off';

    pd.PathBasedCustomization=char({});

    pd.ObservabilityCustomization=char({});

    pd.Assertions='UseLocalSettings';

    pd.ProofAssumptions='UseLocalSettings';

    pd.LoadExternalTestCases='off';

    pd.ExternalTestData='';

    pd.GenerateCompleteTestSuite='on';

    pd.ExtendExistingTests='off';

    pd.ExistingTestFile='';

    pd.IgnoreExistTestSatisfied='on';

    pd.IgnoreCovSatisfied='off';

    pd.CoverageDataFile='';

    pd.CovFilter='off';

    pd.CovFilterFileName='';

    pd.IncludeRelationalBoundary='off';

    pd.RelativeTolerance=0.01;

    pd.AbsoluteTolerance=1e-05;

    pd.ErrorDetectionStrategy='DetectErrors';

    pd.DetectDeadLogic='off';

    pd.DetectActiveLogic='on';

    pd.DeadLogicObjectives='ConditionDecision';

    pd.DetectOutOfBounds='on';

    pd.DetectDivisionByZero='on';

    pd.DetectIntegerOverflow='on';

    pd.DetectInfNaN='off';

    pd.DetectSubnormal='off';

    pd.DesignMinMaxCheck='off';

    pd.DetectDSMHazards='off';

    pd.DetectDSMAccessViolations='off';

    pd.DetectBlockConditions='';

    pd.DetectHISMViolationsHisl_0002='off';

    pd.DetectHISMViolationsHisl_0003='off';

    pd.DetectHISMViolationsHisl_0004='off';

    pd.DetectHISMViolationsHisl_0028='off';

    pd.DetectBlockInputRangeViolations='off';

    pd.DetectFloatOverflow='off';

    pd.DetectSFTransConflict='on';

    pd.DetectSFStateInconsistency='on';

    pd.DetectSFArrayOutOfBounds='on';

    pd.DetectEMLArrayOutOfBounds='on';

    pd.DetectSLSelectorOutOfBounds='on';

    pd.DetectSLMPSwitchOutOfBounds='on';

    pd.DetectSLInvalidCast='on';

    pd.DetectSLMergeConflict='on';

    pd.DetectSLUninitializedDSR='on';

    pd.ProvingStrategy='Prove';

    pd.MaxViolationSteps=20;

    pd.SaveDataFile='on';

    pd.DataFileName='$ModelName$_sldvdata';

    pd.SaveExpectedOutput='off';

    pd.RandomizeNoEffectData='off';

    pd.SaveHarnessModel='off';

    pd.HarnessModelFileName='$ModelName$_harness';

    pd.ModelReferenceHarness='on';

    pd.HarnessSource='Signal Editor';

    pd.SaveSystemTestHarness='off';

    pd.SystemTestFileName='$ModelName$_harness';

    pd.SaveReport='off';

    pd.ReportPDFFormat='off';

    pd.ReportFileName='$ModelName$_report';

    pd.ReportIncludeGraphics='off';

    pd.DisplayReport='on';

    pd.DisplayResultsOnModel='off';

    pd.EnableObjComposition='off';

    pd.ObjectiveComposeSpecFileName='sldv_compose_spec.m';

    pd.SFcnSupport='on';

    pd.SFcnExtraOptions='';

    pd.CodeAnalysisExtraOptions='';

    pd.CodeAnalysisIgnoreVolatile='on';

    pd.ReduceRationalApprox='on';

    pd.SlTestFileName='$ModelName$_test';

    pd.SlTestHarnessName='$ModelName$_sldvharness';

    pd.SlTestHarnessSource='Inport';

    pd.StrictEnhancedMCDC='off';

    pd.RebuildModelRepresentation='IfChangeIsDetected';

    pd.RequirementsTableAnalysis='off';

    pd.ExtendUsingSimulation='off';

    pd.AnalyzeAllStartupVariants='on';


    h.PrivateData=pd;
