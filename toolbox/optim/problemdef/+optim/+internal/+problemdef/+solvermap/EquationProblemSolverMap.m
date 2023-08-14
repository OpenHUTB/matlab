classdef EquationProblemSolverMap<optim.internal.problemdef.solvermap.AbstractSolverMap







    properties(Hidden,Constant,Access=private)
        SolverMap=optim.internal.problemdef.solvermap.EquationProblemSolverMap();
    end

    methods(Access=private)
        function this=EquationProblemSolverMap()

        end
    end

    methods(Static,Access=public)

        function map=getSolverMap()
            map=optim.internal.problemdef.solvermap.EquationProblemSolverMap.SolverMap;
        end

        function solvers=getSolvers(problem,hasIntCon)




            if isempty(problem.Variables)
                solvers=getSupportedSolvers(eqnproblem);
                return
            end


            if nargin<2
                hasIntCon=hasIntegerConstraints(problem,[]);
            end


            if hasIntCon
                solvers={};
                return
            end


            [equationType,isScalar]=optim.internal.problemdef.solvermap.EquationProblemSolverMap.getEquationType(problem);


            solvers=optim.internal.problemdef.solvermap.EquationProblemSolverMap.([equationType,'Equations']);
            if hasBounds(problem)
                boundSolvers=optim.internal.problemdef.solvermap.EquationProblemSolverMap.BoundConstraints;
                solvers=intersect(solvers,boundSolvers,'stable');
            end


            solvers=optim.internal.problemdef.solvermap.EquationProblemSolverMap.checkLsqnonneg(solvers,problem);


            solvers=optim.internal.problemdef.solvermap.EquationProblemSolverMap.checkFzero(solvers,problem,isScalar);



            solvers=intersect(solvers,getSupportedSolvers(problem),'stable');
        end
    end

    methods(Static,Access=protected)

        function[type,isScalar]=getEquationType(problem)




            if isstruct(problem.Equations)
                equations=struct2cell(problem.Equations);
            else
                equations={problem.Equations};
            end


            isScalar=numel(equations)==1&&numel(equations{1})==1;


            type='Linear';
            for ct=1:numel(equations)
                thisInput=equations{ct};
                if~isLinear(thisInput)
                    type='Nonlinear';
                    return;
                end
            end
        end

        function solvers=checkFzero(solvers,problem,isScalar)


            varStruct=problem.Variables;
            varNames=fieldnames(varStruct);
            singleScalarVar=numel(varNames)==1&&numel(varStruct.(varNames{1}))==1;
            if any(strcmp(solvers,'fzero'))&&~(singleScalarVar&&isScalar)
                solvers=setdiff(solvers,'fzero','stable');
            end
        end
    end

    properties(Constant)



        MatlabAndOptimSolvers={...
        'lsqlin',...
        'fzero',...
        'fsolve',...
        'lsqnonlin',...
        'lsqnonneg'};

        GlobalSolvers={};

        AllSolvers=[
        optim.internal.problemdef.solvermap.EquationProblemSolverMap.MatlabAndOptimSolvers,...
        optim.internal.problemdef.solvermap.EquationProblemSolverMap.GlobalSolvers];

        NonlinearEquations={...
        'fzero',...
        'fsolve',...
        'lsqnonlin'};

        LinearEquations=[...
        'lsqlin',...
        optim.internal.problemdef.solvermap.EquationProblemSolverMap.NonlinearEquations,...
        'lsqnonneg'];

        BoundConstraints={...
        'lsqlin',...
        'lsqnonlin',...
        'lsqnonneg'};
    end
end
