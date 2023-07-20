classdef LUTDBUnitToApproximateLUTSolutionAdapter<FunctionApproximation.internal.DBUnitToSolutionAdapter





    methods
        function[proxySolution,diagnostic]=createSolution(~,dbUnit,problemDefinition,options,dataBase)
            options.Display=true;
            solution=FunctionApproximation.internal.ApproximateLUTSolution();
            diagnostic=MException.empty;

            if isempty(dbUnit)
                diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:approximationNotPossible'));
            else

                if~dbUnit.ConstraintMet
                    diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:noFeasibleSolutionFound'));
                end

                serializeableData=dbUnit.SerializeableData;
                approximationWrapper=FunctionApproximation.internal.getWrapper(serializeableData,options);
                errorFunction=FunctionApproximation.internal.functionwrapper.ErrorFunctionWrapper(...
                problemDefinition.InputFunctionWrapper,approximationWrapper,options.AbsTol,options.RelTol);

                solution.ErrorFunction=errorFunction;
                solution.DataBase=dataBase;
                solution.Options=options;
                solution.DBUnit=dbUnit;
                solution.SourceProblem=problemDefinition;
                solution.ID=dbUnit.ID;
                solution.Feasible=dbUnit.ConstraintMet;
            end

            proxySolution=FunctionApproximation.LUTSolution(solution);
        end
    end
end
