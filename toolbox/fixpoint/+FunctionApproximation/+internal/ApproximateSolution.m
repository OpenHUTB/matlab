classdef(Abstract)ApproximateSolution<matlab.mixin.CustomDisplay&handle






    properties(SetAccess={?FunctionApproximation.internal.DBUnitToSolutionAdapter,...
        ?FunctionApproximation.internal.ApproximateSolution})
        ID double
        Feasible logical
        SourceProblem FunctionApproximation.internal.ProblemDefinition
    end

    properties(Hidden,SetAccess={?FunctionApproximation.internal.DBUnitToSolutionAdapter,...
        ?FunctionApproximation.internal.ApproximateSolution})
        ErrorFunction FunctionApproximation.internal.functionwrapper.ErrorFunctionWrapper
        DataBase FunctionApproximation.internal.database.ApproximationSolutionsDataBase
        DBUnit FunctionApproximation.internal.database.DBUnit
        Options FunctionApproximation.Options
    end

    methods

        varargout=approximate(this,varargin)
        varargout=compare(this)
        solution=solutionfromID(this,ID)
        solutions=allsolutions(this)
        solutions=feasiblesolutions(this)
        displayallsolutions(this)
        displayfeasiblesolutions(this)
        replaceWithApproximate(this,varargin)
        revertToOriginal(this,varargin)
    end

    methods(Hidden)
        function flag=isequal(this,other)
            flag=isequal(class(this),class(other));
            flag=flag&&(this.ID==other.ID);
            flag=flag&&(this.Feasible==other.Feasible);
            flag=flag&&isequal(this.ErrorFunction.Original.Data,other.ErrorFunction.Original.Data);
            flag=flag&&isequal(this.ErrorFunction.Approximation.Data,other.ErrorFunction.Approximation.Data);
            flag=flag&&isequal(this.SourceProblem,other.SourceProblem);
            flag=flag&&isequal(this.Options,other.Options);
        end

        function flag=isequaln(this,other)
            flag=FunctionApproximation.internal.isequaln(this,other);
        end
    end

    methods(Access=protected)
        function header=getHeader(this)
            dimStr=matlab.mixin.CustomDisplay.convertDimensionsToString(this);
            header=FunctionApproximation.internal.DisplayUtils.getClassHeaderString(...
            this,...
            message('SimulinkFixedPoint:functionApproximation:withProperties').getString(),...
            dimStr);
        end
    end
end
