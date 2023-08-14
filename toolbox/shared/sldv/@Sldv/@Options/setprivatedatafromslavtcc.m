function setprivatedatafromslavtcc(h)









    pd=h.PrivateData;

    pd.Mode=get(h.sldvcc,[h.extproductTag,'Mode']);

    pd.MaxProcessTime=get(h.sldvcc,[h.extproductTag,'MaxProcessTime']);

    pd.AnalysisLevel=get(h.sldvcc,[h.extproductTag,'AnalysisLevel']);

    pd.DisplayUnsatisfiableObjectives=get(h.sldvcc,[h.extproductTag,'DisplayUnsatisfiableObjectives']);

    pd.AutomaticStubbing=get(h.sldvcc,[h.extproductTag,'AutomaticStubbing']);

    pd.UseParallel=get(h.sldvcc,[h.extproductTag,'UseParallel']);

    pd.DesignMinMaxConstraints=get(h.sldvcc,[h.extproductTag,'DesignMinMaxConstraints']);

    pd.AnalysisFilter=get(h.sldvcc,[h.extproductTag,'AnalysisFilter']);

    pd.AnalysisFilterFileName=get(h.sldvcc,[h.extproductTag,'AnalysisFilterFileName']);

    pd.OutputDir=get(h.sldvcc,[h.extproductTag,'OutputDir']);

    pd.MakeOutputFilesUnique=get(h.sldvcc,[h.extproductTag,'MakeOutputFilesUnique']);

    pd.BlockReplacement=get(h.sldvcc,[h.extproductTag,'BlockReplacement']);

    pd.BlockReplacementRulesList=get(h.sldvcc,[h.extproductTag,'BlockReplacementRulesList']);

    pd.BlockReplacementModelFileName=get(h.sldvcc,[h.extproductTag,'BlockReplacementModelFileName']);


    pd.ParameterConfiguration=get(h.sldvcc,[h.extproductTag,'ParameterConfiguration']);

    pd.Parameters=get(h.sldvcc,[h.extproductTag,'Parameters']);

    pd.ParametersConfigFileName=get(h.sldvcc,[h.extproductTag,'ParametersConfigFileName']);




    pd.ParametersUseConfig=get(h.sldvcc,[h.extproductTag,'ParametersUseConfig']);

    pd.TestgenTarget=get(h.sldvcc,[h.extproductTag,'TestgenTarget']);

    pd.ModelCoverageObjectives=get(h.sldvcc,[h.extproductTag,'ModelCoverageObjectives']);

    pd.TestConditions=get(h.sldvcc,[h.extproductTag,'TestConditions']);

    pd.TestObjectives=get(h.sldvcc,[h.extproductTag,'TestObjectives']);

    pd.MaxTestCaseSteps=get(h.sldvcc,[h.extproductTag,'MaxTestCaseSteps']);

    pd.AllowLegacyTestSuiteOptimization=get(h.sldvcc,[h.extproductTag,'AllowLegacyTestSuiteOptimization']);

    pd.TestSuiteOptimization=get(h.sldvcc,[h.extproductTag,'TestSuiteOptimization']);

    pd.PathBasedTestGeneration=get(h.sldvcc,[h.extproductTag,'PathBasedTestGeneration']);

    pd.PathBasedCustomization=get(h.sldvcc,[h.extproductTag,'PathBasedCustomization']);

    pd.ObservabilityCustomization=get(h.sldvcc,[h.extproductTag,'ObservabilityCustomization']);

    pd.Assertions=get(h.sldvcc,[h.extproductTag,'Assertions']);

    pd.ProofAssumptions=get(h.sldvcc,[h.extproductTag,'ProofAssumptions']);

    pd.LoadExternalTestCases=get(h.sldvcc,[h.extproductTag,'LoadExternalTestCases']);

    pd.ExternalTestData=get(h.sldvcc,[h.extproductTag,'ExternalTestData']);

    pd.GenerateCompleteTestSuite=get(h.sldvcc,[h.extproductTag,'GenerateCompleteTestSuite']);

    pd.ExtendExistingTests=get(h.sldvcc,[h.extproductTag,'ExtendExistingTests']);

    pd.ExistingTestFile=get(h.sldvcc,[h.extproductTag,'ExistingTestFile']);

    pd.IgnoreExistTestSatisfied=get(h.sldvcc,[h.extproductTag,'IgnoreExistTestSatisfied']);

    pd.IgnoreCovSatisfied=get(h.sldvcc,[h.extproductTag,'IgnoreCovSatisfied']);

    pd.CoverageDataFile=get(h.sldvcc,[h.extproductTag,'CoverageDataFile']);

    pd.CovFilter=get(h.sldvcc,[h.extproductTag,'CovFilter']);

    pd.CovFilterFileName=get(h.sldvcc,[h.extproductTag,'CovFilterFileName']);

    pd.IncludeRelationalBoundary=get(h.sldvcc,[h.extproductTag,'IncludeRelationalBoundary']);

    pd.RelativeTolerance=get(h.sldvcc,[h.extproductTag,'RelativeTolerance']);

    pd.AbsoluteTolerance=get(h.sldvcc,[h.extproductTag,'AbsoluteTolerance']);

    pd.ErrorDetectionStrategy=get(h.sldvcc,[h.extproductTag,'ErrorDetectionStrategy']);

    pd.DetectDeadLogic=get(h.sldvcc,[h.extproductTag,'DetectDeadLogic']);

    pd.DetectActiveLogic=get(h.sldvcc,[h.extproductTag,'DetectActiveLogic']);

    pd.DeadLogicObjectives=get(h.sldvcc,[h.extproductTag,'DeadLogicObjectives']);

    pd.DetectOutOfBounds=get(h.sldvcc,[h.extproductTag,'DetectOutOfBounds']);

    pd.DetectDivisionByZero=get(h.sldvcc,[h.extproductTag,'DetectDivisionByZero']);

    pd.DetectIntegerOverflow=get(h.sldvcc,[h.extproductTag,'DetectIntegerOverflow']);

    pd.DetectInfNaN=get(h.sldvcc,[h.extproductTag,'DetectInfNaN']);

    pd.DetectSubnormal=get(h.sldvcc,[h.extproductTag,'DetectSubnormal']);

    pd.DesignMinMaxCheck=get(h.sldvcc,[h.extproductTag,'DesignMinMaxCheck']);

    pd.DetectDSMHazards=get(h.sldvcc,[h.extproductTag,'DetectDSMHazards']);

    pd.DetectDSMAccessViolations=get(h.sldvcc,[h.extproductTag,'DetectDSMAccessViolations']);

    pd.DetectBlockConditions=get(h.sldvcc,[h.extproductTag,'DetectBlockConditions']);

    pd.DetectHISMViolationsHisl_0002=get(h.sldvcc,[h.extproductTag,'DetectHISMViolationsHisl_0002']);

    pd.DetectHISMViolationsHisl_0003=get(h.sldvcc,[h.extproductTag,'DetectHISMViolationsHisl_0003']);

    pd.DetectHISMViolationsHisl_0004=get(h.sldvcc,[h.extproductTag,'DetectHISMViolationsHisl_0004']);

    pd.DetectHISMViolationsHisl_0028=get(h.sldvcc,[h.extproductTag,'DetectHISMViolationsHisl_0028']);

    pd.DetectBlockInputRangeViolations=get(h.sldvcc,[h.extproductTag,'DetectBlockInputRangeViolations']);

    pd.DetectFloatOverflow=get(h.sldvcc,[h.extproductTag,'DetectFloatOverflow']);

    pd.DetectSFTransConflict=get(h.sldvcc,[h.extproductTag,'DetectSFTransConflict']);

    pd.DetectSFStateInconsistency=get(h.sldvcc,[h.extproductTag,'DetectSFStateInconsistency']);

    pd.DetectSFArrayOutOfBounds=get(h.sldvcc,[h.extproductTag,'DetectSFArrayOutOfBounds']);

    pd.DetectEMLArrayOutOfBounds=get(h.sldvcc,[h.extproductTag,'DetectEMLArrayOutOfBounds']);

    pd.DetectSLSelectorOutOfBounds=get(h.sldvcc,[h.extproductTag,'DetectSLSelectorOutOfBounds']);

    pd.DetectSLMPSwitchOutOfBounds=get(h.sldvcc,[h.extproductTag,'DetectSLMPSwitchOutOfBounds']);

    pd.DetectSLInvalidCast=get(h.sldvcc,[h.extproductTag,'DetectSLInvalidCast']);

    pd.DetectSLMergeConflict=get(h.sldvcc,[h.extproductTag,'DetectSLMergeConflict']);

    pd.DetectSLUninitializedDSR=get(h.sldvcc,[h.extproductTag,'DetectSLUninitializedDSR']);

    pd.ProvingStrategy=get(h.sldvcc,[h.extproductTag,'ProvingStrategy']);

    pd.MaxViolationSteps=get(h.sldvcc,[h.extproductTag,'MaxViolationSteps']);

    pd.SaveDataFile=get(h.sldvcc,[h.extproductTag,'SaveDataFile']);

    pd.DataFileName=get(h.sldvcc,[h.extproductTag,'DataFileName']);

    pd.SaveExpectedOutput=get(h.sldvcc,[h.extproductTag,'SaveExpectedOutput']);

    pd.RandomizeNoEffectData=get(h.sldvcc,[h.extproductTag,'RandomizeNoEffectData']);

    pd.SaveHarnessModel=get(h.sldvcc,[h.extproductTag,'SaveHarnessModel']);

    pd.HarnessModelFileName=get(h.sldvcc,[h.extproductTag,'HarnessModelFileName']);

    pd.ModelReferenceHarness=get(h.sldvcc,[h.extproductTag,'ModelReferenceHarness']);

    pd.HarnessSource=get(h.sldvcc,[h.extproductTag,'HarnessSource']);

    pd.SaveSystemTestHarness=get(h.sldvcc,[h.extproductTag,'SaveSystemTestHarness']);

    pd.SystemTestFileName=get(h.sldvcc,[h.extproductTag,'SystemTestFileName']);

    pd.SaveReport=get(h.sldvcc,[h.extproductTag,'SaveReport']);

    pd.ReportPDFFormat=get(h.sldvcc,[h.extproductTag,'ReportPDFFormat']);

    pd.ReportFileName=get(h.sldvcc,[h.extproductTag,'ReportFileName']);

    pd.ReportIncludeGraphics=get(h.sldvcc,[h.extproductTag,'ReportIncludeGraphics']);

    pd.DisplayReport=get(h.sldvcc,[h.extproductTag,'DisplayReport']);

    pd.DisplayResultsOnModel=get(h.sldvcc,[h.extproductTag,'DisplayResultsOnModel']);

    pd.EnableObjComposition=get(h.sldvcc,[h.extproductTag,'EnableObjComposition']);

    pd.ObjectiveComposeSpecFileName=get(h.sldvcc,[h.extproductTag,'ObjectiveComposeSpecFileName']);

    pd.SFcnSupport=get(h.sldvcc,[h.extproductTag,'SFcnSupport']);

    pd.SFcnExtraOptions=get(h.sldvcc,[h.extproductTag,'SFcnExtraOptions']);

    pd.CodeAnalysisExtraOptions=get(h.sldvcc,[h.extproductTag,'CodeAnalysisExtraOptions']);

    pd.CodeAnalysisIgnoreVolatile=get(h.sldvcc,[h.extproductTag,'CodeAnalysisIgnoreVolatile']);

    pd.ReduceRationalApprox=get(h.sldvcc,[h.extproductTag,'ReduceRationalApprox']);

    pd.SlTestFileName=get(h.sldvcc,[h.extproductTag,'SlTestFileName']);

    pd.SlTestHarnessName=get(h.sldvcc,[h.extproductTag,'SlTestHarnessName']);

    pd.SlTestHarnessSource=get(h.sldvcc,[h.extproductTag,'SlTestHarnessSource']);

    pd.StrictEnhancedMCDC=get(h.sldvcc,[h.extproductTag,'StrictEnhancedMCDC']);

    pd.RebuildModelRepresentation=get(h.sldvcc,[h.extproductTag,'RebuildModelRepresentation']);

    pd.RequirementsTableAnalysis=get(h.sldvcc,[h.extproductTag,'RequirementsTableAnalysis']);

    pd.ExtendUsingSimulation=get(h.sldvcc,[h.extproductTag,'ExtendUsingSimulation']);

    pd.AnalyzeAllStartupVariants=get(h.sldvcc,[h.extproductTag,'AnalyzeAllStartupVariants']);


    h.PrivateData=pd;
