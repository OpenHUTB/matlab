classdef(Hidden)AbstractOptionsData




    properties(Abstract)
        WordLengths{mustBeValidWordLength(WordLengths)}
        BreakpointSpecification(1,:)FunctionApproximation.BreakpointSpecification
        AbsTol{mustBeValidAbsTol(AbsTol)}
        RelTol{mustBeValidRelTol(RelTol)}
        AllowUpdateDiagram(1,1)logical
        Display(1,1)logical
        Interpolation(1,1)FunctionApproximation.InterpolationMethod
        SaturateToOutputType(1,1)logical
        MaxTime{mustBeValidMaxTime(MaxTime)}
        MaxMemoryUsage(1,1)double{mustBePositive}
        MemoryUnits(1,1)FunctionApproximation.internal.MemoryUnit
        OnCurveTableValues(1,1)logical
        AUTOSARCompliant(1,1)logical
        UseParallel(1,1)logical
        ExploreHalf(1,1)logical
DefaultFields
        HardwareType(1,1)FunctionApproximation.HardwareTypes
        AllowSubSystem(1,1)logical
        UseClipping(1,1)logical
        UseBPSpecAsIs(1,1)logical
        MinFeasibleSolutions(1,1)double{mustBePositive,mustBeInteger}
        MaxNumDim(1,1)double{mustBePositive,mustBeInteger,mustBeLessThanOrEqual(MaxNumDim,30)}
        DefaultMemoryUsageBits(1,1)double{mustBePositive,mustBeInteger}
        Optimset(1,1)struct
        MinFractionFeasibleSolutions(1,1)double{mustBeNonnegative,mustBeLessThanOrEqual(MinFractionFeasibleSolutions,1)}
        ConsiderAUTOSARBlocksetExists(1,1)logical
        UseFunctionApproximationBlock(1,1)logical
        ExploreFloatingPoint(1,1)logical
        ExploreFixedPoint(1,1)logical
        TableValueOptimizationNormOrder(1,1)double{mustBePositive(TableValueOptimizationNormOrder),validateNormOrder(TableValueOptimizationNormOrder)}
        PNormSQPToleranceThreshold(1,1)double{mustBeLessThanOrEqual(PNormSQPToleranceThreshold,1),mustBeGreaterThan(PNormSQPToleranceThreshold,0)}
        HDLOptimized(1,1)logical
        ApproximateSolutionType(1,:)FunctionApproximation.internal.ApproximateSolutionType
    end
end

function mustBeValidAbsTol(tolVal)

    parsedTolerance=FunctionApproximation.internal.Utils.parseCharValue(tolVal);
    validateattributes(parsedTolerance,{'numeric','embedded.fi'},{'scalar'})
    mustBeNonnegative(parsedTolerance)
    mustBeFinite(parsedTolerance)
    mustBeNonNan(parsedTolerance)
end

function mustBeValidRelTol(tolVal)

    parsedTolerance=FunctionApproximation.internal.Utils.parseCharValue(tolVal);
    validateattributes(parsedTolerance,{'numeric','embedded.fi'},{'scalar'})
    mustBeNonnegative(parsedTolerance)
    mustBeFinite(parsedTolerance)
    mustBeNonNan(parsedTolerance)
end

function mustBeValidMaxTime(timeVal)

    parsedTolerance=FunctionApproximation.internal.Utils.parseCharValue(timeVal);
    validateattributes(parsedTolerance,{'numeric'},{'scalar'})
    mustBePositive(parsedTolerance)
end


function mustBeValidWordLength(value)

    parsedTolerance=FunctionApproximation.internal.Utils.parseCharValue(value);
    validateattributes(parsedTolerance,{'numeric','embedded.fi'},{})
    mustBeNonempty(parsedTolerance)
    mustBeFinite(parsedTolerance)
    mustBeNonNan(parsedTolerance)
    mustBeInteger(parsedTolerance)
    mustBeGreaterThanOrEqual(parsedTolerance,1)
    mustBeLessThanOrEqual(parsedTolerance,128)
end

function validateNormOrder(value)
    if~isinf(value)
        mustBeInteger(value);
    end
end