classdef OptimizationProblem<optim.internal.problemdef.ProblemImpl
















    properties
        ObjectiveSense='minimize'
    end

    properties(Dependent=true)
Objective
Constraints
    end


    methods
        problemStruct=prob2struct(prob,varargin);
        [sol,varargout]=solve(prob,varargin)
    end


    methods

        function obj=get.Objective(prob)
            obj=prob.ObjectivesStore;
        end

        function constr=get.Constraints(prob)
            constr=prob.ConstraintsStore;
        end

        function sense=get.ObjectiveSense(prob)
            if isstruct(prob.ObjectiveSense)
                sense=prob.ObjectiveSense;
            else
                sense=char(prob.ObjectiveSense);
            end
        end

        function prob=set.ObjectiveSense(prob,senseIn)


            if isstruct(senseIn)
                if isstruct(prob.ObjectivesStore)
                    objNames=fieldnames(prob.ObjectivesStore);
                    fnames=fieldnames(senseIn);
                    if any(~ismember(objNames,fnames))
                        error(message('optim_problemdef:OptimizationProblem:ObjSenseMustHaveSameFieldsAsObj'));
                    end
                    if any(~ismember(fnames,objNames))
                        warning(message('optim_problemdef:OptimizationProblem:ObjSenseHasFieldsNotInObj'));
                    end
                else
                    validObjSense=newline+strjoin(blanks(4)+...
                    ["'max'";"'maximize'";"'min'";"'minimize'"],'\n');
                    error(message('optim_problemdef:OptimizationProblem:InvalidObjSense',validObjSense));
                end
            end


            if isstruct(senseIn)
                sense=structfun(@iValidateObjectiveSenseString,senseIn,...
                'UniformOutput',false);
            else
                sense=iValidateObjectiveSenseString(senseIn);
            end


            if isstruct(sense)


                fnames=fieldnames(sense);
                if numel(fnames)>1
                    senseOut=sense;
                else
                    senseOut=sense.(fnames{1});
                end
            elseif isstruct(prob.ObjectiveSense)&&...
                isstruct(prob.ObjectivesStore)&&...
                numel(fieldnames(prob.ObjectivesStore))>1


                senseOut=prob.ObjectiveSense;
                fnames=fieldnames(senseOut);
                for i=1:numel(fnames)
                    senseOut.(fnames{i})=sense;
                end
            else



                senseOut=sense;
            end
            prob.ObjectiveSense=senseOut;
        end



        function prob=set.Objective(prob,expr)
            prob.ObjectivesStore=expr;
        end



        function prob=set.Constraints(prob,constr)
            prob.ConstraintsStore=constr;
        end

    end




    properties(Hidden,SetAccess=protected,GetAccess=public)
        OptimizationProblemVersion=1;
    end

    properties(Constant,Hidden)

        SupportedSolvers=...
        optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.MatlabAndOptimSolvers;

        SupportedGlobalSolvers=...
        optim.internal.problemdef.solvermap.OptimizationProblemSolverMap.GlobalSolvers;

        MessageCatalogID="optim_problemdef:OptimizationProblem";

        ObjectivePtyName="Objective";
        ConstraintPtyName="Constraints";

        IntegerSolvers={'intlinprog','ga','surrogateopt','gamultiobj'}

        ObjectiveCompileName="Objective";
        DerivativeCompileName="Gradient";

        SolversWithX0InOptions=["ga","gamultiobj","particleswarm",...
        "surrogateopt","paretosearch"];

        MultiStartSolvers=["fmincon","fminunc","lsqnonlin"]

        GlobalSearchSolvers="fmincon"

        SupportsGlobalSolvers=true;
    end

    methods(Hidden)
        function prob=OptimizationProblem(varargin)
            assert(nargin==0,...
            message('optim_problemdef:OptimizationProblem:InvalidConstruction'));
            prob.ObjectivesStore=prob.getDefaultObjectives();
            prob.ConstraintsStore=prob.getDefaultConstraints();
        end


        prob=subsasgn(prob,s,expr);


        [solvers,objectiveType,constraintType]=getValidSolvers(prob,varargin);


        solver=determineSolver(prob,probStruct,caller);



        ism=isObjectiveMax(prob);



        names=getNonlinearInequalityConstraintNames(p)


        [varNames,objNames,conNames]=getQuantityNames(p)



        quantityNames=getQuantityNamesForTabCompletion(p)



        validateSolverForMultiplePoint(prob,globalSolver,solver);

    end

    methods(Hidden=true,Access=protected)


        probStruct=updateOptions(prob,probStruct);



        probStruct=compileObjectives(prob,probStruct,inMemory,useParallel,fcnName);
        probStruct=compileConstraints(prob,probStruct,inMemory,useParallel,fcnName);
        probStruct=compileMultipleObjectives(prob,probStruct,inMemory,useParallel,fcnname);



        probStruct=updateProbStruct(prob,caller,probStruct,solvername);


        [x,fval,exitflag,output,lambda]=callSolver(prob,probStruct);


        [x,fval,exitflag,output,lambda]=callGlobalSolver(prob,probStruct);



        dispStr=customizeObjectivesProperty(prob,dispStr);



        dispStr=customizeConstraintsProperty(prob,dispStr);



        groups=getCustomPropertyGroup(prob);


        objectiveStr=expandObjectives2str(prob,addBolding,varargin);


        constraintsStr=expandConstraints2str(prob,addBolding,varargin);


        fvalOut=mapFvalSolution(prob,fvalIn);


        lambdaOut=mapLambdaSolution(prob,lambdaIn);




        checkForIncorrectDerivativeOption(prob,nvPairs,caller);


        useFinDiff=useFiniteDifferences(obj,probStruct);



        prob=updateObjectiveSenseAfterObjectiveSet(prob,oldObjective,newObjective);


        isMultiObj=isMultiObjective(prob);

    end

    methods(Static)



        propertyName=getPropertyFromQuantityName(quantityName,...
        variableNames,objectiveNames)

    end

    methods(Static=true,Hidden=true,Access=protected)



        function cName=className()
            cName="OptimizationProblem";
        end



        function expr=getDefaultObjectives()
            expr=optim.problemdef.OptimizationExpression([0,0],{{},{}});
        end



        function constr=getDefaultConstraints()
            constr=struct([]);
        end



        objectivesOut=checkValidObjectives(objectivesIn,...
        settingLabelledObjective);



        constraintsOut=checkValidConstraints(constraintsIn);

    end

end


function sense=iValidateObjectiveSenseString(sense)


    optim.internal.problemdef.mustBeCharVectorOrString(sense,'ObjectiveSense');


    switch lower(sense)
    case{'max','maximize'}
        sense='maximize';
    case{'min','minimize'}
        sense='minimize';
    otherwise
        validObjSense=newline+strjoin(blanks(4)+["'max'";"'maximize'";"'min'";"'minimize'"],'\n');
        error('MATLAB:validators:mustBeMember',...
        getString(message('optim_problemdef:OptimizationProblem:InvalidObjSense',validObjSense)));
    end

end