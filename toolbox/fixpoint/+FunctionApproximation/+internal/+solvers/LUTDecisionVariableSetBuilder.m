classdef LUTDecisionVariableSetBuilder<handle





    properties(SetAccess=protected)
        DecisionVariableSets FunctionApproximation.internal.solvers.ApproximateLUTDecisionVariableSet
    end

    methods(Abstract)
        decisionVariableSets=build(this,varargin);
    end

    methods(Sealed,Access=protected)
        function decisionVariableSets=initializeDVSets(~,numSets)
            singleSet=FunctionApproximation.internal.solvers.ApproximateLUTDecisionVariableSet();
            decisionVariableSets=repmat(singleSet,1,numSets);
        end
    end
end