classdef OptimizationProblemSolverMap<optim.internal.problemdef.solvermap.AbstractSolverMap







    properties(Hidden,Constant,Access=private)
        SolverMap=optim.internal.problemdef.solvermap.OptimizationProblemSolverMap();
    end

    methods(Access=private)
        function this=OptimizationProblemSolverMap()

        end
    end

    methods(Static,Access=public)

        function map=getSolverMap()
            map=optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.SolverMap;
        end

        function[solvers,objectiveType,constraintType]=getSolvers(problem,compile,hasIntCon)




            if isempty(problem.Variables)
                solvers=getSupportedSolvers(optimproblem);
                objectiveType='Numeric';
                constraintType='Empty';
                return
            end


            if nargin<3
                hasIntCon=hasIntegerConstraints(problem,[]);


                if nargin<2
                    compile=true;
                end
            end


            objectiveType=...
            optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.getObjectiveType(problem,compile);
            [constraintType,hasNonlinearEquality]=...
            optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.getConstraintType(problem);
            solvers=intersect(optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.([objectiveType,'Objective']),...
            optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.([constraintType,'Constraints']),'stable');


            if hasIntCon



                if hasNonlinearEquality
                    solvers=cell(1,0);
                    return
                end

                intSolvers=optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.IntegerConstraints;
                solvers=intersect(intSolvers,solvers,'stable');
            end


            if hasNonlinearEquality
                solvers=setdiff(solvers,{'paretosearch','surrogateopt'},'stable');
            end


            solvers=optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.checkForFiniteBounds(solvers,problem);


            solvers=optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.checkLsqnonneg(solvers,problem);



            solvers=intersect(solvers,getSupportedSolvers(problem),'stable');
        end
    end

    methods(Static,Access=protected)

        function type=getObjectiveType(problem,compile)




            objective=problem.Objective;


            if isempty(objective)
                type='Numeric';
                return
            end


            if numel(objective)>1
                type='Multi';
                return
            end
            if isstruct(objective)
                names=fieldnames(objective);
                emptyObj=structfun(@(x)isempty(x),objective);
                nonEmptyObj=~emptyObj;
                if isempty(nonEmptyObj)||all(emptyObj)
                    type='Numeric';
                    return
                elseif sum(nonEmptyObj)>1
                    type='Multi';
                    return
                else

                    objective=objective.(names{nonEmptyObj});
                end
            end


            type=char(getType(objective));
            if~isLinear(objective)&&...
                strncmpi(problem.ObjectiveSense,'min',3)&&...
                isSumSquares(objective)
                if strcmp(type,'Nonlinear')
                    type='NonlinearLeastSquares';
                else
                    type='LinearLeastSquares';
                end
            elseif compile&&strcmp(type,'Quadratic')



                TotalVar=optim.problemdef.OptimizationVariable.setVariableOffset(problem.Variables);
                H=problem.Compiler.compileQuadraticObjective(objective,TotalVar);
                if nnz(H)==0
                    type='Linear';
                end
            end
        end

        function[type,hasNonlinearEquality]=getConstraintType(problem)




            if hasBounds(problem)
                type='Bound';
            else
                type='Empty';
            end


            hasNonlinearEquality=false;



            if isempty(problem.Constraints)
                return
            elseif isstruct(problem.Constraints)
                constraints=struct2cell(problem.Constraints);
                emptyConstr=cellfun(@(x)isempty(x),constraints);
                if isempty(emptyConstr)||all(emptyConstr)
                    return
                else
                    constraints=constraints(~emptyConstr);
                end
            else
                constraints={problem.Constraints};
            end


            type='Linear';
            for ct=1:numel(constraints)
                thisInput=constraints{ct};
                thisRelation=getRelation(thisInput);




                if isConic(thisInput)&&~strcmp(type,'Nonlinear')
                    type='SecondOrderCone';
                elseif~isLinear(thisInput)
                    type='Nonlinear';




                    if strcmp(thisRelation,'==')
                        hasNonlinearEquality=true;
                        return;
                    end
                end
            end
        end

        function solvers=checkForFiniteBounds(solvers,problem)


            if any(strcmp(solvers,'surrogateopt'))&&...
                ~all(structfun(@(x)all(isfinite(x.LowerBound),'all')&&...
                all(isfinite(x.UpperBound),'all'),problem.Variables))
                solvers=setdiff(solvers,'surrogateopt','stable');
            end
        end
    end

    properties(Constant)



        MatlabAndOptimSolvers={...
        'linprog',...
        'intlinprog',...
        'coneprog',...
        'lsqlin',...
        'lsqnonneg',...
        'quadprog',...
        'lsqnonlin',...
        'lsqcurvefit',...
        'fminunc',...
        'fmincon'};

        GlobalSolvers={...
        'ga',...
        'patternsearch',...
        'surrogateopt',...
        'particleswarm',...
        'simulannealbnd',...
        'gamultiobj',...
        'paretosearch'};

        AllSolvers=[
        optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.MatlabAndOptimSolvers,...
        optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.GlobalSolvers];

        SingleObjective={...
        'linprog',...
        'intlinprog',...
        'coneprog',...
        'lsqlin',...
        'lsqnonneg',...
        'quadprog',...
        'lsqnonlin',...
        'lsqcurvefit',...
        'fminunc',...
        'fmincon',...
        'ga',...
        'patternsearch',...
        'surrogateopt',...
        'particleswarm',...
        'simulannealbnd'};

        MultiObjective={...
        'gamultiobj',...
        'paretosearch'};

        NonlinearObjective={...
        'fminunc',...
        'fmincon',...
        'ga',...
        'patternsearch',...
        'surrogateopt',...
        'particleswarm',...
        'simulannealbnd',...
        'gamultiobj',...
        'paretosearch'};

        QuadraticObjective=[...
        'quadprog',...
        optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.NonlinearObjective];

        LinearObjective=[...
        'linprog',...
        'intlinprog',...
        'coneprog',...
        optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.QuadraticObjective];

        NumericObjective=...
        optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.LinearObjective;

        NonlinearLeastSquaresObjective=[...
        'lsqnonlin',...
        'lsqcurvefit',...
        optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.NonlinearObjective];

        LinearLeastSquaresObjective=[...
        'lsqlin',...
        'lsqnonneg',...
        'quadprog',...
        optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.NonlinearLeastSquaresObjective];

        NonlinearConstraints={...
        'fmincon',...
        'ga',...
        'patternsearch',...
        'surrogateopt',...
        'gamultiobj',...
        'paretosearch'};

        SecondOrderConeConstraints=[...
        'coneprog',...
        optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.NonlinearConstraints];

        LinearConstraints=[...
        'linprog',...
        'quadprog',...
        'intlinprog',...
        'lsqlin',...
        optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.SecondOrderConeConstraints];

        BoundConstraints=[...
        optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.LinearConstraints(1:4),...
        'lsqnonneg',...
        'lsqnonlin',...
        'lsqcurvefit',...
        optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.LinearConstraints(5:end),...
        'particleswarm',...
        'simulannealbnd'];

        IntegerConstraints={...
        'intlinprog',...
        'ga',...
        'surrogateopt',...
        'gamultiobj'};

        EmptyConstraints=...
        optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.AllSolvers;
    end
end
