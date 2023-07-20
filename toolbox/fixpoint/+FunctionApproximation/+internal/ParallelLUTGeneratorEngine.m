classdef(Sealed)ParallelLUTGeneratorEngine<FunctionApproximation.internal.ApproximateLUTGeneratorEngine







    methods
        function this=ParallelLUTGeneratorEngine(problemObject)
            this=this@FunctionApproximation.internal.ApproximateLUTGeneratorEngine(problemObject);
        end
    end

    methods(Access=protected)
        function executeSolvers(this,allCombinations,solverQueue)


            parpoolObject=gcp('nocreate');


            modelInfo=attachFilesToParpool(this,parpoolObject);
            nSolvers=numel(solverQueue);
            if~isempty(modelInfo)
                for iSolver=1:nSolvers
                    solverQueue(iSolver).setModelInfo(modelInfo);
                end
            end





            poolsize=parpoolObject.NumWorkers;
            combinationSetSize=max(ceil(poolsize/numel(solverQueue)),1);

            counter=1;
            maxObjectiveValue=this.Options.DefaultMemoryUsageBits;
            hardConstraint=solverQueue(1).HardConsTracker;
            softConstraint=solverQueue(1).SoftConsTracker;
            while hardConstraint.advance()&&softConstraint.advance()&&(counter<=numel(allCombinations))



                combinations=FunctionApproximation.internal.solvers.ApproximateLUTDecisionVariableSet.empty();
                while(numel(combinations)<combinationSetSize)&&(counter<=numel(allCombinations))&&hardConstraint.advance()
                    combinations(end+1)=allCombinations(counter);%#ok<AGROW>
                    counter=counter+1;
                end


                errorFeasibleDBUnits=getFeasibleDBUnits(this.DataBase,1);
                if~isempty(errorFeasibleDBUnits)
                    bestDBUnit=getBest(this.DataBase,errorFeasibleDBUnits);
                    maxObjectiveValue=min(bestDBUnit.ObjectiveValue,maxObjectiveValue);
                end


                for iSolver=1:nSolvers
                    solverQueue(iSolver).setMaxObjectiveValue(maxObjectiveValue);
                end


                nCombinations=numel(combinations);
                nProcesses=nSolvers*nCombinations;
                futureObjects=parallel.FevalFuture.empty();
                for iSolver=1:nSolvers
                    for iCombination=1:nCombinations
                        iProcess=sub2ind([nSolvers,nCombinations],iSolver,iCombination);
                        futureObjects(iProcess)=parfeval(parpoolObject,@solve,1,solverQueue(iSolver),combinations(iCombination));
                    end
                end



                nCompletedProcesses=1;
                while hardConstraint.advance()&&(nCompletedProcesses<=nProcesses)

                    try
                        [~,database]=fetchNext(futureObjects);
                    catch err



                        if contains(err.identifier,'parallel:')&&~isempty(err.cause)&&contains(err.cause{1}.identifier,'SimulinkFixedPoint:functionApproximation')
                            err=err.cause{1};
                        end
                        throwAsCaller(err);
                    end


                    dbUnits=getAllDBUnits(database);
                    for iUnit=1:numel(dbUnits)
                        if~hasDBUnit(this.DataBase,dbUnits(iUnit),"Full")
                            this.DataBase.add(dbUnits(iUnit));
                        end
                    end


                    nCompletedProcesses=nCompletedProcesses+1;
                end


                cancel(futureObjects);




                dbUnits=getAllDBUnits(this.DataBase);
                for iSolver=1:nSolvers
                    solverQueue(iSolver).DataBase.clearDBUnits();
                    for iUnit=1:numel(dbUnits)
                        solverQueue(iSolver).DataBase.add(dbUnits(iUnit));
                    end
                end
            end
        end

        function registerDataBase(~,solverQueue)



            for ii=1:numel(solverQueue)
                solverQueue(ii).DataBase=FunctionApproximation.internal.database.ApproximationSolutionsDataBase();
            end
        end
    end

    methods(Hidden)
        function modelInfo=attachFilesToParpool(this,parpoolObject)



            modelInfo=[];
            if this.Problem.InputFunctionType=="GenericFunctionHandle"
                functionWrapper=this.Problem.InputFunctionWrapper;
                while~isa(functionWrapper.FunctionToEvaluate,'function_handle')



                    functionWrapper=functionWrapper.FunctionToEvaluate;
                end
                if~isempty(functionWrapper.TempDirHandler)


                    if~ismember(functionWrapper.TempDirHandler.TempDir,parpoolObject.AttachedFiles)
                        parpoolObject.addAttachedFiles(functionWrapper.TempDirHandler.TempDir);
                    end
                end
            elseif ismember(this.Problem.InputFunctionType,["GenericBlock","SubSystem"])
                functionWrapper=this.Problem.InputFunctionWrapper;
                while~isa(functionWrapper.FunctionToEvaluate,'FunctionApproximation.internal.datatomodeladapter.ModelInfo')



                    functionWrapper=functionWrapper.FunctionToEvaluate;
                end
                if~isempty(functionWrapper.FunctionToEvaluate.TempDirHandler)


                    functionWrapper.FunctionToEvaluate.closeModel();
                    if~ismember(functionWrapper.FunctionToEvaluate.TempDirHandler.TempDir,parpoolObject.AttachedFiles)
                        parpoolObject.addAttachedFiles(functionWrapper.FunctionToEvaluate.TempDirHandler.TempDir);
                    end
                    modelInfo=functionWrapper.FunctionToEvaluate;
                end
            end
        end
    end
end
