function restoreDefaults(h,hDlg)









    if nargin<2
        hDlg=[];
    end

    if~isempty(hDlg)
        TagMain='ConfigSet_SlAvt_MainPanel_';

        objProp=[h.productTag,'Mode'];
        hDlg.setWidgetValue([TagMain,objProp],1);

        objProp=[h.productTag,'MaxProcessTime'];
        hDlg.setWidgetValue([TagMain,objProp],'300');

        objProp=[h.productTag,'MaxTestCaseSteps'];
        changeWidgetAppearance(hDlg,TagMain,objProp,'10000');

        objProp=[h.productTag,'OutputDir'];
        hDlg.setWidgetValue([TagMain,objProp],'sldv_output/$ModelName$');

        objProp=[h.productTag,'MakeOutputFilesUnique'];
        hDlg.setWidgetValue([TagMain,objProp],true);


        TagPreprocess='ConfigSet_SlAvt_PreprocessPanel_';

        objProp=[h.productTag,'BlockReplacement'];
        hDlg.setWidgetValue([TagPreprocess,objProp],false);

        objProp=[h.productTag,'BlockReplacementModelFileName'];
        changeWidgetAppearance(hDlg,TagPreprocess,objProp,'$ModelName$_replacement');

        TagTest='ConfigSet_SlAvt_TestGenerationPanel_';

        objProp=[h.productTag,'TestConditions'];
        hDlg.setWidgetValue([TagTest,objProp],0);

        objProp=[h.productTag,'TestObjectives'];
        hDlg.setWidgetValue([TagTest,objProp],0);

        objProp=[h.productTag,'ModelCoverageObjectives'];
        hDlg.setWidgetValue([TagTest,objProp],2);

        objProp=[h.productTag,'TestSuiteOptimization'];
        hDlg.setWidgetValue([TagTest,objProp],0);

        TagAssert='ConfigSet_SlAvt_AssertionDebugPanel_';

        objProp=[h.productTag,'Assertions'];
        hDlg.setWidgetValue([TagAssert,objProp],0);

        objProp=[h.productTag,'ProofAssumptions'];
        hDlg.setWidgetValue([TagAssert,objProp],0);

        objProp=[h.productTag,'ProvingStrategy'];
        hDlg.setWidgetValue([TagAssert,objProp],02);

        TagResult='ConfigSet_SlAvt_ResultsPanel_';

        objProp=[h.productTag,'SaveHarnessModel'];
        hDlg.setWidgetValue([TagResult,objProp],false);

        objProp=[h.productTag,'HarnessModelFileName'];
        changeWidgetAppearance(hDlg,TagResult,objProp,'$ModelName$_harness');

        objProp=[h.productTag,'DataFileName'];
        changeWidgetAppearance(hDlg,TagResult,objProp,'$ModelName$_sldvdata');

        TagReport='ConfigSet_SlAvt_ReportPanel_';

        objProp=[h.productTag,'SaveReport'];
        hDlg.setWidgetValue([TagReport,objProp],false);

        objProp=[h.productTag,'ReportPDFFormat'];
        hDlg.setWidgetValue([TagReport,objProp],false);

        objProp=[h.productTag,'ReportFileName'];
        changeWidgetAppearance(hDlg,TagReport,objProp,'$ModelName$_report');

    else
        Tag=h.productTag;

        set(h,[Tag,'Mode'],'TestGeneration');
        set(h,[Tag,'MaxProcessTime'],300);
        set(h,[Tag,'AnalysisLevel'],2);
        set(h,[Tag,'DisplayUnsatisfiableObjectives'],'off');
        set(h,[Tag,'AutomaticStubbing'],'on');
        set(h,[Tag,'UseParallel'],'off');
        set(h,[Tag,'DesignMinMaxConstraints'],'on');
        set(h,[Tag,'AnalysisFilter'],'off');
        set(h,[Tag,'AnalysisFilterFileName'],'');
        set(h,[Tag,'OutputDir'],'sldv_output/$ModelName$');
        set(h,[Tag,'MakeOutputFilesUnique'],'on');
        set(h,[Tag,'BlockReplacement'],'off');
        set(h,[Tag,'BlockReplacementRulesList'],'<FactoryDefaultRules>');
        set(h,[Tag,'BlockReplacementModelFileName'],'$ModelName$_replacement');
        set(h,[Tag,'SubSystemToStub'],[]);
        set(h,[Tag,'ParameterConfiguration'],'None');
        set(h,[Tag,'Parameters'],'off');
        set(h,[Tag,'ParametersConfigFileName'],'sldv_params_template.m');
        set(h,[Tag,'ParameterNames'],[]);
        set(h,[Tag,'ParameterConstraints'],[]);
        set(h,[Tag,'ParameterUseInAnalysis'],[]);
        set(h,[Tag,'ParametersUseConfig'],'off');
        set(h,[Tag,'TestgenTarget'],'Model');
        set(h,[Tag,'ModelCoverageObjectives'],'ConditionDecision');
        set(h,[Tag,'TestConditions'],'UseLocalSettings');
        set(h,[Tag,'TestObjectives'],'UseLocalSettings');
        set(h,[Tag,'MaxTestCaseSteps'],10000);
        set(h,[Tag,'AllowLegacyTestSuiteOptimization'],'off');
        set(h,[Tag,'TestSuiteOptimization'],'Auto');
        set(h,[Tag,'PathBasedTestGeneration'],'off');
        set(h,[Tag,'PathBasedCustomization'],char({}));
        set(h,[Tag,'ObservabilityCustomization'],char({}));
        set(h,[Tag,'Assertions'],'UseLocalSettings');
        set(h,[Tag,'ProofAssumptions'],'UseLocalSettings');
        set(h,[Tag,'LoadExternalTestCases'],'off');
        set(h,[Tag,'ExternalTestData'],'');
        set(h,[Tag,'GenerateCompleteTestSuite'],'on');
        set(h,[Tag,'ExtendExistingTests'],'off');
        set(h,[Tag,'ExistingTestFile'],'');
        set(h,[Tag,'IgnoreExistTestSatisfied'],'on');
        set(h,[Tag,'IgnoreCovSatisfied'],'off');
        set(h,[Tag,'CoverageDataFile'],'');
        set(h,[Tag,'CovFilter'],'off');
        set(h,[Tag,'CovFilterFileName'],'');
        set(h,[Tag,'IncludeRelationalBoundary'],'off');
        set(h,[Tag,'RelativeTolerance'],0.01);
        set(h,[Tag,'AbsoluteTolerance'],1e-05);
        set(h,[Tag,'ErrorDetectionStrategy'],'DetectErrors');
        set(h,[Tag,'DetectDeadLogic'],'off');
        set(h,[Tag,'DetectActiveLogic'],'on');
        set(h,[Tag,'DeadLogicObjectives'],'ConditionDecision');
        set(h,[Tag,'DetectOutOfBounds'],'on');
        set(h,[Tag,'DetectDivisionByZero'],'on');
        set(h,[Tag,'DetectIntegerOverflow'],'on');
        set(h,[Tag,'DetectInfNaN'],'off');
        set(h,[Tag,'DetectSubnormal'],'off');
        set(h,[Tag,'DesignMinMaxCheck'],'off');
        set(h,[Tag,'DetectDSMHazards'],'off');
        set(h,[Tag,'DetectDSMAccessViolations'],'off');
        set(h,[Tag,'DetectBlockConditions'],'');
        set(h,[Tag,'DetectHISMViolationsHisl_0002'],'off');
        set(h,[Tag,'DetectHISMViolationsHisl_0003'],'off');
        set(h,[Tag,'DetectHISMViolationsHisl_0004'],'off');
        set(h,[Tag,'DetectHISMViolationsHisl_0028'],'off');
        set(h,[Tag,'DetectBlockInputRangeViolations'],'off');
        set(h,[Tag,'DetectFloatOverflow'],'off');
        set(h,[Tag,'DetectSFTransConflict'],'on');
        set(h,[Tag,'DetectSFStateInconsistency'],'on');
        set(h,[Tag,'DetectSFArrayOutOfBounds'],'on');
        set(h,[Tag,'DetectEMLArrayOutOfBounds'],'on');
        set(h,[Tag,'DetectSLSelectorOutOfBounds'],'on');
        set(h,[Tag,'DetectSLMPSwitchOutOfBounds'],'on');
        set(h,[Tag,'DetectSLInvalidCast'],'on');
        set(h,[Tag,'DetectSLMergeConflict'],'on');
        set(h,[Tag,'DetectSLUninitializedDSR'],'on');
        set(h,[Tag,'ProvingStrategy'],'Prove');
        set(h,[Tag,'MaxViolationSteps'],20);
        set(h,[Tag,'SaveDataFile'],'on');
        set(h,[Tag,'DataFileName'],'$ModelName$_sldvdata');
        set(h,[Tag,'SaveExpectedOutput'],'off');
        set(h,[Tag,'RandomizeNoEffectData'],'off');
        set(h,[Tag,'SaveHarnessModel'],'off');
        set(h,[Tag,'HarnessModelFileName'],'$ModelName$_harness');
        set(h,[Tag,'ModelReferenceHarness'],'on');
        set(h,[Tag,'HarnessSource'],'Signal Editor');
        set(h,[Tag,'SaveSystemTestHarness'],'off');
        set(h,[Tag,'SystemTestFileName'],'$ModelName$_harness');
        set(h,[Tag,'SaveReport'],'off');
        set(h,[Tag,'ReportPDFFormat'],'off');
        set(h,[Tag,'ReportFileName'],'$ModelName$_report');
        set(h,[Tag,'ReportIncludeGraphics'],'off');
        set(h,[Tag,'DisplayReport'],'on');
        set(h,[Tag,'DisplayResultsOnModel'],'off');
        set(h,[Tag,'EnableObjComposition'],'off');
        set(h,[Tag,'ObjectiveComposeSpecFileName'],'sldv_compose_spec.m');
        set(h,[Tag,'SFcnSupport'],'on');
        set(h,[Tag,'SFcnExtraOptions'],'');
        set(h,[Tag,'CodeAnalysisExtraOptions'],'');
        set(h,[Tag,'CodeAnalysisIgnoreVolatile'],'on');
        set(h,[Tag,'ReduceRationalApprox'],'on');
        set(h,[Tag,'SlTestFileName'],'$ModelName$_test');
        set(h,[Tag,'SlTestHarnessName'],'$ModelName$_sldvharness');
        set(h,[Tag,'SlTestHarnessSource'],'Inport');
        set(h,[Tag,'StrictEnhancedMCDC'],'off');
        set(h,[Tag,'RebuildModelRepresentation'],'IfChangeIsDetected');
        set(h,[Tag,'RequirementsTableAnalysis'],'off');
        set(h,[Tag,'ExtendUsingSimulation'],'off');
        set(h,[Tag,'AnalyzeAllStartupVariants'],'on');

    end



    function changeWidgetAppearance(hDlg,tag,objProp,val)

        hDlg.setEnabled([tag,objProp,'Enabled'],true);
        hDlg.setVisible([tag,objProp,'Enabled'],true);
        hDlg.setWidgetValue([tag,objProp,'Enabled'],val);
        hDlg.setVisible([tag,objProp,'Disabled'],false);
