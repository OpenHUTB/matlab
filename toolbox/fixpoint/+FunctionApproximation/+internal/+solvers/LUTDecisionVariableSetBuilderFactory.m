classdef LUTDecisionVariableSetBuilderFactory





    methods(Static)
        function builder=getBuilder(options)
            if options.Interpolation=="None"
                builder=FunctionApproximation.internal.solvers.NoInterploationWLComboDecisionVariableSetBuilder();
            else
                builder=FunctionApproximation.internal.solvers.WLComboDecisionVariableSetBuilder();
            end
        end
    end
end
