function[problemStruct,useParallel]=prob2structImpl(prob,caller,x0,options,inMemory,...
    useParallel,objectiveFcnName,constraintFcnName,filePath,...
    objectiveDerivative,constraintDerivative,customSolver,globalSolver)




























    problemStruct.NumVars=0;
    problemStruct.subfun=struct;
    problemStruct.objectiveDerivative=objectiveDerivative;
    problemStruct.constraintDerivative=constraintDerivative;
    problemStruct.NumNonlinEqConstraints=0;
    problemStruct.FcnHandleForWorkers.funfcn={};
    problemStruct.FcnHandleForWorkers.confcn={};
    problemStruct.CtsSolverWithIntVars.selected=false;
    problemStruct.CtsSolverWithIntVars.intcon=[];
    problemStruct.CtsSolverWithIntVars.intvarnames={};
    problemStruct.filePath=filePath;
    problemStruct.x0Input=x0;
    problemStruct.SolveSetInitialX=false;
    problemStruct.SolveSetInitialObjConVals=false;



    problemStruct=prob.compileVarInfo(problemStruct,x0);






    if strcmp(caller,'prob2struct')&&~isempty(problemStruct.intcon)&&...
        ~isempty(customSolver)&&~any(strcmp(customSolver,prob.IntegerSolvers))
        problemStruct.CtsSolverWithIntVars.selected=true;
        problemStruct.CtsSolverWithIntVars.intcon=problemStruct.intcon;
        problemStruct.intcon=[];
        problemStruct=setVariablesForCtsSolverWithIntVars(prob,problemStruct);
        c=onCleanup(@()resetVariablesForCtsSolverWithIntVars(prob,problemStruct));
    end


    problemStruct.solver=determineSolver(prob,problemStruct,caller);














    problemStruct.derivativeFreeSolver=any(strcmpi(problemStruct.solver,getSolversThatNeedDenseMatrices()));


    if useParallel
        if useFiniteDifferences(prob,problemStruct)||...
            (~isempty(globalSolver)&&isa(globalSolver,'MultiStart'))||...
            problemStruct.derivativeFreeSolver




            try

                pool=gcp;
            catch

                pool=[];
            end
            if isempty(pool)

                useParallel=false;
                options.UseParallel=false;
                warning(message('optimlib:commonMsgs:NoPCTLicense'));
            end
        else


            useParallel=false;
            options.UseParallel=false;
            warning(message('optim_problemdef:OptimizationProblem:solve:UseParallelWithADIgnored'));
        end
    end


    problemStruct=prob.compileConstraints(problemStruct,inMemory,useParallel,...
    constraintFcnName);


    problemStruct=prob.compileObjectives(problemStruct,inMemory,useParallel,...
    objectiveFcnName);





    if isfield(problemStruct,'intcon')&&~isempty(problemStruct.intcon)
        hasNonlinearObjective=isfield(problemStruct,'objective');
        hasNonlinearConstraints=isfield(problemStruct,'nonlcon');
        isMILP=strcmp(problemStruct.solver,'intlinprog')&&...
        ~hasNonlinearObjective&&~hasNonlinearConstraints;
        if~isMILP&&~optim.internal.utils.hasGlobalOptimizationToolbox


            if isstruct(prob.Objective)
                objNames=fieldnames(prob.Objective);
                isMIQP=numel(objNames)==1&&isQuadratic(prob.Objective.(objNames{1}))&&~hasNonlinearConstraints;
            else
                isMIQP=isscalar(prob.Objective)&&isQuadratic(prob.Objective)&&~hasNonlinearConstraints;
            end
            if isMIQP
                mID='optim_problemdef:OptimizationProblem:%s:IntegerQP';
            else
                mID='optim_problemdef:OptimizationProblem:%s:IntegerNLP';
            end
            throwAsCaller(MException(sprintf(mID,caller),...
            getString(message(sprintf(mID,'solve')))));
        end
    end


    optim.internal.problemdef.writeCompiledFcn(problemStruct.subfun,inMemory,useParallel,filePath);



    problemStruct.options=options;
    if isa(options,'optim.options.SolverOptions')
        problemStruct.setByUserOptions=getSetByUserOptionNames(options);
    else
        problemStruct.setByUserOptions={};
    end


    problemStruct.nvars=problemStruct.NumVars;
    defaultSolverX0=isempty(customSolver)&&isfield(problemStruct,'solver')&&~any(strcmpi(problemStruct.solver,getSolversWithNvarInput()));
    userSolverX0=~isempty(customSolver)&&~any(strcmpi(customSolver,getSolversWithNvarInput()));
    if(defaultSolverX0||userSolverX0)
        problemStruct=rmfield(problemStruct,'nvars');
    end




    if isa(x0,"optim.problemdef.OptimizationValues")
        NonScalarX0Solvers=["ga","gamultiobj","paretosearch","particleswarm","surrogateopt"];
        ScalarX0SolversWithGlobalSolvers=["fmincon","fminunc","lsqnonlin","lsqcurvefit"];
        if isempty(customSolver)
            checkSolver=problemStruct.solver;
        else
            checkSolver=customSolver;
        end
        isNonScalarX0Solver=any(strcmp(checkSolver,NonScalarX0Solvers));
        isScalarX0SolverWithGlobalSolver=...
        any(strcmp(checkSolver,ScalarX0SolversWithGlobalSolvers))&&~isempty(globalSolver);

        if~isscalar(x0)&&~isNonScalarX0Solver&&~isScalarX0SolverWithGlobalSolver
            mID='optim_problemdef:OptimizationProblem:%s:NonScalarX0';
            throwAsCaller(MException(sprintf(mID,caller),...
            getString(message(sprintf(mID,'solve')))));
        end
    end


    if optim.internal.problemdef.display.allowsDisplay(options)
        prob.displayReformulationMessage(problemStruct);
    end


    if(strlength(customSolver)>0)
        targetSolver=customSolver;
    else
        targetSolver=problemStruct.solver;
    end
    problemStruct=updateProbStruct(prob,caller,problemStruct,targetSolver);


    if~inMemory
        problemStruct=rmfield(problemStruct,'FcnHandleForWorkers');
    end


    if any(strcmpi(problemStruct.solver,getSolversThatNeedDenseMatrices))
        problemStruct=convertLinearConstraintsX0ToFull(problemStruct);
    end


    if problemStruct.CtsSolverWithIntVars.selected
        warning(message('optim_problemdef:ProblemImpl:prob2struct:CustomCtsSolverWithIntVars',upper(customSolver)));
        problemStruct.intcon=problemStruct.CtsSolverWithIntVars.intcon;
    end



    problemStruct=rmfield(problemStruct,...
    {'NumVars','subfun','NumNonlinEqConstraints','CtsSolverWithIntVars','filePath','x0Input'});

end


function solvers=getSolversWithNvarInput()
    solvers=["ga","gamultiobj","paretosearch","particleswarm"];
end

function solvers=getSolversThatNeedDenseMatrices()
    solvers=["ga","gamultiobj","paretosearch","patternsearch","surrogateopt"];
end

function probStruct=convertLinearConstraintsX0ToFull(probStruct)
    probStruct.Aineq=full(probStruct.Aineq);
    probStruct.bineq=full(probStruct.bineq);
    probStruct.Aeq=full(probStruct.Aeq);
    probStruct.beq=full(probStruct.beq);

    if isfield(probStruct,'x0')
        probStruct.x0=full(probStruct.x0);
    end
end

function probStruct=setVariablesForCtsSolverWithIntVars(prob,probStruct)

    vars=prob.Variables;
    varNames=fieldnames(vars);
    numVarNames=numel(varNames);
    isInt=false(1,numVarNames);
    for k=1:numVarNames
        if strcmp(vars.(varNames{k}).Type,'integer')
            vars.(varNames{k}).Type='continuous';
            isInt(k)=true;
        end
    end
    probStruct.CtsSolverWithIntVars.intvarnames=varNames(isInt);

end

function resetVariablesForCtsSolverWithIntVars(prob,probStruct)

    vars=prob.Variables;
    intvarnames=probStruct.CtsSolverWithIntVars.intvarnames;
    for k=1:numel(intvarnames)
        vars.(intvarnames{k}).Type='integer';
    end

end
