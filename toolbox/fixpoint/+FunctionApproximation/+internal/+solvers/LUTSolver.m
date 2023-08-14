classdef(Abstract)LUTSolver<FunctionApproximation.internal.solvers.SolverInterface




    properties(SetAccess=protected)
Original
NumberOfDimensions
Grid
GridSizeInitializer
StorageWordLengths
StorageTypes
InputTypes
OutputType
UseBruteForce
ExtremaStrategy
InputFunctionType
Spacing
BruteForceGrid
CombinationSetConsTracker
ContextForInitialPoints
        NumInitialPoints=[]
        ModelInfo=[]
        TableValueOptimizerContext=FunctionApproximation.internal.solvers.TableValueOptimizerContext();
        TableValueOptimizer FunctionApproximation.internal.solvers.TableValueOptimizer
RelaxThreshold
    end

    properties(SetAccess={?FunctionApproximation.internal.solvers.LUTSolver,...
        ?FunctionApproximation.internal.ApproximateLUTGeneratorEngine})
TableDataRangeObject
ValidationRangeObject
        TruncatedRangeObject=FunctionApproximation.internal.Range.empty();
    end

    methods(Access=protected)
        gridCreator=getGridCreator(~,inputTypes);
        performSearch(this);
        gridObject=getGrid(this,gridSize);
        flag=proceedToValidateConstraint(this,dbUnit);
        flag=attemptConstraintCheck(this,currentObjectiveValue);
        setSpacing(this);
        [recheckConstraintMet,currentError]=validateWithSaturationOn(this,constraintMet,currentError,blockWrapper);
    end

    methods(Access={?FunctionApproximation.internal.solvers.LUTSolver,...
        ?FunctionApproximation.internal.progresstracking.TrackingStrategy})
        maxAttempts=getMaxAttempts(this);
        dbUnits=getFeasibleDBUnits(this,varargin);
    end

    methods(Hidden)
        function setOptions(this,options)
            options.BreakpointSpecification=this.Spacing;
            this.Options=options;
        end

        function setModelInfo(this,modelInfo)
            this.ModelInfo=modelInfo;
        end
    end

    methods
        function this=LUTSolver()
            this=this@FunctionApproximation.internal.solvers.SolverInterface();
            setSpacing(this);
        end

        function db=solve(this,combinations)
            if~isempty(this.ModelInfo)
%#USEPARALLEL
                functionWrapper=this.Original;
                while~isa(functionWrapper,'FunctionApproximation.internal.functionwrapper.BlockWrapper')



                    functionWrapper=functionWrapper.FunctionToEvaluate;
                end
                functionWrapper.setFunctionToEvaluate(this.ModelInfo);

                functionWrapper=this.ErrorFunction.Original;
                while~isa(functionWrapper,'FunctionApproximation.internal.functionwrapper.BlockWrapper')



                    functionWrapper=functionWrapper.FunctionToEvaluate;
                end
                functionWrapper.setFunctionToEvaluate(this.ModelInfo);
            end


            this.CombinationSetConsTracker.initialize();


            for ii=1:numel(combinations)


                data=getData(this,combinations(ii));
                this.ErrorFunction.modify(data);




                performSearch(this);

                if~this.CombinationSetConsTracker.advance()
                    break;
                end
            end

            db=this.DataBase;
        end

        function registerDependencies(this,problemObject)

            this.NumberOfDimensions=problemObject.NumberOfInputs;
            gridCreator=getGridCreator(this,problemObject.InputTypes);
            this.InputTypes=problemObject.InputTypes;
            this.UseBruteForce=...
            FunctionApproximation.internal.canBruteForceGridingBeUsed(...
            this.ValidationRangeObject,this.InputTypes);
            this.Original=problemObject.InputFunctionWrapper;
            this.InputFunctionType=problemObject.InputFunctionType;

            this.CombinationSetConsTracker=FunctionApproximation.internal.progresstracking.getCombSetConstraintsProgressTracker(this,getMaxAttempts(this));

            this.ContextForInitialPoints=FunctionApproximation.internal.gridsizeinitializer.ContextInitialPoints();
            this.ContextForInitialPoints.FunctionWrapper=problemObject.InputFunctionWrapper;
            this.ContextForInitialPoints.FunctionType=this.InputFunctionType;
            this.ContextForInitialPoints.AbsTol=this.Options.AbsTol;
            this.ContextForInitialPoints.RelTol=this.Options.RelTol;
            this.ContextForInitialPoints.RangeObject=this.TableDataRangeObject;
            this.ContextForInitialPoints.InputTypes=this.InputTypes;
            this.ContextForInitialPoints.GridStorageTypes=this.InputTypes;
            this.ContextForInitialPoints.Spacing=this.Spacing;
            this.ContextForInitialPoints.ScaleFactor=2;

            bruteForceGridingStrategyFactory=FunctionApproximation.internal.gridcreator.GridingStrategyFactory();
            bruteForceGridCreator=bruteForceGridingStrategyFactory.getMaximumPointsGridStrategy(this.UseBruteForce,this.InputTypes);
            bruteForceGrid=bruteForceGridCreator.getGrid(this.ValidationRangeObject,[]);
            this.BruteForceGrid=FunctionApproximation.internal.Grid(bruteForceGrid,bruteForceGridCreator);

            extremaStrategyFactory=FunctionApproximation.internal.extremastrategy.ExtremaStrategyFactory();
            this.ExtremaStrategy=extremaStrategyFactory.getStrategy(this.UseBruteForce,this.NumberOfDimensions);

            if this.UseBruteForce


                grid=this.BruteForceGrid.SingleDimensionDomains;
            else


                tmpGridInitializer=FunctionApproximation.internal.gridsizeinitializer.MinimumNumberOfPointsInitializer();
                tmpGridCreator=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(problemObject.InputTypes);
                grid=tmpGridCreator.getGrid(this.ValidationRangeObject,getGridSize(tmpGridInitializer,this.ContextForInitialPoints));
            end
            this.Grid=FunctionApproximation.internal.Grid(grid,gridCreator);

            this.OutputType=problemObject.OutputType;
            serializeableData=FunctionApproximation.internal.serializabledata.LUTModelData();
            tableData=FunctionApproximation.internal.getTableData(FunctionApproximation.BreakpointSpecification.ExplicitValues,problemObject.InputFunctionWrapper,this.Grid);
            serializeableData=serializeableData.update(...
            this.InputTypes,this.OutputType,...
            this.Spacing,tableData,[this.InputTypes,this.OutputType],...
            FunctionApproximation.internal.modifyInterpString(this.Options.Interpolation));
            serializeableData.HDLOptimized=this.Options.HDLOptimized;
            serializeableData.ApproximateType=this.Options.ApproximateSolutionType;

            approximationWrapper=FunctionApproximation.internal.getWrapper(serializeableData,this.Options);



            this.ErrorFunction=FunctionApproximation.internal.functionwrapper.ErrorFunctionWrapper(problemObject.InputFunctionWrapper,approximationWrapper,this.Options.AbsTol,this.Options.RelTol);
            outputRange=double(fixed.internal.type.finiteRepresentableRange(this.OutputType));
            this.OutputTypeRange=outputRange+[-1,1]*this.Options.AbsTol;

            if~this.Options.OnCurveTableValues
                this.TableValueOptimizerContext.TestGrid=this.BruteForceGrid;
                this.TableValueOptimizerContext.TestSet=this.BruteForceGrid.getSets();
                this.TableValueOptimizerContext.OriginalFunctionEvaluation=problemObject.InputFunctionWrapper.evaluate(this.TableValueOptimizerContext.TestSet);
                this.TableValueOptimizerContext.Options=this.Options;
                this.TableValueOptimizerContext.HardConstraintTracker=this.HardConsTracker;
                this.TableValueOptimizerContext.BreakpointSpecification=this.Spacing;
                this.TableValueOptimizerContext.Interpolation=this.Options.Interpolation;
                this.TableValueOptimizerContext.NormOrder=this.Options.TableValueOptimizationNormOrder;
                this.TableValueOptimizerContext.OriginalFunctionEvaluationAbsoluteValue=abs(this.TableValueOptimizerContext.OriginalFunctionEvaluation);
                this.TableValueOptimizerContext.ErrorBound=max(this.Options.RelTol*this.TableValueOptimizerContext.OriginalFunctionEvaluationAbsoluteValue,this.Options.AbsTol);
                this.TableValueOptimizer=FunctionApproximation.internal.solvers.getTableValueOptimizer(this.TableValueOptimizerContext);
            end
        end
    end

    methods(Access=protected)
        function resetApproximationParameters(this)
            anyUpdates=false;
            data=this.ErrorFunction.Approximation.Data;
            if~strcmp(data.RoundingMode,'Simplest')
                anyUpdates=true;
                data.RoundingMode='Simplest';
            end
            if~strcmp(data.SaturateOnIntegerOverflow,'off')
                anyUpdates=true;
                data.SaturateOnIntegerOverflow='off';
            end
            if anyUpdates
                this.ErrorFunction.Approximation.modify(data);
            end
        end

        function currentError=getError(this,gridSize)
            currentError=NaN;


            trivialSolutionObjectiveValue=FunctionApproximation.internal.getLUTDataMemoryUsage(...
            this.Options.BreakpointSpecification,...
            2*ones(size(gridSize)),...
            this.StorageWordLengths(1:end-1),...
            this.StorageWordLengths(end)...
            );
            betterSolutionCanBeFound=this.MaxObjectiveValue>trivialSolutionObjectiveValue;
            hardConstraintNotReached=this.HardConsTracker.advance();

            if hardConstraintNotReached&&betterSolutionCanBeFound
                resetApproximationParameters(this);




                gridObject=getGrid(this,gridSize);
                currentError=evaluateGridObject(this,gridObject);

                if this.Options.Interpolation~="Flat"
                    return
                end

                flat1DExplicitValueOffCuveUnsaturatedOutputFlag=FunctionApproximation.internal.Utils.isFlat1DExplicitValueOffCurveUnsaturatedOutput(this.Options,this.NumberOfDimensions);
                if flat1DExplicitValueOffCuveUnsaturatedOutputFlag
                    return
                end






                gridObjectNew=gridObject;
                nAttempts=2;
                for ii=1:nAttempts
                    gridObjectNew=FunctionApproximation.internal.updateGridForFlatInterpolation(gridObjectNew);
                    currentErrorFlat=evaluateGridObject(this,gridObjectNew);
                    currentError=min(currentError,currentErrorFlat);


                    if(currentError>this.Options.AbsTol)
                        break;
                    end
                end
            end
        end

        function currentError=evaluateGridObject(this,gridObject)
            maxErrorCoordinates=NaN;
            currentError=NaN;


            currentObjectiveValue=FunctionApproximation.internal.getLUTDataMemoryUsage(...
            this.Options.BreakpointSpecification,...
            gridObject.GridSize,...
            this.StorageWordLengths(1:end-1),...
            this.StorageWordLengths(end),...
            this.Options.HDLOptimized,...
            lower(char(this.Options.Interpolation)));




            dbUnit=FunctionApproximation.internal.database.LUTDBUnit();
            dbUnit.GridSize=gridObject.GridSize;
            dbUnit.ConstraintAt=maxErrorCoordinates;
            dbUnit.ConstraintValue=[currentError,this.ObjectiveValue];
            dbUnit.ConstraintValueMustBeLessThan=[this.Options.AbsTol,this.Options.MaxMemoryUsageBits];
            dbUnit.ObjectiveValue=currentObjectiveValue;
            dbUnit.BreakpointSpecification=this.Spacing;
            dbUnit.Grid=gridObject;
            dbUnit.StorageTypes=this.StorageTypes;



            if attemptConstraintCheck(this,currentObjectiveValue)




                if proceedToValidateConstraint(this,dbUnit)

                    [maxErrorCoordinates,currentError,tableValuesOptimized]=constraintFunction(this,gridObject,currentObjectiveValue);
                    dbUnit.ConstraintAt=maxErrorCoordinates;
                    dbUnit.ConstraintValue=[currentError,currentObjectiveValue];
                    dbUnit.SerializeableData=this.ErrorFunction.Approximation.Data;
                    dbUnit.TableValuesOptimized=tableValuesOptimized;
                    this.ObjectiveValue=dbUnit.ObjectiveValue;
                    registerDBUnit(this,dbUnit);
                else
                    dbUnit=getDBUnit(this.DataBase,getHexString(dbUnit,"Partial"),"Partial");
                    currentError=dbUnit.ConstraintValue(1);
                end

                if dbUnit.IndividualConstraintMet(1)


                    updateMaxObjectiveValue(this);
                end
            end
        end

        function registerDBUnit(this,dbUnit)
            if isnan(dbUnit.ConstraintValue(1))
                return;
            end
            this.DataBase.add(dbUnit);



            converter=FunctionApproximation.internal.losslessdatatypeconverter.getConverter(this.Options);
            [addUnit,newDBUnit]=converter.convert(dbUnit,this.Options);

            if addUnit&&~hasDBUnit(this.DataBase,newDBUnit,"Full")
                this.DataBase.add(newDBUnit);
            end
        end

        function updateMaxObjectiveValue(this)




            dbUnits=getFeasibleDBUnits(this.DataBase,1);
            if~isempty(dbUnits)
                currentBest=min([dbUnits.ObjectiveValue]);
                if currentBest<this.MaxObjectiveValue
                    this.MaxObjectiveValue=currentBest;
                end
            end
        end

        function[errorAt,currentError]=getMaximumError(this,gridObject)

            maximaFinder=FunctionApproximation.internal.getExtremaFinder([],'Maximize');
            sumBreakpointWLs=sum(this.StorageWordLengths(1:end-1));
            [errorAt,currentError]=getExtrema(maximaFinder,this.ErrorFunction,...
            this.BruteForceGrid,sumBreakpointWLs);

            if~this.UseBruteForce
                gridObjectForMaxima=getGridObjectForMaxima(this,gridObject);

                maximaFinder=FunctionApproximation.internal.getExtremaFinder(this.ExtremaStrategy,'Maximize');
                [errorAtDomainSearch,currentErrorDomainSearch]=getExtrema(maximaFinder,...
                this.ErrorFunction,gridObjectForMaxima,sumBreakpointWLs);
                if currentErrorDomainSearch>currentError
                    currentError=currentErrorDomainSearch;
                    errorAt=errorAtDomainSearch;
                end
            end
        end

        function[errorAt,currentError]=getMaximumErrorWithBlockWrapper(this,gridObject)




            data=this.ErrorFunction.Approximation.Data;
            wrapper=FunctionApproximation.internal.functionwrapper.ApproximateWrapperFactory.getApproximationWrapper(this.Options,data);
            originalApproximate=this.ErrorFunction.Approximation;
            this.ErrorFunction=FunctionApproximation.internal.functionwrapper.ErrorFunctionWrapper(...
            this.ErrorFunction.Original,wrapper,...
            this.ErrorFunction.AbsTol,this.ErrorFunction.RelTol);
            [errorAt,currentError]=getMaximumError(this,gridObject);


            this.ErrorFunction=FunctionApproximation.internal.functionwrapper.ErrorFunctionWrapper(...
            this.ErrorFunction.Original,originalApproximate,...
            this.ErrorFunction.AbsTol,this.ErrorFunction.RelTol);
        end

        function tableData=getTableData(this,gridObject)




            tableData=FunctionApproximation.internal.getTableData(...
            FunctionApproximation.BreakpointSpecification.ExplicitValues,...
            this.ErrorFunction.Original,...
            gridObject);
        end

        function updateErrorFunction(this,tableData)

            serializeableData=this.ErrorFunction.Approximation.Data;
            serializeableData.Data=tableData;
            this.ErrorFunction.modify(serializeableData);
        end

        function[errorAt,maxError,acceptOptimizedTable]=constraintFunction(this,gridObject,currentObjectiveValue)


            errorAt=NaN;
            maxError=NaN;
            tableData=getTableData(this,gridObject);
            acceptOptimizedTable=false;

            if~FunctionApproximation.internal.isNaNOrInf(tableData{end})

                updateErrorFunction(this,tableData);
                [errorAt,maxError]=getMaximumError(this,gridObject);


                constraintMet=passAllConstraints(this,maxError,currentObjectiveValue);
                [~,maxError]=bruteForceValidation(this,constraintMet,maxError,currentObjectiveValue);




                proceedToOptimizeTableValues=~isnan(maxError)...
                &&~this.Options.OnCurveTableValues...
                &&~passErrorConstraint(this,maxError)...
                &&this.TableValueOptimizer.proceedToOptimize(this.TableValueOptimizerContext,maxError);


                if proceedToOptimizeTableValues

                    this.TableValueOptimizerContext.ApproximateFunction=this.ErrorFunction.Approximation;
                    this.TableValueOptimizerContext.TableData=tableData;
                    this.TableValueOptimizerContext.BreakpointGrid=gridObject;
                    this.TableValueOptimizer.setContext(this.TableValueOptimizerContext);
                    optimized=this.TableValueOptimizer.optimize();
                    if optimized
                        tableDataOpt=tableData;
                        tableDataOpt{end}=this.TableValueOptimizer.OptimizedTableValues;

                        updateErrorFunction(this,tableDataOpt);
                        [errorAtOpt,maxErrorOpt]=getMaximumErrorWithBlockWrapper(this,gridObject);




                        acceptOptimizedTable=~isnan(maxErrorOpt)&&(maxErrorOpt<maxError);
                        if acceptOptimizedTable
                            maxError=maxErrorOpt;
                            errorAt=errorAtOpt;
                            tableData=tableDataOpt;
                        end
                        updateErrorFunction(this,tableData);
                    end
                end
                if~this.Options.HDLOptimized
                    [errorAt,maxError]=validateWithNearestRounding(this,errorAt,maxError,gridObject);
                end
                checkOriginalFunctionOverflow(this,errorAt);
            end
        end

        function pass=passErrorConstraint(this,constraintValue)
            pass=~isempty(constraintValue)&&(constraintValue<=this.Options.AbsTol);
        end

        function pass=passMemoryConstraint(this,currentObjectiveValue)
            pass=~isempty(currentObjectiveValue)&&(currentObjectiveValue<=this.Options.MaxMemoryUsageBits);
        end

        function pass=passAllConstraints(this,constraintValue,currentObjectiveValue)
            pass=passErrorConstraint(this,constraintValue)&&passMemoryConstraint(this,currentObjectiveValue);
        end

        function points=initializePoints(this)
            if isempty(this.NumInitialPoints)
                this.NumInitialPoints=getGridSize(this.GridSizeInitializer,this.ContextForInitialPoints);
            end
            points=this.NumInitialPoints;
        end

        function gridObjectForMaxima=getGridObjectForMaxima(this,gridObject)
            if this.UseBruteForce
                gridObjectForMaxima=this.Grid;
            else
                gridCreator=FunctionApproximation.internal.gridcreator.QuantizedEvenSpacingCartesianGrid(this.InputTypes);
                gridObjectForMaxima=FunctionApproximation.internal.Grid(gridObject.SingleDimensionDomains,gridCreator);
            end
        end

        function[recheckConstraintMet,currentError]=bruteForceValidation(this,constraintMet,currentError,currentObjectiveValue)
            recheckConstraintMet=constraintMet;






            case1=this.UseBruteForce&&FunctionApproximation.internal.tolCheckEdgeCase(currentError,this.ErrorFunction.AbsTol);





            case2=~this.UseBruteForce&&constraintMet;


            case3=this.Options.HDLOptimized;
            case4=(this.Options.ApproximateSolutionType==FunctionApproximation.internal.ApproximateSolutionType.Simulink);

            verifyWithApproximate=(case1||case2||case3);
            if verifyWithApproximate
                gridToUse=this.BruteForceGrid;
                maximaFinder=FunctionApproximation.internal.getExtremaFinder([],'Maximize');
                data=this.ErrorFunction.Approximation.Data;
                approximateWrapper=FunctionApproximation.internal.functionwrapper.ApproximateWrapperFactory.getApproximationWrapper(this.Options,data);
                errFunction=FunctionApproximation.internal.functionwrapper.ErrorFunctionWrapper(this.ErrorFunction.Original,approximateWrapper,this.ErrorFunction.AbsTol,this.ErrorFunction.RelTol);
                [~,currentError]=getExtrema(maximaFinder,errFunction,gridToUse,this.Options);
                recheckConstraintMet=passAllConstraints(this,currentError,currentObjectiveValue);
                if case4
                    [recheckConstraintMet,currentError]=validateWithSaturationOn(this,recheckConstraintMet,currentError,approximateWrapper);
                end
            end
        end

        function[errorAt,currentError]=validateWithNearestRounding(this,errorAt,currentError,gridObject)
            dError=currentError-this.ErrorFunction.AbsTol;
            dErrorMax=FunctionApproximation.internal.Utils.getMinimumAbsoluteTolerance(this.OutputType);
            if(dError>0)&&(dError<=dErrorMax)




                data=this.ErrorFunction.Approximation.Data;
                roundingMode=data.RoundingMode;
                data.RoundingMode='Nearest';
                this.ErrorFunction.Approximation.modify(data);
                [newErrorAt,newError]=getMaximumErrorWithBlockWrapper(this,gridObject);
                if newError<currentError
                    errorAt=newErrorAt;
                    currentError=newError;
                    roundingMode='Nearest';
                end
                data.RoundingMode=roundingMode;
                this.ErrorFunction.Approximation.modify(data);
            end
        end

        function data=getData(this,dtCombination)
            this.StorageTypes=dtCombination.StorageTypes;
            this.StorageWordLengths=arrayfun(@(x)x.WordLength,this.StorageTypes);
            data=this.ErrorFunction.Approximation.Data;
            data.StorageTypes=this.StorageTypes;
        end


    end
end


