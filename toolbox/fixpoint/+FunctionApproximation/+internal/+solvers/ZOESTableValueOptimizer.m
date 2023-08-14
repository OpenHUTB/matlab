classdef ZOESTableValueOptimizer<FunctionApproximation.internal.solvers.TableValueOptimizer







    properties(SetAccess=private)
TableDataType
    end


    methods
        function optimized=optimize(this)





            tableData=this.Context.TableData;
            mapperStrategies(this.Context.NumberOfDimensions)=FunctionApproximation.internal.gridcreator.GridMapperStrategyFactory().getStrategyForLeftToRightGridScan(this.Context.Options.Interpolation);
            g=FunctionApproximation.internal.gridcreator.GridMapperFactory().getCompositeGridMapper(mapperStrategies);
            g.setKeyGrid(this.Context.BreakpointGrid.SingleDimensionDomains);
            g.setValueGrid(this.Context.TestGrid.SingleDimensionDomains);
            g.constructMap();
            g.getKeyGridIndicesWithMapping();
            indexToModify=g.getKeyGridIndicesWithMapping();
            bpCoordinateSetToModify=FunctionApproximation.internal.CoordinateSetCreator(indexToModify).CoordinateSets;

            origionalFunctionValue=this.Context.OriginalFunctionEvaluation;

            tvSolution=tableData{end};

            dimension=this.Context.NumberOfDimensions;

            if dimension==1
                for jj=1:length(indexToModify{1})
                    index=indexToModify{1}(jj);
                    indicesForTestVector=g.getIndices({[index,index]});
                    indicesForTestVector=indicesForTestVector{1};
                    originalFuntionValueAtTestIndices=origionalFunctionValue(indicesForTestVector);
                    errorValueAtTestIndices=this.Context.ErrorBound(indicesForTestVector);
                    tvSolution(index)=...
                    this.getUnquantizedOptimalTableValue(originalFuntionValueAtTestIndices,errorValueAtTestIndices);
                end

            else



                for ii=1:size(bpCoordinateSetToModify,1)
                    TestpointIndices=cell(1,dimension);
                    for jj=1:dimension
                        TestpointIndices{jj}=[bpCoordinateSetToModify(ii,jj),bpCoordinateSetToModify(ii,jj)];
                    end
                    tpIndicesToModify=g.getIndices(TestpointIndices);

                    tpGridToModify=FunctionApproximation.internal.CoordinateSetCreator(tpIndicesToModify).CoordinateSets;

                    tpGridToModifyLinearCellInput=num2cell(tpGridToModify,1);

                    LineartpIndicesToModify=sub2ind(this.Context.TestGrid.GridSize,tpGridToModifyLinearCellInput{:});


                    originalFuntionValueAtTestIndices=origionalFunctionValue(LineartpIndicesToModify);
                    errorValueAtTestIndices=this.Context.ErrorBound(LineartpIndicesToModify);

                    indicesForTestVector=num2cell(bpCoordinateSetToModify(ii,:),1);
                    tvSolution(sub2ind(size(tvSolution),indicesForTestVector{:}))=...
                    this.getUnquantizedOptimalTableValue(originalFuntionValueAtTestIndices,errorValueAtTestIndices);
                end
            end

            optimized=true;

            this.OptimizedTableValues=double(fixed.internal.math.castUniversal(tvSolution,this.TableDataType));

        end

        function proceed=proceedToOptimize(this,context,maxError)%#ok<INUSD>
            proceed=true;
        end
    end

    methods(Static)
        function tv=getUnquantizedOptimalTableValue(originalFuntionValue,errorFunctionValue)
            tv=(max(originalFuntionValue-errorFunctionValue)+...
            min(originalFuntionValue+errorFunctionValue))/2;
        end
    end
end
