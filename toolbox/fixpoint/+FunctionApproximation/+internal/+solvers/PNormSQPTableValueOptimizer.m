classdef PNormSQPTableValueOptimizer<FunctionApproximation.internal.solvers.TableValueOptimizer




    properties(SetAccess=private)
TableDataType
ModifyIndices
LinearIndices
SolverOptions
    end

    methods(Access=protected)
        function updateContext(this)

            data=this.Context.ApproximateFunction.Data;
            this.TableDataType=data.StorageTypes(end);
            data.StorageTypes(end)=numerictype('double');
            if isa(this.Context.ApproximateFunction,'FunctionApproximation.internal.functionwrapper.BlockWrapper')
                if(this.Context.Options.Interpolation=="Flat")&&(this.Context.NumberOfDimensions>1)
                    data.InterpolationMethod='linear';
                end
            end
            this.Context.ApproximateFunction=FunctionApproximation.internal.getWrapper(data);


            errorValues=abs(this.Context.OriginalFunctionEvaluation-this.Context.ApproximateFunction.evaluate(this.Context.TestSet));
            errorRatio=errorValues./this.Context.ErrorBound;
            maxRatio=max(errorRatio);
            cutOff=min(maxRatio,1)*this.Context.Options.PNormSQPToleranceThreshold;
            violationIndices=errorRatio>cutOff;
            violationSets=this.Context.TestSet(violationIndices,:);
            this.ModifyIndices=cell(1,this.Context.NumberOfDimensions);
            valueGrid=cell(1,this.Context.NumberOfDimensions);
            for ii=1:this.Context.NumberOfDimensions
                valueGrid{ii}=unique(violationSets(:,ii)','sorted');
            end
            mapperStrategies(this.Context.NumberOfDimensions)=FunctionApproximation.internal.gridcreator.GridMapperStrategyFactory().getStrategyForLeftToRightGridScan(this.Context.Options.Interpolation);
            g=FunctionApproximation.internal.gridcreator.GridMapperFactory().getCompositeGridMapper(mapperStrategies);
            g.setKeyGrid(this.Context.BreakpointGrid.SingleDimensionDomains);
            g.setValueGrid(valueGrid);
            g.constructMap();
            indexToModify=g.getKeyGridIndicesWithMapping();
            for ii=1:this.Context.NumberOfDimensions
                numBreakpoints=numel(this.Context.BreakpointGrid.SingleDimensionDomains{ii});
                this.ModifyIndices{ii}=union(indexToModify{ii},min(indexToModify{ii}+1,numBreakpoints),'sorted');
            end


            this.LinearIndices=FunctionApproximation.internal.CoordinateSetCreator(this.ModifyIndices).CoordinateSets;
            if this.Context.NumberOfDimensions>1
                indicesCell=num2cell(this.LinearIndices,1);
                this.LinearIndices=sub2ind(this.Context.BreakpointGrid.GridSize,indicesCell{:});
                this.LinearIndices=sort(this.LinearIndices);
            end


            this.SolverOptions=this.Context.Options.Optimset;
            diffMinChange=FunctionApproximation.internal.Utils.getMinimumAbsoluteTolerance(this.TableDataType);
            if isempty(this.SolverOptions.DiffMinChange)

                this.SolverOptions.DiffMinChange=diffMinChange;
            end


            if isempty(this.SolverOptions.MaxIter)
                this.SolverOptions.MaxIter=15*this.Context.NumberOfDimensions;
            end


            if isempty(this.SolverOptions.TolFun)

                this.SolverOptions.TolFun=1e-6;
            end

            if isempty(this.SolverOptions.MaxFunEvals)

                maxFunctionEvaluations=20*numel(this.LinearIndices);
                maxFunctionEvaluations=min(maxFunctionEvaluations,500*this.Context.NumberOfDimensions);
                this.SolverOptions.MaxFunEvals=maxFunctionEvaluations;
            end

            if isempty(this.SolverOptions.OutputFcn)



                this.SolverOptions.OutputFcn=@(x,optimValues,state)...
                FunctionApproximation.internal.solvers.tableValueOptimizationOutputFunction(x,optimValues,state,...
                this.Context.HardConstraintTracker,this.Context.Options,this.SolverOptions);
            end
        end
    end

    methods
        function optimized=optimize(this)
            optimized=false;
            tableData=this.Context.TableData;
            tvInitial=tableData{end};


            testSets=this.Context.TestSet;
            f_true=this.Context.OriginalFunctionEvaluation;
            approximation=this.Context.ApproximateFunction;

            objectiveFunction=@(tv)FunctionApproximation.internal.solvers.tableValueOptimizationObjective(...
            tv,f_true,approximation,tableData,testSets,this.LinearIndices,this.Context.NormOrder,this.Context.ErrorBound);
            A=[];
            b=[];
            Aeq=[];
            beq=[];
            tvStart=tvInitial(this.LinearIndices);
            dt=max(abs(tvStart)*this.Context.Options.RelTol,this.Context.Options.AbsTol);
            if any(dt>=this.SolverOptions.DiffMinChange)
                boundOverflowCorrection=dt-this.SolverOptions.DiffMinChange/2;
                invalidCorrectionAt=boundOverflowCorrection<this.SolverOptions.DiffMinChange;
                boundOverflowCorrection(invalidCorrectionAt)=this.SolverOptions.DiffMinChange;
                lb=tvStart-boundOverflowCorrection;
                ub=tvStart+boundOverflowCorrection;
                nonlincon=[];
                try
                    optimized=true;

                    tvOpt=fixed.internal.math.nlcidsh(objectiveFunction,tvStart,...
                    A,b,Aeq,beq,lb,ub,nonlincon,this.SolverOptions);
                catch err %#ok<NASGU>, for debuggging


                    optimized=false;
                    tvOpt=tvStart;
                end
                tvSolution=tvInitial;
                tvSolution(this.LinearIndices)=tvOpt;
                this.OptimizedTableValues=double(fixed.internal.math.castUniversal(tvSolution,this.TableDataType));
            end
        end
        function proceed=proceedToOptimize(this,context,maxError)%#ok<INUSL>
            relaxThreshold=context.BreakpointSpecification.isEvenSpacing()&&(context.NumberOfDimensions==1);


            tolCheckFactor=FunctionApproximation.internal.solvers.getFactorForUpperBoundTVOpt(...
            context.NumberOfDimensions,context.Interpolation,relaxThreshold);
            maxErrorForOptimization=context.Options.AbsTol*tolCheckFactor;
            proceed=maxError<=maxErrorForOptimization;
        end

    end
end
