classdef EquationProblem<optim.internal.problemdef.ProblemImpl

















    properties(Dependent)
Equations
    end


    methods
        problemStruct=prob2struct(prob,varargin);
        [sol,varargout]=solve(prob,varargin)
    end


    methods

        function eqns=get.Equations(prob)
            eqns=prob.ObjectivesStore;
        end

    end




    properties(Hidden,SetAccess=protected,GetAccess=public)
        EquationProblemVersion=1;
    end

    properties(Constant,Hidden)

        SupportedSolvers=...
        optim.internal.problemdef.solvermap.EquationProblemSolverMap.MatlabAndOptimSolvers;

        SupportedGlobalSolvers=...
        optim.internal.problemdef.solvermap.EquationProblemSolverMap.GlobalSolvers;

        MessageCatalogID="optim_problemdef:EquationProblem";

        ObjectivePtyName="Equations";
        ConstraintPtyName="";

        IntegerSolvers={};

        ObjectiveCompileName="Equation";
        DerivativeCompileName="Jacobian";

        SupportsGlobalSolvers=false;
    end

    methods(Hidden)
        function prob=EquationProblem()
            prob.ObjectivesStore=prob.getDefaultObjectives();
            prob.ConstraintsStore=prob.getDefaultConstraints();
        end


        prob=subsasgn(prob,s,expr);


        solvers=getValidSolvers(prob,varargin);


        solver=determineSolver(prob,probStruct,caller);



        ism=isObjectiveMax(prob);
    end

    methods(Hidden,Access=protected)



        probStruct=compileObjectives(prob,probStruct,inMemory,useParallel,fcnName);
        probStruct=compileConstraints(prob,probStruct,inMemory,useParallel,fcnName);



        displayReformulationMessage(prob,probStruct);



        probStruct=updateProbStruct(prob,caller,probStruct,solvername);


        [x,fval,exitflag,output,lambda]=callSolver(prob,probStruct);



        dispStr=customizeObjectivesProperty(prob,dispStr);



        dispStr=customizeConstraintsProperty(prob,dispStr);



        groups=getCustomPropertyGroup(prob);


        objectiveStr=expandObjectives2str(prob,addBolding,varargin);


        constraintsStr=expandConstraints2str(prob,addBolding,varargin);



        constraintsOut=checkValidConstraints(prob,constraintsIn);


        fvalOut=mapFvalSolution(prob,fvalIn);


        lambdaOut=mapLambdaSolution(prob,lambdaIn);


        probStruct=updateOptions(prob,probStruct);




        checkForIncorrectDerivativeOption(prob,nvPairs,caller);


        useFinDiff=useFiniteDifferences(obj,probStruct);

    end

    methods(Static,Hidden,Access=protected)



        function cName=className()
            cName="EquationProblem";
        end



        function expr=getDefaultObjectives()
            expr=struct([]);
        end



        function constr=getDefaultConstraints()
            constr=struct([]);
        end


        tolFunValue=getFunctionToleranceForSolve(solver,varargin)



        objectivesOut=checkValidObjectives(objectivesIn,...
        settingLabelledObjectives);

    end

end
