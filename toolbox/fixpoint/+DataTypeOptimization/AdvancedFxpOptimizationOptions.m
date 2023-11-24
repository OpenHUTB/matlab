classdef AdvancedFxpOptimizationOptions

    properties
        PerformNeighborhoodSearch(1,1)logical
        EnforceLooseCoupling(1,1)logical
        UseDerivedRangeAnalysis(1,1)logical
        SimulationScenarios Simulink.SimulationInput
        SafetyMargin(1,1)double
        DataTypeOverride(1,1)DataTypeOptimization.OverrideType{mustBeMember(DataTypeOverride,0:3)}
        HandleUnsupported(1,1)DataTypeOptimization.UnsupportedHandlingMode{mustBeMember(HandleUnsupported,0:2)}
        PerformSlopeBiasCancellation(1,1)logical
        InstrumentationContext string
    end

    properties(Hidden)
        ClearSDIOnEval(1,1)logical
        EvaluationSimMode(1,1)DataTypeOptimization.SimMode{mustBeMember(EvaluationSimMode,0:2)}
    end

    methods
        function this=AdvancedFxpOptimizationOptions(varargin)
            p=createInputParser(this);
            p.parse(varargin{:});
            this.PerformNeighborhoodSearch=p.Results.PerformNeighborhoodSearch;
            this.EnforceLooseCoupling=p.Results.EnforceLooseCoupling;
            this.UseDerivedRangeAnalysis=p.Results.UseDerivedRangeAnalysis;
            this.SimulationScenarios=p.Results.SimulationScenarios;
            this.SafetyMargin=p.Results.SafetyMargin;
            this.DataTypeOverride=p.Results.DataTypeOverride;
            this.HandleUnsupported=p.Results.HandleUnsupported;
            this.PerformSlopeBiasCancellation=p.Results.PerformSlopeBiasCancellation;
            this.ClearSDIOnEval=p.Results.ClearSDIOnEval;
            this.EvaluationSimMode=p.Results.EvaluationSimMode;
            this.InstrumentationContext=p.Results.InstrumentationContext;
        end

        function this=set.SafetyMargin(this,sm)
            validateattributes(sm,{'numeric'},{'scalar','finite','real','>=',0});
            this.SafetyMargin=sm;
        end

    end

    methods(Hidden)
        function p=createInputParser(~)

            p=inputParser();
            p.KeepUnmatched=true;
            p.addParameter('PerformNeighborhoodSearch',true);
            p.addParameter('EnforceLooseCoupling',true);
            p.addParameter('UseDerivedRangeAnalysis',false);
            p.addParameter('SimulationScenarios',Simulink.SimulationInput.empty());
            p.addParameter('SafetyMargin',0);
            p.addParameter('DataTypeOverride',DataTypeOptimization.OverrideType('Off'));
            p.addParameter('HandleUnsupported',DataTypeOptimization.UnsupportedHandlingMode('Isolate'));
            p.addParameter('PerformSlopeBiasCancellation',false);
            p.addParameter('ClearSDIOnEval',true);
            p.addParameter('EvaluationSimMode',DataTypeOptimization.SimMode("Accelerator"));
            p.addParameter('InstrumentationContext',string.empty(1,0));
        end
    end
end