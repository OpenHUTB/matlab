classdef(Abstract)SolverInterface<matlab.mixin.Heterogeneous&handle




    properties(SetAccess={?FunctionApproximation.internal.solvers.SolverInterface,...
        ?SolverTestCase})
ErrorFunction
Options
        ObjectiveValue=-Inf
        MaxObjectiveValue=Inf
OutputTypeRange
    end

    properties(SetAccess={?FunctionApproximation.internal.solvers.SolverInterface,...
        ?FunctionApproximation.internal.ApproximateGeneratorEngine,...
        ?tMaxSuccessAttemptStrategy,...
        ?tProgressTracker,...
        ?SolverTestCase})
DataBase
SoftConsTracker
HardConsTracker
    end

    methods
        solve(this,problemObject,varargin)
        registerDependencies(this)
    end

    methods(Access=?FunctionApproximation.internal.ApproximateGeneratorEngine)
        function setMaxObjectiveValue(this,maxObjectiveValue)
            this.MaxObjectiveValue=maxObjectiveValue;
        end
    end

    methods(Access=protected)
        function checkOriginalFunctionOverflow(this,errorAt)
            originalFunctionValue=this.ErrorFunction.Original.evaluate(errorAt);
            if(originalFunctionValue>this.OutputTypeRange(2)||originalFunctionValue<this.OutputTypeRange(1))&&isempty(this.DataBase.getBestFeasible())
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:increaseOutputRepresentableRange',...
                num2str(originalFunctionValue),...
                mat2str(errorAt),...
                mat2str(this.OutputTypeRange)...
                ));
                error(struct('message',diagnostic.getReport,'identifier',diagnostic.identifier,'stack',diagnostic.stack));
            end
        end
    end

    methods(Hidden)
        function setOptions(this,options)
            this.Options=options;
        end
    end
end
