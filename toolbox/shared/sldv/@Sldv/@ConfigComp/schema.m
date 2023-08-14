function schema








    pk=findpackage('Sldv');
    parentcls=findclass(findpackage('Simulink'),'CustomCC');
    c=schema.class(pk,'ConfigComp',parentcls);

    visibility='on';
    privateVisibility='off';
    Tag='DV';





    if isempty(findtype('enumTestSuiteOptimization'))||isempty(findtype('enumProvingStrategy'))
        testStrategies={'Auto','CombinedObjectives (Nonlinear Extended)','IndividualObjectives','LongTestcases','LargeModel (Nonlinear Extended)','CombinedObjectives','LargeModel'};
        proveStrategies={'Prove','FindViolation','ProveWithViolationDetection'};
        if exist('Sldv.ExternalEngineUtils','class')
            external=Sldv.ExternalEngineUtils.getAll;
        else
            external={};
        end
        for i=1:length(external)
            try
                eng=eval(external{i}.Name);
                if eng.TestCaseGeneration
                    testStrategies{end+1}=eng.Name;
                end
                if eng.PropertyProving
                    proveStrategies{end+1}=eng.Name;
                end
            catch MEx %#ok<NASGU>

            end
        end
    end

    if isempty(findtype('enumMode'))
        schema.EnumType('enumMode',{'DesignErrorDetection','TestGeneration','PropertyProving'});
    end

    if isempty(findtype('enumTestgenTarget'))
        schema.EnumType('enumTestgenTarget',{'Model','GenCodeTopModel','GenCodeModelRef'});
    end

    if isempty(findtype('enumTestandCheck'))
        schema.EnumType('enumTestandCheck',{'UseLocalSettings','EnableAll','DisableAll'});
    end

    if isempty(findtype('enumModelCoverageObjectives'))
        schema.EnumType('enumModelCoverageObjectives',{'None','Decision','ConditionDecision','MCDC','EnhancedMCDC'});
    end

    if isempty(findtype('enumTestSuiteOptimization'))
        schema.EnumType('enumTestSuiteOptimization',testStrategies);
    end

    if isempty(findtype('enumErrorDetectionStrategy'))
        schema.EnumType('enumErrorDetectionStrategy',{'DetectErrors'});
    end

    if isempty(findtype('enumProvingStrategy'))
        schema.EnumType('enumProvingStrategy',proveStrategies);
    end

    if isempty(findtype('enumHarnessSource'))
        schema.EnumType('enumHarnessSource',{'Signal Builder','Signal Editor'});
    end

    if isempty(findtype('enumRebuildModelRepresentation'))
        schema.EnumType('enumRebuildModelRepresentation',{'Always','IfChangeIsDetected'});
    end

    if isempty(findtype('enumParameterConfiguration'))
        schema.EnumType('enumParameterConfiguration',{'None','Auto','DetermineFromGeneratedCode','UseParameterTable','UseParameterConfigFile'});
    end

    if isempty(findtype('enumDeadLogicObjectives'))
        schema.EnumType('enumDeadLogicObjectives',{'Decision','ConditionDecision','MCDC'});
    end





    p=schema.prop(c,[Tag,'Mode'],'enumMode');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'MaxProcessTime'],'double');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'AnalysisLevel'],'double');
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,[Tag,'DisplayUnsatisfiableObjectives'],'on/off');
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,[Tag,'AutomaticStubbing'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'UseParallel'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DesignMinMaxConstraints'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'AnalysisFilter'],'on/off');
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,[Tag,'AnalysisFilterFileName'],'ustring');
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,[Tag,'OutputDir'],'ustring');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'MakeOutputFilesUnique'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'BlockReplacement'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'BlockReplacementRulesList'],'ustring');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'BlockReplacementModelFileName'],'ustring');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'SubSystemToStub'],'mxArray');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'ParameterConfiguration'],'enumParameterConfiguration');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'Parameters'],'on/off');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'ParametersConfigFileName'],'ustring');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'ParameterNames'],'mxArray');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'ParameterConstraints'],'mxArray');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'ParameterUseInAnalysis'],'mxArray');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'ParametersUseConfig'],'on/off');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'TestgenTarget'],'enumTestgenTarget');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'ModelCoverageObjectives'],'enumModelCoverageObjectives');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'TestConditions'],'enumTestandCheck');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'TestObjectives'],'enumTestandCheck');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'MaxTestCaseSteps'],'int32');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'AllowLegacyTestSuiteOptimization'],'on/off');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'TestSuiteOptimization'],'enumTestSuiteOptimization');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'PathBasedTestGeneration'],'on/off');
    p.Visible=privateVisibility;
    p.AccessFlags.PublicSet='off';

    p=schema.prop(c,[Tag,'PathBasedCustomization'],'ustring');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'ObservabilityCustomization'],'ustring');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'Assertions'],'enumTestandCheck');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'ProofAssumptions'],'enumTestandCheck');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'LoadExternalTestCases'],'on/off');
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,[Tag,'ExternalTestData'],'ustring');
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,[Tag,'GenerateCompleteTestSuite'],'on/off');
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,[Tag,'ExtendExistingTests'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'ExistingTestFile'],'ustring');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'IgnoreExistTestSatisfied'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'IgnoreCovSatisfied'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'CoverageDataFile'],'ustring');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'CovFilter'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'CovFilterFileName'],'ustring');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'IncludeRelationalBoundary'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'RelativeTolerance'],'double');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'AbsoluteTolerance'],'double');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'ErrorDetectionStrategy'],'enumErrorDetectionStrategy');
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,[Tag,'DetectDeadLogic'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DetectActiveLogic'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DeadLogicObjectives'],'enumDeadLogicObjectives');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DetectOutOfBounds'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DetectDivisionByZero'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DetectIntegerOverflow'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DetectInfNaN'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DetectSubnormal'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DesignMinMaxCheck'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DetectDSMHazards'],'on/off');
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,[Tag,'DetectDSMAccessViolations'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DetectBlockConditions'],'ustring');
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,[Tag,'DetectHISMViolationsHisl_0002'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DetectHISMViolationsHisl_0003'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DetectHISMViolationsHisl_0004'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DetectHISMViolationsHisl_0028'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DetectBlockInputRangeViolations'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DetectFloatOverflow'],'on/off');
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,[Tag,'DetectSFTransConflict'],'on/off');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'DetectSFStateInconsistency'],'on/off');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'DetectSFArrayOutOfBounds'],'on/off');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'DetectEMLArrayOutOfBounds'],'on/off');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'DetectSLSelectorOutOfBounds'],'on/off');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'DetectSLMPSwitchOutOfBounds'],'on/off');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'DetectSLInvalidCast'],'on/off');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'DetectSLMergeConflict'],'on/off');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'DetectSLUninitializedDSR'],'on/off');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'ProvingStrategy'],'enumProvingStrategy');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'MaxViolationSteps'],'int32');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'SaveDataFile'],'on/off');
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,[Tag,'DataFileName'],'ustring');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'SaveExpectedOutput'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'RandomizeNoEffectData'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'SaveHarnessModel'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'HarnessModelFileName'],'ustring');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'ModelReferenceHarness'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'HarnessSource'],'enumHarnessSource');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'SaveSystemTestHarness'],'on/off');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'SystemTestFileName'],'ustring');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'SaveReport'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'ReportPDFFormat'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'ReportFileName'],'ustring');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'ReportIncludeGraphics'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DisplayReport'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'DisplayResultsOnModel'],'on/off');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'EnableObjComposition'],'on/off');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'ObjectiveComposeSpecFileName'],'ustring');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'SFcnSupport'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'SFcnExtraOptions'],'ustring');
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';

    p=schema.prop(c,[Tag,'CodeAnalysisExtraOptions'],'ustring');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'CodeAnalysisIgnoreVolatile'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'ReduceRationalApprox'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'SlTestFileName'],'ustring');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'SlTestHarnessName'],'ustring');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'SlTestHarnessSource'],'ustring');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'StrictEnhancedMCDC'],'on/off');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'RebuildModelRepresentation'],'enumRebuildModelRepresentation');
    p.Visible=visibility;

    p=schema.prop(c,[Tag,'RequirementsTableAnalysis'],'on/off');
    p.Visible=privateVisibility;

    p=schema.prop(c,[Tag,'ExtendUsingSimulation'],'on/off');
    p.Visible=privateVisibility;
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,[Tag,'AnalyzeAllStartupVariants'],'on/off');
    p.Visible=visibility;





    p=schema.prop(c,[Tag,'ActiveTab'],'int');
    p.Visible=privateVisibility;
    p.FactoryValue=0;

    p=schema.prop(c,'SldvSubComponents','mxArray');
    p.Visible=privateVisibility;
    p.FactoryValue=[];
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'productTag','string');
    p.Visible=privateVisibility;
    p.FactoryValue=Tag;
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'SubsystemToAnalyze','mxArray');
    p.Visible=privateVisibility;
    p.FactoryValue=[];
    p.AccessFlags.Serialize='off';

    p=schema.prop(c,'ParameterManager','mxArray');
    p.Visible=privateVisibility;
    p.FactoryValue=[];
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='off';







    Simulink.TargetCCPropertyAttributes.regPropPresetListener(c);





    m=schema.method(c,'dialogCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string','string'};
    s.OutputTypes={};


    m=schema.method(c,'isVisible');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};


    m=schema.method(c,'getActiveTab');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'int'};


    m=schema.method(c,'skipModelReferenceComparison');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};


    m=schema.method(c,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'ustring'};


    m=schema.method(c,'getParameterManager');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};


    m=schema.method(c,'upgrade');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

