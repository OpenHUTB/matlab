classdef(Abstract)AbstractSolverMap








    methods(Access=protected)
        function this=AbstractSolverMap()

        end
    end

    methods(Abstract,Static,Access=public)


        [solvers,varargout]=getSolvers(problem,hasIntCon);
    end

    methods(Static,Access=protected)

        function solvers=checkLsqnonneg(solvers,problem)


            if any(strcmp(solvers,'lsqnonneg'))&&...
                ~all(structfun(@(x)all(~isfinite(x.UpperBound),'all')&&...
                all(x.LowerBound==0,'all'),problem.Variables))
                solvers=setdiff(solvers,'lsqnonneg','stable');
            end
        end
    end
end
