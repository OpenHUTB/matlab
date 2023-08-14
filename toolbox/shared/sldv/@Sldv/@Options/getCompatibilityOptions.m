function compatOpts=getCompatibilityOptions(h)









    compatOpts.General.Mode=h.Mode;
    compatOpts.General.AutomaticStubbing=h.AutomaticStubbing;
    compatOpts.General.DesignMinMaxConstraints=h.DesignMinMaxConstraints;
    compatOpts.BlockReplacement.BlockReplacement=h.BlockReplacement;
    compatOpts.BlockReplacement.BlockReplacementRulesList=h.BlockReplacementRulesList;
    compatOpts.BlockReplacement.BlockReplacementModelFileName=h.BlockReplacementModelFileName;
    compatOpts.Parameters.ParameterConfiguration=h.ParameterConfiguration;
    compatOpts.Parameters.Parameters=h.Parameters;
    compatOpts.Parameters.ParametersConfigFileName=h.ParametersConfigFileName;
    compatOpts.Parameters.ParameterNames=h.ParameterNames;
    compatOpts.Parameters.ParameterConstraints=h.ParameterConstraints;
    compatOpts.Parameters.ParameterUseInAnalysis=h.ParameterUseInAnalysis;
    compatOpts.Parameters.ParametersUseConfig=h.ParametersUseConfig;
    compatOpts.TestGeneration.TestgenTarget=h.TestgenTarget;
    compatOpts.TestGeneration.ModelCoverageObjectives=h.ModelCoverageObjectives;
    compatOpts.TestGeneration.PathBasedTestGeneration=h.PathBasedTestGeneration;
    compatOpts.TestGeneration.PathBasedCustomization=h.PathBasedCustomization;
    compatOpts.TestGeneration.ObservabilityCustomization=h.ObservabilityCustomization;
    compatOpts.TestGeneration.IncludeRelationalBoundary=h.IncludeRelationalBoundary;
    compatOpts.TestGeneration.RelativeTolerance=h.RelativeTolerance;
    compatOpts.TestGeneration.AbsoluteTolerance=h.AbsoluteTolerance;
    compatOpts.ErrorDetection.DetectDeadLogic=h.DetectDeadLogic;
    compatOpts.ErrorDetection.DetectActiveLogic=h.DetectActiveLogic;
    compatOpts.ErrorDetection.DeadLogicObjectives=h.DeadLogicObjectives;
    compatOpts.ErrorDetection.DetectOutOfBounds=h.DetectOutOfBounds;
    compatOpts.ErrorDetection.DetectDivisionByZero=h.DetectDivisionByZero;
    compatOpts.ErrorDetection.DetectIntegerOverflow=h.DetectIntegerOverflow;
    compatOpts.ErrorDetection.DetectInfNaN=h.DetectInfNaN;
    compatOpts.ErrorDetection.DetectSubnormal=h.DetectSubnormal;
    compatOpts.ErrorDetection.DesignMinMaxCheck=h.DesignMinMaxCheck;
    compatOpts.ErrorDetection.DetectDSMHazards=h.DetectDSMHazards;
    compatOpts.ErrorDetection.DetectDSMAccessViolations=h.DetectDSMAccessViolations;
    compatOpts.ErrorDetection.DetectBlockConditions=h.DetectBlockConditions;
    compatOpts.ErrorDetection.DetectHISMViolationsHisl_0002=h.DetectHISMViolationsHisl_0002;
    compatOpts.ErrorDetection.DetectHISMViolationsHisl_0003=h.DetectHISMViolationsHisl_0003;
    compatOpts.ErrorDetection.DetectHISMViolationsHisl_0004=h.DetectHISMViolationsHisl_0004;
    compatOpts.ErrorDetection.DetectHISMViolationsHisl_0028=h.DetectHISMViolationsHisl_0028;
    compatOpts.ErrorDetection.DetectBlockInputRangeViolations=h.DetectBlockInputRangeViolations;
    compatOpts.ErrorDetection.DetectFloatOverflow=h.DetectFloatOverflow;
    compatOpts.ErrorDetection.DetectSFTransConflict=h.DetectSFTransConflict;
    compatOpts.ErrorDetection.DetectSFStateInconsistency=h.DetectSFStateInconsistency;
    compatOpts.ErrorDetection.DetectSFArrayOutOfBounds=h.DetectSFArrayOutOfBounds;
    compatOpts.ErrorDetection.DetectEMLArrayOutOfBounds=h.DetectEMLArrayOutOfBounds;
    compatOpts.ErrorDetection.DetectSLSelectorOutOfBounds=h.DetectSLSelectorOutOfBounds;
    compatOpts.ErrorDetection.DetectSLMPSwitchOutOfBounds=h.DetectSLMPSwitchOutOfBounds;
    compatOpts.ErrorDetection.DetectSLInvalidCast=h.DetectSLInvalidCast;
    compatOpts.ErrorDetection.DetectSLMergeConflict=h.DetectSLMergeConflict;
    compatOpts.ErrorDetection.DetectSLUninitializedDSR=h.DetectSLUninitializedDSR;
    compatOpts.TestGeneration.EnableObjComposition=h.EnableObjComposition;
    compatOpts.TestGeneration.ObjectiveComposeSpecFileName=h.ObjectiveComposeSpecFileName;
    compatOpts.SFunctions.SFcnSupport=h.SFcnSupport;
    compatOpts.SFunctions.SFcnExtraOptions=h.SFcnExtraOptions;
    compatOpts.General.CodeAnalysisExtraOptions=h.CodeAnalysisExtraOptions;
    compatOpts.General.CodeAnalysisIgnoreVolatile=h.CodeAnalysisIgnoreVolatile;
    compatOpts.TestGeneration.StrictEnhancedMCDC=h.StrictEnhancedMCDC;
    compatOpts.RequirementsTableAnalysis.RequirementsTableAnalysis=h.RequirementsTableAnalysis;
    compatOpts.General.AnalyzeAllStartupVariants=h.AnalyzeAllStartupVariants;

