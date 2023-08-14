classdef OptionsData<FunctionApproximation.AbstractOptionsData




    properties(Constant,Hidden)
        MAXMEMORYVALUE=80000000
    end

    properties(Dependent,Hidden)
MaxMemoryUsageBits
    end

    properties
        WordLengths=[8,16,32]
        BreakpointSpecification=FunctionApproximation.BreakpointSpecification.ExplicitValues
        AbsTol=2^-7
        RelTol=2^-7
AllowUpdateDiagram
Display
Interpolation
        SaturateToOutputType=false
        MaxTime=Inf
        MaxMemoryUsage=FunctionApproximation.internal.option.OptionsData.MAXMEMORYVALUE
        MemoryUnits="bits"
OnCurveTableValues
AUTOSARCompliant
UseParallel
ExploreHalf
HDLOptimized
        ApproximateSolutionType=FunctionApproximation.internal.ApproximateSolutionType.Simulink
    end

    properties(Hidden)
DefaultFields
HardwareType
AllowSubSystem
UseClipping
UseBPSpecAsIs
        MinFeasibleSolutions=1
        MaxNumDim=1
        DefaultMemoryUsageBits=FunctionApproximation.Options.MAXMEMORYVALUE;
Optimset
MinFractionFeasibleSolutions
ConsiderAUTOSARBlocksetExists
UseFunctionApproximationBlock
ExploreFloatingPoint
ExploreFixedPoint
        TableValueOptimizationNormOrder=2
        PNormSQPToleranceThreshold=0.4
    end

    methods
        function this=OptionsData(varargin)
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'WordLengths',this.WordLengths);
            addParameter(p,'HardwareType',FunctionApproximation.HardwareTypes.Microprocessor);
            addParameter(p,'BreakpointSpecification',this.BreakpointSpecification);
            addParameter(p,'Interpolation',FunctionApproximation.InterpolationMethod.Linear);
            addParameter(p,'AbsTol',this.AbsTol);
            addParameter(p,'RelTol',this.RelTol);
            addParameter(p,'AllowUpdateDiagram',true);
            addParameter(p,'Display',true);
            addParameter(p,'AllowSubSystem',true);
            addParameter(p,'UseClipping',false);
            addParameter(p,'UseBPSpecAsIs',false);
            addParameter(p,'MinFeasibleSolutions',10);
            addParameter(p,'MaxMemoryUsage',FunctionApproximation.Options.MAXMEMORYVALUE);
            addParameter(p,'DefaultMemoryUsageBits',FunctionApproximation.Options.MAXMEMORYVALUE)
            addParameter(p,'MaxNumDim',3);
            addParameter(p,'SaturateToOutputType',false);
            addParameter(p,'MaxTime',this.MaxTime);
            addParameter(p,'MemoryUnits',this.MemoryUnits);
            addParameter(p,'OnCurveTableValues',false);
            addParameter(p,'Optimset',FunctionApproximation.internal.solvers.getOptionsForTVOptimization());
            addParameter(p,'MinFractionFeasibleSolutions',1/75);
            addParameter(p,'AUTOSARCompliant',false);
            addParameter(p,'ConsiderAUTOSARBlocksetExists',true);
            addParameter(p,'UseParallel',false);
            addParameter(p,'UseFunctionApproximationBlock',true);
            addParameter(p,'ExploreFloatingPoint',false);
            addParameter(p,'ExploreFixedPoint',true);
            addParameter(p,'ExploreHalf',true);
            addParameter(p,'TableValueOptimizationNormOrder',2);
            addParameter(p,'PNormSQPToleranceThreshold',0.4);
            addParameter(p,'HDLOptimized',false);
            addParameter(p,'ApproximateSolutionType',this.ApproximateSolutionType);

            parse(p,varargin{:});

            this.WordLengths=p.Results.WordLengths;
            this.HardwareType=p.Results.HardwareType;
            this.BreakpointSpecification=p.Results.BreakpointSpecification;
            this.Interpolation=p.Results.Interpolation;
            this.AbsTol=p.Results.AbsTol;
            this.RelTol=p.Results.RelTol;
            this.AllowUpdateDiagram=p.Results.AllowUpdateDiagram;
            this.Display=p.Results.Display;
            this.AllowSubSystem=p.Results.AllowSubSystem;
            this.UseClipping=p.Results.UseClipping;
            this.UseBPSpecAsIs=p.Results.UseBPSpecAsIs;
            this.MinFeasibleSolutions=p.Results.MinFeasibleSolutions;
            this.DefaultMemoryUsageBits=p.Results.DefaultMemoryUsageBits;
            this.MaxNumDim=p.Results.MaxNumDim;
            this.SaturateToOutputType=p.Results.SaturateToOutputType;
            this.MaxTime=p.Results.MaxTime;
            this.MemoryUnits=p.Results.MemoryUnits;
            this.MaxMemoryUsage=p.Results.MaxMemoryUsage;
            this.OnCurveTableValues=p.Results.OnCurveTableValues;
            this.Optimset=p.Results.Optimset;
            this.MinFractionFeasibleSolutions=p.Results.MinFractionFeasibleSolutions;
            this.AUTOSARCompliant=p.Results.AUTOSARCompliant;
            this.ConsiderAUTOSARBlocksetExists=p.Results.ConsiderAUTOSARBlocksetExists;
            this.UseParallel=p.Results.UseParallel;
            this.UseFunctionApproximationBlock=p.Results.UseFunctionApproximationBlock;
            this.ExploreFloatingPoint=p.Results.ExploreFloatingPoint;
            this.ExploreFixedPoint=p.Results.ExploreFixedPoint;
            this.ExploreHalf=p.Results.ExploreHalf;
            this.TableValueOptimizationNormOrder=p.Results.TableValueOptimizationNormOrder;
            this.PNormSQPToleranceThreshold=p.Results.PNormSQPToleranceThreshold;
            this.HDLOptimized=p.Results.HDLOptimized;
            this.DefaultFields=p.UsingDefaults;
            this.ApproximateSolutionType=p.Results.ApproximateSolutionType;
        end

        function this=set.WordLengths(this,value)
            value=FunctionApproximation.internal.Utils.parseCharValue(value);
            this.WordLengths=sort(unique(double(value)));
            this=updateDefaultFields(this,'WordLengths');
        end

        function this=set.BreakpointSpecification(this,value)
            this.BreakpointSpecification=value;
            this=updateDefaultFields(this,'BreakpointSpecification');
        end

        function this=set.AbsTol(this,value)
            this.AbsTol=value;
            this.AbsTol=double(FunctionApproximation.internal.Utils.parseCharValue(this.AbsTol));
            this=updateDefaultFields(this,'AbsTol');
        end

        function this=set.RelTol(this,value)
            this.RelTol=value;
            this.RelTol=double(FunctionApproximation.internal.Utils.parseCharValue(this.RelTol));
            this=updateDefaultFields(this,'RelTol');
        end

        function this=set.AllowUpdateDiagram(this,value)
            this.AllowUpdateDiagram=value;
            this=updateDefaultFields(this,'AllowUpdateDiagram');
        end

        function this=set.Display(this,value)
            this.Display=value;
            this=updateDefaultFields(this,'Display');
        end

        function this=set.Interpolation(this,value)
            this.Interpolation=value;
            this=updateDefaultFields(this,'Interpolation');
        end

        function this=set.HardwareType(this,value)
            this.HardwareType=value;
            this=updateDefaultFields(this,'HardwareType');
        end

        function this=set.UseClipping(this,value)
            this.UseClipping=value;
            this=updateDefaultFields(this,'UseClipping');
        end

        function this=set.UseBPSpecAsIs(this,value)
            this.UseBPSpecAsIs=value;
            this=updateDefaultFields(this,'UseBPSpecAsIs');
        end

        function this=set.MinFeasibleSolutions(this,value)
            this.MinFeasibleSolutions=value;
            this=updateDefaultFields(this,'MinFeasibleSolutions');
        end

        function this=set.MaxMemoryUsage(this,value)
            validateAgainstUnit(this,value);
            this.MaxMemoryUsage=value;
            this=updateDefaultFields(this,'MaxMemoryUsage');
        end

        function this=set.DefaultMemoryUsageBits(this,value)
            this.DefaultMemoryUsageBits=value;
            this=updateDefaultFields(this,'DefaultMemoryUsageBits');
        end

        function this=set.MaxNumDim(this,value)
            this.MaxNumDim=value;
            this=updateDefaultFields(this,'MaxNumDim');
        end

        function this=set.SaturateToOutputType(this,value)
            this.SaturateToOutputType=value;
            this=updateDefaultFields(this,'SaturateToOutputType');
        end

        function this=set.MaxTime(this,value)
            this.MaxTime=value;
            this.MaxTime=double(FunctionApproximation.internal.Utils.parseCharValue(this.MaxTime));
            this=updateDefaultFields(this,'MaxTime');
        end

        function this=set.MemoryUnits(this,value)
            this.MemoryUnits=value;
            this=updateDefaultFields(this,'MemoryUnits');
        end

        function this=set.OnCurveTableValues(this,value)
            this.OnCurveTableValues=value;
            this=updateDefaultFields(this,'OnCurveTableValues');
        end

        function this=set.MinFractionFeasibleSolutions(this,value)
            this.MinFractionFeasibleSolutions=value;
            this=updateDefaultFields(this,'MinFractionFeasibleSolutions');
        end

        function this=set.AUTOSARCompliant(this,value)
            this.AUTOSARCompliant=value;
            this=updateDefaultFields(this,'AUTOSARCompliant');
        end

        function this=set.ConsiderAUTOSARBlocksetExists(this,value)
            this.ConsiderAUTOSARBlocksetExists=value;
            this=updateDefaultFields(this,'ConsiderAUTOSARBlocksetExists');
        end

        function this=set.UseParallel(this,value)
            this.UseParallel=value;
            this=updateDefaultFields(this,'UseParallel');
        end

        function this=set.UseFunctionApproximationBlock(this,value)
            this.UseFunctionApproximationBlock=value;
            this=updateDefaultFields(this,'UseFunctionApproximationBlock');
        end

        function this=set.ExploreFloatingPoint(this,value)
            this.ExploreFloatingPoint=value;
            this=updateDefaultFields(this,'ExploreFloatingPoint');
        end

        function this=set.ExploreFixedPoint(this,value)
            this.ExploreFixedPoint=value;
            this=updateDefaultFields(this,'ExploreFixedPoint');
        end

        function this=set.TableValueOptimizationNormOrder(this,value)
            this.TableValueOptimizationNormOrder=value;
            this=updateDefaultFields(this,'TableValueOptimizationNormOrder');
        end

        function this=set.PNormSQPToleranceThreshold(this,value)
            this.PNormSQPToleranceThreshold=value;
            this=updateDefaultFields(this,'PNormSQPToleranceThreshold');
        end

        function this=set.ExploreHalf(this,value)
            this.ExploreHalf=value;
            this=updateDefaultFields(this,'ExploreHalf');
        end

        function this=set.HDLOptimized(this,value)
            this.HDLOptimized=value;
            this=updateDefaultFields(this,'HDLOptimized');
        end

        function this=set.ApproximateSolutionType(this,value)
            this.ApproximateSolutionType=value;
            this=updateDefaultFields(this,'ApproximateSolutionType');
        end

        function value=get.MemoryUnits(this)
            value=char(this.MemoryUnits);
        end

        function this=set.MaxMemoryUsageBits(this,value)
            conversionFactor=FunctionApproximation.internal.MemoryUnit.getConversionFactor(...
            FunctionApproximation.internal.MemoryUnit.bits,...
            this.MemoryUnits);
            this.MaxMemoryUsage=value*conversionFactor;
        end

        function value=get.MaxMemoryUsageBits(this)
            conversionFactor=FunctionApproximation.internal.MemoryUnit.getConversionFactor(...
            this.MemoryUnits,...
            FunctionApproximation.internal.MemoryUnit.bits);
            value=this.MaxMemoryUsage*conversionFactor;
        end
    end

    methods(Access=private)
        function this=updateDefaultFields(this,paramName)
            this.DefaultFields=this.DefaultFields(~ismember(this.DefaultFields,paramName));
        end

        function validateAgainstUnit(this,value)
            if this.MemoryUnits=="bits"
                try
                    mustBeInteger(value);
                catch err
                    err.throwAsCaller()
                end
            end
        end
    end
end

