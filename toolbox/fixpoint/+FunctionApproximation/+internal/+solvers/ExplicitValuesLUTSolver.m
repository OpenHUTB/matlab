classdef ExplicitValuesLUTSolver<FunctionApproximation.internal.solvers.LUTSolver





    properties(Access=private)
MaxPoints
ScaleError
FactorForTVOpt
    end

    methods(Access=private)
        function resetScaleError(this)
            this.ScaleError=1;
        end

        function resetMaxPoints(this)
            this.MaxPoints=2^12;
        end
    end

    methods
        function registerDependencies(this,problemObject)
            registerDependencies@FunctionApproximation.internal.solvers.LUTSolver(this,problemObject);
            this.GridSizeInitializer=FunctionApproximation.internal.gridsizeinitializer.MinimumNumberOfPointsInitializer();
            gridCreator=register(this.Grid.GridCreator,this.ErrorFunction,this.Options.AbsTol,this.InputTypes,this.Options);
            this.Grid=FunctionApproximation.internal.Grid(this.Grid.SingleDimensionDomains,gridCreator);
            this.FactorForTVOpt=FunctionApproximation.internal.solvers.getFactorForUpperBoundTVOpt(...
            this.NumberOfDimensions,this.Options.Interpolation,this.RelaxThreshold);
            resetMaxPoints(this);
            resetScaleError(this);
        end
    end

    methods(Access=protected)

        function gridCreator=getGridCreator(this,inputTypes)

            Flat1DExplicitValueOffCuveUnsaturatedOutputFlag=FunctionApproximation.internal.Utils.isFlat1DExplicitValueOffCurveUnsaturatedOutput(this.Options,1);
            if Flat1DExplicitValueOffCuveUnsaturatedOutputFlag
                gridCreator=FunctionApproximation.internal.gridcreator.TvbpZOES1D(inputTypes);
            else
                gridCreator=FunctionApproximation.internal.gridcreator.QuantizedExplicitValues1D(inputTypes);
            end
            gridCreator.MaxPoints=this.MaxPoints;
        end

        function setSpacing(this)
            this.Spacing=FunctionApproximation.BreakpointSpecification.ExplicitValues;
        end

        function performSearch(this)






            dbUnits=getFeasibleDBUnits(this,1);
            if~isempty(dbUnits)
                bestDBUnit=this.DataBase.getBest(dbUnits);
                proceedToSolve=any(this.StorageWordLengths<bestDBUnit.StorageWordLengths);
                if all(this.StorageWordLengths==bestDBUnit.StorageWordLengths)
                    proceedToSolve=~isequaln(this.StorageTypes,bestDBUnit.StorageTypes);
                end
            else
                proceedToSolve=true;
            end

            if proceedToSolve
                maxWL=FunctionApproximation.internal.gridcreator.QuantizedExplicitValues1D.MaxWordLength+1;
                upperLimitMaxPoints=2^min(maxWL,this.StorageWordLengths(1));
                defaultStartGridSize=2*ones(1,this.NumberOfDimensions);
                this.MaxPoints=upperLimitMaxPoints;
                cutoff=this.Options.AbsTol;
                count=0;
                maxFeasible=1+~this.Options.OnCurveTableValues;
                Flat1DExplicitValueOffCuveUnsaturatedOutputFlag=FunctionApproximation.internal.Utils.isFlat1DExplicitValueOffCurveUnsaturatedOutput(this.Options,1);
                if this.Options.OnCurveTableValues
                    se=[1,1-(2^-8)];
                    this.ScaleError=se(1);
                    e1=getError(this,defaultStartGridSize);
                    if numel(getFeasibleDBUnits(this,1))<maxFeasible
                        this.ScaleError=se(2);
                        e2=getError(this,defaultStartGridSize);
                    end
                else
                    if Flat1DExplicitValueOffCuveUnsaturatedOutputFlag
                        se=[1,0.999,0.99,0.95,0.9,0.8,0.7];
                        for jj=1:numel(se)
                            this.ScaleError=se(jj);
                            e1=getError(this,defaultStartGridSize);
                            if this.passErrorConstraint(e1)
                                break
                            end
                        end
                    else
                        se=[this.FactorForTVOpt,1];
                        this.ScaleError=se(1);
                        e1=getError(this,defaultStartGridSize);
                        if this.passErrorConstraint(e1)

                            se(2)=se(1)*(1+2^-3);
                        end
                        this.ScaleError=se(2);
                        e2=getError(this,defaultStartGridSize);
                    end
                end

                if~Flat1DExplicitValueOffCuveUnsaturatedOutputFlag
                    while(count<4)&&(numel(getFeasibleDBUnits(this,1))<maxFeasible)
                        this.ScaleError=min(se)*(1-2^-8);
                        if e1~=e2
                            this.ScaleError=se(1)+((cutoff-e1)/(e2-e1))*(se(2)-se(1));
                        end
                        se(1)=se(2);
                        se(2)=this.ScaleError;
                        e1=e2;
                        e2=getError(this,defaultStartGridSize);
                        count=count+1;
                    end
                end
            end


            resetScaleError(this);
            resetMaxPoints(this);
        end

        function gridObject=getGrid(this,gridSize)
            gridCreator=getGridCreator(this,this.StorageTypes(1:end-1));
            absTol=this.ScaleError*this.Options.AbsTol;
            approximate=FunctionApproximation.internal.getWrapper(this.ErrorFunction.Approximation.Data);
            errorFunction=FunctionApproximation.internal.functionwrapper.ErrorFunctionWrapper(...
            this.ErrorFunction.Original,approximate,this.ErrorFunction.AbsTol,this.ErrorFunction.RelTol);
            gridCreator=register(gridCreator,errorFunction,absTol,this.InputTypes,this.Options);
            rangeObject=this.TableDataRangeObject;
            grid=getGrid(gridCreator,rangeObject,gridSize);
            gridObject=FunctionApproximation.internal.Grid(grid,gridCreator);
        end

        function flag=proceedToValidateConstraint(~,~)

            flag=true;
        end

        function flag=attemptConstraintCheck(~,~)

            flag=true;
        end

        function data=getData(this,dtCombination)
            data=getData@FunctionApproximation.internal.solvers.LUTSolver(this,dtCombination);
            data.SaturateOnIntegerOverflow='off';
        end

        function[recheckConstraintMet,outputError]=validateWithSaturationOn(this,constraintMet,currentError,blockWrapper)









            recheckConstraintMet=constraintMet;
            outputError=currentError;
            if~constraintMet
                data=blockWrapper.Data;
                data.SaturateOnIntegerOverflow='on';
                blockWrapper.modify(data);
                maximaFinder=FunctionApproximation.internal.getExtremaFinder([],'Maximize');
                errFunction=FunctionApproximation.internal.functionwrapper.ErrorFunctionWrapper(this.ErrorFunction.Original,blockWrapper,this.ErrorFunction.AbsTol,this.ErrorFunction.RelTol);
                [~,newError]=getExtrema(maximaFinder,errFunction,this.BruteForceGrid,this.Options);
                recheckConstraintMet=passAllConstraints(this,newError,this.ObjectiveValue);
                if newError<currentError
                    outputError=newError;
                    this.ErrorFunction.Approximation.modify(data);
                end
            end
        end
    end

    methods(Access={?FunctionApproximation.internal.solvers.LUTSolver,...
        ?FunctionApproximation.internal.progresstracking.TrackingStrategy})

        function maxAttempts=getMaxAttempts(~)
            maxAttempts=3;
        end

        function dbUnits=getFeasibleDBUnits(this,varargin)
            dbUnits=getFeasibleDBUnits(this.DataBase,varargin{:});
            if~isempty(dbUnits)
                dbUnits=dbUnits([dbUnits.BreakpointSpecification]=="ExplicitValues");
            end
        end
    end
end

