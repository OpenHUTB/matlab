classdef LUTSolverFactory



    methods
        function solverQueue=getSolverQueue(this,~,options)
            solverQueue=FunctionApproximation.internal.solvers.LUTSolver.empty;
            for ii=1:numel(options.BreakpointSpecification)
                solverQueue=[solverQueue,this.getSolver(options.BreakpointSpecification(ii))];%#ok<AGROW>
            end
        end
    end

    methods(Static)
        function solver=getSolver(breakpointSpecification)
            if isEvenSpacing(breakpointSpecification)
                if breakpointSpecification==FunctionApproximation.BreakpointSpecification.EvenPow2Spacing
                    solver=FunctionApproximation.internal.solvers.EvenPow2SpacingLUTSolver();
                else
                    solver=FunctionApproximation.internal.solvers.EvenSpacingLUTSolver();
                end
            elseif breakpointSpecification==FunctionApproximation.BreakpointSpecification.ExplicitValues
                solver=FunctionApproximation.internal.solvers.ExplicitValuesLUTSolver();
            end
        end
    end
end
