classdef ApproximateLUTGeneratorEngine<FunctionApproximation.internal.ApproximateGeneratorEngine





    methods
        function this=ApproximateLUTGeneratorEngine(problemObject)
            this=this@FunctionApproximation.internal.ApproximateGeneratorEngine(problemObject);
        end

        function[diagnostic,solution]=run(this)
            validationRangeObject=FunctionApproximation.internal.Range(this.Problem.InputLowerBounds,this.Problem.InputUpperBounds);



            if this.Problem.InputFunctionType==FunctionApproximation.internal.FunctionType.LUTBlock
                losslessCompresionSolver=FunctionApproximation.internal.solvers.LosslessCompressionSolver();
                losslessCompresionSolver.DataBase=this.DataBase;
                losslessCompresionSolver.ValidationRangeObject=validationRangeObject;
                losslessCompresionSolver.TableDataRangeObject=validationRangeObject;
                this.updateOptionsOnSolvers(losslessCompresionSolver,this.Options)
                losslessCompresionSolver.registerDependencies(this.Problem);
                losslessCompresionSolver.solve();
            end

            if this.Problem.ToleranceCanBeMet&&~isempty(this.Options.BreakpointSpecification)
                solverQueue=FunctionApproximation.internal.LUTSolverFactory().getSolverQueue(this.Problem,this.Options);
                nSolvers=numel(solverQueue);


                for ii=1:nSolvers
                    solverQueue(ii).ValidationRangeObject=validationRangeObject;
                    solverQueue(ii).TableDataRangeObject=validationRangeObject;
                end

                if(this.Problem.NumberOfInputs==1)&&this.Options.UseClipping


                    rangeTruncator=FunctionApproximation.internal.rangetruncator.RangeTruncator1D();
                    truncatedRange=rangeTruncator.truncate(...
                    this.Problem.InputFunctionWrapper,...
                    validationRangeObject,...
                    this.Problem.InputTypes,...
                    this.Options);










                    clippingIsSetByUser=~ismember('UseClipping',this.Options.DefaultFields);
                    for ii=1:nSolvers
                        spacing=solverQueue(ii).Spacing;
                        if(spacing=="ExplicitValues")||(~(spacing=="ExplicitValues")&&clippingIsSetByUser)
                            solverQueue(ii).TableDataRangeObject=truncatedRange;
                        end
                        solverQueue(ii).TruncatedRangeObject=truncatedRange;
                    end
                end



                [softConsTracker,hardConsTracker]=FunctionApproximation.internal.progresstracking.getConstraintsProgressTracker(this.DataBase,this.Options);
                softConsTracker.initialize();
                hardConsTracker.initialize();
                for ii=1:nSolvers
                    solverQueue(ii).SoftConsTracker=softConsTracker;
                    solverQueue(ii).HardConsTracker=hardConsTracker;
                end


                this.updateOptionsOnSolvers(solverQueue,this.Options)

                for ii=1:nSolvers
                    solverQueue(ii).registerDependencies(this.Problem);
                end

                this.registerDataBase(solverQueue);

                if this.ExploreFixedPoint
                    dataTypeCombinations=FunctionApproximation.internal.ApproximateLUTDecisionVariableSetFactory().getApproximateLUTDecisionVariableSet(this.Problem,this.Options);
                    if~isempty(dataTypeCombinations)
                        tmpOptions=this.Options;
                        tmpOptions.ExploreFixedPoint=true;
                        tmpOptions.ExploreFloatingPoint=false;
                        this.updateOptionsOnSolvers(solverQueue,tmpOptions)
                        executeSolvers(this,dataTypeCombinations,solverQueue);
                    end
                end

                if this.ExploreFloatingPoint
                    tmpOptions=this.Options;
                    tmpOptions.ExploreFixedPoint=false;
                    tmpOptions.ExploreFloatingPoint=true;
                    this.updateOptionsOnSolvers(solverQueue,tmpOptions)
                    executeFloatingPointCase(this,solverQueue);
                end

                if~this.Options.AUTOSARCompliant
                    registerSimplerSpacing(this);
                end
                FunctionApproximation.internal.DisplayUtils.displayCauses(solverQueue(1).HardConsTracker.TrackerDiagnostic,this.Options);
            end

            adapter=FunctionApproximation.internal.LUTDBUnitToApproximateLUTSolutionAdapter;
            dbUnit=this.DataBase.getBest();
            if isempty(dbUnit)
                dbUnit=this.DataBase.getBestInfeasible();
            end
            [solution,diagnostic]=adapter.createSolution(dbUnit,this.Problem,this.Options,this.DataBase);
        end
    end

    methods(Abstract,Access=protected)
        executeSolvers(this,allCombinations,solverQueue)
        registerDataBase(this,solverQueue);
    end

    methods(Access=private)
        function executeFloatingPointCase(this,solverQueue)





            dbUnit=this.DataBase.getBestFeasible();
            interfaceTypes=[this.Problem.InputTypes,this.Problem.OutputType];
            if isempty(dbUnit)
                storageTypes=interfaceTypes;
            else
                storageTypes=dbUnit.StorageTypes;
            end
            combinationsFactory=FunctionApproximation.internal.ApproximateLUTFloatingPointDecisionVariableSetFactory();
            floatingPointCombinations=combinationsFactory.getApproximateLUTDecisionVariableSet(this.Problem,storageTypes);
            if~isempty(floatingPointCombinations)
                validCombinations=true(1,numel(floatingPointCombinations));
                for ii=1:numel(floatingPointCombinations)
                    newStorageTypes=floatingPointCombinations(ii).StorageTypes;
                    newStorageTypes=this.handleHalfInStorageTypes(interfaceTypes,newStorageTypes,storageTypes);
                    floatingPointCombinations(ii)=setStorageTypes(floatingPointCombinations(ii),newStorageTypes);
                    validCombinations(ii)=any(arrayfun(@(x)fixed.internal.type.isAnyFloat(x),newStorageTypes));
                end
                floatingPointCombinations=floatingPointCombinations(validCombinations);
                wlSum=zeros(1,numel(floatingPointCombinations));
                for ii=1:numel(floatingPointCombinations)
                    localStorageTypes=floatingPointCombinations(ii).StorageTypes;
                    wlSum(ii)=sum(arrayfun(@(x)x.WordLength,localStorageTypes));
                end
                [~,indices]=sort(wlSum);
                floatingPointCombinations=floatingPointCombinations(indices);
                executeSolvers(this,floatingPointCombinations,solverQueue);
            end
        end

        function registerSimplerSpacing(this)



            if this.Options.UseBPSpecAsIs||this.ExploreFloatingPoint



                return;
            end
            allDBUnits=getAllDBUnits(this.DataBase);
            for iUnit=1:numel(allDBUnits)
                if allDBUnits(iUnit).IndividualConstraintMet(1)
                    sData=allDBUnits(iUnit).SerializeableData;
                    newSData=FunctionApproximation.internal.serializabledata.convertToSimplerSpacing(sData);
                    spacingChanged=newSData.Spacing~=sData.Spacing;
                    if spacingChanged
                        newUnit=allDBUnits(iUnit);
                        newUnit.SerializeableData=newSData;
                        newUnit.BreakpointSpecification=newSData.Spacing;
                        if~hasDBUnit(this.DataBase,newUnit,"Full")
                            this.DataBase.add(newUnit);
                        end
                    end
                end
            end
        end
    end

    methods(Static,Hidden)
        function combinationSetSize=getCombinationSetSize(inputFunctionType,wordLenghts)



            if isBlock(inputFunctionType)





                combinationSetSize=16;
            else
                if max(wordLenghts)<=18




                    combinationSetSize=8;
                else

                    combinationSetSize=16;
                end
            end
        end

        function newStorageTypes=handleHalfInStorageTypes(interfaceTypes,newStorageTypes,originalStorageTypes)
            allTypes=[interfaceTypes,newStorageTypes];
            isFloatVector=arrayfun(@(x)fixed.internal.type.isAnyFloat(x),allTypes);
            if~all(isFloatVector)
                numStorageTypes=numel(newStorageTypes);
                for iType=1:numStorageTypes
                    if newStorageTypes(iType).ishalf()
                        if originalStorageTypes(iType).WordLength>=32
                            newStorageTypes(iType)=numerictype('single');
                        else
                            newStorageTypes(iType)=originalStorageTypes(iType);
                        end
                    end
                end
            end
        end
    end
end


