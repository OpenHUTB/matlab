classdef TableValueOptimizerContext








    properties
        NormOrder{mustBePositive(NormOrder),mustBeInteger(NormOrder)}=2
        ApproximateFunction FunctionApproximation.internal.functionwrapper.AbstractWrapper=FunctionApproximation.internal.functionwrapper.FunctionHandleWrapper.empty()
OriginalFunctionEvaluation
        TestGrid FunctionApproximation.internal.Grid
TestSet
OriginalFunctionEvaluationAbsoluteValue
        TableData cell
        BreakpointGrid FunctionApproximation.internal.Grid
        Options FunctionApproximation.Options
        HardConstraintTracker FunctionApproximation.internal.ProgressTracker
        BreakpointSpecification FunctionApproximation.BreakpointSpecification
ErrorBound
        Interpolation FunctionApproximation.InterpolationMethod
    end

    properties(Dependent)
NumberOfDimensions
    end

    methods
        function nd=get.NumberOfDimensions(this)
            nd=size(this.TestSet,2);
        end
    end
end
